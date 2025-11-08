-- Rate limiting at database level using PostgreSQL
-- This provides server-side rate limiting to protect against abuse

-- Create a table to track API request rates per user
CREATE TABLE IF NOT EXISTS api_rate_limits (
    user_id uuid REFERENCES auth.users(id) PRIMARY KEY,
    requests_this_minute int DEFAULT 0,
    requests_this_hour int DEFAULT 0,
    minute_window_start timestamp DEFAULT NOW(),
    hour_window_start timestamp DEFAULT NOW(),
    last_request_at timestamp DEFAULT NOW()
);

-- Enable RLS on rate limits table
ALTER TABLE api_rate_limits ENABLE ROW LEVEL SECURITY;

-- Users can only see and update their own rate limit data
CREATE POLICY "Users can only see their own rate limits"
  ON api_rate_limits FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can only update their own rate limits"
  ON api_rate_limits FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own rate limits"
  ON api_rate_limits FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Function to check and enforce rate limits
-- Returns TRUE if request is allowed, FALSE if rate limit exceeded
CREATE OR REPLACE FUNCTION check_rate_limit(
    p_user_id uuid,
    p_max_per_minute int DEFAULT 60,
    p_max_per_hour int DEFAULT 1000
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_record api_rate_limits%ROWTYPE;
    v_now timestamp := NOW();
    v_minute_expired boolean;
    v_hour_expired boolean;
BEGIN
    -- Get or create rate limit record for user
    SELECT * INTO v_record
    FROM api_rate_limits
    WHERE user_id = p_user_id;

    IF NOT FOUND THEN
        -- First request from this user
        INSERT INTO api_rate_limits (user_id, requests_this_minute, requests_this_hour, minute_window_start, hour_window_start, last_request_at)
        VALUES (p_user_id, 1, 1, v_now, v_now, v_now);
        RETURN TRUE;
    END IF;

    -- Check if windows have expired
    v_minute_expired := (EXTRACT(EPOCH FROM (v_now - v_record.minute_window_start)) >= 60);
    v_hour_expired := (EXTRACT(EPOCH FROM (v_now - v_record.hour_window_start)) >= 3600);

    -- Reset counters if windows expired
    IF v_minute_expired THEN
        v_record.requests_this_minute := 0;
        v_record.minute_window_start := v_now;
    END IF;

    IF v_hour_expired THEN
        v_record.requests_this_hour := 0;
        v_record.hour_window_start := v_now;
    END IF;

    -- Check rate limits
    IF v_record.requests_this_minute >= p_max_per_minute THEN
        -- Rate limit exceeded
        RETURN FALSE;
    END IF;

    IF v_record.requests_this_hour >= p_max_per_hour THEN
        -- Rate limit exceeded
        RETURN FALSE;
    END IF;

    -- Increment counters
    UPDATE api_rate_limits
    SET
        requests_this_minute = v_record.requests_this_minute + 1,
        requests_this_hour = v_record.requests_this_hour + 1,
        minute_window_start = v_record.minute_window_start,
        hour_window_start = v_record.hour_window_start,
        last_request_at = v_now
    WHERE user_id = p_user_id;

    RETURN TRUE;
END;
$$;

-- Function to get current rate limit status for a user
CREATE OR REPLACE FUNCTION get_rate_limit_status(p_user_id uuid)
RETURNS TABLE (
    requests_this_minute int,
    requests_this_hour int,
    remaining_this_minute int,
    remaining_this_hour int,
    minute_window_reset_in_seconds int,
    hour_window_reset_in_seconds int
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_record api_rate_limits%ROWTYPE;
    v_now timestamp := NOW();
    v_max_per_minute int := 60;
    v_max_per_hour int := 1000;
BEGIN
    SELECT * INTO v_record
    FROM api_rate_limits
    WHERE user_id = p_user_id;

    IF NOT FOUND THEN
        -- No rate limit record yet
        RETURN QUERY SELECT 0, 0, v_max_per_minute, v_max_per_hour, 60, 3600;
        RETURN;
    END IF;

    RETURN QUERY SELECT
        v_record.requests_this_minute,
        v_record.requests_this_hour,
        GREATEST(0, v_max_per_minute - v_record.requests_this_minute),
        GREATEST(0, v_max_per_hour - v_record.requests_this_hour),
        GREATEST(0, 60 - EXTRACT(EPOCH FROM (v_now - v_record.minute_window_start))::int),
        GREATEST(0, 3600 - EXTRACT(EPOCH FROM (v_now - v_record.hour_window_start))::int);
END;
$$;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_api_rate_limits_user_id ON api_rate_limits(user_id);
CREATE INDEX IF NOT EXISTS idx_api_rate_limits_last_request ON api_rate_limits(last_request_at);

-- Cleanup function to remove old rate limit records (optional, run periodically)
CREATE OR REPLACE FUNCTION cleanup_old_rate_limits()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM api_rate_limits
    WHERE last_request_at < NOW() - INTERVAL '24 hours';
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION check_rate_limit(uuid, int, int) TO authenticated;
GRANT EXECUTE ON FUNCTION get_rate_limit_status(uuid) TO authenticated;

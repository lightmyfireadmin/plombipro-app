-- Migration: Create comprehensive appointments system with routing and ETA tracking
-- Date: 2025-01-06
-- Description: Adds appointments, routes, and ETA tracking for plumber daily scheduling

-- ============================================================================
-- APPOINTMENTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Client and job site relations
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    job_site_id UUID REFERENCES job_sites(id) ON DELETE SET NULL,

    -- Appointment details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,

    -- Duration and timing
    estimated_duration_minutes INTEGER DEFAULT 60,
    actual_start_time TIMESTAMPTZ,
    actual_end_time TIMESTAMPTZ,

    -- Location details
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    postal_code VARCHAR(10) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(2) DEFAULT 'FR',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),

    -- ETA tracking
    planned_eta TIMESTAMPTZ NOT NULL, -- Original planned arrival time
    current_eta TIMESTAMPTZ, -- Updated ETA based on traffic/progress
    last_eta_update TIMESTAMPTZ,
    eta_update_interval_minutes INTEGER DEFAULT 15, -- Auto-update frequency

    -- Route and sequence
    daily_sequence INTEGER, -- Order in the day (1st, 2nd, 3rd appointment)
    route_distance_meters INTEGER, -- Distance from previous appointment
    route_duration_minutes INTEGER, -- Travel time from previous appointment

    -- Status tracking
    status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN (
        'scheduled', 'confirmed', 'in_transit', 'arrived',
        'in_progress', 'completed', 'cancelled', 'no_show'
    )),

    -- SMS notification tracking
    sms_notifications_enabled BOOLEAN DEFAULT true,
    last_sms_sent_at TIMESTAMPTZ,
    sms_count INTEGER DEFAULT 0,

    -- Notes and internal info
    internal_notes TEXT,
    customer_notes TEXT, -- Special instructions from customer

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT valid_daily_sequence CHECK (daily_sequence > 0),
    CONSTRAINT valid_eta_interval CHECK (eta_update_interval_minutes > 0)
);

-- ============================================================================
-- DAILY ROUTES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS daily_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Route date and planning
    route_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Starting point (home/office)
    start_address VARCHAR(255),
    start_latitude DECIMAL(10, 8),
    start_longitude DECIMAL(11, 8),
    start_time TIME,

    -- Route optimization
    is_optimized BOOLEAN DEFAULT false,
    optimization_date TIMESTAMPTZ,
    total_distance_meters INTEGER,
    total_duration_minutes INTEGER,

    -- Tracking
    route_started_at TIMESTAMPTZ,
    route_completed_at TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT 'planned' CHECK (status IN (
        'planned', 'active', 'completed', 'cancelled'
    )),

    -- Unique constraint: one route per user per day
    CONSTRAINT unique_user_route_date UNIQUE (user_id, route_date)
);

-- ============================================================================
-- ETA HISTORY TABLE (for tracking ETA changes)
-- ============================================================================
CREATE TABLE IF NOT EXISTS appointment_eta_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,

    -- ETA tracking
    eta TIMESTAMPTZ NOT NULL,
    delay_minutes INTEGER, -- Difference from planned ETA (negative = early)

    -- Reason for update
    update_reason VARCHAR(100) CHECK (update_reason IN (
        'manual', 'automatic', 'traffic', 'previous_delay', 'route_optimization'
    )),

    -- SMS notification
    sms_sent BOOLEAN DEFAULT false,
    sms_sent_at TIMESTAMPTZ,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- SMS NOTIFICATIONS LOG TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS appointment_sms_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,

    -- SMS details
    recipient_phone VARCHAR(20) NOT NULL,
    message_content TEXT NOT NULL,

    -- Delivery tracking
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    delivery_status VARCHAR(50) DEFAULT 'pending' CHECK (delivery_status IN (
        'pending', 'sent', 'delivered', 'failed', 'queued'
    )),
    error_message TEXT,

    -- SMS provider details (Twilio)
    provider_message_sid VARCHAR(100),
    provider VARCHAR(50) DEFAULT 'twilio',

    -- Cost tracking
    cost_eur DECIMAL(10, 4),

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Appointments indexes
CREATE INDEX idx_appointments_user_id ON appointments(user_id);
CREATE INDEX idx_appointments_client_id ON appointments(client_id);
CREATE INDEX idx_appointments_job_site_id ON appointments(job_site_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_user_date_sequence ON appointments(user_id, appointment_date, daily_sequence);
CREATE INDEX idx_appointments_planned_eta ON appointments(planned_eta);

-- Daily routes indexes
CREATE INDEX idx_daily_routes_user_id ON daily_routes(user_id);
CREATE INDEX idx_daily_routes_route_date ON daily_routes(route_date);
CREATE INDEX idx_daily_routes_status ON daily_routes(status);

-- ETA history indexes
CREATE INDEX idx_eta_history_appointment_id ON appointment_eta_history(appointment_id);
CREATE INDEX idx_eta_history_created_at ON appointment_eta_history(created_at);

-- SMS log indexes
CREATE INDEX idx_sms_log_appointment_id ON appointment_sms_log(appointment_id);
CREATE INDEX idx_sms_log_sent_at ON appointment_sms_log(sent_at);
CREATE INDEX idx_sms_log_delivery_status ON appointment_sms_log(delivery_status);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointment_eta_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointment_sms_log ENABLE ROW LEVEL SECURITY;

-- Appointments policies
CREATE POLICY "Users can view their own appointments"
    ON appointments FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own appointments"
    ON appointments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own appointments"
    ON appointments FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own appointments"
    ON appointments FOR DELETE
    USING (auth.uid() = user_id);

-- Daily routes policies
CREATE POLICY "Users can view their own routes"
    ON daily_routes FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own routes"
    ON daily_routes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own routes"
    ON daily_routes FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own routes"
    ON daily_routes FOR DELETE
    USING (auth.uid() = user_id);

-- ETA history policies (read-only for users, write through functions)
CREATE POLICY "Users can view ETA history for their appointments"
    ON appointment_eta_history FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM appointments
            WHERE appointments.id = appointment_eta_history.appointment_id
            AND appointments.user_id = auth.uid()
        )
    );

CREATE POLICY "System can insert ETA history"
    ON appointment_eta_history FOR INSERT
    WITH CHECK (true); -- Will be restricted through application logic

-- SMS log policies (read-only for users)
CREATE POLICY "Users can view SMS logs for their appointments"
    ON appointment_sms_log FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM appointments
            WHERE appointments.id = appointment_sms_log.appointment_id
            AND appointments.user_id = auth.uid()
        )
    );

CREATE POLICY "System can insert SMS logs"
    ON appointment_sms_log FOR INSERT
    WITH CHECK (true); -- Will be restricted through application logic

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Update updated_at timestamp on appointments
CREATE OR REPLACE FUNCTION update_appointments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION update_appointments_updated_at();

-- Update updated_at timestamp on daily_routes
CREATE OR REPLACE FUNCTION update_daily_routes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_daily_routes_updated_at
    BEFORE UPDATE ON daily_routes
    FOR EACH ROW
    EXECUTE FUNCTION update_daily_routes_updated_at();

-- Automatically create ETA history when ETA is updated
CREATE OR REPLACE FUNCTION log_eta_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.current_eta IS DISTINCT FROM OLD.current_eta THEN
        INSERT INTO appointment_eta_history (
            appointment_id,
            eta,
            delay_minutes,
            update_reason
        ) VALUES (
            NEW.id,
            NEW.current_eta,
            EXTRACT(EPOCH FROM (NEW.current_eta - NEW.planned_eta)) / 60,
            'automatic'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_eta_update
    AFTER UPDATE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION log_eta_update();

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to get next appointment in sequence
CREATE OR REPLACE FUNCTION get_next_appointment(p_user_id UUID, p_current_date DATE, p_current_sequence INTEGER)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    address VARCHAR,
    planned_eta TIMESTAMPTZ,
    current_eta TIMESTAMPTZ,
    latitude DECIMAL,
    longitude DECIMAL,
    daily_sequence INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id,
        a.title,
        a.address_line1 || ', ' || a.postal_code || ' ' || a.city,
        a.planned_eta,
        COALESCE(a.current_eta, a.planned_eta),
        a.latitude,
        a.longitude,
        a.daily_sequence
    FROM appointments a
    WHERE a.user_id = p_user_id
        AND a.appointment_date = p_current_date
        AND a.daily_sequence > p_current_sequence
        AND a.status IN ('scheduled', 'confirmed')
    ORDER BY a.daily_sequence
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate delay from planned ETA
CREATE OR REPLACE FUNCTION calculate_eta_delay(p_appointment_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_delay INTEGER;
BEGIN
    SELECT
        EXTRACT(EPOCH FROM (COALESCE(current_eta, planned_eta) - planned_eta)) / 60
    INTO v_delay
    FROM appointments
    WHERE id = p_appointment_id;

    RETURN COALESCE(v_delay, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to get daily appointments summary
CREATE OR REPLACE FUNCTION get_daily_appointments_summary(p_user_id UUID, p_date DATE)
RETURNS TABLE (
    total_appointments INTEGER,
    completed_appointments INTEGER,
    pending_appointments INTEGER,
    total_estimated_duration INTEGER,
    current_delay_minutes INTEGER,
    next_appointment_id UUID
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::INTEGER as total_appointments,
        COUNT(*) FILTER (WHERE status = 'completed')::INTEGER as completed_appointments,
        COUNT(*) FILTER (WHERE status IN ('scheduled', 'confirmed', 'in_transit'))::INTEGER as pending_appointments,
        SUM(estimated_duration_minutes)::INTEGER as total_estimated_duration,
        SUM(EXTRACT(EPOCH FROM (COALESCE(current_eta, planned_eta) - planned_eta)) / 60)::INTEGER as current_delay_minutes,
        (
            SELECT id FROM appointments
            WHERE user_id = p_user_id
                AND appointment_date = p_date
                AND status IN ('scheduled', 'confirmed')
            ORDER BY daily_sequence
            LIMIT 1
        ) as next_appointment_id
    FROM appointments
    WHERE user_id = p_user_id
        AND appointment_date = p_date;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SAMPLE DATA (for testing - remove in production)
-- ============================================================================
-- Uncomment to insert sample data:
-- INSERT INTO appointments (user_id, title, appointment_date, appointment_time, address_line1, postal_code, city, planned_eta, daily_sequence)
-- VALUES
--     ('00000000-0000-0000-0000-000000000000', 'Réparation fuite', '2025-01-07', '09:00', '123 Rue de Rivoli', '75001', 'Paris', '2025-01-07 09:00:00+01', 1),
--     ('00000000-0000-0000-0000-000000000000', 'Installation chaudière', '2025-01-07', '11:00', '45 Avenue des Champs-Élysées', '75008', 'Paris', '2025-01-07 11:00:00+01', 2);

-- ============================================================================
-- ROLLBACK SCRIPT (save separately)
-- ============================================================================
/*
DROP TABLE IF EXISTS appointment_sms_log CASCADE;
DROP TABLE IF EXISTS appointment_eta_history CASCADE;
DROP TABLE IF EXISTS daily_routes CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP FUNCTION IF EXISTS update_appointments_updated_at();
DROP FUNCTION IF EXISTS update_daily_routes_updated_at();
DROP FUNCTION IF EXISTS log_eta_update();
DROP FUNCTION IF EXISTS get_next_appointment(UUID, DATE, INTEGER);
DROP FUNCTION IF EXISTS calculate_eta_delay(UUID);
DROP FUNCTION IF EXISTS get_daily_appointments_summary(UUID, DATE);
*/

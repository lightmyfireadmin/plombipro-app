-- #############################################################################
-- ## PART 1: PostgreSQL Function for Handling Payment Reminders
-- #############################################################################
-- This function queries for unpaid invoices that are due soon,
-- and calls the 'send-email' edge function to send a reminder.

CREATE OR REPLACE FUNCTION public.handle_payment_reminders()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  invoice_record RECORD;
  client_email TEXT;
  -- Replace these placeholders with your actual Supabase project URL and service role key.
  -- For better security, consider using the Supabase Vault to store secrets.
  project_url TEXT := 'https://<YOUR-PROJECT-REF>.supabase.co';
  service_key TEXT := Deno.env.get('SPB_SERVICE_ROLE_KEY'); -- Or your raw service key
BEGIN
  -- Select invoices due in the next 3 days that are not paid.
  -- NOTE: To prevent sending emails every day for the same invoice, you should add
  -- a 'reminder_sent_at' timestamp column to your 'invoices' table.
  -- Then, add the following condition to the WHERE clause:
  -- AND (reminder_sent_at IS NULL OR reminder_sent_at <= now() - interval '1 day')
  FOR invoice_record IN
    SELECT * FROM public.invoices
    WHERE due_date <= (now() + interval '3 days') AND payment_status <> 'paid'
  LOOP
    -- Get the client's email address from the clients table
    SELECT email INTO client_email FROM public.clients WHERE id = invoice_record.client_id;

    -- If a client email is found, send the reminder email
    IF client_email IS NOT NULL THEN
      PERFORM net.http_post(
        url := project_url || '/functions/v1/send-email',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || service_key
        ),
        body := jsonb_build_object(
          'to', client_email,
          'subject', 'Rappel: Votre facture PlombiPro ' || invoice_record.invoice_number,
          'template', 'payment_reminder',
          'context', jsonb_build_object(
            'invoice_number', invoice_record.invoice_number,
            'amount', invoice_record.total_ttc,
            'company_name', 'PlombiPro'
          )
        )
      );

      -- NOTE: If you add the 'reminder_sent_at' column, you would update it here:
      -- UPDATE public.invoices SET reminder_sent_at = now() WHERE id = invoice_record.id;

    END IF;
  END LOOP;
END;
$$;


-- #############################################################################
-- ## PART 2: Schedule the Cron Job
-- #############################################################################
-- This command schedules the 'handle_payment_reminders' function to run
-- every day at 9:00 AM UTC. You only need to run this once in the Supabase SQL Editor.

SELECT cron.schedule(
  'daily-payment-reminders', -- A unique name for the cron job
  '0 9 * * *',               -- Cron schedule for 9:00 AM UTC every day
  'SELECT public.handle_payment_reminders()' -- The function to run
);

-- #############################################################################
-- ## OPTIONAL: How to manage the cron job
-- #############################################################################

-- To unschedule the job, run this:
-- SELECT cron.unschedule('daily-payment-reminders');

-- To see all currently scheduled jobs, run this:
-- SELECT * FROM cron.job;

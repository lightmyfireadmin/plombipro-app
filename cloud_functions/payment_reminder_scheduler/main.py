import functions_framework
from supabase import create_client, Client
import os
from datetime import datetime, timedelta

# Initialize Supabase client
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

# Placeholder for the send_email function URL
SEND_EMAIL_FUNCTION_URL = os.environ.get("SEND_EMAIL_FUNCTION_URL")

@functions_framework.cloud_event
def schedule_payment_reminders(cloud_event):
    try:
        # 1. Query for overdue invoices
        today = datetime.utcnow().date()
        overdue_invoices_response = supabase.table('invoices').select('*')\
            .lt('due_date', str(today))\
            .neq('payment_status', 'paid')\
            .execute()

        if not overdue_invoices_response.data:
            print("No overdue invoices found.")
            return {'success': True, 'message': 'No overdue invoices'}, 200

        # 2. For each overdue invoice, trigger an email
        for invoice in overdue_invoices_response.data:
            # Check if a reminder was sent recently
            last_reminder_sent = invoice.get('last_reminder_sent')
            if last_reminder_sent and (today - datetime.fromisoformat(last_reminder_sent).date()) < timedelta(days=7):
                continue # Skip if a reminder was sent in the last 7 days

            # Trigger the send_email cloud function (placeholder)
            # In a real implementation, you would make an HTTP request to the send_email function
            print(f"Sending reminder for invoice {invoice.get('id')}")

            # Update the invoice with the new reminder date and count
            reminder_count = invoice.get('reminder_sent_count', 0) + 1
            supabase.table('invoices').update({
                'last_reminder_sent': str(today),
                'reminder_sent_count': reminder_count
            }).eq('id', invoice.get('id')).execute()

        return {'success': True}, 200

    except Exception as e:
        print(f"Error scheduling payment reminders: {e}")
        return {'success': False, 'error': str(e)}, 500

import functions_framework
from supabase import create_client, Client
import os
from datetime import datetime

# Initialize Supabase client
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

@functions_framework.cloud_event
def check_quote_expiry(cloud_event):
    try:
        # 1. Query for expired quotes
        today = datetime.utcnow().date()
        expired_quotes_response = supabase.table('quotes').select('id')\
            .lt('expiry_date', str(today))\
            .eq('status', 'sent')\
            .execute()

        if not expired_quotes_response.data:
            print("No expired quotes found.")
            return {'success': True, 'message': 'No expired quotes'}, 200

        # 2. For each expired quote, update the status
        for quote in expired_quotes_response.data:
            supabase.table('quotes').update({'status': 'expired'}).eq('id', quote.get('id')).execute()

        return {'success': True}, 200

    except Exception as e:
        print(f"Error checking quote expiry: {e}")
        return {'success': False, 'error': str(e)}, 500

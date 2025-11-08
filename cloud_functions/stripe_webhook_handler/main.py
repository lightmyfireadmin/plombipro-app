import functions_framework
import os
import stripe
from datetime import datetime
from supabase import create_client, Client

# Initialize Supabase client
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

# Initialize Stripe client
stripe.api_key = os.environ.get("STRIPE_SECRET_KEY")

@functions_framework.http
def stripe_webhook_handler(request):
    payload = request.data
    sig_header = request.headers.get('Stripe-Signature')
    endpoint_secret = os.environ.get('STRIPE_WEBHOOK_SECRET')

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, endpoint_secret
        )
    except ValueError as e:
        # Invalid payload
        return {'success': False, 'error': 'Invalid payload'}, 400
    except stripe.error.SignatureVerificationError as e:
        # Invalid signature
        return {'success': False, 'error': 'Invalid signature'}, 400

    # Handle the event
    if event['type'] == 'customer.subscription.created':
        subscription = event['data']['object']
        user_id = subscription['metadata']['user_id']
        supabase.table('profiles').update({'subscription_plan': 'pro'}).eq('id', user_id).execute()
        supabase.table('stripe_subscriptions').insert({
            'user_id': user_id,
            'stripe_customer_id': subscription['customer'],
            'stripe_subscription_id': subscription['id'],
            'plan_id': subscription['items']['data'][0]['plan']['id'],
            'status': subscription['status'],
            'current_period_start': datetime.fromtimestamp(subscription['current_period_start']),
            'current_period_end': datetime.fromtimestamp(subscription['current_period_end']),
        }).execute()
    elif event['type'] == 'customer.subscription.deleted':
        subscription = event['data']['object']
        user_id = subscription['metadata']['user_id']
        supabase.table('profiles').update({'subscription_plan': 'free'}).eq('id', user_id).execute()
        supabase.table('stripe_subscriptions').update({'status': 'canceled'}).eq('stripe_subscription_id', subscription['id']).execute()
    else:
        print('Unhandled event type {}'.format(event['type']))

    return {'success': True}, 200

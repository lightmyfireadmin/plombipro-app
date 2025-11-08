import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import Stripe from 'https://esm.sh/stripe@11.1.0'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4'
import { corsHeaders } from '../_shared/cors.ts'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!,
  {
    apiVersion: '2022-11-15',
    // @ts-ignore
    httpClient: Stripe.createFetchHttpClient(),
  }
)

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { user_id, return_url, refresh_url } = await req.json()

    if (!user_id) {
      throw new Error('User ID is required.')
    }

    // Initialize Supabase client with service role key for admin access
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SPB_SERVICE_ROLE_KEY')!
    )

    // 1. Create a new Stripe Express Account
    const account = await stripe.accounts.create({
      type: 'express',
      country: 'FR', // Assuming France based on French UI
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
      business_type: 'individual', // Or 'company' based on user profile
      // You might want to prefill more information from the user's profile
    })

    // 2. Save the new account ID to the user's public.profiles row
    const { error: updateError } = await supabaseAdmin
      .from('profiles')
      .update({ stripe_connect_id: account.id })
      .eq('id', user_id)

    if (updateError) {
      throw new Error(`Failed to update user profile: ${updateError.message}`)
    }

    // 3. Create an Account Link URL for onboarding
    const accountLink = await stripe.accountLinks.create({
      account: account.id,
      refresh_url: refresh_url || `${Deno.env.get('SUPABASE_URL')}/auth/v1/callback`, // Fallback URL
      return_url: return_url || `${Deno.env.get('SUPABASE_URL')}/auth/v1/callback`, // Fallback URL
      type: 'account_onboarding',
    })

    return new Response(
      JSON.stringify({ success: true, url: accountLink.url }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})

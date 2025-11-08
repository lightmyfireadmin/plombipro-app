import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import Stripe from 'https://esm.sh/stripe@11.1.0'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4' // Added for admin client
import { corsHeaders } from '../_shared/cors.ts'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
  apiVersion: '2022-11-15',
  // @ts-ignore
  httpClient: Stripe.createFetchHttpClient(),
})

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { amount, currency = 'eur', invoice_id } = await req.json()

    if (typeof amount !== 'number') {
        throw new Error('Amount must be a number.');
    }

    // Extract user ID from the JWT (assuming the function is protected)
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Authorization header missing.')
    }
    const token = authHeader.split(' ')[1]
    const { data: { user }, error: authError } = await createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')! // Use anon key for client-side auth
    ).auth.getUser(token)

    if (authError || !user) {
      throw new Error('User not authenticated.')
    }
    const userId = user.id

    // Initialize Supabase client with service role key for admin access
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SPB_SERVICE_ROLE_KEY')!
    )

    // Fetch the user's stripe_connect_id from their profile
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('profiles')
      .select('stripe_connect_id')
      .eq('id', userId)
      .single()

    if (profileError || !profile || !profile.stripe_connect_id) {
      throw new Error('Stripe Connect account not linked for this user.')
    }
    const connectedAccountId = profile.stripe_connect_id

    // Stripe expects amount in cents, so we convert it.
    const amountInCents = Math.round(amount * 100)

    // Calculate application fee (e.g., 2% of the total)
    const applicationFeeAmount = Math.round(amountInCents * 0.02) // 2% fee

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInCents,
      currency: currency,
      metadata: { invoice_id },
      application_fee_amount: applicationFeeAmount, // Platform fee
      transfer_data: {
        destination: connectedAccountId, // Transfer to connected account
      },
    })

    return new Response(
      JSON.stringify({
        success: true,
        client_secret: paymentIntent.client_secret,
        payment_intent_id: paymentIntent.id,
      }),
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

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
// @ts-ignore
import Stripe from 'https://esm.sh/stripe@11.1.0'
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
    const { payment_id } = await req.json()

    if (!payment_id) {
      throw new Error('Missing required parameter: payment_id')
    }

    // Create a refund in Stripe using the Payment Intent ID.
    const refund = await stripe.refunds.create({
      payment_intent: payment_id,
    })

    return new Response(
      JSON.stringify({
        success: true,
        refund_id: refund.id,
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

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { corsHeaders } from '../_shared/cors.ts'

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')

/**
 * Builds the HTML content for an email based on a template and context data.
 * @param template - The name of the email template (e.g., 'quote_sent').
 * @param context - An object containing data to populate the template.
 * @returns The generated HTML string for the email body.
 */
function _build_email_html(template: string, context: any): string {
  switch (template) {
    case 'quote_sent':
      return `
        <h1>Bonjour,</h1>
        <p>Veuillez trouver ci-joint votre devis n° <strong>${context.quote_number}</strong> d'un montant de <strong>${context.amount}€</strong>.</p>
        <p>Ce devis est valide jusqu'au ${context.valid_until}.</p>
        <p>Cordialement,</p>
        <p>L'équipe ${context.company_name}</p>
      `;
    case 'invoice_sent':
      return `
        <h1>Bonjour,</h1>
        <p>Voici votre facture n° <strong>${context.invoice_number}</strong> pour un montant de <strong>${context.amount}€</strong>.</p>
        <p>Cordialement,</p>
        <p>L'équipe ${context.company_name}</p>
      `;
    case 'payment_reminder':
      return `
        <h1>Rappel de paiement</h1>
        <p>Bonjour,</p>
        <p>Ceci est un rappel amical concernant la facture n° <strong>${context.invoice_number}</strong> d'un montant de <strong>${context.amount}€</strong>, qui est maintenant due.</p>
        <p>Merci de procéder au paiement dès que possible.</p>
        <p>Cordialement,</p>
        <p>L'équipe ${context.company_name}</p>
      `;
    default:
      return `<p>Notification de PlombiPro.</p>`;
  }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { to, subject, template, context, pdf_base64, filename } = await req.json()

    const html_content = _build_email_html(template, context)

    const resendPayload: {
      from: string;
      to: string;
      subject: string;
      html: string;
      attachments?: { filename: string; content: string }[];
    } = {
      from: 'facturation@plombipro.fr',
      to: to,
      subject: subject,
      html: html_content,
    };

    if (pdf_base64 && filename) {
      resendPayload.attachments = [{
        filename: filename,
        content: pdf_base64,
      }];
    }

    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify(resendPayload),
    })

    const data = await response.json();

    if (!response.ok) {
        // Use Resend's error message if available
        throw new Error(data.message || 'Failed to send email');
    }

    return new Response(JSON.stringify({ success: true, data }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})

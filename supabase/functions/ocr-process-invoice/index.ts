import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

// @ts-ignore
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4'
import { corsHeaders } from '../_shared/cors.ts'

console.log(`Function "browser-with-cors" up and running!`)

serve(async (req) => {
  // This is needed if you're planning to invoke your function from a browser.
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { image_base64 } = await req.json()
    const ocrSpaceApiKey = Deno.env.get('OCR_SPACE_API_KEY')

    // 1. Call ocr.space API
    const formData = new FormData()
    formData.append('base64Image', `data:image/jpeg;base64,${image_base64}`)
    formData.append('language', 'fre')

    const ocrResponse = await fetch('https://api.ocr.space/parse/image', {
      method: 'POST',
      headers: { 'apikey': ocrSpaceApiKey },
      body: formData,
    })

    const ocrResult = await ocrResponse.json()
    if (!ocrResult.ParsedResults || ocrResult.ParsedResults.length === 0) {
      throw new Error('OCR processing failed or returned no results.')
    }
    const rawText = ocrResult.ParsedResults[0].ParsedText

    // 2. Parse rawText (your regex logic here)
    const parsedData = _parseInvoiceData(rawText) // Implement this function

    return new Response(JSON.stringify({ success: true, result: parsedData }), {
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

function _parseInvoiceData(text: string) {\n  const data = {\n    supplier: \'Fournisseur non trouvé\',\n    amount: 0.0,\n    date: \'\',\n    items: [], // Line items are not requested yet, keep as empty array\n    rawText: text,\n  };\n\n  const lines = text.split(\'\\n\');\n\n  // ===== EXTRACT SUPPLIER NAME =====\n  const supplierKeywords = [\'SARL\', \'SAS\', \'Fournisseur\', \'EURL\', \'SA\', \'Ltd\', \'Inc\', \'Plomberie\', \'Sanitaire\'];\n  for (let i = 0; i < Math.min(lines.length, 15); i++) {\n    const line = lines[i];\n    if (supplierKeywords.some(keyword => line.toLowerCase().includes(keyword.toLowerCase()))) {\n      data.supplier = line.trim();\n      break;\n    }\n  }\n  if (data.supplier === \'Fournisseur non trouvé\' && lines.length > 0) {\n    data.supplier = lines[0].trim(); // Fallback to first line\n  }\n\n  // ===== EXTRACT AMOUNT =====\n  const amountPatterns = [\n    /(?:TOTAL|Total|MONTANT|Montant|À payer|à payer)[\\s:]*([0-9]+[.,][0-9]{2})/, // e.g., Total: 123.45\n    /([0-9]+[.,][0-9]{2})\\s*(?:€|EUR)/, // e.g., 123.45 €\n  ];\n\n  for (const pattern of amountPatterns) {\n    const matches = text.match(pattern);\n    if (matches && matches[1]) {\n      const amountStr = matches[1].replace(\',\', \'.\');\n      data.amount = parseFloat(amountStr);\n      break;\n    }\n  }\n\n  // ===== EXTRACT DATE =====\n  const datePatterns = [\n    /(?:Date|DATE)[\s:]*(\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4})/, // e.g., Date: 01/01/2023 or Date: 01-01-2023\n    /(\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4})/, // e.g., 01/01/2023\n  ];\n\n  for (const pattern of datePatterns) {\n    const matches = text.match(pattern);\n    if (matches && matches[1]) {\n      data.date = matches[1];\n      break;\n    }\n  }\n\n  return data;\n}\n

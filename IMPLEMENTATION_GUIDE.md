# PlombiFacto - Top 10 Priorities Implementation Guide

**Quick Reference for Developers**
**Based on:** GAP_ANALYSIS_AND_ROADMAP.md

---

## Priority 1: Create 50+ Plumbing Templates

### What's Needed:
A comprehensive library of pre-built quote templates for common plumbing jobs.

### Implementation Steps:

1. **Create Templates Data Structure** (1 day)
```json
// lib/data/templates/bathroom_renovation.json
{
  "id": "template_001",
  "name": "Rénovation Salle de Bain Complète",
  "category": "Bathroom",
  "description": "Rénovation complète avec douche, lavabo, WC",
  "line_items": [
    {
      "description": "Douche italienne 90x90cm avec paroi",
      "quantity": 1,
      "unit": "unité",
      "unit_price_ht": 800.00,
      "vat_rate": 20.0,
      "category": "Sanitaire"
    },
    {
      "description": "Lavabo suspendu + mitigeur",
      "quantity": 1,
      "unit": "unité",
      "unit_price_ht": 350.00,
      "vat_rate": 20.0,
      "category": "Sanitaire"
    },
    {
      "description": "WC suspendu avec bâti-support",
      "quantity": 1,
      "unit": "unité",
      "unit_price_ht": 450.00,
      "vat_rate": 20.0,
      "category": "Sanitaire"
    },
    {
      "description": "Tuyauterie PER + raccordements",
      "quantity": 1,
      "unit": "ensemble",
      "unit_price_ht": 300.00,
      "vat_rate": 20.0,
      "category": "Plomberie"
    },
    {
      "description": "Main d'œuvre installation (2 jours)",
      "quantity": 16,
      "unit": "heures",
      "unit_price_ht": 45.00,
      "vat_rate": 20.0,
      "category": "Service"
    }
  ],
  "default_terms": "Devis valable 30 jours. Acompte de 30% à la commande. Paiement du solde à la fin des travaux.",
  "estimated_duration_hours": 16,
  "default_validity_days": 30
}
```

2. **Create All 50+ Templates** (8-10 days)

Required templates (from PDF spec):
- ✅ bathroom_renovation.json
- ✅ kitchen_plumbing.json
- ✅ heating_installation.json
- ✅ boiler_replacement.json
- ✅ leak_repair.json
- ✅ drain_cleaning.json
- ✅ water_heater_installation.json
- ✅ radiator_installation.json
- ✅ emergency_callout.json
- ✅ annual_maintenance.json
- ✅ solar_water_heater.json
- ✅ underfloor_heating.json
- ✅ pipe_replacement.json
- ✅ shower_installation.json
- ✅ bathtub_installation.json
- ✅ toilet_installation.json
- ✅ sink_replacement.json
- ✅ faucet_replacement.json
- ✅ dishwasher_installation.json
- ✅ washing_machine_connection.json
- ... (30 more)

3. **Update Database Schema** (1 day)
```sql
-- Add to supabase_schema.sql
CREATE TABLE templates (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES profiles(id), -- NULL for system templates
    template_name text NOT NULL,
    template_type text DEFAULT 'quote',
    category text,
    line_items jsonb NOT NULL,
    default_terms text,
    estimated_duration_hours int,
    default_validity_days int DEFAULT 30,
    is_system_template boolean DEFAULT false,
    times_used int DEFAULT 0,
    last_used timestamp,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Insert system templates
INSERT INTO templates (template_name, category, line_items, is_system_template, ...)
-- Load from JSON files
```

4. **Create Template Selector UI** (2 days)
```dart
// lib/screens/quotes/widgets/template_selector_dialog.dart
class TemplateSelectorDialog extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un modèle...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          // Category tabs
          TabBar(tabs: [
            Tab(text: 'Salle de bain'),
            Tab(text: 'Cuisine'),
            Tab(text: 'Chauffage'),
            // ...
          ]),
          // Template grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                return TemplateCard(template: templates[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

5. **Integrate into QuoteFormPage** (1 day)
```dart
// Add button to QuoteFormPage
ElevatedButton.icon(
  icon: Icon(Icons.library_books),
  label: Text('Utiliser un modèle'),
  onPressed: () async {
    final template = await showDialog<Template>(
      context: context,
      builder: (_) => TemplateSelectorDialog(),
    );
    if (template != null) {
      setState(() {
        _lineItems = template.lineItems;
        _notesController.text = template.defaultTerms;
        _calculateTotals();
      });
    }
  },
),
```

**Total Effort:** 12-14 days

---

## Priority 2: Implement Auto-Generated Quote/Invoice Numbers

### What's Needed:
Sequential, non-gapped numbering with custom prefixes.

### Implementation Steps:

1. **Add Settings Table** (30 min)
```sql
CREATE TABLE settings (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id) UNIQUE,
    invoice_prefix text DEFAULT 'FACT-',
    quote_prefix text DEFAULT 'DEV-',
    invoice_starting_number int DEFAULT 1,
    quote_starting_number int DEFAULT 1,
    reset_numbering_annually boolean DEFAULT false,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);
```

2. **Create Cloud Function** (2-3 hours)
```python
# cloud_functions/generate_document_number/main.py
@functions_framework.http
def generate_number(request):
    request_json = request.get_json()
    user_id = request_json.get('user_id')
    doc_type = request_json.get('type')  # 'quote' or 'invoice'

    # Fetch settings
    settings = supabase.table('settings').select('*').eq('user_id', user_id).single().execute()

    if doc_type == 'quote':
        prefix = settings.data.get('quote_prefix', 'DEV-')
        counter_field = 'quote_starting_number'
    else:
        prefix = settings.data.get('invoice_prefix', 'FACT-')
        counter_field = 'invoice_starting_number'

    # Get current counter
    current_number = settings.data.get(counter_field, 1)

    # Check if annual reset
    if settings.data.get('reset_numbering_annually'):
        year = datetime.now().year
        number_str = f"{prefix}{year}-{current_number:05d}"
    else:
        number_str = f"{prefix}{current_number:05d}"

    # Increment counter
    supabase.table('settings').update({
        counter_field: current_number + 1
    }).eq('user_id', user_id).execute()

    return {'success': True, 'number': number_str}
```

3. **Update QuoteFormPage** (1 hour)
```dart
Future<String> _generateQuoteNumber() async {
  final response = await http.post(
    Uri.parse('https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/generate_number'),
    body: jsonEncode({
      'user_id': Supabase.instance.client.auth.currentUser!.id,
      'type': 'quote',
    }),
  );
  final data = jsonDecode(response.body);
  return data['number'];
}

// In _saveQuote():
final quoteNumber = _quote?.quoteNumber ?? await _generateQuoteNumber();
```

**Total Effort:** 1 day

---

## Priority 3: Enhanced OCR Processor

### What's Needed:
Extract line items, dates, invoice numbers, not just supplier and total.

### Implementation:

1. **Upgrade OCR Parser** (4-5 days)
```python
# cloud_functions/ocr_processor/main.py
import re
from datetime import datetime

def parse_invoice_text(raw_text: str) -> dict:
    """
    Advanced parsing with regex patterns for French invoices.
    """
    extracted = {
        'supplier_name': None,
        'invoice_number': None,
        'invoice_date': None,
        'line_items': [],
        'subtotal_ht': 0.0,
        'total_vat': 0.0,
        'total_ttc': 0.0,
        'confidence_scores': {}
    }

    lines = raw_text.split('\n')

    # 1. Supplier Name (usually in first 3 lines)
    for line in lines[:3]:
        if len(line.strip()) > 5 and not re.search(r'\d', line):
            extracted['supplier_name'] = line.strip()
            extracted['confidence_scores']['supplier_name'] = 0.85
            break

    # 2. Invoice Number (patterns: Facture N°, Invoice #, Fact:, etc.)
    invoice_patterns = [
        r'Facture\s+N[°o]?\s*:?\s*([A-Z0-9-]+)',
        r'Invoice\s+#?\s*:?\s*([A-Z0-9-]+)',
        r'Fact\.?\s*:?\s*([A-Z0-9-]+)',
        r'N°\s+([A-Z0-9-]+)',
    ]
    for pattern in invoice_patterns:
        match = re.search(pattern, raw_text, re.IGNORECASE)
        if match:
            extracted['invoice_number'] = match.group(1)
            extracted['confidence_scores']['invoice_number'] = 0.90
            break

    # 3. Date (DD/MM/YYYY, DD-MM-YYYY, etc.)
    date_pattern = r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'
    date_match = re.search(date_pattern, raw_text)
    if date_match:
        day, month, year = date_match.groups()
        year = year if len(year) == 4 else f"20{year}"
        try:
            extracted['invoice_date'] = f"{year}-{month.zfill(2)}-{day.zfill(2)}"
            extracted['confidence_scores']['invoice_date'] = 0.95
        except:
            pass

    # 4. Line Items (complex table detection)
    # Look for patterns like: "Description  Qté  Prix Unit.  Total"
    table_started = False
    for i, line in enumerate(lines):
        # Detect table header
        if re.search(r'(Désignation|Description|Libellé).*?(Qté|Quantité).*?(Prix|PU)', line, re.IGNORECASE):
            table_started = True
            continue

        # Parse table rows
        if table_started:
            # Stop at totals line
            if re.search(r'(Total|Sous-total|ST HT|TOTAL HT)', line, re.IGNORECASE):
                table_started = False
                continue

            # Try to extract: description, quantity, unit price, total
            # Pattern: "text  [number]  [number]  [number]"
            parts = line.split()
            numbers = [p.replace(',', '.') for p in parts if re.match(r'[\d,\.]+$', p)]

            if len(numbers) >= 3:  # At least qty, unit_price, total
                try:
                    description = ' '.join([p for p in parts if not re.match(r'[\d,\.]+$', p)])
                    quantity = float(numbers[-3])
                    unit_price = float(numbers[-2])
                    total = float(numbers[-1])

                    extracted['line_items'].append({
                        'description': description,
                        'quantity': quantity,
                        'unit_price': unit_price,
                        'total': total,
                    })
                except:
                    pass

    # 5. Totals
    # Subtotal HT
    ht_match = re.search(r'(Sous-total|Total)\s+HT\s*:?\s*([\d\s,.]+)', raw_text, re.IGNORECASE)
    if ht_match:
        extracted['subtotal_ht'] = float(ht_match.group(2).replace(' ', '').replace(',', '.'))

    # Total TTC
    ttc_match = re.search(r'Total\s+TTC\s*:?\s*([\d\s,.]+)', raw_text, re.IGNORECASE)
    if ttc_match:
        extracted['total_ttc'] = float(ttc_match.group(2).replace(' ', '').replace(',', '.'))

    # VAT (derive from HT and TTC if not found)
    extracted['total_vat'] = extracted['total_ttc'] - extracted['subtotal_ht']

    return extracted
```

2. **Add Review UI** (2 days)
```dart
// lib/screens/ocr/review_extracted_data_page.dart
class ReviewExtractedDataPage extends StatefulWidget {
  final Map<String, dynamic> extractedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vérifier les données extraites')),
      body: Column(
        children: [
          // Show confidence scores
          if (confidenceScore < 0.7)
            Banner(message: 'Vérification recommandée', color: Colors.orange),

          // Editable fields
          TextFormField(
            initialValue: extractedData['supplier_name'],
            decoration: InputDecoration(labelText: 'Fournisseur'),
          ),
          TextFormField(
            initialValue: extractedData['invoice_number'],
            decoration: InputDecoration(labelText: 'N° Facture'),
          ),
          // ...

          // Line items with checkboxes to add to catalog
          ListView.builder(
            itemCount: extractedData['line_items'].length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(item['description']),
                  subtitle: Text('${item['quantity']} x ${item['unit_price']}€'),
                  trailing: Checkbox(
                    value: _selectedItems[index],
                    onChanged: (val) => setState(() => _selectedItems[index] = val),
                  ),
                ),
              );
            },
          ),

          // Actions
          Row(
            children: [
              ElevatedButton(
                child: Text('Ajouter au catalogue'),
                onPressed: _addSelectedToCatalog,
              ),
              ElevatedButton(
                child: Text('Générer un devis'),
                onPressed: _generateQuoteFromScan,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

**Total Effort:** 6-7 days

---

## Priority 4: Factur-X & French Legal Compliance

### What's Needed:
EN16931 compliant XML embedded in PDF.

### Implementation:

1. **Use Existing Library** (1 day setup)
```bash
cd cloud_functions/facturx_generator
pip install factur-x
```

2. **Implement Full XML Generation** (3-4 days)
```python
# cloud_functions/facturx_generator/main.py
from facturx import generate_facturx
from lxml import etree

def generate_en16931_xml(invoice_data: dict) -> bytes:
    """
    Generate EN16931 compliant XML.
    """
    # Fetch company profile
    company = supabase.table('profiles').select('*').eq('id', invoice_data['user_id']).single().execute().data

    # Fetch client
    client = supabase.table('clients').select('*').eq('id', invoice_data['client_id']).single().execute().data

    # Build XML structure per EN16931
    root = etree.Element("{urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100}CrossIndustryInvoice")

    # Header
    context = etree.SubElement(root, "ExchangedDocumentContext")
    # ... add GuidelineSpecifiedDocumentContextParameter

    # Buyer/Seller
    transaction = etree.SubElement(root, "SupplyChainTradeTransaction")
    seller = etree.SubElement(transaction, "ApplicableHeaderTradeAgreement")
    # ... add SellerTradeParty with company info

    buyer = etree.SubElement(transaction, "ApplicableHeaderTradeAgreement")
    # ... add BuyerTradeParty with client info

    # Line items
    for item in invoice_data['line_items']:
        line = etree.SubElement(transaction, "IncludedSupplyChainTradeLineItem")
        # ... add item details

    # Totals
    settlement = etree.SubElement(transaction, "ApplicableHeaderTradeSettlement")
    # ... add tax totals, grand total

    return etree.tostring(root, pretty_print=True, xml_declaration=True, encoding='UTF-8')

def embed_xml_in_pdf(pdf_path: str, xml_bytes: bytes) -> str:
    """
    Use factur-x library to embed XML in PDF.
    """
    output_path = pdf_path.replace('.pdf', '_facturx.pdf')
    generate_facturx(
        pdf_invoice=pdf_path,
        facturx_xml=xml_bytes,
        output_pdf_file=output_path,
        facturx_level='en16931',  # Or 'minimum', 'basic', 'extended'
    )
    return output_path
```

**Total Effort:** 4-5 days

---

## Priority 5-10: Quick Implementation Notes

### 5. Quote/Invoice Form Enhancements (4 days)
- Add VAT dropdown: `DropdownButton<double>(items: [0, 5.5, 10, 20])`
- Add discount field: `TextFormField(keyboardType: TextInputType.number)`
- Product autocomplete: Use `Autocomplete<Product>` widget
- Reorderable line items: `ReorderableListView`

### 6. Database Triggers (2 days)
```sql
-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_quotes_modtime
BEFORE UPDATE ON quotes
FOR EACH ROW EXECUTE FUNCTION update_modified_column();
```

### 7. Stripe Subscription UI (3 days)
- Create checkout session via Cloud Function
- Redirect to Stripe Checkout
- Handle webhooks properly
- Display plan comparison

### 8. Job Sites Tabs (5 days)
- Use `DefaultTabController` with 7 tabs
- Financial tab: Calculate costs from purchases + time logs
- Photos tab: `ImagePicker` + `GridView`
- Time tracking: Start/stop timer with `Timer.periodic`

### 9. PDF Generation Polish (3 days)
- Add company logo: `pdf.widgets.Image`
- Proper layout: Use `pdf.widgets.Table`
- Legal mentions: Fetch from company profile

### 10. Web Scraping (10 days - COMPLEX)
- Use `BeautifulSoup` or `Selenium` for JS-heavy sites
- Respect robots.txt
- Rate limiting (1 request per 2 seconds)
- Error handling & retry logic
- Schedule weekly with Cloud Scheduler

---

## Quick Wins (Can Do Today!)

### 1. Fix HomePage Placeholders (30 min)
```dart
// Fetch user name
final profile = await SupabaseService.fetchProfile();
Text('Bonjour, ${profile.firstName}!'),

// Wire up scan action
_ActionButton(
  title: 'Scanner',
  icon: Icons.qr_code_scanner,
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScanInvoicePage())),
),
```

### 2. Add VAT Dropdown to Quote/Invoice Forms (15 min)
```dart
DropdownButton<double>(
  value: _selectedVatRate,
  items: [0.0, 5.5, 10.0, 20.0].map((rate) {
    return DropdownMenuItem(value: rate, child: Text('${rate}%'));
  }).toList(),
  onChanged: (val) => setState(() {
    _selectedVatRate = val!;
    _calculateTotals();
  }),
),
```

### 3. Add Privacy Policy Page (1 hour)
```dart
// lib/screens/legal/privacy_policy_page.dart
class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Politique de Confidentialité')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text('''
# Politique de Confidentialité

**Dernière mise à jour:** ${DateTime.now().year}

## 1. Collecte de Données
Nous collectons les données suivantes:
- Nom, prénom, email
- SIRET, informations d'entreprise
- Données de facturation

## 2. Utilisation des Données
Vos données sont utilisées uniquement pour:
- Générer des devis et factures
- Gérer votre abonnement
- Améliorer nos services

## 3. Vos Droits (GDPR)
Vous avez le droit:
- D'accéder à vos données
- De rectifier vos données
- De supprimer votre compte
- D'exporter vos données

...
        '''),
      ),
    );
  }
}
```

---

## Testing Checklist Before Launch

- [ ] Quote number generation (sequential, no gaps)
- [ ] Invoice number generation (sequential, no gaps)
- [ ] OCR scanning (10 different invoice formats)
- [ ] PDF generation (with logo, correct layout)
- [ ] Stripe payment flow (test mode)
- [ ] Factur-X validation (use EN16931 validator)
- [ ] All forms validation (required fields, email format)
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] Offline mode (cache data, queue uploads)
- [ ] Performance (load time < 2 sec, PDF gen < 5 sec)

---

**Happy Coding! 🚀**


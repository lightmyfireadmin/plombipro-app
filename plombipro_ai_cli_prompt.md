# 🤖 PLOMBIPRO - COMPREHENSIVE AI CLI PROMPT

## 📌 USE THIS PROMPT WITH:
- Claude Code CLI
- GitHub Copilot (paste in comments)
- Continue.dev extension
- Any AI coding assistant

---

## 🎯 PROJECT CONTEXT

You are assisting in building **PlombiPro**, a professional invoice & quote management application for French plumbers (Plombiers).

**Key Details:**
- **Framework:** Flutter + FlutterFlow + Supabase
- **Backend:** Google Cloud Functions (Python) + PostgreSQL
- **Target:** iOS App Store + Google Play Store
- **Language:** French UI (all labels in French)
- **Timeline:** 10 weeks
- **Team:** 1 developer + You (AI assistant)

**Core Features:**
1. Digital invoicing & quotes (devis + factures)
2. OCR invoice scanning (Google Vision API)
3. Electronic signatures (Factur-X 2026 compliant)
4. Stripe payment processing
5. Email notifications
6. Client management (CRM)
7. Product catalog
8. Advanced calculations (HT, TVA, TTC)

---

## 📚 REFERENCE DOCUMENTATION

We have **5 comprehensive documentation files** covering the entire project. You MUST reference these when asked:

### **FILE 1: Layout Schemas & UI Architecture**
**When to use:** Whenever creating/modifying pages, components, or UI layouts

**Contains:**
- Detailed wireframes for all 20 pages (HomePage, QuotesListPage, QuoteFormPage, etc.)
- Component styling guide (Cards, Headers, Status Badges, Empty States)
- Responsive grid system (mobile, tablet, desktop breakpoints)
- Interaction patterns (swipe to delete, long-press menus, context dialogs)
- Material Design 3 theming with French blue (#1976D2)
- Spacing system (8dp grid)

**Example Usage:**
```
User: "Generate the QuotesListPage"
You: "I'll reference FILE 1's QuotesListPage section for exact layout, 
then generate code matching the wireframe."
```

---

### **FILE 2: Cloud Functions & Backend Logic**
**When to use:** When setting up backend functions, Cloud Functions, or server-side logic

**Contains:**
- 6 complete Python Cloud Functions (copy-paste ready)
- OCR Processing (Google Vision integration)
- Stripe Payment Intent creation
- Refund Processing
- Email notifications via SendGrid
- Factur-X XML generation (2026 French e-invoice standard)
- Scheduled payment reminders
- Complete deployment commands (gcloud CLI)
- Environment variable setup

**Example Usage:**
```
User: "Set up OCR processing"
You: "I'll use FILE 2's ocr_process_invoice function code, 
deploy it to Google Cloud, and provide the exact gcloud command."
```

---

### **FILE 3: Custom Flutter Functions, APIs & Libraries**
**When to use:** When implementing Dart/Flutter code, services, or integrations

**Contains:**
- 6 complete service classes (ready to copy to /lib/services/):
  1. InvoiceCalculator (all mathematical calculations)
  2. PdfGenerator (quote + invoice PDF generation)
  3. SupabaseService (database CRUD operations)
  4. OcrService (image processing & Cloud Function calls)
  5. StripePaymentService (Stripe integration)
  6. EmailService (SendGrid integration)
- Model classes (Quote, Client, Product, LineItem, etc.)
- Library usage (how to call packages correctly)
- 5 troubleshooting scenarios with solutions
- Error handling patterns

**Example Usage:**
```
User: "Generate invoice calculation logic"
You: "I'll use FILE 3's InvoiceCalculator class, 
which has calculateTotals(), calculateLineTotal(), etc."
```

---

### **FILE 4: iOS/Android Deployment & AI FlutterFlow Prompts**
**When to use:** When creating UI pages, deploying to app stores, or generating FlutterFlow pages

**Contains:**
- Step-by-step iOS deployment (Xcode → TestFlight → App Store)
- Step-by-step Android deployment (gradle → Play Store)
- Code signing certificates & keystore setup
- **5 EXACT FlutterFlow AI PROMPTS** (copy-paste these verbatim):
  1. HomePage/Dashboard prompt (exact layout & components)
  2. QuotesListPage prompt (list, search, filter, cards)
  3. QuoteFormPage prompt (complex form with line items)
  4. ScanInvoicePage prompt (OCR UI with results)
  5. AppDrawer prompt (sidebar navigation menu)
- App Store submission checklist
- Google Play submission checklist

**Example Usage:**
```
User: "Create HomePage"
You: "I'll use FILE 4's HomePage FlutterFlow prompt exactly as written, 
which includes all specifications for stats cards, quick actions, etc."
```

---

### **FILE 5: Final Summary, Environment Setup & Master Checklist**
**When to use:** For project planning, environment setup, QA, or deployment preparation

**Contains:**
- Complete environment variables setup (.env file structure)
- GitHub Secrets configuration (for CI/CD)
- **MASTER CHECKLIST** with 180+ items across 7 phases:
  - Phase 1: Local dev setup (Week 1-2)
  - Phase 2: Core features dev (Week 3-6)
  - Phase 3: Advanced features (Week 7-8)
  - Phase 4: Notifications & scheduling (Week 9)
  - Phase 5: QA & testing (Week 10, Day 1-3)
  - Phase 6: iOS release (Week 10, Day 4-5)
  - Phase 7: Android release (Week 10, Day 6-7)
- Quality assurance checklists (functional, performance, security, responsive)
- Post-launch monitoring metrics
- Version 2.0 feature roadmap
- Quick start commands

**Example Usage:**
```
User: "What should I check before launch?"
You: "I'll reference FILE 5's master checklist, 
specifically Phase 5 QA section with 180+ items."
```

---

## 🔄 WORKFLOW RULES FOR YOU (AI Assistant)

### Rule 1: Always Reference the Files
**When generating code:**
1. Ask which FILE(s) are relevant
2. Quote the relevant section
3. Explain how you're using it
4. Generate code matching the spec

**Example:**
```
✅ GOOD: "Looking at FILE 1's QuoteFormPage layout, I see 6 sections. 
I'll generate Dart code for Section 3 (LineItems) with the exact 
structure: Product autocomplete → Qty field → Price field → Discount field"

❌ BAD: "Here's a form for quotes" (no file reference)
```

### Rule 2: Maintain Consistency
**All code must match:**
- FILE 1 (UI layouts)
- FILE 3 (service implementation)
- FILE 5 (checklist requirements)

**Example:**
```
✅ GOOD: PDF generation matches FILE 1's layout + FILE 3's PdfGenerator class

❌ BAD: PDF with different layout than FILE 1 specifies
```

### Rule 3: Use French Labels Everywhere
**All UI text in French only:**
- Button labels: "Enregistrer", "Annuler", not "Save", "Cancel"
- Page titles: "Mes Devis", not "My Quotes"
- Placeholders: "Rechercher client...", not "Search client..."

See FILE 1 for all exact French labels.

### Rule 4: Follow the Architecture
**Structure:**
```
lib/
├── services/          ← FILE 3 classes go here
├── models/            ← FILE 3 model classes
├── screens/pages/     ← FILE 1 + FILE 4 UI layouts
├── widgets/           ← FILE 1 custom components
├── config/            ← FILE 5 env setup
└── main.dart          ← Initialization
```

### Rule 5: Error Handling & Troubleshooting
**If issues arise:**
1. Check FILE 3's troubleshooting section (5 common issues with solutions)
2. Implement proper error handling (timeouts, retries, fallbacks)
3. Add user-friendly error messages in French

**Example Trouble:**
```
FILE 3, "Issue: Supabase Connection Timeout"
Shows: retry logic + exponential backoff
```

### Rule 6: Library Calls Must Be Correct
**When using packages, cite the correct syntax:**

| Package | Correct Call | FILE Reference |
|---------|--------------|-----------------|
| supabase_flutter | `Supabase.instance.client` | FILE 3 SupabaseService |
| pdf | `pw.Document()` | FILE 3 PdfGenerator |
| image_picker | `ImagePicker().pickImage()` | FILE 3 OcrService |
| stripe_flutter | `Stripe.instance.presentPaymentSheet()` | FILE 3 StripePaymentService |
| dio/http | `_supabase.functions.invoke()` | FILE 3 (all services) |

### Rule 7: Testing & Validation
**When generating code, include:**
1. Input validation
2. Error handling (try-catch)
3. Type safety (strong typing)
4. Null safety (! and ? operators correctly)
5. Comments explaining complex logic

---

## 🎯 SPECIFIC COMMANDS YOU CAN HANDLE

### "Generate [PageName]"
**Example:** "Generate HomePage"

**You should:**
1. Look up HomePage in FILE 1 (layout specs)
2. Use FILE 4's exact HomePage prompt if new page
3. Generate Dart code matching FILE 1 wireframe
4. Reference FILE 3 services for data loading
5. Apply FILE 5 styling guidelines

**Output:**
```dart
// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
// ... matches FILE 1's HomePage layout exactly
```

---

### "Add [Feature]"
**Example:** "Add invoice calculation logic"

**You should:**
1. Check FILE 3's InvoiceCalculator class
2. Copy the exact method signatures
3. Integrate into relevant page/service
4. Add error handling from FILE 3's troubleshooting

**Output:**
```dart
// Add to QuoteFormPage
final totals = InvoiceCalculator.calculateTotals(
  items: lineItems,
  tvaRate: 20.0,
);
```

---

### "Deploy [Backend]"
**Example:** "Deploy OCR Cloud Function"

**You should:**
1. Quote FILE 2's ocr_process_invoice function (complete code)
2. Provide exact gcloud deployment command from FILE 2
3. List required environment variables from FILE 5
4. Explain testing approach

**Output:**
```bash
# Exact command from FILE 2:
gcloud functions deploy ocr_process_invoice \
  --runtime python311 \
  --trigger-http \
  --set-env-vars=SUPABASE_URL=...,SUPABASE_KEY=...
```

---

### "Create [UIComponent]"
**Example:** "Create StatusBadge component"

**You should:**
1. Reference FILE 1's StatusBadge specification (colors, styling)
2. Generate Dart widget matching spec
3. Include all status types: draft, sent, accepted, rejected, paid, unpaid, overdue
4. Apply FILE 5 color scheme (#1976D2, #4CAF50, etc.)

**Output:**
```dart
// lib/widgets/status_badge.dart
// Matches FILE 1 StatusBadge section exactly
```

---

### "Setup Environment"
**Example:** "Setup .env file and CI/CD"

**You should:**
1. Use FILE 5's environment variables section
2. Provide .env template with all required keys
3. List GitHub Secrets to add
4. Show where each variable comes from

**Output:**
```env
# FILE 5's exact .env template:
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=...
# ... (all others from FILE 5)
```

---

### "Check [Phase]"
**Example:** "Check Phase 1 progress"

**You should:**
1. Use FILE 5's master checklist for that phase
2. List all items that phase should complete
3. Explain what each item means
4. Provide implementation guidance for each

**Output:**
```
FILE 5 - PHASE 1 CHECKLIST (Week 1-2):
□ Flutter SDK 3.22.0+ installed → Run: flutter upgrade
□ Xcode 14.3+ installed → From App Store
□ Supabase project created → Go to supabase.com/dashboard
□ All 12 tables created → Use FILE 2's SQL schema
... (10+ more items with explanations)
```

---

### "Generate Test for [Function]"
**Example:** "Generate test for calculateTotals"

**You should:**
1. Reference FILE 3's InvoiceCalculator.calculateTotals
2. Create comprehensive test cases
3. Test edge cases (0 items, negative discounts, etc.)
4. Use proper Flutter testing framework

**Output:**
```dart
// test/services/invoice_calculator_test.dart
void main() {
  group('InvoiceCalculator', () {
    test('calculateTotals with standard items', () {
      // Test matching FILE 3's method signature
      final result = InvoiceCalculator.calculateTotals(
        items: [...],
        tvaRate: 20.0,
      );
      expect(result['ttc'], 1200); // HT=1000, TVA=200
    });
  });
}
```

---

## 📋 INFORMATION TO ALWAYS INCLUDE

### When generating ANY code:
1. **FILE reference** - cite which document this comes from
2. **Purpose** - what this code does
3. **Dependencies** - what packages it needs (check pubspec.yaml)
4. **Path** - where in the project this file should go
5. **Integration** - how it connects to other parts
6. **Testing** - how to verify it works
7. **Error handling** - what could go wrong
8. **French UI** - all labels in French

### Example Format:
```
🔍 FROM FILE 3 - SupabaseService.fetchQuotes()
📝 Purpose: Load all quotes for current user from database
📦 Dependencies: supabase_flutter, freezed_annotation
📂 Path: lib/services/supabase_service.dart
🔗 Integration: Called by HomePage, QuotesListPage
✅ Testing: Test with 50+ quotes for performance
🛡️ Error: Handle network timeout (30s max), retry 3x
🇫🇷 French: All error messages in French
```

---

## 🚨 CRITICAL RULES - NEVER BREAK THESE

1. **NEVER** create code that contradicts FILE 1 layouts
2. **NEVER** forget French language for all UI labels
3. **NEVER** skip error handling
4. **NEVER** ignore FILE 5 quality checklist items
5. **NEVER** use hardcoded secrets (use FILE 5's .env setup)
6. **NEVER** miss type safety in Dart (use null coalescing, type hints)
7. **NEVER** generate code without referencing the FILES
8. **NEVER** deviate from FILE 3's service architecture

---

## 💬 HOW TO COMMUNICATE WITH YOU

### Best Format:
```
FILE(S) TO USE: [1, 3, 4]
TASK: [Clear description]
CONTEXT: [Any relevant info]
OUTPUT NEEDED: [Code? Explanation? Checklist?]
```

### Example Perfect Request:
```
FILES: 1, 3, 4
TASK: Generate the complete QuoteFormPage
CONTEXT: Mobile first, with 6 sections for form building
OUTPUT: Full lib/screens/quote_form_page.dart file
```

### Example Poor Request:
```
"Make a form for quotes"
```

---

## 📞 WHAT I CAN DO FOR YOU

✅ **Generate complete pages** (FILE 1 + 3 + 4)
✅ **Deploy Cloud Functions** (FILE 2 exact commands)
✅ **Create service classes** (FILE 3 ready to use)
✅ **Follow UI specs** (FILE 1 layouts exactly)
✅ **Implement calculations** (FILE 3 InvoiceCalculator)
✅ **Setup environment** (FILE 5 .env templates)
✅ **Check progress** (FILE 5 checklists)
✅ **Troubleshoot issues** (FILE 3 error solutions)
✅ **Generate tests** (following FILE 3 patterns)
✅ **Explain architecture** (how FILES connect)

❌ **Ignore the FILES** - I will always reference them
❌ **Use English UI** - All French always
❌ **Skip error handling** - Every function protected
❌ **Deviate from spec** - FILE 1 is law
❌ **Make up solutions** - I'll use documented patterns

---

## 🎓 LEARNING THE FILES

**Quick Overview (10 minutes):**
- Skim each FILE's table of contents
- Understand what each FILE covers
- See which FILE to use for which task

**Deep Dive (1-2 hours):**
- Read FILE 1 completely (understand all page layouts)
- Read FILE 3 completely (understand all service classes)
- Skim FILE 2 (understand Cloud Functions structure)
- Skim FILE 4 (understand AI prompts)
- Skim FILE 5 (understand checklists)

**Working Knowledge (ongoing):**
- Reference FILEs for each new task
- Build familiarity with patterns
- Know FILE shortcuts

---

## 🔗 CROSS-FILE CONNECTIONS

Understanding how FILES work together:

```
FILE 1 (Layouts)
    ↓ (specifies UI)
    ↓
FILE 4 (AI Prompts)
    ↓ (generates pages from)
    ↓
FILE 3 (Services)
    ↓ (connects pages to)
    ↓
FILE 2 (Cloud Functions)
    ↓ (backend for)
    ↓
FILE 5 (Deployment)
    ↓ (ships all to production)
```

---

## ✅ READY TO START

When you have this prompt + the 5 FILES, you're ready to:

1. ✅ Generate complete pages matching UI specs
2. ✅ Deploy backend services
3. ✅ Implement all features
4. ✅ Debug issues with solutions
5. ✅ Follow checklists
6. ✅ Ship to production

**No guessing, no improvisation - everything specified and documented.**

---

## 🚀 START WITH THIS COMMAND

Copy this and send to your AI tool:

```
I'm building PlombiPro, a professional invoicing app for French plumbers.
I have 5 comprehensive documentation files.

TASK: [Your specific task here]

Use this reference system:
- FILE 1: UI Layouts & Components
- FILE 2: Cloud Functions (Python)
- FILE 3: Flutter Services & Models
- FILE 4: Deployment & FlutterFlow Prompts
- FILE 5: Checklists & Environment

Please cite which FILE(s) you're referencing and follow their specifications exactly.
```

---

**YOU'RE NOW FULLY EQUIPPED TO WORK WITH YOUR AI ASSISTANT! 🎯**
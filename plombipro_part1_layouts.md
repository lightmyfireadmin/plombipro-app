# PLOMBIPRO - PART 1: DETAILED LAYOUT SCHEMAS & UI ARCHITECTURE

## 🎨 LAYOUT SYSTEM & RESPONSIVE DESIGN

### Device Breakpoints (Flutter responsive)
```dart
class ResponsiveBreakpoints {
  static const double mobile = 0;      // 0 - 599px
  static const double tablet = 600;    // 600 - 1199px
  static const double desktop = 1200;  // 1200px+
  
  static bool isMobile(double width) => width < tablet;
  static bool isTablet(double width) => width >= tablet && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}
```

### Base Spacing System (8dp grid)
```dart
class AppSpacing {
  static const double xs = 4.0;   // Extra small
  static const double sm = 8.0;   // Small
  static const double md = 16.0;  // Medium (base)
  static const double lg = 24.0;  // Large
  static const double xl = 32.0;  // Extra large
  static const double xxl = 48.0; // Extra extra large
}
```

---

## 📱 CORE LAYOUT SCHEMAS

### 1. HomePage (Dashboard) Layout Tree

```
SafeArea
  ├─ Scaffold
  │   ├─ AppBar
  │   │   ├─ Title: "PlombiPro"
  │   │   ├─ Actions: [Settings, Notifications]
  │   │   └─ Bottom: SearchBar
  │   │
  │   ├─ Drawer: AppDrawer()
  │   │
  │   └─ Body: CustomScrollView(
  │       ├─ SliverAppBar (sticky stats)
  │       │   ├─ UserGreeting
  │       │   ├─ CompanyName
  │       │   └─ CurrentDate
  │       │
  │       └─ SliverList
  │           ├─ QuickStatsSection (4 cards in 2x2 grid)
  │           │   ├─ Card: "CA du mois: 12,450€"
  │           │   ├─ Card: "Factures impayées: 3 (2,100€)"
  │           │   ├─ Card: "Devis en attente: 2"
  │           │   └─ Card: "RDV aujourd'hui: 1"
  │           │
  │           ├─ Divider
  │           │
  │           ├─ RecentActivitySection
  │           │   ├─ SectionTitle: "Activité récente"
  │           │   │
  │           │   └─ HorizontalListView (scrollable)
  │           │       ├─ QuoteCard
  │           │       ├─ InvoiceCard
  │           │       ├─ ClientCard
  │           │       └─ QuoteCard
  │           │
  │           ├─ Divider
  │           │
  │           ├─ QuickActionsSection
  │           │   └─ Wrap (4 items, responsive)
  │           │       ├─ ActionButton: "+ Nouveau devis"
  │           │       ├─ ActionButton: "+ Nouvelle facture"
  │           │       ├─ ActionButton: "📸 Scanner"
  │           │       └─ ActionButton: "📞 Contacter"
  │           │
  │           └─ SizedBox(height: 32) // Bottom padding
  │
  └─ FloatingActionButton: "+"
```

**FlutterFlow AI Prompt:**
```
Create a dashboard page with:
1. SafeArea with Scaffold
2. AppBar with title "PlombiPro" and settings icon
3. Sticky header showing today's date and company name
4. 4 stat cards in 2x2 grid layout showing:
   - Monthly revenue (HT)
   - Unpaid invoices count and amount
   - Pending quotes
   - Today's appointments
5. Horizontal scrollable list of recent quotes/invoices (5 items)
6. 4 quick action buttons in a wrap layout:
   - "+ Nouveau devis"
   - "+ Nouvelle facture"
   - "📸 Scanner facture"
   - "📞 Contacter client"
7. Material Design 3 styling with blue primary color
8. Responsive for mobile, tablet, desktop
```

---

### 2. QuotesListPage Layout Tree

```
SafeArea
  ├─ Scaffold
  │   ├─ AppBar: "Mes Devis"
  │   │   └─ Actions: [Search, Filter]
  │   │
  │   └─ Body: Column(
  │       ├─ SearchAndFilterBar
  │       │   ├─ TextField: Search by client/number
  │       │   ├─ Chip: "Tous"
  │       │   ├─ Chip: "Brouillon"
  │       │   ├─ Chip: "Envoyés"
  │       │   ├─ Chip: "Acceptés"
  │       │   └─ Chip: "Rejetés"
  │       │
  │       ├─ Divider
  │       │
  │       └─ Expanded(
  │           └─ ListView.builder (quotes list)
  │               └─ QuoteCard
  │                   ├─ Row
  │                   │   ├─ Expanded (content)
  │                   │   │   ├─ Row (quote# + status)
  │                   │   │   ├─ SizedBox(4)
  │                   │   │   ├─ Text: Client name
  │                   │   │   └─ SizedBox(8)
  │                   │   ├─ Row (price + date)
  │                   │   │   ├─ Text: "1,250€"
  │                   │   │   └─ Text: "15 jan"
  │                   │   │
  │                   │   └─ PopupMenuButton
  │                   │       ├─ View
  │                   │       ├─ Edit
  │                   │       ├─ Delete
  │                   │       ├─ Send (email)
  │                   │       └─ Download PDF
  │                   │
  │                   └─ Divider
  │
  └─ FloatingActionButton: "➕ Nouveau devis"
```

**FlutterFlow AI Prompt:**
```
Create a quotes list page with:
1. AppBar with title "Mes Devis" and search icon
2. Search bar (TextField) to search by client name or quote number
3. Filter chips (Tous, Brouillon, Envoyés, Acceptés, Rejetés) in horizontal scroll
4. ListView of quote cards with:
   - Left side: Quote number, client name (smaller text), and amount in bold
   - Right side: Status badge (color-coded) and date
   - On card tap: navigate to QuoteDetailPage
   - Long press: show context menu (View, Edit, Download PDF, Send via Email, Delete)
5. Empty state when no quotes: "Aucun devis" with icon and "Créer mon premier devis" button
6. FAB at bottom: "➕ Nouveau devis" navigates to QuoteFormPage
7. Pull-to-refresh functionality
```

---

### 3. QuoteFormPage Layout Tree (Complex)

```
SafeArea
  ├─ Scaffold
  │   ├─ AppBar: "Nouveau Devis" or "Éditer Devis"
  │   │   └─ Actions: [Save, More options]
  │   │
  │   └─ Body: Form(
  │       └─ ListView(
  │           children: [
  │               // ===== SECTION 1: CLIENT SELECTION =====
  │               SectionHeader("Client"),
  │               SearchableDropdown
  │                   ├─ TextField with autocomplete
  │                   └─ List of existing clients + "Créer nouveau"
  │               SizedBox(16)
  │               
  │               // ===== SECTION 2: DATES =====
  │               SectionHeader("Dates"),
  │               Row(
  │                   ├─ Expanded: DatePicker("Date devis")
  │                   └─ Expanded: DatePicker("Valide jusqu'au")
  │               )
  │               SizedBox(16)
  │               
  │               // ===== SECTION 3: LINE ITEMS =====
  │               SectionHeader("Lignes"),
  │               LineItemsBuilder(
  │                   ├─ LineItem 1
  │                   │   ├─ Autocomplete product search
  │                   │   ├─ Qty field
  │                   │   ├─ Price field
  │                   │   ├─ Discount field
  │                   │   ├─ Total (calculated)
  │                   │   └─ Delete button
  │                   │
  │                   ├─ LineItem 2
  │                   ├─ ...
  │                   │
  │                   └─ "+ Ajouter ligne" button
  │               )
  │               SizedBox(16)
  │               
  │               // ===== SECTION 4: CALCULATIONS =====
  │               Card(
  │                   ├─ Row: "Total HT" | "1,000€"
  │                   ├─ Row: "TVA (20%)" | "200€"
  │                   ├─ Divider
  │                   ├─ Row: "Total TTC" | "1,200€" (bold)
  │                   ├─ Divider
  │                   └─ Row: "Acompte (20%)" | "240€"
  │               )
  │               SizedBox(16)
  │               
  │               // ===== SECTION 5: OPTIONS =====
  │               SectionHeader("Options"),
  │               TextField: "Notes"
  │               SizedBox(8)
  │               Row(
  │                   ├─ Checkbox: "Nécessite signature"
  │                   └─ Checkbox: "Envoyer après création"
  │               )
  │               SizedBox(16)
  │               
  │               // ===== SECTION 6: ACTIONS =====
  │               Row(
  │                   ├─ Expanded: OutlinedButton("Annuler")
  │                   ├─ SizedBox(8)
  │                   └─ Expanded: ElevatedButton("Enregistrer")
  │               )
  │               SizedBox(8)
  │               Row(
  │                   ├─ Expanded: OutlinedButton("Télécharger PDF")
  │                   ├─ SizedBox(8)
  │                   └─ Expanded: ElevatedButton("Envoyer par email")
  │               )
  │               SizedBox(32) // Bottom padding
  │           ]
  │       )
  │   )
```

**FlutterFlow AI Prompt:**
```
Create a quote form page (complex) with sections:

1. CLIENT SECTION:
   - Searchable dropdown to select existing client
   - Show client details if selected
   - Option to create new client inline

2. DATE SECTION:
   - Two date pickers side by side: "Date devis" and "Valide jusqu'au"

3. LINE ITEMS SECTION:
   - Add up to 20 line items dynamically
   - Each line item has:
     * Product autocomplete (searches from products table)
     * Quantity field (decimal, up to 3 decimals)
     * Unit price field (auto-filled from product, editable)
     * Discount % field
     * Total (auto-calculated as qty × price × (1 - discount%))
     * Delete button per line
   - "+ Ajouter ligne" button to add new item
   - Items sorted by sort_order

4. CALCULATIONS SECTION (read-only card):
   - Total HT (sum of line totals)
   - TVA rate selector (dropdown: 5.5%, 10%, 20%)
   - Total TVA (calculated)
   - Separator line
   - Total TTC (HT + TVA) - bold, larger font
   - Separator line
   - Deposit % field + calculated amount

5. OPTIONS SECTION:
   - Notes textarea (multi-line)
   - Checkbox: "Require customer signature"
   - Checkbox: "Send immediately after creation"

6. ACTION BUTTONS:
   - Top row: [Cancel] [Save]
   - Bottom row: [Download PDF] [Send Email]

7. Validations:
   - Quote number auto-generated (DEV-YYYY-NNN format)
   - At least one line item required
   - Client required
   - All numeric fields validated

8. Material Design 3, blue theme, responsive layout
```

---

### 4. ClientsListPage Layout Tree

```
SafeArea
  ├─ Scaffold
  │   ├─ AppBar: "Mes Clients"
  │   │
  │   └─ Body: Column(
  │       ├─ SearchBar + TagFilter
  │       │   ├─ TextField: "Rechercher client..."
  │       │   ├─ Chip: All tags (scrollable)
  │       │   └─ FilterButton: "Inactifs"
  │       │
  │       └─ Expanded(
  │           └─ ListView.builder
  │               └─ ClientCard
  │                   ├─ LeadingCircle: Avatar or Initials
  │                   ├─ Expanded(
  │                   │   ├─ Text: Company name (bold)
  │                   │   ├─ Text: Email + Phone (small)
  │                   │   └─ Row: [Tags as mini chips]
  │                   │)
  │                   ├─ Column(
  │                   │   ├─ Text: "CA: 1,250€" (small)
  │                   │   └─ Text: "Dernière: 5 jan" (small)
  │                   │)
  │                   └─ PopupMenu
  │                       ├─ View details
  │                       ├─ Edit
  │                       ├─ New quote
  │                       ├─ New invoice
  │                       └─ Delete
  │
  └─ FAB: "➕ Nouveau client"
```

---

### 5. InvoiceFormPage - Key Differences from QuoteForm

```
Same structure as QuoteFormPage PLUS:

Additional fields below Line Items:

├─ Payment Deadline (days): Dropdown [15, 30, 45, 60]
├─ Notes: "Conditions: NET 30"
├─ Payment section:
│   ├─ Payment Method dropdown [Bank transfer, Stripe, Cash, Check]
│   ├─ Stripe payment button (if method = Stripe)
│   └─ Reference field (IBAN for bank, transaction ID for Stripe)
│
└─ Electronic Invoice:
    ├─ Checkbox: "Generate Factur-X 2026 compliant"
    └─ (Automatic on save if checked)
```

---

### 6. ScanInvoicePage Layout Tree

```
SafeArea
  ├─ Scaffold
  │   ├─ AppBar: "Scanner facture"
  │   │
  │   └─ Body: SingleChildScrollView(
  │       └─ Column(
  │           ├─ // ===== IMAGE CAPTURE SECTION =====
  │           SectionHeader("Étape 1: Capturer image"),
  │           Card(
  │               ├─ Center(
  │               │   ├─ IF image == null:
  │               │   │   ├─ Icon: Camera
  │               │   │   ├─ Text: "Prendre une photo"
  │               │   │   └─ Row buttons:
  │               │   │       ├─ Button: "📷 Caméra"
  │               │   │       └─ Button: "📁 Galerie"
  │               │   │
  │               │   └─ IF image != null:
  │               │       ├─ Image preview (400x300)
  │               │       ├─ Button: "Retirer image"
  │               │       └─ Button: "Modifier image"
  │               └─)
  │           )
  │           SizedBox(24)
  │           
  │           ├─ // ===== OCR PROCESSING =====
  │           Center(
  │               └─ ElevatedButton(
  │                   label: "Scan avec OCR",
  │                   onPressed: _procesOcr,
  │                   enabled: image != null
  │               )
  │           )
  │           
  │           ├─ IF loading:
  │           │   ├─ LinearProgressIndicator
  │           │   ├─ Text: "Traitement OCR... 35%"
  │           │   └─ Text: "Extraction des données..."
  │           │
  │           └─ IF result != null:
  │               ├─ SectionHeader("Étape 2: Résultats OCR")
  │               │
  │               ├─ Card(
  │               │   ├─ Row: "Fournisseur" | TextField (editable)
  │               │   ├─ Row: "Montant" | TextField(€) (editable)
  │               │   ├─ Row: "Confiance" | ProgressBar (color-coded)
  │               │   │   // Green > 85%, Yellow 65-85%, Red < 65%
  │               │   ├─ Divider
  │               │   │
  │               │   └─ Text: "Lignes détectées:"
  │               │       └─ ListView
  │               │           ├─ ListTile
  │               │           │   ├─ "Robinet mélangeur"
  │               │           │   ├─ "Qté: 1"
  │               │           │   └─ "60€"
  │               │           ├─ ListTile: ...
  │               │           └─ ...
  │               │)
  │               │
  │               ├─ SectionHeader("Vérification")
  │               │
  │               ├─ Row(
  │               │   ├─ Icon: Check (green)
  │               │   ├─ Expanded: Text: "Les données semblent correctes?"
  │               │   └─ Row: [Non] [Oui]
  │               │)
  │               │
  │               └─ IF verified:
  │                   ├─ SectionHeader("Étape 3: Créer facture")
  │                   │
  │                   ├─ Row(
  │                   │   ├─ Expanded: OutlinedButton("Annuler")
  │                   │   ├─ SizedBox(8)
  │                   │   └─ Expanded: ElevatedButton("Créer facture fournisseur")
  │                   │)
  │                   │
  │                   └─ Text: "Une facture sera créée avec les données extraites"
  │
  │           └─ SizedBox(32)
  │       )
  │   )
```

**FlutterFlow AI Prompt:**
```
Create ScanInvoicePage with:

1. IMAGE CAPTURE SECTION:
   - Large card with Camera icon
   - Two buttons: "📷 Prendre photo" (opens camera) and "📁 Galerie" (opens file picker)
   - Show selected image preview (400x300)
   - "Remove image" button below preview
   - Image stored temporarily in app

2. OCR PROCESSING:
   - "Scan avec OCR" button (disabled if no image)
   - On click: show loading with progress bar (0-100%)
   - Call Supabase Cloud Function: ocr_process_invoice

3. RESULTS DISPLAY:
   - Card showing detected supplier name (editable)
   - Detected amount (editable, currency field)
   - Confidence score as progress bar:
     * Green: > 85% (excellent)
     * Yellow: 65-85% (good)
     * Red: < 65% (poor)
   - List of detected line items with qty and price
   - Each item is editable

4. VERIFICATION SECTION:
   - "Are results correct?" with Yes/No buttons
   - If No: user can manually edit fields
   - If Yes: show "Create supplier invoice" button

5. CREATE BUTTON:
   - "Créer facture fournisseur" button
   - Creates entry in invoices table with parsed data
   - Navigates to InvoiceDetailPage with new invoice

6. Error handling:
   - Show error message if OCR fails (< 40% confidence)
   - Option to manually enter data
   - Save as draft if user wants
```

---

## 🎨 COMPONENT STYLING GUIDE

### Card Styling (Reusable)
```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final Function()? onTap;

  const AppCard({
    required this.child,
    this.padding,
    this.elevation = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
```

### Section Header (Reusable)
```dart
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Function()? onActionPressed;
  final String? actionLabel;

  const SectionHeader({
    required this.title,
    this.subtitle,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          if (actionLabel != null && onActionPressed != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
```

### Empty State (Reusable)
```dart
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonLabel;
  final Function()? onButtonPressed;

  const EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (buttonLabel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onButtonPressed,
              child: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 📐 GRID & SPACING GUIDELINES

### Quote/Invoice Card Grid
- **Mobile**: 1 column (full width)
- **Tablet**: 2 columns (50% width each, 8dp gap)
- **Desktop**: 3 columns (33% width each, 16dp gap)

### Dashboard Stats Cards
- **Mobile**: 2 columns (50% width)
- **Tablet**: 2 columns (50% width)
- **Desktop**: 4 columns (25% width)

### Product Grid
- **Mobile**: 2 columns
- **Tablet**: 3 columns
- **Desktop**: 4 columns

---

## 🎯 INTERACTION PATTERNS

### Long Press Context Menu
```dart
onLongPress: () {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.visibility),
          title: Text('Voir'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Éditer'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: Text('Supprimer'),
          onTap: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
```

### Swipe to Delete
```dart
Dismissible(
  key: Key(quote.id),
  direction: DismissDirection.endToStart,
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 16),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (direction) => _deleteQuote(quote.id),
  child: QuoteCard(quote: quote),
)
```

---

**Ready for Part 2: Cloud Functions & Backend!**
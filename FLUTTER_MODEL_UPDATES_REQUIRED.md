# Flutter Model Updates Required After Schema Migration

**Date:** 2025-11-12
**Related Migration:** `20251112_fix_critical_schema_sync.sql`

After running the database migration, you MUST update your Flutter models to match the new schema.

---

## 1. Product Model (lib/models/product.dart)

### Add Missing Field

Add `userId` field around line 2:

```dart
class Product {
  final String? id;
  final String userId;  // ← ADD THIS
  final String? ref;
  final String name;
  // ... rest of fields
```

### Update Constructor

Add `userId` to required parameters (around line 19):

```dart
Product({
  this.id,
  required this.userId,  // ← ADD THIS
  this.ref,
  required this.name,
  // ... rest of parameters
});
```

### Update toJson()

Add `user_id` to the JSON output (around line 35):

```dart
Map<String, dynamic> toJson() => {
      'user_id': userId,  // ← ADD THIS
      'ref': ref,
      'name': name,
      // ... rest of fields
    };
```

### Update fromJson()

Add `user_id` parsing (around line 50):

```dart
factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'],
    userId: json['user_id'] ?? '',  // ← ADD THIS
    ref: json['ref'],
    name: json['name'] ?? '',
    // ... rest of fields
  );
}
```

### Update copyWith()

Add `userId` parameter (around line 87):

```dart
Product copyWith({
  String? id,
  String? userId,  // ← ADD THIS
  String? ref,
  // ... rest of parameters
}) {
  return Product(
    id: id ?? this.id,
    userId: userId ?? this.userId,  // ← ADD THIS
    ref: ref ?? this.ref,
    // ... rest of fields
  );
}
```

---

## 2. Quote Model (lib/models/quote.dart)

### Add Missing Field

Add `userId` field around line 5:

```dart
class Quote {
  final String? id;
  final String userId;  // ← ADD THIS
  final String quoteNumber;
  final String clientId;
  // ... rest of fields
```

### Update Constructor

Add `userId` (around line 18):

```dart
Quote({
  this.id,
  required this.userId,  // ← ADD THIS
  required this.quoteNumber,
  required this.clientId,
  // ... rest of parameters
});
```

### Update toJson()

Add `user_id` (around line 52):

```dart
Map<String, dynamic> toJson() => {
      'user_id': userId,  // ← ADD THIS
      'quote_number': quoteNumber,
      'client_id': clientId,
      'quote_date': date.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'status': status,
      'subtotal_ht': totalHt,  // ← NOTE: Use subtotal_ht not total_ht
      'total_vat': totalTva,    // ← NOTE: Use total_vat not total_tva
      'total_ttc': totalTtc,
      'notes': notes,
    };
```

### Update fromJson()

Add `user_id` and fix column names (around line 33):

```dart
factory Quote.fromJson(Map<String, dynamic> json) {
  return Quote(
    id: json['id'],
    userId: json['user_id'] ?? '',  // ← ADD THIS
    quoteNumber: json['quote_number'] ?? '',
    clientId: json['client_id'] ?? '',
    date: DateTime.parse(json['quote_date'] ?? DateTime.now().toIso8601String()),
    expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
    status: json['status'] ?? 'draft',
    totalHt: (json['subtotal_ht'] as num?)?.toDouble() ?? 0,  // ← Use subtotal_ht
    totalTva: (json['total_vat'] as num?)?.toDouble() ?? 0,   // ← Use total_vat
    totalTtc: (json['total_ttc'] as num?)?.toDouble() ?? 0,
    items: json['quote_items'] != null
        ? (json['quote_items'] as List).map((i) => LineItem.fromJson(i)).toList()
        : [],
    notes: json['notes'],
    client: json['clients'] != null ? Client.fromJson(json['clients']) : null,
  );
}
```

---

## 3. Invoice Model (lib/models/invoice.dart)

### Add Missing Field

Add `userId` field around line 3:

```dart
class Invoice {
  final String? id;
  final String userId;  // ← ADD THIS
  final String number;
  final String clientId;
  // ... rest of fields
```

### Update Constructor

Add `userId` (around line 25):

```dart
Invoice({
  this.id,
  required this.userId,  // ← ADD THIS
  required this.number,
  required this.clientId,
  // ... rest of parameters
});
```

### Update toJson()

**CRITICAL FIX:** Add `user_id` AND `status` field (around line 73):

```dart
Map<String, dynamic> toJson() => {
      'user_id': userId,  // ← ADD THIS (was missing!)
      'invoice_number': number,
      'client_id': clientId,
      'invoice_date': date.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'status': status,  // ← ADD THIS (was missing!)
      'payment_status': paymentStatus,
      'subtotal_ht': totalHt,  // ← Use subtotal_ht not total_ht
      'total_vat': totalTva,   // ← Use total_vat not total_tva
      'total_ttc': totalTtc,
      'amount_paid': amountPaid,
      'balance_due': balanceDue,
      'notes': notes,
      'payment_method': paymentMethod,
      'is_electronic': isElectronic,
      'xml_url': xmlUrl,
    };
```

### Update fromJson()

Add `user_id` and fix column names (around line 42):

```dart
factory Invoice.fromJson(Map<String, dynamic> json) {
  return Invoice(
    id: json['id'],
    userId: json['user_id'] ?? '',  // ← ADD THIS
    number: json['invoice_number'] ?? json['number'] ?? '',
    clientId: json['client_id'] ?? '',
    date: json['invoice_date'] != null
        ? DateTime.parse(json['invoice_date'])
        : DateTime.now(),
    dueDate: json['due_date'] != null
        ? DateTime.parse(json['due_date'])
        : null,
    status: json['status'] ?? 'draft',
    paymentStatus: json['payment_status'] ?? 'unpaid',
    totalHt: (json['subtotal_ht'] as num?)?.toDouble() ?? 0,  // ← Use subtotal_ht
    totalTva: (json['total_vat'] as num?)?.toDouble() ?? 0,   // ← Use total_vat
    totalTtc: (json['total_ttc'] as num?)?.toDouble() ?? 0,
    amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
    balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0,
    notes: json['notes'],
    paymentMethod: json['payment_method'],
    isElectronic: json['is_electronic'] ?? false,
    xmlUrl: json['xml_url'],
    items: json['invoice_items'] != null
        ? (json['invoice_items'] as List)
            .map((item) => LineItem.fromJson(item))
            .toList()
        : [],
    client: json['clients'] != null ? Client.fromJson(json['clients']) : null,
  );
}
```

---

## 4. Client Model (lib/models/client.dart)

### Fix toJson() Ambiguity

**CRITICAL FIX:** Update toJson() to conditionally write company_name OR last_name (around line 48):

```dart
Map<String, dynamic> toJson() {
  final json = <String, dynamic>{
    'client_type': clientType,
    'salutation': salutation,
    'first_name': firstName,
    'email': email,
    'phone': phone,
    'mobile_phone': mobilePhone,
    'address': address,
    'postal_code': postalCode,
    'city': city,
    'country': country,
    'billing_address': billingAddress,
    'siret': siret,
    'vat_number': vatNumber,
    'default_payment_terms': defaultPaymentTerms,
    'default_discount': defaultDiscount,
    'is_favorite': isFavorite,
    'tags': tags,
    'notes': notes,
  };

  // ← FIX: Conditionally add company_name OR last_name based on type
  if (clientType == 'company') {
    json['company_name'] = name;
    json['last_name'] = null;
  } else {
    json['last_name'] = name;
    json['company_name'] = null;
  }

  return json;
}
```

---

## 5. Payment Model

### Fix payment_method Values

Ensure you're using the correct values that match the CHECK constraint:

```dart
// CORRECT values: 'cash', 'check', 'card', 'transfer', 'other'
// NOT 'bank_transfer' - use 'transfer' instead
```

Update any hardcoded payment method strings in your code:

```dart
// ❌ WRONG
paymentMethod: 'bank_transfer'

// ✅ CORRECT
paymentMethod: 'transfer'
```

---

## 6. Appointment Model (lib/models/appointment.dart)

The appointment model already has all the fields, but ensure:

1. **Date/Time handling:** The model uses `appointment_date` and `appointment_time` separately
2. **All new fields are included** in fromJson/toJson
3. **Check constraints match** - status values: 'scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show'
4. **Priority values** - 'low', 'normal', 'high', 'urgent'

---

## Verification Checklist

After making these changes:

- [ ] Product model includes `userId` field
- [ ] Quote model includes `userId` field
- [ ] Invoice model includes `userId` AND `status` in toJson()
- [ ] All fromJson() use `subtotal_ht` not `total_ht`
- [ ] All fromJson() use `total_vat` not `total_tva`
- [ ] Client toJson() conditionally writes company_name OR last_name
- [ ] Payment methods use 'transfer' not 'bank_transfer'
- [ ] Run `flutter pub run build_runner build` if using code generation
- [ ] Test creating a product from Flutter
- [ ] Test creating a quote from Flutter
- [ ] Test creating an invoice from Flutter
- [ ] Verify no null errors or missing field errors

---

## Testing Commands

After updating models, test with:

```dart
// Test Product
final product = Product(
  userId: 'test-user-id',  // ← Now required
  name: 'Test Product',
  unitPrice: 100.0,
);
final json = product.toJson();
print(json['user_id']); // Should print 'test-user-id'

// Test Quote
final quote = Quote(
  userId: 'test-user-id',  // ← Now required
  quoteNumber: 'Q-001',
  clientId: 'client-id',
  date: DateTime.now(),
);
final json = quote.toJson();
print(json['user_id']); // Should print 'test-user-id'
print(json['subtotal_ht']); // Should use subtotal_ht, not total_ht

// Test Invoice
final invoice = Invoice(
  userId: 'test-user-id',  // ← Now required
  number: 'INV-001',
  clientId: 'client-id',
  date: DateTime.now(),
  status: 'draft',
);
final json = invoice.toJson();
print(json['user_id']); // Should print 'test-user-id'
print(json['status']); // Should print 'draft'
```

---

## Common Errors After Migration

### "null is not a subtype of type String"
**Cause:** Missing `userId` in model
**Fix:** Add `required this.userId` to constructor

### "Column 'user_id' has no value"
**Cause:** Not including `user_id` in toJson()
**Fix:** Add `'user_id': userId` to toJson()

### "Column 'status' has no value" (Invoices)
**Cause:** Missing `status` in Invoice toJson()
**Fix:** Add `'status': status` to Invoice toJson()

### "Column 'total_ht' does not exist"
**Cause:** Using wrong column name
**Fix:** Use `subtotal_ht` in quotes/invoices

### Silent data loss / null values
**Cause:** fromJson() reading different column than toJson() writes
**Fix:** Ensure both use exact same column names

---

## Need Help?

If you encounter errors after these changes:

1. Check the full audit report: `DATABASE_CODEBASE_SYNC_AUDIT.md`
2. Verify migration ran successfully: Run verification queries from migration file
3. Check Supabase logs for specific error messages
4. Test one model at a time to isolate issues

---

**Last Updated:** 2025-11-12
**Status:** Ready for implementation after migration

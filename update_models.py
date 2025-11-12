#!/usr/bin/env python3
"""
Automated Flutter Model Updater
Date: 2025-11-12
Purpose: Automatically update Flutter models to match new database schema
"""

import os
import re
import shutil
from datetime import datetime
from pathlib import Path

# ANSI colors
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

PROJECT_ROOT = Path("/Users/utilisateur/Desktop/plombipro/plombipro-app")
MODELS_DIR = PROJECT_ROOT / "lib" / "models"
BACKUP_DIR = PROJECT_ROOT / f"models_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

def print_header(text):
    """Print a formatted header"""
    print("\n" + "=" * 70)
    print(f"  {text}")
    print("=" * 70 + "\n")

def print_success(text):
    """Print success message"""
    print(f"{GREEN}✅ {text}{NC}")

def print_warning(text):
    """Print warning message"""
    print(f"{YELLOW}⚠️  {text}{NC}")

def print_error(text):
    """Print error message"""
    print(f"{RED}❌ {text}{NC}")

def print_info(text):
    """Print info message"""
    print(f"{BLUE}ℹ️  {text}{NC}")

def create_backup():
    """Create backup of original model files"""
    print_header("Creating Backup")

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    models = ['product.dart', 'quote.dart', 'invoice.dart', 'client.dart', 'payment.dart']
    for model in models:
        src = MODELS_DIR / model
        if src.exists():
            shutil.copy2(src, BACKUP_DIR / model)
            print(f"   Backed up: {model}")

    print_success(f"Backup created at: {BACKUP_DIR}")

def update_product_model():
    """Update Product model with userId field"""
    print_header("Updating Product Model")

    file_path = MODELS_DIR / "product.dart"
    if not file_path.exists():
        print_error("Product model not found")
        return False

    with open(file_path, 'r') as f:
        content = f.read()

    # Add userId field after id
    if 'final String userId;' not in content:
        content = re.sub(
            r'(final String\? id;)',
            r'\1\n  final String userId;',
            content
        )
        print_info("Added userId field")

    # Add userId to constructor
    if 'required this.userId,' not in content:
        content = re.sub(
            r'(Product\(\{[^}]*this\.id,)',
            r'\1\n    required this.userId,',
            content
        )
        print_info("Added userId to constructor")

    # Add user_id to toJson
    if "'user_id': userId" not in content:
        content = re.sub(
            r"(toJson\(\) => \{)",
            r"\1\n      'user_id': userId,",
            content
        )
        print_info("Added user_id to toJson()")

    # Add userId to fromJson
    if "userId: json['user_id']" not in content:
        content = re.sub(
            r"(id: json\['id'\],)",
            r"\1\n      userId: json['user_id'] ?? '',",
            content
        )
        print_info("Added userId to fromJson()")

    # Add userId to copyWith
    if 'String? userId,' not in content and 'copyWith' in content:
        content = re.sub(
            r'(Product copyWith\(\{[^}]*String\? id,)',
            r'\1\n    String? userId,',
            content
        )
        content = re.sub(
            r'(return Product\([^}]*id: id \?\? this\.id,)',
            r'\1\n      userId: userId ?? this.userId,',
            content
        )
        print_info("Added userId to copyWith()")

    with open(file_path, 'w') as f:
        f.write(content)

    print_success("Product model updated")
    return True

def update_quote_model():
    """Update Quote model with userId and fix column names"""
    print_header("Updating Quote Model")

    file_path = MODELS_DIR / "quote.dart"
    if not file_path.exists():
        print_error("Quote model not found")
        return False

    with open(file_path, 'r') as f:
        content = f.read()

    # Add userId field
    if 'final String userId;' not in content:
        content = re.sub(
            r'(final String\? id;)',
            r'\1\n  final String userId;',
            content
        )
        print_info("Added userId field")

    # Add userId to constructor
    if 'required this.userId,' not in content:
        content = re.sub(
            r'(Quote\(\{[^}]*this\.id,)',
            r'\1\n    required this.userId,',
            content
        )
        print_info("Added userId to constructor")

    # Add user_id to toJson and fix column names
    if "'user_id': userId" not in content:
        content = re.sub(
            r"(toJson\(\) => \{)",
            r"\1\n      'user_id': userId,",
            content
        )
        print_info("Added user_id to toJson()")

    # Fix column names in toJson: total_tva -> total_vat
    content = re.sub(r"'total_tva': totalTva", "'total_vat': totalTva", content)
    print_info("Fixed column name: total_tva -> total_vat")

    # Add userId to fromJson
    if "userId: json['user_id']" not in content:
        content = re.sub(
            r"(id: json\['id'\],)",
            r"\1\n      userId: json['user_id'] ?? '',",
            content
        )
        print_info("Added userId to fromJson()")

    # Fix column names in fromJson
    content = re.sub(r"json\['total_tva'\]", "json['total_vat']", content)

    with open(file_path, 'w') as f:
        f.write(content)

    print_success("Quote model updated")
    return True

def update_invoice_model():
    """Update Invoice model with userId, status, and fix column names"""
    print_header("Updating Invoice Model")

    file_path = MODELS_DIR / "invoice.dart"
    if not file_path.exists():
        print_error("Invoice model not found")
        return False

    with open(file_path, 'r') as f:
        content = f.read()

    # Add userId field
    if 'final String userId;' not in content:
        content = re.sub(
            r'(final String\? id;)',
            r'\1\n  final String userId;',
            content
        )
        print_info("Added userId field")

    # Add userId to constructor
    if 'required this.userId,' not in content:
        content = re.sub(
            r'(Invoice\(\{[^}]*this\.id,)',
            r'\1\n    required this.userId,',
            content
        )
        print_info("Added userId to constructor")

    # Add user_id to toJson
    if "'user_id': userId" not in content:
        content = re.sub(
            r"(toJson\(\) => \{)",
            r"\1\n      'user_id': userId,",
            content
        )
        print_info("Added user_id to toJson()")

    # Add status to toJson if missing
    if "'status': status" not in content:
        # Add after payment_status or at appropriate location
        content = re.sub(
            r"('payment_status': paymentStatus,)",
            r"'status': status,\n      \1",
            content
        )
        print_info("Added status to toJson()")

    # Fix column names: total_tva -> total_vat
    content = re.sub(r"'total_tva': totalTva", "'total_vat': totalTva", content)
    content = re.sub(r"json\['total_tva'\]", "json['total_vat']", content)
    print_info("Fixed column names")

    # Add userId to fromJson
    if "userId: json['user_id']" not in content:
        content = re.sub(
            r"(id: json\['id'\],)",
            r"\1\n      userId: json['user_id'] ?? '',",
            content
        )
        print_info("Added userId to fromJson()")

    with open(file_path, 'w') as f:
        f.write(content)

    print_success("Invoice model updated")
    return True

def update_client_model():
    """Update Client model to fix toJson ambiguity"""
    print_header("Updating Client Model")

    file_path = MODELS_DIR / "client.dart"
    if not file_path.exists():
        print_error("Client model not found")
        return False

    with open(file_path, 'r') as f:
        content = f.read()

    # Find and replace the toJson method
    # Look for the pattern where both company_name and last_name are set to name
    pattern = r"(Map<String, dynamic> toJson\(\) \{[^}]*)'company_name': name,[^}]*'last_name': name,"

    if re.search(pattern, content, re.DOTALL):
        # Replace with conditional logic
        replacement = r'''\1// Conditionally add company_name OR last_name based on type
    if (clientType == 'company') {
      json['company_name'] = name;
      json['last_name'] = null;
    } else {
      json['last_name'] = name;
      json['company_name'] = null;
    }

    return json;
  }'''

        # This is complex, needs manual intervention
        print_warning("Client model toJson() needs manual fix")
        print_info("See FLUTTER_MODEL_UPDATES_REQUIRED.md for details")
        return False

    print_info("Client model may already be correct or needs manual review")
    return True

def fix_payment_method_values():
    """Fix payment method values: bank_transfer -> transfer"""
    print_header("Fixing Payment Method Values")

    count = 0
    for dart_file in MODELS_DIR.parent.rglob("*.dart"):
        try:
            with open(dart_file, 'r') as f:
                content = f.read()

            if 'bank_transfer' in content:
                new_content = content.replace("'bank_transfer'", "'transfer'")
                new_content = new_content.replace('"bank_transfer"', '"transfer"')

                with open(dart_file, 'w') as f:
                    f.write(new_content)

                print_info(f"Updated: {dart_file.relative_to(PROJECT_ROOT)}")
                count += 1
        except Exception as e:
            print_error(f"Error processing {dart_file}: {e}")

    if count == 0:
        print_info("No files needed updating")
    else:
        print_success(f"Fixed payment method values in {count} files")

    return True

def verify_updates():
    """Verify that updates were applied correctly"""
    print_header("Verification")

    checks = []

    # Check Product model
    product_path = MODELS_DIR / "product.dart"
    if product_path.exists():
        with open(product_path, 'r') as f:
            content = f.read()
        has_userid = 'final String userId;' in content
        checks.append(("Product has userId field", has_userid))

    # Check Quote model
    quote_path = MODELS_DIR / "quote.dart"
    if quote_path.exists():
        with open(quote_path, 'r') as f:
            content = f.read()
        has_userid = 'final String userId;' in content
        checks.append(("Quote has userId field", has_userid))

    # Check Invoice model
    invoice_path = MODELS_DIR / "invoice.dart"
    if invoice_path.exists():
        with open(invoice_path, 'r') as f:
            content = f.read()
        has_userid = 'final String userId;' in content
        has_status = "'status': status" in content
        checks.append(("Invoice has userId field", has_userid))
        checks.append(("Invoice toJson has status", has_status))

    print()
    for check_name, passed in checks:
        if passed:
            print_success(check_name)
        else:
            print_error(check_name)

    return all(passed for _, passed in checks)

def main():
    """Main execution"""
    print("""
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   🔧 AUTOMATED FLUTTER MODEL UPDATER (Python Edition)            ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
    """)

    # Create backup
    create_backup()

    # Update models
    results = []
    results.append(("Product", update_product_model()))
    results.append(("Quote", update_quote_model()))
    results.append(("Invoice", update_invoice_model()))
    results.append(("Client", update_client_model()))
    results.append(("Payment Methods", fix_payment_method_values()))

    # Verify
    verify_updates()

    # Summary
    print_header("Summary")
    print()
    for model_name, success in results:
        if success:
            print_success(f"{model_name} updated")
        else:
            print_warning(f"{model_name} needs manual attention")

    print()
    print_header("Next Steps")
    print("""
1. Review the changes in your models

2. Manually fix Client model toJson():
   - Open: lib/models/client.dart
   - Replace lines with 'company_name': name and 'last_name': name
   - Add conditional logic (see FLUTTER_MODEL_UPDATES_REQUIRED.md)

3. Run build_runner if using code generation:
   cd /Users/utilisateur/Desktop/plombipro/plombipro-app
   flutter pub run build_runner build --delete-conflicting-outputs

4. Analyze your code:
   flutter analyze

5. Test your changes:
   flutter test

6. Test creating records from Flutter to verify sync
    """)

    print_header("Backup Location")
    print(f"\n   {BACKUP_DIR}\n")
    print("   To restore a model:")
    print(f"   cp {BACKUP_DIR}/product.dart {MODELS_DIR}/")
    print()

    print_success("Automated updates complete!")
    print()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print_error(f"An error occurred: {e}")
        import traceback
        traceback.print_exc()

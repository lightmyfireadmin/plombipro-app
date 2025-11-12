#!/usr/bin/env python3
"""
Idempotent Flutter Model Updater
Date: 2025-11-12
Purpose: Safely update Flutter models (can be run multiple times)
"""

import os
import re
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

def print_info(text):
    """Print info message"""
    print(f"{BLUE}ℹ️  {text}{NC}")

def print_skip(text):
    """Print skip message"""
    print(f"{BLUE}⏭️  {text}{NC}")

def create_backup():
    """Create backup of original model files"""
    print_header("Creating Backup")

    # Only create backup if we're actually making changes
    models = ['product.dart', 'quote.dart', 'invoice.dart', 'client.dart', 'payment.dart']
    needs_backup = False

    for model in models:
        src = MODELS_DIR / model
        if src.exists():
            with open(src, 'r') as f:
                content = f.read()
            # Check if any changes would be made
            if ('userId' not in content and model in ['product.dart', 'quote.dart', 'invoice.dart']) or \
               ('bank_transfer' in content):
                needs_backup = True
                break

    if not needs_backup:
        print_skip("No changes needed, skipping backup")
        return False

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    for model in models:
        src = MODELS_DIR / model
        if src.exists():
            import shutil
            shutil.copy2(src, BACKUP_DIR / model)
            print(f"   Backed up: {model}")

    print_success(f"Backup created at: {BACKUP_DIR}")
    return True

def update_product_model():
    """Update Product model with userId field (idempotent)"""
    print_header("Updating Product Model")

    file_path = MODELS_DIR / "product.dart"
    if not file_path.exists():
        print_warning("Product model not found")
        return False

    with open(file_path, 'r') as f:
        content = f.read()

    original_content = content
    changes_made = []

    # Add userId field after id (only if not present)
    if 'final String userId;' not in content:
        content = re.sub(
            r'(final String\? id;)',
            r'\1\n  final String userId;',
            content,
            count=1
        )
        changes_made.append("Added userId field")
    else:
        print_skip("userId field already exists")

    # Add userId to constructor (only if not present)
    if 'required this.userId,' not in content:
        content = re.sub(
            r'(Product\(\{[^}]*this\.id,)',
            r'\1\n    required this.userId,',
            content,
            count=1
        )
        changes_made.append("Added userId to constructor")
    else:
        print_skip("userId in constructor already exists")

    # Add user_id to toJson (only if not present)
    if "'user_id': userId" not in content:
        content = re.sub(
            r"(toJson\(\) => \{)",
            r"\1\n      'user_id': userId,",
            content,
            count=1
        )
        changes_made.append("Added user_id to toJson()")
    else:
        print_skip("user_id in toJson() already exists")

    # Add userId to fromJson (only if not present)
    if "userId: json['user_id']" not in content:
        content = re.sub(
            r"(id: json\['id'\],)",
            r"\1\n      userId: json['user_id'] ?? '',",
            content,
            count=1
        )
        changes_made.append("Added userId to fromJson()")
    else:
        print_skip("userId in fromJson() already exists")

    # Add userId to copyWith (only if not present)
    if 'copyWith' in content and 'String? userId,' not in content:
        content = re.sub(
            r'(Product copyWith\(\{[^}]*String\? id,)',
            r'\1\n    String? userId,',
            content,
            count=1
        )
        content = re.sub(
            r'(return Product\([^}]*id: id \?\? this\.id,)',
            r'\1\n      userId: userId ?? this.userId,',
            content,
            count=1
        )
        changes_made.append("Added userId to copyWith()")
    elif 'copyWith' not in content:
        print_skip("No copyWith method found")
    else:
        print_skip("userId in copyWith() already exists")

    # Only write if changes were made
    if content != original_content:
        with open(file_path, 'w') as f:
            f.write(content)
        for change in changes_made:
            print_info(change)
        print_success("Product model updated")
        return True
    else:
        print_skip("Product model already up to date")
        return False

def update_quote_model():
    """Update Quote model with userId and fix column names (idempotent)"""
    print_header("Updating Quote Model")

    file_path = MODELS_DIR / "quote.dart"
    if not file_path.exists():
        print_warning("Quote model not found")
        return False

    with open(file_path, 'r') as f:
        content = f.read()

    original_content = content
    changes_made = []

    # Add userId field
    if 'final String userId;' not in content:
        content = re.sub(
            r'(final String\? id;)',
            r'\1\n  final String userId;',
            content,
            count=1
        )
        changes_made.append("Added userId field")
    else:
        print_skip("userId field already exists")

    # Add userId to constructor
    if 'required this.userId,' not in content:
        content = re.sub(
            r'(Quote\(\{[^}]*this\.id,)',
            r'\1\n    required this.userId,',
            content,
            count=1
        )
        changes_made.append("Added userId to constructor")
    else:
        print_skip("userId in constructor already exists")

    # Add user_id to toJson
    if "'user_id': userId" not in content:
        content = re.sub(
            r"(toJson\(\) => \{)",
            r"\1\n      'user_id': userId,",
            content,
            count=1
        )
        changes_made.append("Added user_id to toJson()")
    else:
        print_skip("user_id in toJson() already exists")

    # Fix column names in toJson: total_tva -> total_vat
    if "'total_tva': totalTva" in content:
        content = re.sub(r"'total_tva': totalTva", "'total_vat': totalTva", content)
        changes_made.append("Fixed column name: total_tva -> total_vat")
    else:
        print_skip("Column names already correct in toJson()")

    # Add userId to fromJson
    if "userId: json['user_id']" not in content:
        content = re.sub(
            r"(id: json\['id'\],)",
            r"\1\n      userId: json['user_id'] ?? '',",
            content,
            count=1
        )
        changes_made.append("Added userId to fromJson()")
    else:
        print_skip("userId in fromJson() already exists")

    # Fix column names in fromJson
    if "json['total_tva']" in content:
        content = re.sub(r"json\['total_tva'\]", "json['total_vat']", content)
        changes_made.append("Fixed column name in fromJson(): total_tva -> total_vat")
    else:
        print_skip("Column names already correct in fromJson()")

    if content != original_content:
        with open(file_path, 'w') as f:
            f.write(content)
        for change in changes_made:
            print_info(change)
        print_success("Quote model updated")
        return True
    else:
        print_skip("Quote model already up to date")
        return False

def update_invoice_model():
    """Update Invoice model with userId, status, and fix column names (idempotent)"""
    print_header("Updating Invoice Model")

    file_path = MODELS_DIR / "invoice.dart"
    if not file_path.exists():
        print_warning("Invoice model not found")
        return False

    with open(file_path, 'r') as f:
        content = f.read()

    original_content = content
    changes_made = []

    # Add userId field
    if 'final String userId;' not in content:
        content = re.sub(
            r'(final String\? id;)',
            r'\1\n  final String userId;',
            content,
            count=1
        )
        changes_made.append("Added userId field")
    else:
        print_skip("userId field already exists")

    # Add userId to constructor
    if 'required this.userId,' not in content:
        content = re.sub(
            r'(Invoice\(\{[^}]*this\.id,)',
            r'\1\n    required this.userId,',
            content,
            count=1
        )
        changes_made.append("Added userId to constructor")
    else:
        print_skip("userId in constructor already exists")

    # Add user_id to toJson
    if "'user_id': userId" not in content:
        content = re.sub(
            r"(toJson\(\) => \{)",
            r"\1\n      'user_id': userId,",
            content,
            count=1
        )
        changes_made.append("Added user_id to toJson()")
    else:
        print_skip("user_id in toJson() already exists")

    # Add status to toJson if missing
    if "'status': status" not in content:
        # Try to add after payment_status or at appropriate location
        if "'payment_status': paymentStatus," in content:
            content = re.sub(
                r"('payment_status': paymentStatus,)",
                r"'status': status,\n      \1",
                content,
                count=1
            )
            changes_made.append("Added status to toJson()")
        else:
            print_warning("Could not find appropriate location for status in toJson()")
    else:
        print_skip("status in toJson() already exists")

    # Fix column names: total_tva -> total_vat
    if "'total_tva': totalTva" in content:
        content = re.sub(r"'total_tva': totalTva", "'total_vat': totalTva", content)
        changes_made.append("Fixed column names in toJson()")
    else:
        print_skip("Column names already correct in toJson()")

    if "json['total_tva']" in content:
        content = re.sub(r"json\['total_tva'\]", "json['total_vat']", content)
        changes_made.append("Fixed column names in fromJson()")
    else:
        print_skip("Column names already correct in fromJson()")

    # Add userId to fromJson
    if "userId: json['user_id']" not in content:
        content = re.sub(
            r"(id: json\['id'\],)",
            r"\1\n      userId: json['user_id'] ?? '',",
            content,
            count=1
        )
        changes_made.append("Added userId to fromJson()")
    else:
        print_skip("userId in fromJson() already exists")

    if content != original_content:
        with open(file_path, 'w') as f:
            f.write(content)
        for change in changes_made:
            print_info(change)
        print_success("Invoice model updated")
        return True
    else:
        print_skip("Invoice model already up to date")
        return False

def check_client_model():
    """Check Client model toJson() (idempotent check)"""
    print_header("Checking Client Model")

    file_path = MODELS_DIR / "client.dart"
    if not file_path.exists():
        print_warning("Client model not found")
        return False

    with open(file_path, 'r') as f:
        content = f.read()

    # Check if conditional logic exists
    if "if (clientType == 'company')" in content and "json['company_name'] = name" in content:
        print_skip("Client model toJson() already has conditional logic")
        return True
    elif "'company_name': name" in content and "'last_name': name" in content:
        print_warning("Client model toJson() still needs manual fix")
        print_info("See FLUTTER_MODEL_UPDATES_REQUIRED.md for details")
        return False
    else:
        print_skip("Client model appears to be correctly configured")
        return True

def fix_payment_method_values():
    """Fix payment method values: bank_transfer -> transfer (idempotent)"""
    print_header("Fixing Payment Method Values")

    count = 0
    for dart_file in MODELS_DIR.parent.rglob("*.dart"):
        try:
            with open(dart_file, 'r') as f:
                content = f.read()

            if 'bank_transfer' in content:
                new_content = content.replace("'bank_transfer'", "'transfer'")
                new_content = new_content.replace('"bank_transfer"', '"transfer"')

                # Only write if changes were made
                if new_content != content:
                    with open(dart_file, 'w') as f:
                        f.write(new_content)
                    print_info(f"Updated: {dart_file.relative_to(PROJECT_ROOT)}")
                    count += 1
        except Exception as e:
            print_warning(f"Error processing {dart_file}: {e}")

    if count == 0:
        print_skip("No files needed updating (all already using 'transfer')")
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

    # Check Client model
    client_path = MODELS_DIR / "client.dart"
    if client_path.exists():
        with open(client_path, 'r') as f:
            content = f.read()
        has_conditional = "if (clientType == 'company')" in content
        checks.append(("Client has conditional toJson logic", has_conditional))

    print()
    for check_name, passed in checks:
        if passed:
            print_success(check_name)
        else:
            print_warning(f"{check_name} - NOT FOUND")

    return all(passed for _, passed in checks)

def main():
    """Main execution"""
    print("""
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   🔧 IDEMPOTENT FLUTTER MODEL UPDATER (Python Edition)           ║
║   Can be run multiple times safely                               ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
    """)

    # Create backup only if changes are needed
    backup_created = create_backup()

    # Update models
    results = []
    results.append(("Product", update_product_model()))
    results.append(("Quote", update_quote_model()))
    results.append(("Invoice", update_invoice_model()))
    results.append(("Client", check_client_model()))
    results.append(("Payment Methods", fix_payment_method_values()))

    # Verify
    all_good = verify_updates()

    # Summary
    print_header("Summary")
    print()

    any_changes = any(success for _, success in results)

    if not any_changes:
        print_success("All models already up to date - no changes needed!")
    else:
        for model_name, success in results:
            if success:
                print_success(f"{model_name} updated")
            else:
                print_warning(f"{model_name} needs attention")

    print()
    if backup_created:
        print_header("Backup Location")
        print(f"\n   {BACKUP_DIR}\n")
        print("   To restore a model:")
        print(f"   cp {BACKUP_DIR}/product.dart {MODELS_DIR}/")
        print()
    else:
        print_info("No backup created (no changes were needed)")

    if all_good:
        print_success("All models are correctly synchronized!")
    else:
        print_header("Next Steps")
        print("""
1. Review any warnings above
2. Run flutter analyze to verify syntax
3. Test your changes
        """)

    print()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"{RED}❌ An error occurred: {e}{NC}")
        import traceback
        traceback.print_exc()

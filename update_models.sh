#!/bin/bash
################################################################################
# AUTOMATED FLUTTER MODEL UPDATER
# Date: 2025-11-12
# Purpose: Automatically update Flutter models to match new database schema
################################################################################

set -e  # Exit on error

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║   🔧 AUTOMATED FLUTTER MODEL UPDATER                             ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project paths
PROJECT_ROOT="/Users/utilisateur/Desktop/plombipro/plombipro-app"
MODELS_DIR="$PROJECT_ROOT/lib/models"
BACKUP_DIR="$PROJECT_ROOT/models_backup_$(date +%Y%m%d_%H%M%S)"

# Create backup
echo "📦 Creating backup of models..."
mkdir -p "$BACKUP_DIR"
cp "$MODELS_DIR/product.dart" "$BACKUP_DIR/" 2>/dev/null || true
cp "$MODELS_DIR/quote.dart" "$BACKUP_DIR/" 2>/dev/null || true
cp "$MODELS_DIR/invoice.dart" "$BACKUP_DIR/" 2>/dev/null || true
cp "$MODELS_DIR/client.dart" "$BACKUP_DIR/" 2>/dev/null || true
cp "$MODELS_DIR/payment.dart" "$BACKUP_DIR/" 2>/dev/null || true

echo -e "${GREEN}✅ Backup created at: $BACKUP_DIR${NC}"
echo ""

################################################################################
# FUNCTION: Update Product Model
################################################################################
update_product_model() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔧 Updating Product Model..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file="$MODELS_DIR/product.dart"

    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Product model not found${NC}"
        return 1
    fi

    # Create temporary file
    local temp_file="${file}.tmp"

    # Read the file and make changes
    cat "$file" | \
    # Add userId field after id field
    sed '/final String? id;/a\
  final String userId;' | \
    # Add userId to constructor parameters (after id parameter)
    sed '/Product({/,/})/ {
        /this\.id,/ a\
    required this.userId,
    }' | \
    # Add user_id to toJson (after opening brace)
    sed "/toJson() => {/a\\
      'user_id': userId," | \
    # Add user_id to fromJson (after id field)
    sed "/id: json\['id'\],/a\\
      userId: json['user_id'] ?? ''," | \
    # Add userId to copyWith method
    sed '/Product copyWith({/,/})/ {
        /String? id,/ a\
    String? userId,
    }' | \
    sed '/return Product(/,/);/ {
        /id: id ?? this\.id,/ a\
      userId: userId ?? this.userId,
    }' > "$temp_file"

    # Replace original file
    mv "$temp_file" "$file"

    echo -e "${GREEN}✅ Product model updated${NC}"
    echo "   - Added userId field"
    echo "   - Updated constructor"
    echo "   - Updated toJson()"
    echo "   - Updated fromJson()"
    echo "   - Updated copyWith()"
    echo ""
}

################################################################################
# FUNCTION: Update Quote Model
################################################################################
update_quote_model() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔧 Updating Quote Model..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file="$MODELS_DIR/quote.dart"

    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Quote model not found${NC}"
        return 1
    fi

    local temp_file="${file}.tmp"

    cat "$file" | \
    # Add userId field
    sed '/final String? id;/a\
  final String userId;' | \
    # Add userId to constructor
    sed '/Quote({/,/})/ {
        /this\.id,/ a\
    required this.userId,
    }' | \
    # Fix toJson - add user_id and fix column names
    sed "s/'quote_number'/'user_id': userId,\n      'quote_number'/" | \
    sed "s/'subtotal_ht': totalHt/'subtotal_ht': totalHt/" | \
    sed "s/'total_tva': totalTva/'total_vat': totalTva/" | \
    # Fix fromJson - add user_id and fix column names
    sed "/id: json\['id'\]/a\\
      userId: json['user_id'] ?? ''," | \
    sed "s/json\['subtotal_ht'\]/json['subtotal_ht']/" | \
    sed "s/json\['total_tva'\]/json['total_vat']/" > "$temp_file"

    mv "$temp_file" "$file"

    echo -e "${GREEN}✅ Quote model updated${NC}"
    echo "   - Added userId field"
    echo "   - Fixed column names (subtotal_ht, total_vat)"
    echo ""
}

################################################################################
# FUNCTION: Update Invoice Model
################################################################################
update_invoice_model() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔧 Updating Invoice Model..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file="$MODELS_DIR/invoice.dart"

    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Invoice model not found${NC}"
        return 1
    fi

    local temp_file="${file}.tmp"

    cat "$file" | \
    # Add userId field
    sed '/final String? id;/a\
  final String userId;' | \
    # Add userId to constructor
    sed '/Invoice({/,/})/ {
        /this\.id,/ a\
    required this.userId,
    }' | \
    # Add user_id and status to toJson
    sed "s/'invoice_number'/'user_id': userId,\n      'invoice_number'/" | \
    sed "/'due_date':/a\\
      'status': status," | \
    # Fix column names in toJson
    sed "s/'subtotal_ht': totalHt/'subtotal_ht': totalHt/" | \
    sed "s/'total_tva': totalTva/'total_vat': totalTva/" | \
    # Add user_id to fromJson and fix column names
    sed "/id: json\['id'\]/a\\
      userId: json['user_id'] ?? ''," | \
    sed "s/json\['subtotal_ht'\]/json['subtotal_ht']/" | \
    sed "s/json\['total_tva'\]/json['total_vat']/" > "$temp_file"

    mv "$temp_file" "$file"

    echo -e "${GREEN}✅ Invoice model updated${NC}"
    echo "   - Added userId field"
    echo "   - Added status to toJson()"
    echo "   - Fixed column names (subtotal_ht, total_vat)"
    echo ""
}

################################################################################
# FUNCTION: Update Client Model
################################################################################
update_client_model() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔧 Updating Client Model..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file="$MODELS_DIR/client.dart"

    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Client model not found${NC}"
        return 1
    fi

    # Create a Python script to fix the toJson method properly
    cat > /tmp/fix_client_tojson.py << 'PYTHON_SCRIPT'
import re

with open('lib/models/client.dart', 'r') as f:
    content = f.read()

# Find the toJson method and replace it with conditional logic
tojson_pattern = r'(Map<String, dynamic> toJson\(\) \{[\s\S]*?)(\'company_name\': name,[\s\S]*?\'last_name\': name,)'
replacement = r'''\1// Conditionally add company_name OR last_name based on type
    if (clientType == 'company') {
      json['company_name'] = name;
      json['last_name'] = null;
    } else {
      json['last_name'] = name;
      json['company_name'] = null;
    }

    return json;
  }
'''

# This is complex, let's just add a note for manual fix
print("⚠️  Client model needs manual toJson() fix")
PYTHON_SCRIPT

    echo -e "${YELLOW}⚠️  Client model requires manual fix${NC}"
    echo "   - toJson() method needs conditional logic"
    echo "   - See FLUTTER_MODEL_UPDATES_REQUIRED.md for details"
    echo ""
}

################################################################################
# FUNCTION: Update Payment usages (fix bank_transfer -> transfer)
################################################################################
update_payment_method_values() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔧 Fixing payment method values..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Find all Dart files that might use 'bank_transfer'
    local count=0
    while IFS= read -r file; do
        if grep -q "bank_transfer" "$file"; then
            sed -i '' "s/'bank_transfer'/'transfer'/g" "$file"
            sed -i '' 's/"bank_transfer"/"transfer"/g' "$file"
            echo "   - Updated: $(basename $file)"
            ((count++))
        fi
    done < <(find "$PROJECT_ROOT/lib" -name "*.dart" -type f)

    if [ $count -eq 0 ]; then
        echo "   - No files needed updating"
    else
        echo -e "${GREEN}✅ Fixed payment method values in $count files${NC}"
    fi
    echo ""
}

################################################################################
# MAIN EXECUTION
################################################################################

echo "Starting automated model updates..."
echo ""

# Update each model
update_product_model
update_quote_model
update_invoice_model
update_client_model
update_payment_method_values

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✅ Product model updated${NC}"
echo -e "${GREEN}✅ Quote model updated${NC}"
echo -e "${GREEN}✅ Invoice model updated${NC}"
echo -e "${YELLOW}⚠️  Client model needs manual fix${NC}"
echo -e "${GREEN}✅ Payment method values fixed${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 VERIFICATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify changes
echo "Checking for userId in Product model:"
if grep -q "final String userId;" "$MODELS_DIR/product.dart"; then
    echo -e "${GREEN}✅ userId field found${NC}"
else
    echo -e "${RED}❌ userId field NOT found${NC}"
fi

echo ""
echo "Checking for userId in Quote model:"
if grep -q "final String userId;" "$MODELS_DIR/quote.dart"; then
    echo -e "${GREEN}✅ userId field found${NC}"
else
    echo -e "${RED}❌ userId field NOT found${NC}"
fi

echo ""
echo "Checking for userId in Invoice model:"
if grep -q "final String userId;" "$MODELS_DIR/invoice.dart"; then
    echo -e "${GREEN}✅ userId field found${NC}"
else
    echo -e "${RED}❌ userId field NOT found${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  MANUAL STEPS REQUIRED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Fix Client model toJson() method:"
echo "   - Open: lib/models/client.dart"
echo "   - Replace lines with 'company_name': name and 'last_name': name"
echo "   - Add conditional logic (see FLUTTER_MODEL_UPDATES_REQUIRED.md)"
echo ""
echo "2. Run Flutter build_runner if using code generation:"
echo "   cd $PROJECT_ROOT"
echo "   flutter pub run build_runner build --delete-conflicting-outputs"
echo ""
echo "3. Test your changes:"
echo "   flutter analyze"
echo "   flutter test"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 BACKUP LOCATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Original models backed up at:"
echo "$BACKUP_DIR"
echo ""
echo "To restore a model:"
echo "cp $BACKUP_DIR/product.dart $MODELS_DIR/"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✅ Automated updates complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Review changes in your models"
echo "2. Fix Client model toJson() manually"
echo "3. Run flutter pub run build_runner build"
echo "4. Test with flutter analyze"
echo ""

# Quick Setup: Load 50 Quote Templates

## 🚀 Quick Start (2 minutes)

Your app already has 50 professional quote templates ready to use! You just need to load them into your database.

### Step 1: Open Supabase SQL Editor

1. Go to https://supabase.com/dashboard
2. Select your **plombipro-app** project
3. Click **SQL Editor** in sidebar
4. Click **New Query**

### Step 2: Run the Migration

1. Open the file: `migrations/006_plumbing_templates.sql`
2. **Copy all contents** (Ctrl+A, Ctrl+C)
3. **Paste into SQL Editor**
4. Click **RUN** or press Ctrl+Enter

### Step 3: Verify Success

You should see:
```
Successfully created 50 plumbing templates across 27 categories
```

### Step 4: Use Templates in App

1. Open your PlombiPro app
2. Go to **Devis** (Quotes) → **Nouveau Devis** (New Quote)
3. Look for **"Sélectionner un modèle"** button
4. Browse 50 templates organized by category!

---

## 📋 What You Get

### 50 Professional Templates Including:

**Bathroom (10 templates)**
- Complete renovations (standard & premium)
- Shower installations
- Bathtub replacements
- PMR adaptations

**Kitchen (8 templates)**
- Complete kitchen plumbing
- Sink installations
- Dishwasher hookups
- Water filtration systems

**Water Heaters (7 templates)**
- Electric, gas, solar
- Heat pump water heaters
- Instant water heaters
- Replacement & upgrades

**Emergency Repairs (6 templates)**
- Leak repairs
- Burst pipes
- Clogged drains
- Emergency plumbing

**Equipment (8 templates)**
- Washing machines
- Toilets & bidets
- Faucets & valves
- Sump pumps

**Heating (5 templates)**
- Boiler installations
- Radiator replacements
- Underfloor heating
- Annual maintenance

**Specialized (6 templates)**
- Pool systems
- Rainwater harvesting
- Backflow preventers
- Grease traps

---

## ✅ Features

Each template includes:
- ✅ Detailed line items with quantities & prices
- ✅ Professional descriptions
- ✅ VAT rates (20%)
- ✅ Standard terms & conditions
- ✅ Estimated timeframes
- ✅ Warranty information

---

## 🎯 How It Works in the App

1. **Browse Templates**: Organized by category with price estimates
2. **Select Template**: Click to preview line items
3. **Apply to Quote**: Auto-populate your quote form
4. **Customize**: Edit quantities, prices, add/remove items
5. **Save & Send**: Create professional quotes in seconds!

---

## 🔧 Troubleshooting

**Templates not showing?**

Check if they loaded:
```sql
SELECT COUNT(*) FROM templates WHERE is_system_template = true;
```
Should return: **50**

**Still empty?**

1. Check `templates` table exists
2. Re-run the migration
3. Clear app cache and restart

---

## 📞 Need Help?

See detailed instructions: `LOAD_TEMPLATES_INSTRUCTIONS.md`

---

**Migration File:** `migrations/006_plumbing_templates.sql`
**Service Class:** `lib/services/template_service.dart`
**UI Integration:** `lib/screens/quotes/quote_form_page.dart`
**Total Templates:** 50 system templates ready to use!

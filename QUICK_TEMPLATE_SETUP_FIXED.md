# ⚡ Quick Fix: Load 50 Quote Templates (2 Minutes)

> **🔴 IMPORTANT:** Use this FIXED migration, not the old one!

## 🐛 The Bug
Original migration had an RLS policy bug that made system templates invisible.

## ✅ The Fix
New migration fixes RLS policies so system templates are visible to all users.

---

## 🚀 3-Step Setup

### Step 1: Open Supabase SQL Editor
1. https://supabase.com/dashboard
2. Select **plombipro-app** project
3. Click **SQL Editor** → **New Query**

### Step 2: Run Fixed Migration
1. Open: **`migrations/COMPLETE_TEMPLATES_MIGRATION_FIXED.sql`**
2. Copy **ALL 1,460 lines**
3. Paste into SQL Editor
4. Click **RUN**

### Step 3: Test in App
1. Restart PlombiPro app
2. **Devis** → **Nouveau Devis**
3. Click **"Sélectionner un modèle"**
4. **See 50 templates!** 🎉

---

## 📊 What You Get

### 50 Professional Templates

| Category | Count | Examples |
|----------|-------|----------|
| 🛁 Rénovation Salle de Bain | 10 | Complete renovations, shower installs, PMR |
| 🍽️ Plomberie Cuisine | 8 | Kitchen plumbing, sink, dishwasher |
| 🔥 Chauffe-eau | 7 | Electric, gas, solar, heat pump |
| 🚨 Dépannage Urgence | 6 | Leaks, burst pipes, emergency repairs |
| 🔧 Installation Équipements | 8 | Toilets, faucets, washing machines |
| 🏠 Chauffage | 5 | Boilers, radiators, heating systems |
| 🌊 Équipements Spéciaux | 6 | Pools, rainwater, backflow preventers |

**Total:** 50 ready-to-use templates

---

## ✅ Success Indicators

After running migration, you should see:

```
✅ MIGRATION COMPLETE
✅ Successfully created 50 system templates
✅ System templates are visible (RLS configured correctly)
✅ Templates table: CREATED
✅ RLS policies: CONFIGURED
✅ System templates: LOADED (50 templates)
✅ Indexes: CREATED

📋 Template Categories:
   • Chauffage: 5 templates
   • Chauffe-eau: 7 templates
   • Dépannage Urgence: 6 templates
   • Équipements Spéciaux: 6 templates
   • Installation Équipements: 8 templates
   • Plomberie Cuisine: 8 templates
   • Rénovation Salle de Bain: 10 templates
```

---

## 🎯 Each Template Includes

- ✅ Professional line items with descriptions
- ✅ Realistic quantities & prices
- ✅ Correct VAT rates (20%)
- ✅ Units (forfait, unité, mètre, etc.)
- ✅ Terms & conditions
- ✅ Warranty information
- ✅ Estimated timeframes

---

## 💡 How It Works

1. **Browse Templates** - Organized by category
2. **Preview Details** - See all line items & pricing
3. **Apply to Quote** - Auto-populate form
4. **Customize** - Edit prices, quantities, add/remove items
5. **Save & Send** - Professional quote in seconds!

---

## 🔍 Verify Installation

Run in Supabase SQL Editor:

```sql
-- Count templates
SELECT COUNT(*) FROM public.templates
WHERE is_system_template = true;
-- Expected: 50

-- List categories
SELECT category, COUNT(*) as count
FROM public.templates
WHERE is_system_template = true
GROUP BY category
ORDER BY category;

-- Check RLS
SELECT * FROM pg_policies
WHERE tablename = 'templates';
-- Expected: 4 policies (select, insert, update, delete)
```

---

## ❌ Troubleshooting

### Templates still not showing?

**1. Clear template count:**
```sql
SELECT COUNT(*) FROM public.templates WHERE is_system_template = true;
```
If returns 0, the migration didn't complete.

**2. Check for errors:**
Look for red error messages in SQL Editor output.

**3. Clear app cache:**
- Force quit app
- Clear app data (Android)
- Restart app

**4. Check app logs:**
```dart
final templates = await TemplateService.getTemplatesList();
print('Templates: ${templates.length}'); // Should print 50
```

### Error: "relation 'templates' does not exist"
The fixed migration creates the table. This shouldn't happen.

### Error: "policy already exists"
The fixed migration drops existing policies first. If this happens, run:
```sql
DROP POLICY IF EXISTS "templates_select_policy" ON public.templates;
```
Then re-run the full migration.

---

## 📁 Which File to Use?

✅ **USE THIS:** `migrations/COMPLETE_TEMPLATES_MIGRATION_FIXED.sql` (1,460 lines)
- Has RLS policy fix
- Creates table + indexes
- Loads all 50 templates
- Includes verification

❌ **DON'T USE:** `migrations/006_plumbing_templates.sql`
- Missing RLS policy fix
- Templates won't be visible
- Requires manual fixes

---

## 📖 More Information

- **Detailed explanation:** `FIX_TEMPLATES_ISSUE.md`
- **Technical details:** See the migration file comments
- **App integration:** `lib/services/template_service.dart`
- **UI component:** `lib/screens/quotes/quote_form_page.dart`

---

## ✨ After Setup

Your workflow becomes:
1. Client requests quote
2. Select matching template
3. Customize if needed
4. Send professional quote
5. **Save hours per week!**

---

**Migration File:** `migrations/COMPLETE_TEMPLATES_MIGRATION_FIXED.sql`
**Total Templates:** 50 professional plumbing templates
**Setup Time:** 2 minutes
**Time Saved:** Hours per week ⏰

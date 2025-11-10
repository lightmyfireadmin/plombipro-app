# Load Quote Templates into Database

## Problem
The app has 50 pre-built quote templates, but they're not showing up because they haven't been loaded into your Supabase database yet.

## Solution

You have **2 options** to load the templates:

---

### Option 1: Via Supabase SQL Editor (RECOMMENDED)

1. **Open Supabase Dashboard**
   - Go to https://supabase.com/dashboard
   - Select your `plombipro-app` project

2. **Open SQL Editor**
   - Click on "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Load the Migration File**
   - Copy the entire contents of `migrations/006_plumbing_templates.sql`
   - Paste it into the SQL editor
   - Click "Run" or press Ctrl+Enter

4. **Verify**
   ```sql
   SELECT COUNT(*) FROM templates WHERE is_system_template = true;
   ```
   - Should return 50

---

### Option 2: Via psql Command Line

If you have `psql` installed and your database connection string:

```bash
# From the project root
psql "your-supabase-connection-string" < migrations/006_plumbing_templates.sql
```

**Get your connection string from:**
- Supabase Dashboard → Settings → Database → Connection String
- Use the "Session pooler" connection string
- Replace `[YOUR-PASSWORD]` with your database password

---

## After Loading Templates

1. **Restart your app** (if running)
2. **Navigate to** the quote creation screen
3. **You should now see** 50 templates organized by category:
   - Rénovation Salle de Bain (10 templates)
   - Plomberie Cuisine (8 templates)
   - Chauffe-eau (7 templates)
   - Dépannage Urgence (6 templates)
   - Installation Équipements (8 templates)
   - Chauffage (5 templates)
   - Autres Travaux (6 templates)

---

## Template Categories

The 50 templates cover:

- ✅ Bathroom renovations (complete, partial, PMR adaptation)
- ✅ Kitchen plumbing (sink, dishwasher, filtration)
- ✅ Water heaters (electric, gas, solar, heat pump)
- ✅ Emergency repairs (leaks, burst pipes, clogs)
- ✅ Appliance installations (washing machine, toilet, faucet)
- ✅ Heating systems (boiler, radiator, underfloor heating)
- ✅ Specialized work (pool, rainwater, septic, backflow)

---

## Troubleshooting

### "Templates not showing after running migration"

1. **Check if templates were inserted:**
   ```sql
   SELECT template_name, category, is_system_template
   FROM templates
   WHERE is_system_template = true
   ORDER BY category, template_name;
   ```

2. **Check for errors in migration:**
   - Look for SQL error messages
   - Verify the `templates` table exists
   - Check that `gen_random_uuid()` function is available

3. **Clear app cache:**
   - Force quit the app
   - Clear app data (Android) or reinstall (iOS)
   - Restart the app

### "Error: relation 'templates' does not exist"

Run the main schema migration first:
```bash
psql "your-connection-string" < supabase_schema.sql
```

Then run the templates migration.

---

## Verifying Templates Work

1. Open the app
2. Go to **Quotes** → **New Quote**
3. Look for "Use Template" or "Templates" button
4. You should see a categorized list of 50 templates
5. Select one to auto-populate line items

---

**Last Updated:** January 2025
**Migration File:** `migrations/006_plumbing_templates.sql`
**Templates Count:** 50 system templates

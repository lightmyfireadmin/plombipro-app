# 🔧 Fix: Templates Not Showing (RLS Policy Issue)

## 🚨 The Problem

Your 50 quote templates exist but aren't visible in the app because of **Row Level Security (RLS) policy misconfiguration**.

### Root Cause
- System templates have `user_id = NULL` (they're shared across all users)
- Original RLS policy: `auth.uid() = user_id`
- This policy **never matches** for NULL user_id
- Result: **System templates are invisible to all users**

## ✅ The Solution

Run the **comprehensive migration** that:
1. ✅ Creates the templates table (if it doesn't exist)
2. ✅ **Fixes RLS policies** to allow seeing system templates
3. ✅ Loads all 50 system templates
4. ✅ Adds performance indexes
5. ✅ Includes verification checks

## 🚀 How to Fix (2 minutes)

### Step 1: Open Supabase SQL Editor
1. Go to https://supabase.com/dashboard
2. Select your **plombipro-app** project
3. Click **SQL Editor** in the sidebar
4. Click **New Query**

### Step 2: Run the Fixed Migration
1. Open: `migrations/COMPLETE_TEMPLATES_MIGRATION_FIXED.sql`
2. **Copy ALL contents** (1,460 lines)
3. **Paste into SQL Editor**
4. Click **RUN** or press Ctrl+Enter
5. Wait for completion (~5-10 seconds)

### Step 3: Verify Success
You should see output like:
```
✅ MIGRATION COMPLETE
✅ Successfully created 50 system templates
✅ System templates are visible (RLS configured correctly)
✅ Templates table: CREATED
✅ RLS policies: CONFIGURED
✅ System templates: LOADED (50 templates)
✅ Indexes: CREATED
```

### Step 4: Test in App
1. **Restart your PlombiPro app**
2. Go to: **Devis** → **Nouveau Devis**
3. Look for: **"Sélectionner un modèle"** button
4. Click it - **You should see 50 templates!** 🎉

## 📋 What Changed?

### Before (Broken RLS Policy)
```sql
-- ❌ This only matches user's own templates
CREATE POLICY "Users can only see their own templates."
ON templates FOR SELECT
USING (auth.uid() = user_id);
```

### After (Fixed RLS Policy)
```sql
-- ✅ This matches user's templates OR system templates
CREATE POLICY "templates_select_policy"
ON public.templates FOR SELECT
USING (
    auth.uid() = user_id OR         -- User's own templates
    is_system_template = true        -- OR system templates (for everyone)
);
```

## 🎯 Technical Details

### What the Migration Does

**1. Table Creation (Idempotent)**
```sql
CREATE TABLE IF NOT EXISTS public.templates (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id),
    template_name text NOT NULL,
    template_type text DEFAULT 'quote',
    category text,
    line_items jsonb,
    terms_conditions text,
    is_system_template boolean DEFAULT false,
    times_used integer DEFAULT 0,
    last_used timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
```

**2. Performance Indexes**
```sql
CREATE INDEX IF NOT EXISTS idx_templates_user_id ON templates(user_id);
CREATE INDEX IF NOT EXISTS idx_templates_is_system ON templates(is_system_template);
CREATE INDEX IF NOT EXISTS idx_templates_category ON templates(category);
CREATE INDEX IF NOT EXISTS idx_templates_template_type ON templates(template_type);
CREATE INDEX IF NOT EXISTS idx_templates_user_system ON templates(user_id, is_system_template);
```

**3. Fixed RLS Policies**
- ✅ SELECT: Users see their own templates + all system templates
- ✅ INSERT: Users can only create non-system templates
- ✅ UPDATE: Users can only update their own non-system templates
- ✅ DELETE: Users can only delete their own non-system templates

**4. 50 System Templates**
Organized in 7 categories:
- Rénovation Salle de Bain (10)
- Plomberie Cuisine (8)
- Chauffe-eau (7)
- Dépannage Urgence (6)
- Installation Équipements (8)
- Chauffage (5)
- Équipements Spéciaux (6)

## 🔍 Verification Queries

After running the migration, you can verify with these SQL queries:

**Count system templates:**
```sql
SELECT COUNT(*) FROM public.templates
WHERE is_system_template = true;
-- Expected: 50
```

**List categories:**
```sql
SELECT category, COUNT(*) as count
FROM public.templates
WHERE is_system_template = true
GROUP BY category
ORDER BY category;
```

**Test visibility (as a user):**
```sql
SELECT template_name, category
FROM public.templates
WHERE is_system_template = true
LIMIT 10;
-- Should return 10 templates (not empty!)
```

**Check RLS policies:**
```sql
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'templates';
-- Should show 4 policies: select, insert, update, delete
```

## ❌ Common Errors & Solutions

### Error: "relation 'templates' does not exist"
**Solution:** The migration creates the table. This error shouldn't occur with the fixed migration.

### Error: "policy 'templates_select_policy' already exists"
**Solution:** The migration drops existing policies first. If you still get this, run:
```sql
DROP POLICY IF EXISTS "templates_select_policy" ON public.templates;
```
Then re-run the migration.

### Templates still not showing after migration
1. **Check template count:**
   ```sql
   SELECT COUNT(*) FROM public.templates WHERE is_system_template = true;
   ```
   Should return 50.

2. **Check RLS policy:**
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'templates' AND policyname = 'templates_select_policy';
   ```
   Should show the policy exists.

3. **Clear app cache:**
   - Force quit app
   - Clear app data (Android) or reinstall (iOS)
   - Restart app

4. **Check app code:**
   Verify `TemplateService.getTemplatesList()` is being called:
   ```dart
   final templates = await TemplateService.getTemplatesList();
   print('Found ${templates.length} templates'); // Should print: Found 50 templates
   ```

## 📁 Files Changed/Created

1. **`migrations/COMPLETE_TEMPLATES_MIGRATION_FIXED.sql`** (NEW)
   - Complete migration with all fixes
   - 1,460 lines
   - Run this one!

2. **`migrations/006_plumbing_templates.sql`** (OLD)
   - Original migration without RLS fix
   - Don't use this - it has the bug

3. **`FIX_TEMPLATES_ISSUE.md`** (This file)
   - Comprehensive fix documentation

4. **`QUICK_TEMPLATE_SETUP.md`** (Updated)
   - Quick setup guide pointing to fixed migration

## 🎓 Why This Matters

**Row Level Security (RLS)** is a powerful PostgreSQL/Supabase feature that:
- Automatically filters query results based on user permissions
- Runs at the database level (can't be bypassed)
- Essential for multi-tenant SaaS applications

**The bug:**
- System templates needed to be visible to ALL users
- But RLS policy only showed templates WHERE `user_id = current_user_id`
- Since system templates have `user_id = NULL`, they were never visible

**The fix:**
- Updated policy to: `WHERE user_id = current_user_id OR is_system_template = true`
- Now system templates are visible to everyone
- User templates remain private

## 📞 Need Help?

If templates still don't show after running the migration:

1. **Check Supabase logs** for errors
2. **Verify migration ran completely** (check for error messages)
3. **Test with SQL queries** above to isolate the issue
4. **Check app logs** for TemplateService errors

## ✅ Success Checklist

- [ ] Ran `COMPLETE_TEMPLATES_MIGRATION_FIXED.sql` in Supabase
- [ ] Saw success messages in SQL output
- [ ] Verified 50 templates exist (SQL query)
- [ ] Verified RLS policies exist (SQL query)
- [ ] Restarted PlombiPro app
- [ ] Opened Quotes → New Quote
- [ ] Clicked "Sélectionner un modèle"
- [ ] Saw 50 templates organized by category
- [ ] Successfully applied a template to a quote

---

**Created:** January 2025
**Migration File:** `migrations/COMPLETE_TEMPLATES_MIGRATION_FIXED.sql`
**Issue:** RLS policy prevented system templates from being visible
**Status:** ✅ FIXED

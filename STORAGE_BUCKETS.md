# PlombiPro - Storage Buckets Configuration

**Date:** 2025-11-06
**Platform:** Supabase Storage

This document describes all storage buckets needed for the PlombiPro application and their configurations.

---

## Overview

PlombiPro uses **6 storage buckets** for different types of files. Since Supabase storage buckets cannot be created via SQL, they must be created manually through the Supabase Dashboard or CLI.

---

## Bucket List

| # | Bucket Name | Purpose | Public Access | Max File Size | Allowed MIME Types |
|---|-------------|---------|---------------|---------------|-------------------|
| 1 | `avatars` | User profile photos | ✅ Yes | 1 MB | image/jpeg, image/png, image/webp |
| 2 | `logos` | Company logos | ✅ Yes | 1 MB | image/jpeg, image/png, image/webp, image/svg+xml |
| 3 | `documents` | Generated PDFs, Factur-X XML | ❌ No | 5 MB | application/pdf, application/xml |
| 4 | `signatures` | Client signatures on quotes | ❌ No | 500 KB | image/png, image/jpeg |
| 5 | `worksite_photos` | Job site photos | ❌ No | 5 MB | image/jpeg, image/png, image/webp |
| 6 | `scans` | Scanned invoices for OCR | ❌ No | 5 MB | image/jpeg, image/png, application/pdf |

---

## Detailed Bucket Configurations

### 1. Avatars Bucket

**Name:** `avatars`

**Configuration:**
```yaml
Name: avatars
Public: true
File size limit: 1048576 (1 MB)
Allowed MIME types:
  - image/jpeg
  - image/png
  - image/webp
```

**Folder Structure:**
```
avatars/
├── {user_id}/
│   └── avatar.png
```

**Access Pattern:**
- Users can upload, update, and delete their own avatar
- All users can view all avatars (public bucket)

**RLS Policies:**
- ✅ Public read for all
- ✅ Authenticated users can upload to their own folder
- ✅ Users can update/delete their own avatar

**Usage in App:**
- `lib/screens/profile/user_profile_page.dart`

---

### 2. Logos Bucket

**Name:** `logos`

**Configuration:**
```yaml
Name: logos
Public: true
File size limit: 1048576 (1 MB)
Allowed MIME types:
  - image/jpeg
  - image/png
  - image/webp
  - image/svg+xml
```

**Folder Structure:**
```
logos/
├── {user_id}/
│   └── company_logo.png
```

**Access Pattern:**
- Users can upload, update, and delete their own logo
- All users can view all logos (public bucket)
- Logos appear on invoices and quotes

**RLS Policies:**
- ✅ Public read for all
- ✅ Authenticated users can upload to their own folder
- ✅ Users can update/delete their own logo

**Usage in App:**
- `lib/screens/company/company_profile_page.dart`
- `lib/services/pdf_generator.dart` (for invoices/quotes)
- `cloud_functions/invoice_generator/main.py`

---

### 3. Documents Bucket

**Name:** `documents`

**Configuration:**
```yaml
Name: documents
Public: false
File size limit: 5242880 (5 MB)
Allowed MIME types:
  - application/pdf
  - application/xml
```

**Folder Structure:**
```
documents/
├── {user_id}/
│   ├── invoices/
│   │   ├── FACT-2025-0001.pdf
│   │   └── FACT-2025-0001_facturx.xml
│   ├── quotes/
│   │   └── DEV-2025-0001.pdf
│   └── reports/
│       └── monthly_report_2025_01.pdf
```

**Access Pattern:**
- Only authenticated users can access their own documents
- Generated PDFs and XML files are stored here
- Documents include invoices, quotes, Factur-X files

**RLS Policies:**
- ❌ No public access
- ✅ Users can read/write/delete their own documents only

**Usage in App:**
- `lib/services/pdf_generator.dart`
- `lib/services/facturx_service.dart`
- `lib/screens/invoices/invoices_list_page.dart`
- `lib/screens/quotes/quotes_list_page.dart`
- `cloud_functions/invoice_generator/main.py`
- `cloud_functions/facturx_generator/main.py`

---

### 4. Signatures Bucket

**Name:** `signatures`

**Configuration:**
```yaml
Name: signatures
Public: false
File size limit: 512000 (500 KB)
Allowed MIME types:
  - image/png
  - image/jpeg
```

**Folder Structure:**
```
signatures/
├── {user_id}/
│   ├── quote_{quote_id}_signature.png
│   └── invoice_{invoice_id}_signature.png
```

**Access Pattern:**
- Only authenticated users can access their own signatures
- Signatures are captured when clients accept quotes
- PNG format with transparent background preferred

**RLS Policies:**
- ❌ No public access
- ✅ Users can upload signatures for their own quotes/invoices
- ✅ Users can read/delete their own signatures

**Usage in App:**
- `lib/screens/quotes/quote_form_page.dart`
- `lib/widgets/signature_pad.dart`
- `lib/services/pdf_generator.dart` (embedding signatures in PDFs)

---

### 5. Worksite Photos Bucket

**Name:** `worksite_photos`

**Configuration:**
```yaml
Name: worksite_photos
Public: false
File size limit: 5242880 (5 MB)
Allowed MIME types:
  - image/jpeg
  - image/png
  - image/webp
```

**Folder Structure:**
```
worksite_photos/
├── {user_id}/
│   ├── job_site_{id}/
│   │   ├── before_001.jpg
│   │   ├── during_001.jpg
│   │   └── after_001.jpg
```

**Access Pattern:**
- Only authenticated users can access their own worksite photos
- Photos document work progress on job sites
- Support before/during/after photo categorization

**RLS Policies:**
- ❌ No public access
- ✅ Users can upload photos to their own job sites
- ✅ Users can read/delete their own worksite photos

**Usage in App:**
- `lib/screens/job_sites/job_site_detail_page.dart`
- `lib/screens/job_sites/job_site_form_page.dart`
- Job site photo gallery

---

### 6. Scans Bucket

**Name:** `scans`

**Configuration:**
```yaml
Name: scans
Public: false
File size limit: 5242880 (5 MB)
Allowed MIME types:
  - image/jpeg
  - image/png
  - application/pdf
```

**Folder Structure:**
```
scans/
├── {user_id}/
│   ├── scan_{timestamp}_001.jpg
│   ├── scan_{timestamp}_002.pdf
│   └── processed/
│       └── scan_{scan_id}_processed.json
```

**Access Pattern:**
- Only authenticated users can access their own scans
- Scanned supplier invoices for OCR processing
- Temporary storage until converted to purchases

**RLS Policies:**
- ❌ No public access
- ✅ Users can upload scans to their own folder
- ✅ Users can read/delete their own scans

**Usage in App:**
- `lib/screens/ocr/scan_invoice_page.dart`
- `lib/screens/scans/scan_review_page.dart`
- `cloud_functions/ocr_processor/main.py`

---

## Creating Buckets - Step by Step

### Method 1: Supabase Dashboard (Recommended)

1. **Navigate to Storage:**
   - Go to Supabase Dashboard
   - Click on "Storage" in left sidebar

2. **Create Each Bucket:**
   - Click "Create a new bucket"
   - Enter bucket name (e.g., `avatars`)
   - Set "Public bucket" toggle:
     - ✅ ON for: `avatars`, `logos`
     - ❌ OFF for: `documents`, `signatures`, `worksite_photos`, `scans`
   - Set file size limit (see table above)
   - Set allowed MIME types (see configurations above)
   - Click "Create bucket"

3. **Repeat** for all 6 buckets

### Method 2: Supabase CLI

```bash
# Install Supabase CLI if not already installed
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Create buckets (note: MIME types and policies must be set via dashboard or SQL)
supabase storage create avatars --public
supabase storage create logos --public
supabase storage create documents
supabase storage create signatures
supabase storage create worksite_photos
supabase storage create scans
```

### Method 3: Supabase SQL (Limited)

While you cannot create buckets via SQL, you can configure them:

```sql
-- Update bucket settings (run after manual bucket creation)
UPDATE storage.buckets
SET file_size_limit = 1048576
WHERE name = 'avatars';

UPDATE storage.buckets
SET file_size_limit = 1048576
WHERE name = 'logos';

UPDATE storage.buckets
SET file_size_limit = 5242880
WHERE name IN ('documents', 'worksite_photos', 'scans');

UPDATE storage.buckets
SET file_size_limit = 512000
WHERE name = 'signatures';
```

---

## Applying Storage Policies

After creating buckets, apply the RLS policies from `supabase_bucket_policies.sql`:

```bash
# Method 1: Via Supabase Dashboard
# 1. Go to Storage > Policies
# 2. Copy content from supabase_bucket_policies.sql
# 3. Run in SQL Editor

# Method 2: Via Supabase CLI
supabase db push
```

Or run directly:
```bash
psql -h db.xxx.supabase.co -U postgres -d postgres -f supabase_bucket_policies.sql
```

---

## Testing Bucket Access

### Test Public Buckets (avatars, logos)

```dart
// Upload test
final avatarFile = File('path/to/avatar.png');
final response = await Supabase.instance.client.storage
    .from('avatars')
    .upload('${userId}/avatar.png', avatarFile);

// Get public URL
final publicUrl = Supabase.instance.client.storage
    .from('avatars')
    .getPublicUrl('${userId}/avatar.png');
```

### Test Private Buckets (documents, signatures, etc.)

```dart
// Upload test
final pdfFile = File('path/to/invoice.pdf');
final response = await Supabase.instance.client.storage
    .from('documents')
    .upload('${userId}/invoices/test.pdf', pdfFile);

// Get signed URL (expires after specified duration)
final signedUrl = await Supabase.instance.client.storage
    .from('documents')
    .createSignedUrl('${userId}/invoices/test.pdf', 3600); // 1 hour
```

---

## Storage Quotas and Pricing

### Supabase Storage Pricing (as of 2025)

| Plan | Storage | Bandwidth | Pricing |
|------|---------|-----------|---------|
| Free | 1 GB | 2 GB | Free |
| Pro | 100 GB | 200 GB | $25/month |
| Additional | +100 GB | +100 GB | +$10/month |

**Estimated Usage for PlombiPro:**
- **Avatars:** ~1-2 MB per user
- **Logos:** ~1-2 MB per company
- **Documents:** ~100-500 KB per PDF
- **Signatures:** ~50-100 KB per signature
- **Worksite Photos:** ~2-3 MB per photo
- **Scans:** ~1-3 MB per scan

**For 100 active users:**
- Avatars: ~200 MB
- Documents: ~500 MB (assuming 1000 invoices)
- Photos: ~2 GB (assuming 1000 photos)
- **Total:** ~3-5 GB

**Recommendation:** Start with **Pro plan** ($25/month) which includes 100 GB.

---

## Backup and Retention

### Automatic Backups
- Supabase performs daily backups automatically
- Backups retained based on plan:
  - Free: 7 days
  - Pro: 30 days
  - Enterprise: Custom

### Manual Backup
```bash
# Download entire bucket
supabase storage download avatars ./backups/avatars

# Download specific folder
supabase storage download documents/${user_id} ./backups/documents
```

### Retention Policy
- **Documents:** Keep indefinitely (legal requirement)
- **Signatures:** Keep indefinitely (legal proof)
- **Scans:** Delete after 90 days (after OCR processing)
- **Worksite Photos:** Keep for project duration + 1 year
- **Avatars/Logos:** Keep until user updates

---

## Security Best Practices

1. **Never disable RLS** on storage buckets
2. **Always validate file types** before upload
3. **Scan files for malware** (especially user uploads)
4. **Use signed URLs** for private file access
5. **Set appropriate expiration** on signed URLs
6. **Monitor storage usage** to prevent abuse
7. **Implement upload rate limiting** in app
8. **Compress images** before upload to save space

---

## Monitoring and Maintenance

### Monitor Storage Usage
```sql
-- Check total storage per user
SELECT
    (metadata->>'owner')::uuid as user_id,
    COUNT(*) as file_count,
    SUM((metadata->>'size')::bigint) as total_bytes,
    SUM((metadata->>'size')::bigint) / 1024 / 1024 as total_mb
FROM storage.objects
GROUP BY (metadata->>'owner')::uuid
ORDER BY total_bytes DESC;
```

### Clean Up Old Files
```sql
-- Find old scans (>90 days)
SELECT * FROM storage.objects
WHERE bucket_id = 'scans'
  AND created_at < NOW() - INTERVAL '90 days';

-- Delete via Supabase client
await supabase.storage
    .from('scans')
    .remove([...old_file_paths]);
```

---

## Troubleshooting

### Common Issues

**1. "Policy violation" error when uploading**
- **Cause:** RLS policies not applied or user not authenticated
- **Solution:** Check `supabase_bucket_policies.sql` is applied

**2. "File too large" error**
- **Cause:** File exceeds bucket size limit
- **Solution:** Check bucket configuration, compress file, or increase limit

**3. "Invalid MIME type" error**
- **Cause:** File type not allowed in bucket
- **Solution:** Check allowed MIME types, convert file, or update bucket config

**4. "Access denied" on public bucket**
- **Cause:** Bucket not set to public
- **Solution:** Toggle "Public bucket" in dashboard

**5. Signed URL expired**
- **Cause:** URL expiration time passed
- **Solution:** Generate new signed URL with longer duration

---

## Integration with Cloud Functions

Cloud functions need special permissions to access storage:

```python
# In cloud_functions/*/main.py
from supabase import create_client

# Use service role key (not anon key!)
supabase = create_client(
    os.environ.get("SUPABASE_URL"),
    os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
)

# Upload generated PDF
with open('invoice.pdf', 'rb') as f:
    supabase.storage.from_('documents').upload(
        f'{user_id}/invoices/{filename}',
        f,
        file_options={"content-type": "application/pdf"}
    )
```

---

## Migration from Existing Storage

If migrating from another storage provider:

```bash
# 1. Download all files from old provider
# 2. Upload to Supabase bucket

for file in ./old_storage/*; do
  supabase storage upload documents/user123/$file $file
done
```

---

**End of Storage Buckets Documentation**

For questions or issues, refer to:
- Supabase Storage Docs: https://supabase.com/docs/guides/storage
- PlombiPro GitHub Issues: https://github.com/your-org/plombipro-app/issues

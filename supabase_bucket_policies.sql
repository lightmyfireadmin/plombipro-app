-- Policies for avatars bucket
DROP POLICY IF EXISTS "avatars_public_read" ON storage.objects;
CREATE POLICY "avatars_public_read" ON storage.objects
  FOR SELECT
  USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "avatars_authenticated_upload_own" ON storage.objects;
CREATE POLICY "avatars_authenticated_upload_own" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    AND (
      CASE
        WHEN (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) IS NOT NULL
             AND (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) > 0
        THEN (COALESCE((metadata ->> 'size')::bigint, 0) <= (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id))
        ELSE (COALESCE((metadata ->> 'size')::bigint, 0) < 1 * 1024 * 1024) -- Fallback default: 1MB
      END
    )
    AND (metadata ->> 'mimetype') IN ('image/jpeg', 'image/png', 'image/webp')
  );

DROP POLICY IF EXISTS "avatars_authenticated_update_own" ON storage.objects;
CREATE POLICY "avatars_authenticated_update_own" ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'avatars'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  )
  WITH CHECK (
    bucket_id = 'avatars'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    AND (
      CASE
        WHEN (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) IS NOT NULL
             AND (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) > 0
        THEN (COALESCE((metadata ->> 'size')::bigint, 0) <= (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id))
        ELSE (COALESCE((metadata ->> 'size')::bigint, 0) < 1 * 1024 * 1024) -- Fallback default: 1MB
      END
    )
    AND (metadata ->> 'mimetype') IN ('image/jpeg', 'image/png', 'image/webp')
  );

DROP POLICY IF EXISTS "avatars_authenticated_delete_own" ON storage.objects;
CREATE POLICY "avatars_authenticated_delete_own" ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'avatars'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

-- Policies for logos bucket
DROP POLICY IF EXISTS "logos_public_read" ON storage.objects;
CREATE POLICY "logos_public_read" ON storage.objects
  FOR SELECT
  USING (bucket_id = 'logos');

DROP POLICY IF EXISTS "logos_authenticated_upload_own" ON storage.objects;
CREATE POLICY "logos_authenticated_upload_own" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'logos'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    AND (
      CASE
        WHEN (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) IS NOT NULL
             AND (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) > 0
        THEN (COALESCE((metadata ->> 'size')::bigint, 0) <= (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id))
        ELSE (COALESCE((metadata ->> 'size')::bigint, 0) < 1 * 1024 * 1024) -- Fallback default: 1MB
      END
    )
    AND (metadata ->> 'mimetype') IN ('image/jpeg', 'image/png', 'image/webp', 'image/svg+xml')
  );

DROP POLICY IF EXISTS "logos_authenticated_update_own" ON storage.objects;
CREATE POLICY "logos_authenticated_update_own" ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'logos'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  )
  WITH CHECK (
    bucket_id = 'logos'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    AND (
      CASE
        WHEN (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) IS NOT NULL
             AND (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) > 0
        THEN (COALESCE((metadata ->> 'size')::bigint, 0) <= (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id))
        ELSE (COALESCE((metadata ->> 'size')::bigint, 0) < 1 * 1024 * 1024) -- Fallback default: 1MB
      END
    )
    AND (metadata ->> 'mimetype') IN ('image/jpeg', 'image/png', 'image/webp', 'image/svg+xml')
  );

DROP POLICY IF EXISTS "logos_authenticated_delete_own" ON storage.objects;
CREATE POLICY "logos_authenticated_delete_own" ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'logos'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

-- Policies for documents bucket
DROP POLICY IF EXISTS "documents_authenticated_read_own" ON storage.objects;
CREATE POLICY "documents_authenticated_read_own" ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'documents'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

DROP POLICY IF EXISTS "documents_authenticated_upload_own" ON storage.objects;
CREATE POLICY "documents_authenticated_upload_own" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'documents'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    AND (
      CASE
        WHEN (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) IS NOT NULL
             AND (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) > 0
        THEN (COALESCE((metadata ->> 'size')::bigint, 0) <= (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id))
        ELSE (COALESCE((metadata ->> 'size')::bigint, 0) < 5 * 1024 * 1024) -- Fallback default: 5MB
      END
    )
    AND (metadata ->> 'mimetype') IN ('application/pdf', 'application/xml')
  );

DROP POLICY IF EXISTS "documents_authenticated_delete_own" ON storage.objects;
CREATE POLICY "documents_authenticated_delete_own" ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'documents'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

-- Policies for signatures bucket
DROP POLICY IF EXISTS "signatures_authenticated_read_own" ON storage.objects;
CREATE POLICY "signatures_authenticated_read_own" ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'signatures'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

DROP POLICY IF EXISTS "signatures_authenticated_upload_own" ON storage.objects;
CREATE POLICY "signatures_authenticated_upload_own" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'signatures'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    AND (
      CASE
        WHEN (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) IS NOT NULL
             AND (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) > 0
        THEN (COALESCE((metadata ->> 'size')::bigint, 0) <= (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id))
        ELSE (COALESCE((metadata ->> 'size')::bigint, 0) < 500 * 1024) -- Fallback default: 500KB
      END
    )
    AND (metadata ->> 'mimetype') IN ('image/png', 'image/jpeg')
  );

DROP POLICY IF EXISTS "signatures_authenticated_delete_own" ON storage.objects;
CREATE POLICY "signatures_authenticated_delete_own" ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'signatures'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

-- Policies for worksite_photos bucket
DROP POLICY IF EXISTS "worksite_photos_authenticated_read_own" ON storage.objects;
CREATE POLICY "worksite_photos_authenticated_read_own" ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'worksite_photos'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

DROP POLICY IF EXISTS "worksite_photos_authenticated_upload_own" ON storage.objects;
CREATE POLICY "worksite_photos_authenticated_upload_own" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'worksite_photos'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    AND (
      CASE
        WHEN (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) IS NOT NULL
             AND (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) > 0
        THEN (COALESCE((metadata ->> 'size')::bigint, 0) <= (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id))
        ELSE (COALESCE((metadata ->> 'size')::bigint, 0) < 5 * 1024 * 1024) -- Fallback default: 5MB
      END
    )
    AND (metadata ->> 'mimetype') IN ('image/jpeg', 'image/png', 'image/webp')
  );

DROP POLICY IF EXISTS "worksite_photos_authenticated_delete_own" ON storage.objects;
CREATE POLICY "worksite_photos_authenticated_delete_own" ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'worksite_photos'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

-- Policies for scans bucket
DROP POLICY IF EXISTS "scans_authenticated_read_own" ON storage.objects;
CREATE POLICY "scans_authenticated_read_own" ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'scans'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

DROP POLICY IF EXISTS "scans_authenticated_upload_own" ON storage.objects;
CREATE POLICY "scans_authenticated_upload_own" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'scans'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    AND (
      CASE
        WHEN (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) IS NOT NULL
             AND (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id) > 0
        THEN (COALESCE((metadata ->> 'size')::bigint, 0) <= (SELECT file_size_limit FROM storage.buckets WHERE id = storage.objects.bucket_id))
        ELSE (COALESCE((metadata ->> 'size')::bigint, 0) < 5 * 1024 * 1024) -- Fallback default: 5MB
      END
    )
    AND (metadata ->> 'mimetype') IN ('image/jpeg', 'image/png', 'application/pdf')
  );

DROP POLICY IF EXISTS "scans_authenticated_delete_own" ON storage.objects;
CREATE POLICY "scans_authenticated_delete_own" ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'scans'
    AND (SELECT auth.uid()) IS NOT NULL
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

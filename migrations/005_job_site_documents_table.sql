-- Migration 005: Create job_site_documents table
-- This table stores documents attached to job sites (PDFs, images, contracts, invoices, etc.)
-- Required for job site document management functionality

CREATE TABLE job_site_documents (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_site_id uuid REFERENCES job_sites(id) ON DELETE CASCADE,
    document_name text NOT NULL,
    document_url text NOT NULL,
    document_type text, -- 'invoice', 'quote', 'contract', 'photo', 'pdf', 'other'
    file_size int, -- in bytes
    uploaded_at timestamp DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP
);

-- Add index for faster queries by job site
CREATE INDEX idx_job_site_documents_job_site_id ON job_site_documents(job_site_id);

-- Add index for document type filtering
CREATE INDEX idx_job_site_documents_type ON job_site_documents(document_type);

-- Enable Row Level Security
ALTER TABLE job_site_documents ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Users can only access documents from their own job sites

-- SELECT policy
CREATE POLICY "Users can only see documents from their job sites."
ON job_site_documents FOR SELECT
USING (
    auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id)
);

-- INSERT policy
CREATE POLICY "Users can insert documents to their job sites."
ON job_site_documents FOR INSERT
WITH CHECK (
    auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id)
);

-- UPDATE policy
CREATE POLICY "Users can update their job site documents."
ON job_site_documents FOR UPDATE
USING (
    auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id)
);

-- DELETE policy
CREATE POLICY "Users can delete their job site documents."
ON job_site_documents FOR DELETE
USING (
    auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id)
);

-- Add comment for documentation
COMMENT ON TABLE job_site_documents IS 'Stores documents attached to job sites including PDFs, images, contracts, and invoices';
COMMENT ON COLUMN job_site_documents.document_type IS 'Type of document: invoice, quote, contract, photo, pdf, or other';
COMMENT ON COLUMN job_site_documents.file_size IS 'File size in bytes for display purposes';

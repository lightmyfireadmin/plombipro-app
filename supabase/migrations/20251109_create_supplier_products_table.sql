-- Create supplier_products table for Point P and Cedeo catalog integration
-- Migration: 20251109_create_supplier_products_table
-- Description: Stores scraped product data from supplier websites

CREATE TABLE IF NOT EXISTS supplier_products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Supplier information
  supplier TEXT NOT NULL CHECK (supplier IN ('point_p', 'cedeo', 'leroy_merlin', 'castorama')),
  supplier_product_id TEXT,  -- External product ID from supplier

  -- Product details
  reference TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,

  -- Categorization
  category TEXT,
  subcategory TEXT,
  product_type TEXT,  -- 'plumbing', 'heating', 'tools', etc.

  -- Pricing
  price NUMERIC(10, 2),
  price_unit TEXT,  -- 'unit', 'meter', 'pack', etc.
  vat_rate NUMERIC(5, 2) DEFAULT 20.0,

  -- Stock and availability
  in_stock BOOLEAN DEFAULT true,
  stock_level TEXT,  -- 'high', 'medium', 'low', 'out_of_stock'

  -- Additional details
  brand TEXT,
  specifications JSONB,  -- Flexible storage for product specs
  image_url TEXT,
  product_url TEXT,

  -- Technical specifications (for plumbing products)
  diameter_mm NUMERIC(10, 2),  -- Pipe diameter
  length_m NUMERIC(10, 2),     -- Pipe/tube length
  material TEXT,               -- Copper, PVC, PER, etc.

  -- Metadata
  last_scraped_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  scraper_version TEXT,
  is_active BOOLEAN DEFAULT true,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),

  -- Unique constraint on supplier + reference
  UNIQUE(supplier, reference)
);

-- Indexes for performance
CREATE INDEX idx_supplier_products_supplier ON supplier_products(supplier);
CREATE INDEX idx_supplier_products_category ON supplier_products(category);
CREATE INDEX idx_supplier_products_subcategory ON supplier_products(subcategory);
CREATE INDEX idx_supplier_products_product_type ON supplier_products(product_type);
CREATE INDEX idx_supplier_products_price ON supplier_products(price);
CREATE INDEX idx_supplier_products_in_stock ON supplier_products(in_stock);

-- Full-text search index on name and description
CREATE INDEX idx_supplier_products_name_search ON supplier_products
  USING gin(to_tsvector('french', name));
CREATE INDEX idx_supplier_products_description_search ON supplier_products
  USING gin(to_tsvector('french', coalesce(description, '')));

-- Composite index for common queries
CREATE INDEX idx_supplier_products_supplier_category ON supplier_products(supplier, category);
CREATE INDEX idx_supplier_products_supplier_stock ON supplier_products(supplier, in_stock);

-- Enable Row Level Security (but allow public read)
ALTER TABLE supplier_products ENABLE ROW LEVEL SECURITY;

-- RLS Policies - Allow everyone to read supplier products
CREATE POLICY "Anyone can read supplier products"
  ON supplier_products FOR SELECT
  USING (true);

-- Only service role can insert/update (for scrapers)
CREATE POLICY "Service role can insert supplier products"
  ON supplier_products FOR INSERT
  WITH CHECK (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Service role can update supplier products"
  ON supplier_products FOR UPDATE
  USING (auth.jwt() ->> 'role' = 'service_role')
  WITH CHECK (auth.jwt() ->> 'role' = 'service_role');

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_supplier_products_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call the function
CREATE TRIGGER set_supplier_products_updated_at
  BEFORE UPDATE ON supplier_products
  FOR EACH ROW
  EXECUTE FUNCTION update_supplier_products_updated_at();

-- Function to mark products as inactive if not scraped recently
CREATE OR REPLACE FUNCTION mark_stale_products_inactive()
RETURNS void AS $$
BEGIN
  UPDATE supplier_products
  SET is_active = false
  WHERE last_scraped_at < now() - INTERVAL '30 days'
    AND is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Create a view for active products only
CREATE OR REPLACE VIEW active_supplier_products AS
SELECT * FROM supplier_products
WHERE is_active = true AND in_stock = true;

-- Add helpful comments
COMMENT ON TABLE supplier_products IS 'Stores product catalog data scraped from suppliers (Point P, Cedeo, etc.)';
COMMENT ON COLUMN supplier_products.supplier IS 'Supplier name: point_p, cedeo, leroy_merlin, castorama';
COMMENT ON COLUMN supplier_products.specifications IS 'JSON storage for flexible product specifications';
COMMENT ON COLUMN supplier_products.last_scraped_at IS 'When this product was last updated by the scraper';
COMMENT ON COLUMN supplier_products.is_active IS 'False if product not seen in recent scrapes (discontinued)';

-- Sample data for testing (optional - can be removed in production)
INSERT INTO supplier_products (supplier, reference, name, description, category, subcategory, price, price_unit, in_stock, brand) VALUES
('point_p', 'REF-001', 'Tube cuivre écroui 12mm - 5m', 'Tube cuivre écroui diamètre 12mm, longueur 5 mètres', 'Plomberie', 'Tubes cuivre', 45.90, 'unité', true, 'Point.P'),
('point_p', 'REF-002', 'Raccord PER à glissement 16mm', 'Raccord à glissement pour tube PER diamètre 16mm', 'Plomberie', 'Raccords PER', 3.50, 'unité', true, 'Point.P'),
('cedeo', 'CEDEO-001', 'Robinet mélangeur lavabo chromé', 'Robinet mélangeur pour lavabo, finition chromée', 'Sanitaire', 'Robinetterie', 89.00, 'unité', true, 'Cedeo'),
('cedeo', 'CEDEO-002', 'Siphon lavabo plastique orientable', 'Siphon pour lavabo en plastique avec sortie orientable', 'Sanitaire', 'Évacuation', 12.50, 'unité', true, 'Cedeo')
ON CONFLICT (supplier, reference) DO NOTHING;

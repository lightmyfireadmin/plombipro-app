-- =====================================================
-- PLOMBIPRO COMPREHENSIVE SEED DATA
-- Test User: 6b1d26bf-40d7-46c0-9b07-89a120191971
-- =====================================================
-- This script creates a full realistic dataset for testing including:
-- - Company profile with complete details
-- - 15 diverse clients (individuals and companies)
-- - 8 job sites with different statuses
-- - 20 products across various categories
-- - 12 quotes (mix of pending, accepted, rejected)
-- - 10 invoices (mix of paid, unpaid, overdue)
-- - 6 payments
-- - 3 custom templates
-- - Activity logs and appointments
-- =====================================================

BEGIN;

-- Set the test user ID
DO $$
DECLARE
  test_user_id UUID := '6b1d26bf-40d7-46c0-9b07-89a120191971';
BEGIN

-- =====================================================
-- 1. COMPANY PROFILE
-- =====================================================
INSERT INTO profiles (
  id,
  email,
  company_name,
  siret,
  tva_number,
  iban,
  bic,
  phone,
  address,
  postal_code,
  city,
  country,
  created_at,
  updated_at
) VALUES (
  test_user_id,
  'test@plombipro.fr',
  'Plomberie Pro Services',
  '85234567800012',
  'FR85234567800',
  'FR7612345678901234567890123',
  'BNPAFRPPXXX',
  '+33 6 12 34 56 78',
  '15 Rue de la République',
  '75001',
  'Paris',
  'France',
  NOW() - INTERVAL '6 months',
  NOW()
)
ON CONFLICT (id) DO UPDATE SET
  company_name = EXCLUDED.company_name,
  siret = EXCLUDED.siret,
  tva_number = EXCLUDED.tva_number,
  iban = EXCLUDED.iban,
  bic = EXCLUDED.bic,
  phone = EXCLUDED.phone,
  address = EXCLUDED.address,
  postal_code = EXCLUDED.postal_code,
  city = EXCLUDED.city,
  updated_at = NOW();

-- =====================================================
-- 2. CLIENTS (15 diverse clients)
-- =====================================================

-- Individual Clients
INSERT INTO clients (
  id, user_id, client_type, salutation, first_name, last_name,
  email, phone, mobile_phone, address, postal_code, city, country,
  is_favorite, tags, notes, created_at
) VALUES
-- Client 1: VIP Individual
(
  gen_random_uuid(), test_user_id, 'individual', 'M.', 'Jean', 'Dupont',
  'jean.dupont@email.fr', '01 42 12 34 56', '06 12 34 56 78',
  '23 Avenue des Champs-Élysées', '75008', 'Paris', 'France',
  true, ARRAY['VIP', 'Récurrent'], 'Client fidèle depuis 5 ans. Préfère les interventions le matin.',
  NOW() - INTERVAL '5 years'
),
-- Client 2: Regular Individual
(
  gen_random_uuid(), test_user_id, 'individual', 'Mme', 'Marie', 'Martin',
  'marie.martin@email.fr', '01 43 22 33 44', '06 23 45 67 89',
  '45 Rue de Rivoli', '75004', 'Paris', 'France',
  false, ARRAY['Particulier'], 'Appartement au 3ème étage sans ascenseur',
  NOW() - INTERVAL '2 years'
),
-- Client 3: New Individual
(
  gen_random_uuid(), test_user_id, 'individual', 'M.', 'Pierre', 'Dubois',
  'pierre.dubois@email.fr', '01 44 55 66 77', '06 34 56 78 90',
  '12 Boulevard Saint-Germain', '75005', 'Paris', 'France',
  false, ARRAY['Nouveau'], NULL,
  NOW() - INTERVAL '2 months'
),
-- Client 4: Individual in suburbs
(
  gen_random_uuid(), test_user_id, 'individual', 'Mme', 'Sophie', 'Bernard',
  'sophie.bernard@email.fr', '01 45 67 88 99', '06 45 67 89 01',
  '78 Avenue Jean Jaurès', '92100', 'Boulogne-Billancourt', 'France',
  false, ARRAY['Banlieue'], 'Maison individuelle avec jardin',
  NOW() - INTERVAL '1 year'
),
-- Client 5: Senior Individual
(
  gen_random_uuid(), test_user_id, 'individual', 'M.', 'Robert', 'Leroy',
  'robert.leroy@email.fr', '01 46 78 99 00', '06 56 78 90 12',
  '34 Rue Mouffetard', '75005', 'Paris', 'France',
  true, ARRAY['Senior', 'Fidèle'], 'Personne âgée, prévoir temps supplémentaire pour explications',
  NOW() - INTERVAL '8 years'
);

-- Company Clients
INSERT INTO clients (
  id, user_id, client_type, salutation, first_name, company_name,
  email, phone, address, postal_code, city, country,
  siret, vat_number, default_payment_terms, default_discount,
  is_favorite, tags, notes, created_at
) VALUES
-- Client 6: Large company
(
  gen_random_uuid(), test_user_id, 'company', 'M.', 'Michel', 'Immobilière Parisienne',
  'contact@immobiliere-paris.fr', '01 47 89 90 12',
  '88 Avenue Hoche', '75008', 'Paris', 'France',
  '51234567800023', 'FR51234567800', 45, 5.0,
  true, ARRAY['Grand Compte', 'Immobilier'], 'Contrat annuel de maintenance - 15 immeubles',
  NOW() - INTERVAL '3 years'
),
-- Client 7: Restaurant
(
  gen_random_uuid(), test_user_id, 'company', 'Mme', 'Claire', 'Restaurant Le Bon Vivant',
  'contact@lebonvivant.fr', '01 48 90 12 34',
  '56 Rue Saint-Antoine', '75004', 'Paris', 'France',
  '52345678900034', 'FR52345678900', 30, 2.5,
  false, ARRAY['CHR', 'Commercial'], 'Cuisine professionnelle - interventions urgentes fréquentes',
  NOW() - INTERVAL '1 year 6 months'
),
-- Client 8: Hotel
(
  gen_random_uuid(), test_user_id, 'company', 'M.', 'Antoine', 'Hôtel de la Tour',
  'direction@hoteldelatour.fr', '01 49 01 23 45',
  '23 Rue de la Tour', '75016', 'Paris', 'France',
  '53456789000045', 'FR53456789000', 60, 10.0,
  true, ARRAY['Hôtellerie', 'VIP'], 'Hôtel 4 étoiles - 45 chambres - contrat maintenance premium',
  NOW() - INTERVAL '4 years'
),
-- Client 9: Small shop
(
  gen_random_uuid(), test_user_id, 'company', 'Mme', 'Isabelle', 'Boulangerie Artisanale',
  'contact@boulangerie-artisanale.fr', '01 50 12 34 56',
  '12 Rue des Martyrs', '75009', 'Paris', 'France',
  '54567890100056', 'FR54567890100', 30, 0.0,
  false, ARRAY['Commerce', 'PME'], 'Boulangerie avec laboratoire',
  NOW() - INTERVAL '10 months'
),
-- Client 10: Startup office
(
  gen_random_uuid(), test_user_id, 'company', 'M.', 'Thomas', 'TechStart Innovation',
  'facilities@techstart.io', '01 51 23 45 67',
  '142 Rue Montmartre', '75002', 'Paris', 'France',
  '55678901200067', 'FR55678901200', 30, 0.0,
  false, ARRAY['Startup', 'Tech'], 'Bureaux open-space - 200m² - 30 employés',
  NOW() - INTERVAL '8 months'
),
-- Client 11: School
(
  gen_random_uuid(), test_user_id, 'company', 'Mme', 'Catherine', 'École Primaire Saint-Michel',
  'direction@ecole-stmichel.fr', '01 52 34 56 78',
  '67 Rue de Vaugirard', '75006', 'Paris', 'France',
  '56789012300078', 'FR56789012300', 60, 0.0,
  false, ARRAY['Public', 'Éducation'], 'École primaire - 12 classes - interventions pendant vacances scolaires',
  NOW() - INTERVAL '2 years'
),
-- Client 12: Medical office
(
  gen_random_uuid(), test_user_id, 'company', 'Dr.', 'Laurent', 'Cabinet Médical Rive Gauche',
  'secretariat@cabinet-rivegauche.fr', '01 53 45 67 89',
  '34 Boulevard Raspail', '75007', 'Paris', 'France',
  '57890123400089', 'FR57890123400', 30, 0.0,
  true, ARRAY['Médical', 'Prioritaire'], 'Cabinet de médecins - 4 praticiens - interventions rapides essentielles',
  NOW() - INTERVAL '3 years'
),
-- Client 13: Gym
(
  gen_random_uuid(), test_user_id, 'company', 'M.', 'Alexandre', 'Fitness Club Premium',
  'contact@fitnessclub-premium.fr', '01 54 56 78 90',
  '89 Avenue de la Grande Armée', '75017', 'Paris', 'France',
  '58901234500090', 'FR58901234500', 45, 5.0,
  false, ARRAY['Sport', 'Loisirs'], 'Salle de sport - vestiaires et douches - maintenance trimestrielle',
  NOW() - INTERVAL '1 year 3 months'
),
-- Client 14: Co-working space
(
  gen_random_uuid(), test_user_id, 'company', 'Mme', 'Nathalie', 'WorkSpace Paris',
  'admin@workspace-paris.fr', '01 55 67 89 01',
  '156 Rue de Charonne', '75011', 'Paris', 'France',
  '59012345600001', 'FR59012345600', 30, 0.0,
  false, ARRAY['Coworking', 'Moderne'], 'Espace de coworking - 500m² - 10 salles de réunion',
  NOW() - INTERVAL '6 months'
),
-- Client 15: Retail store
(
  gen_random_uuid(), test_user_id, 'company', 'M.', 'François', 'Boutique Mode & Style',
  'contact@mode-et-style.fr', '01 56 78 90 12',
  '45 Rue du Faubourg Saint-Honoré', '75008', 'Paris', 'France',
  '50123456700012', 'FR50123456700', 30, 0.0,
  false, ARRAY['Commerce', 'Retail'], 'Boutique de prêt-à-porter - surface commerciale 120m²',
  NOW() - INTERVAL '1 year'
);

-- =====================================================
-- 3. JOB SITES (4 chantiers with various statuses)
-- =====================================================

WITH client_ids AS (
  SELECT id, company_name FROM clients WHERE user_id = test_user_id AND company_name = 'Immobilière Parisienne'
  UNION ALL
  SELECT id, company_name FROM clients WHERE user_id = test_user_id AND company_name = 'Hôtel de la Tour'
  UNION ALL
  SELECT id, CONCAT(first_name, ' ', last_name) FROM clients WHERE user_id = test_user_id AND last_name = 'Dupont'
  UNION ALL
  SELECT id, company_name FROM clients WHERE user_id = test_user_id AND company_name = 'Restaurant Le Bon Vivant'
)
INSERT INTO job_sites (
  id, user_id, client_id, job_name, description,
  address, status, start_date, estimated_end_date, actual_end_date,
  progress_percentage, estimated_budget, actual_cost,
  notes, created_at
)
SELECT
  gen_random_uuid(), test_user_id, c.id,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN 'Rénovation salle de bain - Immeuble Haussmann'
    WHEN 2 THEN 'Installation chauffage central - Hôtel'
    WHEN 3 THEN 'Réparation fuite cuisine - Maison Dupont'
    WHEN 4 THEN 'Maintenance sanitaires - Restaurant'
  END,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN 'Rénovation complète de 2 salles de bain dans appartement 150m²'
    WHEN 2 THEN 'Installation système de chauffage central pour 45 chambres'
    WHEN 3 THEN 'Réparation urgente fuite sous évier cuisine'
    WHEN 4 THEN 'Maintenance préventive système sanitaire cuisine professionnelle'
  END,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN '88 Avenue Hoche, 75008 Paris'
    WHEN 2 THEN '23 Rue de la Tour, 75016 Paris'
    WHEN 3 THEN '23 Avenue des Champs-Élysées, 75008 Paris'
    WHEN 4 THEN '56 Rue Saint-Antoine, 75004 Paris'
  END,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN 'in_progress'
    WHEN 2 THEN 'planned'
    WHEN 3 THEN 'completed'
    WHEN 4 THEN 'in_progress'
  END,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN NOW() - INTERVAL '15 days'
    WHEN 2 THEN NOW() + INTERVAL '7 days'
    WHEN 3 THEN NOW() - INTERVAL '30 days'
    WHEN 4 THEN NOW() - INTERVAL '5 days'
  END,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN NOW() + INTERVAL '10 days'
    WHEN 2 THEN NOW() + INTERVAL '45 days'
    WHEN 3 THEN NOW() - INTERVAL '28 days'
    WHEN 4 THEN NOW() + INTERVAL '2 days'
  END,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN NULL
    WHEN 2 THEN NULL
    WHEN 3 THEN NOW() - INTERVAL '28 days'
    WHEN 4 THEN NULL
  END,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN 80
    WHEN 2 THEN 0
    WHEN 3 THEN 100
    WHEN 4 THEN 90
  END,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN 4500.00
    WHEN 2 THEN 15000.00
    WHEN 3 THEN 450.00
    WHEN 4 THEN 890.00
  END,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN 3750.50
    WHEN 2 THEN NULL
    WHEN 3 THEN 425.00
    WHEN 4 THEN 780.25
  END,
  CASE ROW_NUMBER() OVER ()
    WHEN 1 THEN 'Client très exigeant. Travaux de qualité requis.'
    WHEN 2 THEN 'Chantier important - bien planifier les étapes'
    WHEN 3 THEN 'Intervention terminée - client satisfait'
    WHEN 4 THEN 'Accès cuisine uniquement entre 14h et 17h'
  END,
  NOW() - INTERVAL '30 days'
FROM client_ids c
LIMIT 4;

-- =====================================================
-- 4. PRODUCTS (20 products across categories)
-- =====================================================

INSERT INTO products (
  id, user_id, name, reference, description, unit,
  purchase_price, sale_price, vat_rate, stock_quantity,
  minimum_stock, supplier, category, is_favorite,
  tags, created_at
) VALUES
-- Robinetterie
(gen_random_uuid(), test_user_id, 'Mitigeur lavabo chromé', 'ROB-MIT-001',
 'Mitigeur monotrou pour lavabo, finition chromée', 'pièce',
 45.90, 125.00, 20.0, 15, 5, 'Grohe', 'Robinetterie', true,
 ARRAY['Grohe', 'Chrome', 'Bestseller'], NOW() - INTERVAL '2 years'),

(gen_random_uuid(), test_user_id, 'Mitigeur douche thermostatique', 'ROB-MIT-002',
 'Mitigeur thermostatique pour douche avec sécurité anti-brûlure', 'pièce',
 89.50, 245.00, 20.0, 8, 3, 'Grohe', 'Robinetterie', true,
 ARRAY['Grohe', 'Sécurité', 'Premium'], NOW() - INTERVAL '1 year'),

(gen_random_uuid(), test_user_id, 'Robinet cuisine douchette', 'ROB-CUI-001',
 'Mitigeur cuisine avec douchette extractible', 'pièce',
 67.00, 189.00, 20.0, 10, 4, 'Hansgrohe', 'Robinetterie', false,
 ARRAY['Hansgrohe', 'Cuisine'], NOW() - INTERVAL '1 year')),

-- Sanitaires
(gen_random_uuid(), test_user_id, 'WC suspendu compact', 'SAN-WC-001',
 'WC suspendu gain de place avec mécanisme économie d''eau', 'pièce',
 145.00, 395.00, 20.0, 6, 2, 'Geberit', 'Sanitaires', true,
 ARRAY['Geberit', 'Eco', 'Moderne'], NOW() - INTERVAL '6 months'),

(gen_random_uuid(), test_user_id, 'Lavabo céramique 60cm', 'SAN-LAV-001',
 'Vasque à poser en céramique blanche 60x45cm', 'pièce',
 56.00, 159.00, 20.0, 12, 5, 'Roca', 'Sanitaires', false,
 ARRAY['Roca', 'Blanc', 'Standard'], NOW() - INTERVAL '1 year')),

(gen_random_uuid(), test_user_id, 'Baignoire acrylique 170cm', 'SAN-BAI-001',
 'Baignoire rectangulaire acrylique 170x75cm', 'pièce',
 234.00, 650.00, 20.0, 3, 1, 'Jacob Delafon', 'Sanitaires', false,
 ARRAY['Jacob Delafon', 'Acrylique'], NOW() - INTERVAL '8 months'),

(gen_random_uuid(), test_user_id, 'Receveur douche extra-plat', 'SAN-REC-001',
 'Receveur de douche 90x90cm hauteur 3cm', 'pièce',
 123.00, 340.00, 20.0, 7, 3, 'Villeroy & Boch', 'Sanitaires', true,
 ARRAY['Villeroy', 'Extra-plat', 'Design'], NOW() - INTERVAL '3 months'),

-- Tuyauterie
(gen_random_uuid(), test_user_id, 'Tube PER nu Ø16mm', 'TUY-PER-016',
 'Tube PER nu diamètre 16mm - couronne 50m', 'ml',
 0.45, 1.20, 20.0, 450, 100, 'Rehau', 'Tuyauterie', true,
 ARRAY['Rehau', 'PER', 'Couronne'], NOW() - INTERVAL '2 years'),

(gen_random_uuid(), test_user_id, 'Tube PER nu Ø20mm', 'TUY-PER-020',
 'Tube PER nu diamètre 20mm - couronne 50m', 'ml',
 0.65, 1.75, 20.0, 300, 80, 'Rehau', 'Tuyauterie', true,
 ARRAY['Rehau', 'PER'], NOW() - INTERVAL '2 years'),

(gen_random_uuid(), test_user_id, 'Tube cuivre écroui Ø14mm', 'TUY-CUI-014',
 'Tube cuivre écroui diamètre 14mm - barre 4m', 'ml',
 3.20, 8.50, 20.0, 160, 40, 'Comap', 'Tuyauterie', false,
 ARRAY['Comap', 'Cuivre'], NOW() - INTERVAL '3 years'),

(gen_random_uuid(), test_user_id, 'Multicouche Ø16mm', 'TUY-MUL-016',
 'Tube multicouche diamètre 16mm - couronne 50m', 'ml',
 0.75, 2.00, 20.0, 250, 60, 'Henco', 'Tuyauterie', true,
 ARRAY['Henco', 'Multicouche', 'Premium'], NOW() - INTERVAL '1 year')),

-- Raccords
(gen_random_uuid(), test_user_id, 'Raccord PER à compression', 'RAC-PER-001',
 'Raccord PER à compression Ø16mm - lot de 10', 'lot',
 12.50, 34.00, 20.0, 45, 15, 'Comap', 'Raccords', true,
 ARRAY['Comap', 'Compression'], NOW() - INTERVAL '1 year'),

(gen_random_uuid(), test_user_id, 'Té égal laiton 15/21', 'RAC-TEE-001',
 'Raccord en Té égal laiton 15/21 (1/2")', 'pièce',
 1.20, 3.50, 20.0, 120, 30, 'Boutte', 'Raccords', false,
 ARRAY['Laiton', 'Standard'], NOW() - INTERVAL '2 years'),

(gen_random_uuid(), test_user_id, 'Coude à sertir cuivre 90°', 'RAC-COU-001',
 'Coude à sertir cuivre 90° Ø14mm', 'pièce',
 2.30, 6.50, 20.0, 80, 20, 'Comap', 'Raccords', false,
 ARRAY['Comap', 'Sertir'], NOW() - INTERVAL '1 year')),

-- Chauffage
(gen_random_uuid(), test_user_id, 'Radiateur aluminium 600mm', 'CHA-RAD-001',
 'Radiateur aluminium hauteur 600mm - 8 éléments', 'pièce',
 89.00, 245.00, 20.0, 12, 4, 'Acova', 'Chauffage', true,
 ARRAY['Acova', 'Aluminium', 'Bestseller'], NOW() - INTERVAL '1 year')),

(gen_random_uuid(), test_user_id, 'Vanne thermostatique radiateur', 'CHA-VAN-001',
 'Tête thermostatique pour radiateur', 'pièce',
 23.00, 65.00, 20.0, 25, 10, 'Danfoss', 'Chauffage', true,
 ARRAY['Danfoss', 'Thermostatique'], NOW() - INTERVAL '6 months'),

(gen_random_uuid(), test_user_id, 'Collecteur chauffage sol 8 circuits', 'CHA-COL-001',
 'Collecteur pour plancher chauffant 8 départs', 'pièce',
 156.00, 425.00, 20.0, 4, 2, 'Oventrop', 'Chauffage', false,
 ARRAY['Oventrop', 'Collecteur'], NOW() - INTERVAL '8 months'),

-- Outils & Consommables
(gen_random_uuid(), test_user_id, 'Pâte à joint pot 500g', 'OUT-PAT-001',
 'Pâte à joint pour raccords filetés - pot 500g', 'pièce',
 8.50, 22.00, 20.0, 35, 10, 'Gebatout', 'Consommables', true,
 ARRAY['Gebatout', 'Joint'], NOW() - INTERVAL '3 years'),

(gen_random_uuid(), test_user_id, 'Téflon rouleau professionnel', 'OUT-TEF-001',
 'Ruban téflon PTFE largeur 19mm - rouleau 50m', 'pièce',
 4.20, 11.50, 20.0, 50, 15, 'Guilbert', 'Consommables', true,
 ARRAY['Téflon', 'Pro'], NOW() - INTERVAL '3 years'),

(gen_random_uuid(), test_user_id, 'Silicone sanitaire blanc', 'OUT-SIL-001',
 'Cartouche silicone sanitaire anti-moisissures 310ml', 'pièce',
 3.80, 10.50, 20.0, 60, 20, 'Rubson', 'Consommables', true,
 ARRAY['Rubson', 'Silicone', 'Blanc'], NOW() - INTERVAL '2 years');

-- =====================================================
-- 5. QUOTES (12 devis avec différents statuts)
-- =====================================================

-- We'll create quotes for different clients with realistic scenarios
-- This requires knowing client IDs, so we'll use a WITH clause

WITH quote_data AS (
  SELECT
    c.id as client_id,
    c.company_name as client_name,
    ROW_NUMBER() OVER (ORDER BY c.created_at) as row_num
  FROM clients c
  WHERE c.user_id = test_user_id
  LIMIT 12
)
INSERT INTO quotes (
  id, user_id, client_id, quote_number, subject, status,
  subtotal, discount_percentage, discount_amount, tax_amount, total,
  valid_until, notes, terms,
  created_at, updated_at
)
SELECT
  gen_random_uuid(),
  test_user_id,
  client_id,
  'DEV-2025-' || LPAD(row_num::TEXT, 4, '0'),
  CASE row_num
    WHEN 1 THEN 'Rénovation salle de bain'
    WHEN 2 THEN 'Installation chauffage central'
    WHEN 3 THEN 'Remplacement robinetterie cuisine'
    WHEN 4 THEN 'Réparation fuite et maintenance'
    WHEN 5 THEN 'Installation sanitaires neufs'
    WHEN 6 THEN 'Mise aux normes plomberie'
    WHEN 7 THEN 'Création salle d''eau'
    WHEN 8 THEN 'Entretien annuel système chauffage'
    WHEN 9 THEN 'Dépannage urgentfuite'
    WHEN 10 THEN 'Installation radiateurs neufs'
    WHEN 11 THEN 'Réfection complète sanitaires'
    WHEN 12 THEN 'Maintenance préventive'
  END,
  CASE row_num
    WHEN 1 THEN 'accepted'
    WHEN 2 THEN 'pending'
    WHEN 3 THEN 'accepted'
    WHEN 4 THEN 'sent'
    WHEN 5 THEN 'pending'
    WHEN 6 THEN 'rejected'
    WHEN 7 THEN 'accepted'
    WHEN 8 THEN 'sent'
    WHEN 9 THEN 'accepted'
    WHEN 10 THEN 'pending'
    WHEN 11 THEN 'draft'
    WHEN 12 THEN 'sent'
  END,
  CASE row_num
    WHEN 1 THEN 3250.00
    WHEN 2 THEN 8900.00
    WHEN 3 THEN 450.00
    WHEN 4 THEN 780.00
    WHEN 5 THEN 2100.00
    WHEN 6 THEN 1650.00
    WHEN 7 THEN 4200.00
    WHEN 8 THEN 590.00
    WHEN 9 THEN 320.00
    WHEN 10 THEN 3100.00
    WHEN 11 THEN 5600.00
    WHEN 12 THEN 890.00
  END,
  CASE row_num WHEN 1 THEN 5.0 WHEN 7 THEN 10.0 ELSE 0.0 END,
  CASE row_num
    WHEN 1 THEN 3250.00 * 0.05
    WHEN 7 THEN 4200.00 * 0.10
    ELSE 0.0
  END,
  CASE row_num
    WHEN 1 THEN (3250.00 - 3250.00 * 0.05) * 0.20
    WHEN 2 THEN 8900.00 * 0.20
    WHEN 3 THEN 450.00 * 0.20
    WHEN 4 THEN 780.00 * 0.20
    WHEN 5 THEN 2100.00 * 0.20
    WHEN 6 THEN 1650.00 * 0.20
    WHEN 7 THEN (4200.00 - 4200.00 * 0.10) * 0.20
    WHEN 8 THEN 590.00 * 0.20
    WHEN 9 THEN 320.00 * 0.20
    WHEN 10 THEN 3100.00 * 0.20
    WHEN 11 THEN 5600.00 * 0.20
    WHEN 12 THEN 890.00 * 0.20
  END,
  CASE row_num
    WHEN 1 THEN (3250.00 - 3250.00 * 0.05) * 1.20
    WHEN 2 THEN 8900.00 * 1.20
    WHEN 3 THEN 450.00 * 1.20
    WHEN 4 THEN 780.00 * 1.20
    WHEN 5 THEN 2100.00 * 1.20
    WHEN 6 THEN 1650.00 * 1.20
    WHEN 7 THEN (4200.00 - 4200.00 * 0.10) * 1.20
    WHEN 8 THEN 590.00 * 1.20
    WHEN 9 THEN 320.00 * 1.20
    WHEN 10 THEN 3100.00 * 1.20
    WHEN 11 THEN 5600.00 * 1.20
    WHEN 12 THEN 890.00 * 1.20
  END,
  NOW() + INTERVAL '30 days',
  CASE row_num
    WHEN 1 THEN 'Devis détaillé pour rénovation complète. Délai: 3 semaines'
    WHEN 2 THEN 'Installation sur 2 mois. Fournitures premium.'
    WHEN 9 THEN 'Intervention urgente réalisée. Devis établi a posteriori.'
    ELSE NULL
  END,
  'Conditions de paiement: 30% à la commande, 70% à la livraison. Garantie 2 ans pièces et main d''œuvre.',
  NOW() - INTERVAL '15 days' * row_num,
  NOW() - INTERVAL '14 days' * row_num
FROM quote_data;

-- =====================================================
-- 6. INVOICES (10 factures avec différents statuts)
-- =====================================================

WITH invoice_data AS (
  SELECT
    c.id as client_id,
    ROW_NUMBER() OVER (ORDER BY c.created_at) as row_num
  FROM clients c
  WHERE c.user_id = test_user_id
  LIMIT 10
)
INSERT INTO invoices (
  id, user_id, client_id, invoice_number, subject,
  issue_date, due_date, payment_date, status, payment_method,
  subtotal, discount_percentage, discount_amount, tax_amount, total,
  amount_paid, payment_status,
  notes, legal_mentions,
  created_at, updated_at
)
SELECT
  gen_random_uuid(),
  test_user_id,
  client_id,
  'FACT-2025-' || LPAD(row_num::TEXT, 4, '0'),
  CASE row_num
    WHEN 1 THEN 'Rénovation salle de bain - Solde'
    WHEN 2 THEN 'Remplacement robinetterie'
    WHEN 3 THEN 'Dépannage urgent'
    WHEN 4 THEN 'Installation chauffage - Acompte 30%'
    WHEN 5 THEN 'Création salle d''eau - Solde'
    WHEN 6 THEN 'Maintenance annuelle'
    WHEN 7 THEN 'Réparation fuite'
    WHEN 8 THEN 'Installation radiateurs - Acompte'
    WHEN 9 THEN 'Entretien système'
    WHEN 10 THEN 'Fourniture matériel'
  END,
  NOW() - INTERVAL '30 days' + (row_num * INTERVAL '3 days'),
  NOW() - INTERVAL '30 days' + (row_num * INTERVAL '3 days') + INTERVAL '30 days',
  CASE row_num
    WHEN 1 THEN NOW() - INTERVAL '25 days'
    WHEN 2 THEN NOW() - INTERVAL '20 days'
    WHEN 3 THEN NOW() - INTERVAL '28 days'
    WHEN 5 THEN NOW() - INTERVAL '15 days'
    WHEN 6 THEN NOW() - INTERVAL '10 days'
    ELSE NULL
  END,
  CASE row_num
    WHEN 1 THEN 'invoiced'
    WHEN 2 THEN 'invoiced'
    WHEN 3 THEN 'invoiced'
    WHEN 4 THEN 'invoiced'
    WHEN 5 THEN 'invoiced'
    WHEN 6 THEN 'invoiced'
    WHEN 7 THEN 'invoiced'
    WHEN 8 THEN 'draft'
    WHEN 9 THEN 'invoiced'
    WHEN 10 THEN 'draft'
  END,
  CASE row_num
    WHEN 1 THEN 'bank_transfer'
    WHEN 2 THEN 'check'
    WHEN 3 THEN 'cash'
    WHEN 5 THEN 'bank_transfer'
    WHEN 6 THEN 'card'
    ELSE NULL
  END,
  CASE row_num
    WHEN 1 THEN 2275.00  -- 70% of 3250
    WHEN 2 THEN 450.00
    WHEN 3 THEN 320.00
    WHEN 4 THEN 2670.00  -- 30% of 8900
    WHEN 5 THEN 2940.00  -- 70% of 4200
    WHEN 6 THEN 590.00
    WHEN 7 THEN 780.00
    WHEN 8 THEN 930.00   -- 30% of 3100
    WHEN 9 THEN 890.00
    WHEN 10 THEN 1250.00
  END,
  0.0, 0.0,
  CASE row_num
    WHEN 1 THEN 2275.00 * 0.20
    WHEN 2 THEN 450.00 * 0.20
    WHEN 3 THEN 320.00 * 0.20
    WHEN 4 THEN 2670.00 * 0.20
    WHEN 5 THEN 2940.00 * 0.20
    WHEN 6 THEN 590.00 * 0.20
    WHEN 7 THEN 780.00 * 0.20
    WHEN 8 THEN 930.00 * 0.20
    WHEN 9 THEN 890.00 * 0.20
    WHEN 10 THEN 1250.00 * 0.20
  END,
  CASE row_num
    WHEN 1 THEN 2275.00 * 1.20
    WHEN 2 THEN 450.00 * 1.20
    WHEN 3 THEN 320.00 * 1.20
    WHEN 4 THEN 2670.00 * 1.20
    WHEN 5 THEN 2940.00 * 1.20
    WHEN 6 THEN 590.00 * 1.20
    WHEN 7 THEN 780.00 * 1.20
    WHEN 8 THEN 930.00 * 1.20
    WHEN 9 THEN 890.00 * 1.20
    WHEN 10 THEN 1250.00 * 1.20
  END,
  CASE row_num
    WHEN 1 THEN 2275.00 * 1.20
    WHEN 2 THEN 450.00 * 1.20
    WHEN 3 THEN 320.00 * 1.20
    WHEN 5 THEN 2940.00 * 1.20
    WHEN 6 THEN 590.00 * 1.20
    ELSE 0.0
  END,
  CASE row_num
    WHEN 1 THEN 'paid'
    WHEN 2 THEN 'paid'
    WHEN 3 THEN 'paid'
    WHEN 4 THEN 'unpaid'
    WHEN 5 THEN 'paid'
    WHEN 6 THEN 'paid'
    WHEN 7 THEN 'overdue'
    WHEN 8 THEN 'unpaid'
    WHEN 9 THEN 'overdue'
    WHEN 10 THEN 'unpaid'
  END,
  CASE row_num
    WHEN 4 THEN 'Acompte de 30% sur installation chauffage'
    WHEN 7 THEN 'Facture en retard - relance envoyée'
    WHEN 9 THEN 'Client à relancer'
    ELSE NULL
  END,
  'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
  NOW() - INTERVAL '30 days' + (row_num * INTERVAL '3 days'),
  NOW() - INTERVAL '29 days' + (row_num * INTERVAL '3 days')
FROM invoice_data;

-- =====================================================
-- 7. PAYMENTS (6 paiements pour factures payées)
-- =====================================================

WITH payment_data AS (
  SELECT
    i.id as invoice_id,
    i.total,
    i.payment_date,
    i.payment_method,
    ROW_NUMBER() OVER (ORDER BY i.issue_date) as row_num
  FROM invoices i
  WHERE i.user_id = test_user_id
    AND i.payment_status = 'paid'
  LIMIT 6
)
INSERT INTO payments (
  id, user_id, invoice_id, amount, payment_method, payment_date,
  notes, created_at
)
SELECT
  gen_random_uuid(),
  test_user_id,
  invoice_id,
  total,
  payment_method,
  payment_date,
  CASE row_num
    WHEN 1 THEN 'Paiement reçu par virement bancaire'
    WHEN 2 THEN 'Chèque encaissé'
    WHEN 3 THEN 'Paiement comptant'
    WHEN 4 THEN 'Virement bancaire - référence incluse'
    WHEN 5 THEN 'Paiement par carte bancaire'
    ELSE NULL
  END,
  payment_date
FROM payment_data;

-- =====================================================
-- 8. CUSTOM TEMPLATES (3 modèles personnalisés)
-- =====================================================

INSERT INTO templates (
  id, user_id, template_name, template_type, content,
  is_default, created_at, updated_at
) VALUES
(
  gen_random_uuid(), test_user_id,
  'Devis Standard Plomberie',
  'quote',
  '{"header": "DEVIS", "sections": ["client_info", "line_items", "totals", "terms"], "footer": "Merci de votre confiance", "colors": {"primary": "#1E40AF", "secondary": "#F59E0B"}}',
  true,
  NOW() - INTERVAL '1 year',
  NOW() - INTERVAL '6 months'
),
(
  gen_random_uuid(), test_user_id,
  'Facture Premium',
  'invoice',
  '{"header": "FACTURE", "logo": true, "sections": ["company_info", "client_info", "line_items", "payment_info", "legal"], "footer": "Plomberie Pro Services - Expert depuis 2015", "colors": {"primary": "#0F172A", "accent": "#14B8A6"}}',
  true,
  NOW() - INTERVAL '1 year',
  NOW() - INTERVAL '3 months'
),
(
  gen_random_uuid(), test_user_id,
  'Contrat Maintenance Annuel',
  'quote',
  '{"header": "CONTRAT DE MAINTENANCE", "sections": ["client_info", "service_description", "schedule", "pricing", "terms"], "terms": "Contrat renouvelable tacitement. Préavis de résiliation: 3 mois.", "colors": {"primary": "#059669"}}',
  false,
  NOW() - INTERVAL '8 months',
  NOW() - INTERVAL '2 months'
);

-- =====================================================
-- 9. APPOINTMENTS (5 rendez-vous à venir)
-- =====================================================

WITH appointment_data AS (
  SELECT
    c.id as client_id,
    js.id as job_site_id,
    ROW_NUMBER() OVER (ORDER BY js.start_date) as row_num
  FROM clients c
  LEFT JOIN job_sites js ON js.client_id = c.id
  WHERE c.user_id = test_user_id
  LIMIT 5
)
INSERT INTO appointments (
  id, user_id, client_id, job_site_id, title, description,
  planned_eta, estimated_duration, status,
  notes, created_at
)
SELECT
  gen_random_uuid(),
  test_user_id,
  client_id,
  job_site_id,
  CASE row_num
    WHEN 1 THEN 'Intervention salle de bain'
    WHEN 2 THEN 'Rendez-vous commercial'
    WHEN 3 THEN 'Dépannage urgent'
    WHEN 4 THEN 'Maintenance préventive'
    WHEN 5 THEN 'Visite technique devis'
  END,
  CASE row_num
    WHEN 1 THEN 'Suite travaux rénovation - pose baignoire'
    WHEN 2 THEN 'Présentation devis installation chauffage'
    WHEN 3 THEN 'Fuite signalée par client - intervention rapide'
    WHEN 4 THEN 'Contrôle annuel système chauffage'
    WHEN 5 THEN 'Prise de mesures et évaluation travaux'
  END,
  CASE row_num
    WHEN 1 THEN NOW() + INTERVAL '2 days' + INTERVAL '9 hours'
    WHEN 2 THEN NOW() + INTERVAL '4 days' + INTERVAL '14 hours'
    WHEN 3 THEN NOW() + INTERVAL '1 day' + INTERVAL '10 hours'
    WHEN 4 THEN NOW() + INTERVAL '7 days' + INTERVAL '8 hours'
    WHEN 5 THEN NOW() + INTERVAL '10 days' + INTERVAL '15 hours'
  END,
  CASE row_num
    WHEN 1 THEN 180  -- 3 heures
    WHEN 2 THEN 60   -- 1 heure
    WHEN 3 THEN 120  -- 2 heures
    WHEN 4 THEN 90   -- 1.5 heures
    WHEN 5 THEN 45   -- 45 minutes
  END,
  CASE row_num
    WHEN 1 THEN 'scheduled'
    WHEN 2 THEN 'scheduled'
    WHEN 3 THEN 'urgent'
    WHEN 4 THEN 'scheduled'
    WHEN 5 THEN 'scheduled'
  END,
  CASE row_num
    WHEN 1 THEN 'Prévoir échelle et assistant'
    WHEN 2 THEN 'Apporter échantillons radiateurs'
    WHEN 3 THEN 'Intervention urgente - priorité haute'
    WHEN 4 THEN 'Contrôle standard'
    WHEN 5 THEN 'Premier contact - être ponctuel'
  END,
  NOW() - INTERVAL '7 days' + (row_num * INTERVAL '1 day')
FROM appointment_data;

RAISE NOTICE 'Seed data successfully created for test user: %', test_user_id;

END $$;

COMMIT;

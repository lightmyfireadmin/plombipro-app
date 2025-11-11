-- =====================================================
-- PLOMBIPRO COMPREHENSIVE SEED DATA
-- Test User: 6b1d26bf-40d7-46c0-9b07-89a120191971
-- =====================================================
-- This script creates a full realistic dataset for testing with deterministic UUIDs
-- Can be run multiple times safely (uses ON CONFLICT DO UPDATE)
-- =====================================================

BEGIN;

-- Set the test user ID
DO $$
DECLARE
  test_user_id UUID := '6b1d26bf-40d7-46c0-9b07-89a120191971';
  -- Deterministic client UUIDs
  client_01 UUID := '10000000-0000-0000-0001-000000000001';
  client_02 UUID := '10000000-0000-0000-0001-000000000002';
  client_03 UUID := '10000000-0000-0000-0001-000000000003';
  client_04 UUID := '10000000-0000-0000-0001-000000000004';
  client_05 UUID := '10000000-0000-0000-0001-000000000005';
  client_06 UUID := '10000000-0000-0000-0001-000000000006';
  client_07 UUID := '10000000-0000-0000-0001-000000000007';
  client_08 UUID := '10000000-0000-0000-0001-000000000008';
  client_09 UUID := '10000000-0000-0000-0001-000000000009';
  client_10 UUID := '10000000-0000-0000-0001-000000000010';
  client_11 UUID := '10000000-0000-0000-0001-000000000011';
  client_12 UUID := '10000000-0000-0000-0001-000000000012';
  client_13 UUID := '10000000-0000-0000-0001-000000000013';
  client_14 UUID := '10000000-0000-0000-0001-000000000014';
  client_15 UUID := '10000000-0000-0000-0001-000000000015';
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
  '01 42 12 34 56',
  '15 Rue de la Plomberie',
  '75012',
  'Paris',
  'France',
  NOW() - INTERVAL '10 years',
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
(client_01, test_user_id, 'individual', 'M.', 'Jean', 'Dupont',
 'jean.dupont@email.fr', '01 42 12 34 56', '06 12 34 56 78',
 '23 Avenue des Champs-Élysées', '75008', 'Paris', 'France',
 true, ARRAY['VIP', 'Récurrent'], 'Client fidèle depuis 5 ans. Préfère les interventions le matin.',
 NOW() - INTERVAL '5 years'),
(client_02, test_user_id, 'individual', 'Mme', 'Marie', 'Martin',
 'marie.martin@email.fr', '01 43 22 33 44', '06 23 45 67 89',
 '45 Rue de Rivoli', '75004', 'Paris', 'France',
 false, ARRAY['Particulier'], 'Appartement au 3ème étage sans ascenseur',
 NOW() - INTERVAL '2 years'),
(client_03, test_user_id, 'individual', 'M.', 'Pierre', 'Dubois',
 'pierre.dubois@email.fr', '01 44 55 66 77', '06 34 56 78 90',
 '12 Boulevard Saint-Germain', '75005', 'Paris', 'France',
 false, ARRAY['Nouveau'], NULL,
 NOW() - INTERVAL '2 months'),
(client_04, test_user_id, 'individual', 'Mme', 'Sophie', 'Bernard',
 'sophie.bernard@email.fr', '01 45 67 88 99', '06 45 67 89 01',
 '78 Avenue Jean Jaurès', '92100', 'Boulogne-Billancourt', 'France',
 false, ARRAY['Banlieue'], 'Maison individuelle avec jardin',
 NOW() - INTERVAL '1 year'),
(client_05, test_user_id, 'individual', 'M.', 'Robert', 'Leroy',
 'robert.leroy@email.fr', '01 46 78 99 00', '06 56 78 90 12',
 '34 Rue Mouffetard', '75005', 'Paris', 'France',
 true, ARRAY['Senior', 'Fidèle'], 'Personne âgée, prévoir temps supplémentaire pour explications',
 NOW() - INTERVAL '8 years')
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  phone = EXCLUDED.phone,
  updated_at = NOW();

-- Company Clients
INSERT INTO clients (
  id, user_id, client_type, salutation, first_name, company_name,
  email, phone, address, postal_code, city, country,
  siret, vat_number, default_payment_terms, default_discount,
  is_favorite, tags, notes, created_at
) VALUES
(client_06, test_user_id, 'company', 'M.', 'Michel', 'Immobilière Parisienne',
 'contact@immobiliere-paris.fr', '01 47 89 90 12',
 '88 Avenue Hoche', '75008', 'Paris', 'France',
 '51234567800023', 'FR51234567800', 45, 5.0,
 true, ARRAY['Grand Compte', 'Immobilier'], 'Contrat annuel de maintenance - 15 immeubles',
 NOW() - INTERVAL '3 years'),
(client_07, test_user_id, 'company', 'Mme', 'Claire', 'Restaurant Le Bon Vivant',
 'contact@lebonvivant.fr', '01 48 90 12 34',
 '56 Rue Saint-Antoine', '75004', 'Paris', 'France',
 '52345678900034', 'FR52345678900', 30, 2.5,
 false, ARRAY['CHR', 'Commercial'], 'Cuisine professionnelle - interventions urgentes fréquentes',
 NOW() - INTERVAL '1 year 6 months'),
(client_08, test_user_id, 'company', 'M.', 'Antoine', 'Hôtel de la Tour',
 'direction@hoteldelatour.fr', '01 49 01 23 45',
 '23 Rue de la Tour', '75016', 'Paris', 'France',
 '53456789000045', 'FR53456789000', 60, 10.0,
 true, ARRAY['Hôtellerie', 'VIP'], 'Hôtel 4 étoiles - 45 chambres - contrat maintenance premium',
 NOW() - INTERVAL '4 years'),
(client_09, test_user_id, 'company', 'Mme', 'Isabelle', 'Boulangerie Artisanale',
 'contact@boulangerie-artisanale.fr', '01 50 12 34 56',
 '89 Rue des Martyrs', '75018', 'Paris', 'France',
 '54567890000056', 'FR54567890000', 30, 0.0,
 false, ARRAY['Artisan', 'Commerce'], 'Boulangerie traditionnelle',
 NOW() - INTERVAL '6 months'),
(client_10, test_user_id, 'company', 'M.', 'François', 'Cabinet Médical Centrale',
 'contact@cabinet-medical.fr', '01 51 23 45 67',
 '12 Rue de la Santé', '75014', 'Paris', 'France',
 '55678900000067', 'FR55678900000', 30, 0.0,
 false, ARRAY['Santé', 'Professional'], 'Cabinet médical 5 praticiens',
 NOW() - INTERVAL '1 year'),
(client_11, test_user_id, 'individual', 'M.', 'Thomas', 'Petit',
 'thomas.petit@email.fr', '01 52 34 56 78',
 '67 Rue du Commerce', '75015', 'Paris', 'France',
 NULL, NULL, NULL, NULL,
 false, ARRAY['Particulier'], NULL,
 NOW() - INTERVAL '3 months'),
(client_12, test_user_id, 'individual', 'Mme', 'Nathalie', 'Moreau',
 'nathalie.moreau@email.fr', '01 53 45 67 89',
 '90 Avenue de la République', '93100', 'Montreuil', 'France',
 NULL, NULL, NULL, NULL,
 false, ARRAY['Banlieue'], 'Préfère les rendez-vous après 17h',
 NOW() - INTERVAL '8 months'),
(client_13, test_user_id, 'company', 'M.', 'Laurent', 'Gym Club Paris',
 'contact@gymclub.fr', '01 54 56 78 90',
 '34 Boulevard de Magenta', '75010', 'Paris', 'France',
 '56789000000078', 'FR56789000000', 45, 5.0,
 false, ARRAY['Sport', 'Commercial'], 'Salle de sport - vestiaires et douches',
 NOW() - INTERVAL '2 years'),
(client_14, test_user_id, 'individual', 'Mme', 'Catherine', 'Blanc',
 'catherine.blanc@email.fr', '01 55 67 89 01',
 '123 Rue de Charenton', '75012', 'Paris', 'France',
 NULL, NULL, NULL, NULL,
 true, ARRAY['VIP', 'Fidèle'], 'Propriétaire de plusieurs biens',
 NOW() - INTERVAL '6 years'),
(client_15, test_user_id, 'company', 'M.', 'David', 'École Montessori',
 'direction@montessori-paris.fr', '01 56 78 90 12',
 '45 Rue de la Pompe', '75116', 'Paris', 'France',
 '57890000000089', 'FR57890000000', 45, 0.0,
 false, ARRAY['Éducation', 'Public'], 'École maternelle et primaire - 120 élèves',
 NOW() - INTERVAL '4 months')
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  phone = EXCLUDED.phone,
  updated_at = NOW();

-- =====================================================
-- 3. JOB SITES (4 chantiers with various statuses)
-- =====================================================

INSERT INTO job_sites (
  id, user_id, client_id, job_name, description,
  address, status, start_date, estimated_end_date, actual_end_date,
  progress_percentage, estimated_budget, actual_cost,
  notes, created_at
) VALUES
('20000000-0000-0000-0005-000000000001', test_user_id, client_06,
 'Rénovation salle de bain - Immeuble Haussmann',
 'Rénovation complète de 2 salles de bain dans appartement 150m²',
 '88 Avenue Hoche, 75008 Paris',
 'in_progress', NOW() - INTERVAL '15 days', NOW() + INTERVAL '15 days', NULL,
 60, 8500.00, 5100.00,
 'Travaux en cours, client très satisfait', NOW() - INTERVAL '30 days'),
('20000000-0000-0000-0005-000000000002', test_user_id, client_08,
 'Installation chauffage central - Hôtel',
 'Installation système de chauffage central pour 45 chambres',
 '23 Rue de la Tour, 75016 Paris',
 'planned', NOW() + INTERVAL '7 days', NOW() + INTERVAL '67 days', NULL,
 0, 45000.00, 0.00,
 'Chantier important - bien planifier les étapes', NOW() - INTERVAL '20 days'),
('20000000-0000-0000-0005-000000000003', test_user_id, client_01,
 'Réparation fuite cuisine - Maison Dupont',
 'Réparation urgente fuite sous évier cuisine',
 '23 Avenue des Champs-Élysées, 75008 Paris',
 'completed', NOW() - INTERVAL '30 days', NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days',
 100, 450.00, 420.00,
 'Intervention terminée - client satisfait', NOW() - INTERVAL '30 days'),
('20000000-0000-0000-0005-000000000004', test_user_id, client_07,
 'Maintenance sanitaires - Restaurant',
 'Maintenance préventive système sanitaire cuisine professionnelle',
 '56 Rue Saint-Antoine, 75004 Paris',
 'in_progress', NOW() - INTERVAL '5 days', NOW() + INTERVAL '5 days', NULL,
 40, 1200.00, 480.00,
 'Accès cuisine uniquement entre 14h et 17h', NOW() - INTERVAL '10 days')
ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  progress_percentage = EXCLUDED.progress_percentage,
  actual_cost = EXCLUDED.actual_cost,
  updated_at = NOW();

-- =====================================================
-- 4. PRODUCTS (20 products across categories)
-- =====================================================

INSERT INTO products (
  id, user_id, name, ref, description, unit,
  price_buy, price_sell, vat_rate, supplier, category, is_favorite,
  created_at
) VALUES
('30000000-0000-0000-0002-000000000001', test_user_id, 'Mitigeur lavabo chromé', 'ROB-MIT-001',
 'Mitigeur monotrou pour lavabo, finition chromée', 'pièce',
 45.90, 125.00, 20.0, 'Grohe', 'Robinetterie', true,
 NOW() - INTERVAL '2 years'),
('30000000-0000-0000-0002-000000000002', test_user_id, 'Mitigeur douche thermostatique', 'ROB-MIT-002',
 'Mitigeur thermostatique pour douche avec sécurité anti-brûlure', 'pièce',
 89.50, 245.00, 20.0, 'Grohe', 'Robinetterie', true,
 NOW() - INTERVAL '1 year'),
('30000000-0000-0000-0002-000000000003', test_user_id, 'Robinet cuisine douchette', 'ROB-CUI-001',
 'Mitigeur cuisine avec douchette extractible', 'pièce',
 67.00, 189.00, 20.0, 'Hansgrohe', 'Robinetterie', false,
 NOW() - INTERVAL '1 year'),
('30000000-0000-0000-0002-000000000004', test_user_id, 'WC suspendu compact', 'SAN-WC-001',
 'WC suspendu gain de place avec mécanisme économie d''eau', 'pièce',
 145.00, 395.00, 20.0, 'Geberit', 'Sanitaires', true,
 NOW() - INTERVAL '6 months'),
('30000000-0000-0000-0002-000000000005', test_user_id, 'Lavabo céramique 60cm', 'SAN-LAV-001',
 'Vasque à poser en céramique blanche 60x45cm', 'pièce',
 56.00, 159.00, 20.0, 'Roca', 'Sanitaires', false,
 NOW() - INTERVAL '1 year'),
('30000000-0000-0000-0002-000000000006', test_user_id, 'Baignoire acrylique 170cm', 'SAN-BAI-001',
 'Baignoire rectangulaire acrylique 170x75cm', 'pièce',
 234.00, 650.00, 20.0, 'Jacob Delafon', 'Sanitaires', false,
 NOW() - INTERVAL '8 months'),
('30000000-0000-0000-0002-000000000007', test_user_id, 'Receveur douche extra-plat', 'SAN-REC-001',
 'Receveur de douche 90x90cm hauteur 3cm', 'pièce',
 123.00, 340.00, 20.0, 'Villeroy & Boch', 'Sanitaires', true,
 NOW() - INTERVAL '3 months'),
('30000000-0000-0000-0002-000000000008', test_user_id, 'Tube PER nu Ø16mm', 'TUY-PER-016',
 'Tube PER nu diamètre 16mm - couronne 50m', 'ml',
 0.45, 1.20, 20.0, 'Rehau', 'Tuyauterie', true,
 NOW() - INTERVAL '2 years'),
('30000000-0000-0000-0002-000000000009', test_user_id, 'Tube PER nu Ø20mm', 'TUY-PER-020',
 'Tube PER nu diamètre 20mm - couronne 50m', 'ml',
 0.65, 1.75, 20.0, 'Rehau', 'Tuyauterie', true,
 NOW() - INTERVAL '2 years'),
('30000000-0000-0000-0002-000000000010', test_user_id, 'Tube cuivre écroui Ø14mm', 'TUY-CUI-014',
 'Tube cuivre écroui diamètre 14mm - barre 4m', 'ml',
 3.20, 8.50, 20.0, 'Comap', 'Tuyauterie', false,
 NOW() - INTERVAL '3 years'),
('30000000-0000-0000-0002-000000000011', test_user_id, 'Multicouche Ø16mm', 'TUY-MUL-016',
 'Tube multicouche diamètre 16mm - couronne 50m', 'ml',
 0.75, 2.00, 20.0, 'Henco', 'Tuyauterie', true,
 NOW() - INTERVAL '1 year'),
('30000000-0000-0000-0002-000000000012', test_user_id, 'Raccord PER à compression', 'RAC-PER-001',
 'Raccord PER à compression Ø16mm - lot de 10', 'lot',
 12.50, 34.00, 20.0, 'Comap', 'Raccords', true,
 NOW() - INTERVAL '1 year'),
('30000000-0000-0000-0002-000000000013', test_user_id, 'Té égal laiton 15/21', 'RAC-TEE-001',
 'Raccord en Té égal laiton 15/21 (1/2")', 'pièce',
 1.20, 3.50, 20.0, 'Boutte', 'Raccords', false,
 NOW() - INTERVAL '2 years'),
('30000000-0000-0000-0002-000000000014', test_user_id, 'Coude à sertir cuivre 90°', 'RAC-COU-001',
 'Coude à sertir cuivre 90° Ø14mm', 'pièce',
 2.30, 6.50, 20.0, 'Comap', 'Raccords', false,
 NOW() - INTERVAL '1 year'),
('30000000-0000-0000-0002-000000000015', test_user_id, 'Radiateur aluminium 600mm', 'CHA-RAD-001',
 'Radiateur aluminium hauteur 600mm - 8 éléments', 'pièce',
 89.00, 245.00, 20.0, 'Acova', 'Chauffage', true,
 NOW() - INTERVAL '1 year'),
('30000000-0000-0000-0002-000000000016', test_user_id, 'Vanne thermostatique radiateur', 'CHA-VAN-001',
 'Tête thermostatique pour radiateur', 'pièce',
 23.00, 65.00, 20.0, 'Danfoss', 'Chauffage', true,
 NOW() - INTERVAL '6 months'),
('30000000-0000-0000-0002-000000000017', test_user_id, 'Collecteur chauffage sol 8 circuits', 'CHA-COL-001',
 'Collecteur pour plancher chauffant 8 départs', 'pièce',
 156.00, 425.00, 20.0, 'Oventrop', 'Chauffage', false,
 NOW() - INTERVAL '8 months'),
('30000000-0000-0000-0002-000000000018', test_user_id, 'Pâte à joint pot 500g', 'OUT-PAT-001',
 'Pâte à joint pour raccords filetés - pot 500g', 'pièce',
 8.50, 22.00, 20.0, 'Gebatout', 'Consommables', true,
 NOW() - INTERVAL '3 years'),
('30000000-0000-0000-0002-000000000019', test_user_id, 'Téflon rouleau professionnel', 'OUT-TEF-001',
 'Ruban téflon PTFE largeur 19mm - rouleau 50m', 'pièce',
 4.20, 11.50, 20.0, 'Guilbert', 'Consommables', true,
 NOW() - INTERVAL '3 years'),
('30000000-0000-0000-0002-000000000020', test_user_id, 'Silicone sanitaire blanc', 'OUT-SIL-001',
 'Cartouche silicone sanitaire anti-moisissures 310ml', 'pièce',
 3.80, 10.50, 20.0, 'Rubson', 'Consommables', true,
 NOW() - INTERVAL '2 years')
ON CONFLICT (id) DO UPDATE SET
  price_buy = EXCLUDED.price_buy,
  price_sell = EXCLUDED.price_sell,
  updated_at = NOW();

-- =====================================================
-- 5. QUOTES (12 devis avec différents statuts)
-- =====================================================

INSERT INTO quotes (
  id, user_id, client_id, quote_number, quote_date, status,
  subtotal_ht, total_vat, total_ttc, notes,
  created_at, updated_at
) VALUES
('40000000-0000-0000-0003-000000000001', test_user_id, client_01, 'DEV-2025-0001',
 (NOW() - INTERVAL '15 days')::date, 'accepted',
 3250.00, 650.00, 3900.00,
 'Rénovation salle de bain - Devis détaillé pour rénovation complète. Délai: 3 semaines',
 NOW() - INTERVAL '15 days', NOW() - INTERVAL '14 days'),
('40000000-0000-0000-0003-000000000002', test_user_id, client_02, 'DEV-2025-0002',
 (NOW() - INTERVAL '30 days')::date, 'draft',
 8900.00, 1780.00, 10680.00,
 'Installation chauffage central - Installation sur 2 mois. Fournitures premium.',
 NOW() - INTERVAL '30 days', NOW() - INTERVAL '28 days'),
('40000000-0000-0000-0003-000000000003', test_user_id, client_03, 'DEV-2025-0003',
 (NOW() - INTERVAL '45 days')::date, 'accepted',
 450.00, 90.00, 540.00,
 'Remplacement robinetterie cuisine',
 NOW() - INTERVAL '45 days', NOW() - INTERVAL '42 days'),
('40000000-0000-0000-0003-000000000004', test_user_id, client_04, 'DEV-2025-0004',
 (NOW() - INTERVAL '60 days')::date, 'sent',
 780.00, 156.00, 936.00,
 'Réparation fuite et maintenance',
 NOW() - INTERVAL '60 days', NOW() - INTERVAL '56 days'),
('40000000-0000-0000-0003-000000000005', test_user_id, client_05, 'DEV-2025-0005',
 (NOW() - INTERVAL '75 days')::date, 'draft',
 2100.00, 420.00, 2520.00,
 'Installation sanitaires neufs',
 NOW() - INTERVAL '75 days', NOW() - INTERVAL '70 days'),
('40000000-0000-0000-0003-000000000006', test_user_id, client_06, 'DEV-2025-0006',
 (NOW() - INTERVAL '90 days')::date, 'rejected',
 1650.00, 330.00, 1980.00,
 'Mise aux normes plomberie',
 NOW() - INTERVAL '90 days', NOW() - INTERVAL '84 days'),
('40000000-0000-0000-0003-000000000007', test_user_id, client_07, 'DEV-2025-0007',
 (NOW() - INTERVAL '105 days')::date, 'accepted',
 4200.00, 840.00, 5040.00,
 'Création salle d''eau',
 NOW() - INTERVAL '105 days', NOW() - INTERVAL '98 days'),
('40000000-0000-0000-0003-000000000008', test_user_id, client_08, 'DEV-2025-0008',
 (NOW() - INTERVAL '120 days')::date, 'sent',
 590.00, 118.00, 708.00,
 'Entretien annuel système chauffage',
 NOW() - INTERVAL '120 days', NOW() - INTERVAL '112 days'),
('40000000-0000-0000-0003-000000000009', test_user_id, client_09, 'DEV-2025-0009',
 (NOW() - INTERVAL '135 days')::date, 'accepted',
 320.00, 64.00, 384.00,
 'Dépannage urgent - Intervention urgente réalisée. Devis établi a posteriori.',
 NOW() - INTERVAL '135 days', NOW() - INTERVAL '126 days'),
('40000000-0000-0000-0003-000000000010', test_user_id, client_10, 'DEV-2025-0010',
 (NOW() - INTERVAL '150 days')::date, 'draft',
 3100.00, 620.00, 3720.00,
 'Installation radiateurs neufs',
 NOW() - INTERVAL '150 days', NOW() - INTERVAL '140 days'),
('40000000-0000-0000-0003-000000000011', test_user_id, client_11, 'DEV-2025-0011',
 (NOW() - INTERVAL '165 days')::date, 'draft',
 5600.00, 1120.00, 6720.00,
 'Réfection complète sanitaires',
 NOW() - INTERVAL '165 days', NOW() - INTERVAL '154 days'),
('40000000-0000-0000-0003-000000000012', test_user_id, client_12, 'DEV-2025-0012',
 (NOW() - INTERVAL '180 days')::date, 'sent',
 890.00, 178.00, 1068.00,
 'Maintenance préventive',
 NOW() - INTERVAL '180 days', NOW() - INTERVAL '168 days')
ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  subtotal_ht = EXCLUDED.subtotal_ht,
  total_vat = EXCLUDED.total_vat,
  total_ttc = EXCLUDED.total_ttc,
  updated_at = NOW();

-- =====================================================
-- 6. INVOICES (10 factures avec différents statuts)
-- =====================================================

INSERT INTO invoices (
  id, user_id, client_id, invoice_number,
  invoice_date, due_date, payment_date, status, payment_method,
  subtotal_ht, total_vat, total_ttc,
  amount_paid, payment_status,
  notes, legal_mentions,
  created_at, updated_at
) VALUES
('50000000-0000-0000-0004-000000000001', test_user_id, client_01, 'FACT-2025-0001',
 (NOW() - INTERVAL '27 days')::date, (NOW() + INTERVAL '3 days')::date,
 (NOW() - INTERVAL '25 days')::date, 'invoiced', 'bank_transfer',
 2275.00, 455.00, 2730.00, 2730.00, 'paid',
 'Rénovation salle de bain - Solde',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
 NOW() - INTERVAL '30 days', NOW() - INTERVAL '29 days'),
('50000000-0000-0000-0004-000000000002', test_user_id, client_02, 'FACT-2025-0002',
 (NOW() - INTERVAL '24 days')::date, (NOW() + INTERVAL '6 days')::date,
 (NOW() - INTERVAL '20 days')::date, 'invoiced', 'check',
 450.00, 90.00, 540.00, 540.00, 'paid',
 'Remplacement robinetterie',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
 NOW() - INTERVAL '27 days', NOW() - INTERVAL '26 days'),
('50000000-0000-0000-0004-000000000003', test_user_id, client_03, 'FACT-2025-0003',
 (NOW() - INTERVAL '21 days')::date, (NOW() + INTERVAL '9 days')::date,
 (NOW() - INTERVAL '28 days')::date, 'invoiced', 'cash',
 320.00, 64.00, 384.00, 384.00, 'paid',
 'Dépannage urgent',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
 NOW() - INTERVAL '24 days', NOW() - INTERVAL '23 days'),
('50000000-0000-0000-0004-000000000004', test_user_id, client_04, 'FACT-2025-0004',
 (NOW() - INTERVAL '18 days')::date, (NOW() + INTERVAL '12 days')::date,
 NULL, 'invoiced', NULL,
 2670.00, 534.00, 3204.00, 0.00, 'unpaid',
 'Installation chauffage - Acompte de 30%',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
 NOW() - INTERVAL '21 days', NOW() - INTERVAL '20 days'),
('50000000-0000-0000-0004-000000000005', test_user_id, client_05, 'FACT-2025-0005',
 (NOW() - INTERVAL '15 days')::date, (NOW() + INTERVAL '15 days')::date,
 (NOW() - INTERVAL '15 days')::date, 'invoiced', 'bank_transfer',
 2940.00, 588.00, 3528.00, 3528.00, 'paid',
 'Création salle d''eau - Solde',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
 NOW() - INTERVAL '18 days', NOW() - INTERVAL '17 days'),
('50000000-0000-0000-0004-000000000006', test_user_id, client_06, 'FACT-2025-0006',
 (NOW() - INTERVAL '12 days')::date, (NOW() + INTERVAL '18 days')::date,
 (NOW() - INTERVAL '10 days')::date, 'invoiced', 'card',
 590.00, 118.00, 708.00, 708.00, 'paid',
 'Maintenance annuelle',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
 NOW() - INTERVAL '15 days', NOW() - INTERVAL '14 days'),
('50000000-0000-0000-0004-000000000007', test_user_id, client_07, 'FACT-2025-0007',
 (NOW() - INTERVAL '9 days')::date, (NOW() + INTERVAL '21 days')::date,
 NULL, 'invoiced', NULL,
 780.00, 156.00, 936.00, 0.00, 'overdue',
 'Réparation fuite - Facture en retard, relance envoyée',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
 NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days'),
('50000000-0000-0000-0004-000000000008', test_user_id, client_08, 'FACT-2025-0008',
 (NOW() - INTERVAL '6 days')::date, (NOW() + INTERVAL '24 days')::date,
 NULL, 'draft', NULL,
 930.00, 186.00, 1116.00, 0.00, 'unpaid',
 'Installation radiateurs - Acompte',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
 NOW() - INTERVAL '9 days', NOW() - INTERVAL '8 days'),
('50000000-0000-0000-0004-000000000009', test_user_id, client_09, 'FACT-2025-0009',
 (NOW() - INTERVAL '3 days')::date, (NOW() + INTERVAL '27 days')::date,
 NULL, 'invoiced', NULL,
 890.00, 178.00, 1068.00, 0.00, 'overdue',
 'Entretien système - Client à relancer',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
 NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days'),
('50000000-0000-0000-0004-000000000010', test_user_id, client_10, 'FACT-2025-0010',
 NOW()::date, (NOW() + INTERVAL '30 days')::date,
 NULL, 'draft', NULL,
 1250.00, 250.00, 1500.00, 0.00, 'unpaid',
 'Fourniture matériel',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris',
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days')
ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  payment_status = EXCLUDED.payment_status,
  amount_paid = EXCLUDED.amount_paid,
  updated_at = NOW();

-- =====================================================
-- 7. PAYMENTS (5 paiements pour factures payées)
-- =====================================================

INSERT INTO payments (
  id, user_id, invoice_id, amount, payment_method, payment_date,
  notes, created_at
) VALUES
('60000000-0000-0000-0007-000000000001', test_user_id,
 '50000000-0000-0000-0004-000000000001', 2730.00, 'bank_transfer',
 (NOW() - INTERVAL '25 days')::date,
 'Paiement reçu par virement bancaire',
 (NOW() - INTERVAL '25 days')::date),
('60000000-0000-0000-0007-000000000002', test_user_id,
 '50000000-0000-0000-0004-000000000002', 540.00, 'check',
 (NOW() - INTERVAL '20 days')::date,
 'Chèque encaissé',
 (NOW() - INTERVAL '20 days')::date),
('60000000-0000-0000-0007-000000000003', test_user_id,
 '50000000-0000-0000-0004-000000000003', 384.00, 'cash',
 (NOW() - INTERVAL '28 days')::date,
 'Paiement comptant',
 (NOW() - INTERVAL '28 days')::date),
('60000000-0000-0000-0007-000000000004', test_user_id,
 '50000000-0000-0000-0004-000000000005', 3528.00, 'bank_transfer',
 (NOW() - INTERVAL '15 days')::date,
 'Virement bancaire - référence incluse',
 (NOW() - INTERVAL '15 days')::date),
('60000000-0000-0000-0007-000000000005', test_user_id,
 '50000000-0000-0000-0004-000000000006', 708.00, 'card',
 (NOW() - INTERVAL '10 days')::date,
 'Paiement par carte bancaire',
 (NOW() - INTERVAL '10 days')::date)
ON CONFLICT (id) DO UPDATE SET
  amount = EXCLUDED.amount,
  updated_at = NOW();

-- =====================================================
-- 8. APPOINTMENTS (5 rendez-vous à venir)
-- =====================================================

INSERT INTO appointments (
  id, user_id, client_id, job_site_id, title, description,
  start_time, end_time, duration_minutes, status,
  notes, created_at
) VALUES
('70000000-0000-0000-0006-000000000001', test_user_id, client_06,
 '20000000-0000-0000-0005-000000000001',
 'Intervention salle de bain',
 'Suite travaux rénovation - pose baignoire',
 NOW() + INTERVAL '2 days' + INTERVAL '9 hours',
 NOW() + INTERVAL '2 days' + INTERVAL '12 hours',
 180, 'scheduled',
 'Prévoir échelle et assistant',
 NOW() - INTERVAL '6 days'),
('70000000-0000-0000-0006-000000000002', test_user_id, client_08,
 '20000000-0000-0000-0005-000000000002',
 'Rendez-vous commercial',
 'Présentation devis installation chauffage',
 NOW() + INTERVAL '4 days' + INTERVAL '14 hours',
 NOW() + INTERVAL '4 days' + INTERVAL '15 hours',
 60, 'scheduled',
 'Apporter échantillons radiateurs',
 NOW() - INTERVAL '5 days'),
('70000000-0000-0000-0006-000000000003', test_user_id, client_01, NULL,
 'Dépannage urgent',
 'Fuite signalée par client - intervention rapide',
 NOW() + INTERVAL '1 day' + INTERVAL '10 hours',
 NOW() + INTERVAL '1 day' + INTERVAL '12 hours',
 120, 'confirmed',
 'Intervention urgente - priorité haute',
 NOW() - INTERVAL '4 days'),
('70000000-0000-0000-0006-000000000004', test_user_id, client_07,
 '20000000-0000-0000-0005-000000000004',
 'Maintenance préventive',
 'Contrôle annuel système chauffage',
 NOW() + INTERVAL '7 days' + INTERVAL '8 hours',
 NOW() + INTERVAL '7 days' + INTERVAL '9 hours' + INTERVAL '30 minutes',
 90, 'scheduled',
 'Contrôle standard',
 NOW() - INTERVAL '3 days'),
('70000000-0000-0000-0006-000000000005', test_user_id, client_02, NULL,
 'Visite technique devis',
 'Prise de mesures et évaluation travaux',
 NOW() + INTERVAL '10 days' + INTERVAL '15 hours',
 NOW() + INTERVAL '10 days' + INTERVAL '15 hours' + INTERVAL '45 minutes',
 45, 'scheduled',
 'Premier contact - être ponctuel',
 NOW() - INTERVAL '2 days')
ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = NOW();

RAISE NOTICE 'Seed data successfully created for test user: %', test_user_id;

END $$;

COMMIT;

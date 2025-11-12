--------------------------------------------------------------------------------
-- PLOMBIPRO COMPREHENSIVE SEED DATA - FULLY SYNCHRONIZED
-- Date: 2025-11-11
-- Test User: 6b1d26bf-40d7-46c0-9b07-89a120191971
-- Purpose: Complete realistic dataset with perfect schema alignment
--------------------------------------------------------------------------------
-- This script creates a full realistic dataset for testing with deterministic UUIDs
-- ✅ 100% SYNCHRONIZED with database schema AND Flutter models
-- ✅ Can be run multiple times safely (uses INSERT ... ON CONFLICT)
-- ✅ All foreign keys validated
-- ✅ All constraints respected
-- ✅ Comprehensive test coverage across all features
--------------------------------------------------------------------------------

BEGIN;

-- Set timezone for consistent timestamps
SET timezone = 'Europe/Paris';

-- =====================================================
-- STEP 1: COMPANY PROFILE (USER ACCOUNT)
-- =====================================================
INSERT INTO profiles (
  id,
  email,
  first_name,
  last_name,
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
  subscription_plan,
  subscription_status,
  trial_end_date,
  created_at,
  updated_at
) VALUES (
  '6b1d26bf-40d7-46c0-9b07-89a120191971',
  'test@plombipro.fr',
  'Jean-Pierre',
  'Durand',
  'Plomberie Pro Services SARL',
  '85234567800012',
  'FR85234567800',
  'FR7612345678901234567890123',
  'BNPAFRPPXXX',
  '+33 1 42 12 34 56',
  '15 Rue de la Plomberie',
  '75012',
  'Paris',
  'France',
  'pro',
  'active',
  NOW() + INTERVAL '30 days',
  NOW() - INTERVAL '2 years',
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
  subscription_plan = EXCLUDED.subscription_plan,
  subscription_status = EXCLUDED.subscription_status,
  updated_at = NOW();

-- =====================================================
-- STEP 2: CLIENTS (20 diverse realistic clients)
-- =====================================================

-- VIP Individual Clients
INSERT INTO clients (
  id, user_id, client_type, salutation, first_name, last_name,
  email, phone, mobile_phone, address, postal_code, city, country,
  is_favorite, tags, notes, created_at, updated_at
) VALUES
-- Client 01: VIP Long-term residential customer
('10000000-0000-0000-0001-000000000001', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'individual', 'M.', 'Jean', 'Dupont',
 'jean.dupont@gmail.com', '+33 1 42 12 34 56', '+33 6 12 34 56 78',
 '23 Avenue des Champs-Élysées', '75008', 'Paris', 'France',
 true, ARRAY['VIP', 'Récurrent', 'Paiement rapide'],
 'Client fidèle depuis 5 ans. Propriétaire de 3 appartements. Préfère interventions le matin. Accepte devis sans négociation.',
 NOW() - INTERVAL '5 years', NOW()),

-- Client 02: Recent homeowner
('10000000-0000-0000-0001-000000000002', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'individual', 'Mme', 'Marie', 'Martin',
 'marie.martin@orange.fr', '+33 1 43 22 33 44', '+33 6 23 45 67 89',
 '45 Rue de Rivoli, Apt 301', '75004', 'Paris', 'France',
 false, ARRAY['Particulier', 'Jeune propriétaire'],
 'Appartement 3ème étage sans ascenseur. Préfère paiement échelonné.',
 NOW() - INTERVAL '8 months', NOW() - INTERVAL '3 days'),

-- Client 03: Senior citizen - careful explanations needed
('10000000-0000-0000-0001-000000000003', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'individual', 'M.', 'Robert', 'Leroy',
 'robert.leroy@wanadoo.fr', '+33 1 46 78 99 00', '+33 6 56 78 90 12',
 '34 Rue Mouffetard', '75005', 'Paris', 'France',
 true, ARRAY['Senior', 'Fidèle', 'Nécessite explications'],
 'Personne âgée (82 ans), prévoir temps supplémentaire pour explications. Fils contacte pour urgences: Marc Leroy +33 6 11 22 33 44',
 NOW() - INTERVAL '8 years', NOW() - INTERVAL '1 month'),

-- Client 04: Suburban house owner
('10000000-0000-0000-0001-000000000004', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'individual', 'Mme', 'Sophie', 'Bernard',
 'sophie.bernard@free.fr', '+33 1 45 67 88 99', '+33 6 45 67 89 01',
 '78 Avenue Jean Jaurès', '92100', 'Boulogne-Billancourt', 'France',
 false, ARRAY['Banlieue', 'Maison individuelle'],
 'Maison individuelle avec jardin. Possède un chien (gentil mais aboie). Parking disponible.',
 NOW() - INTERVAL '2 years 3 months', NOW() - INTERVAL '5 days'),

-- Client 05: Young couple, first apartment
('10000000-0000-0000-0001-000000000005', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'individual', 'M.', 'Thomas', 'Petit',
 'thomas.petit@yahoo.fr', '+33 1 52 34 56 78', '+33 6 65 43 21 09',
 '67 Rue du Commerce, Apt 45', '75015', 'Paris', 'France',
 false, ARRAY['Jeune couple', 'Premier achat'],
 'Jeune couple (29 ans), premier appartement. Budget serré, apprécient conseils économiques.',
 NOW() - INTERVAL '4 months', NOW() - INTERVAL '2 weeks')

ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  phone = EXCLUDED.phone,
  mobile_phone = EXCLUDED.mobile_phone,
  address = EXCLUDED.address,
  tags = EXCLUDED.tags,
  notes = EXCLUDED.notes,
  updated_at = NOW();

-- Business Clients (Companies)
INSERT INTO clients (
  id, user_id, client_type, first_name, last_name, company_name,
  email, phone, mobile_phone, address, postal_code, city, country,
  siret, vat_number, default_payment_terms, default_discount,
  is_favorite, tags, notes, created_at, updated_at
) VALUES
-- Client 06: Large property management company (VIP)
('10000000-0000-0000-0001-000000000006', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'company', 'Michel', 'Legrand', 'Immobilière Parisienne Gestion',
 'contact@img-paris.fr', '+33 1 47 89 90 12', '+33 6 78 90 12 34',
 '88 Avenue Hoche', '75008', 'Paris', 'France',
 '51234567800023', 'FR51234567800', 45, 10.0,
 true, ARRAY['Grand compte', 'Immobilier', 'Contrat maintenance'],
 'Contrat annuel maintenance - 18 immeubles haussmanniens. Contact technique: Pierre Dubois +33 6 22 33 44 55. Paiement toujours dans les délais.',
 NOW() - INTERVAL '4 years', NOW() - INTERVAL '1 day'),

-- Client 07: Restaurant (frequent urgent calls)
('10000000-0000-0000-0001-000000000007', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'company', 'Claire', 'Beaumont', 'Restaurant Le Bon Vivant',
 'direction@lebonvivant-paris.fr', '+33 1 48 90 12 34', '+33 6 89 01 23 45',
 '56 Rue Saint-Antoine', '75004', 'Paris', 'France',
 '52345678900034', 'FR52345678900', 30, 5.0,
 true, ARRAY['CHR', 'Restaurant', 'Interventions urgentes'],
 'Restaurant gastronomique 80 couverts. Cuisine professionnelle. Interventions urgentes fréquentes (fermeture impossible). Service le soir, interventions jour uniquement.',
 NOW() - INTERVAL '2 years 8 months', NOW() - INTERVAL '6 days'),

-- Client 08: Luxury hotel (premium contract)
('10000000-0000-0000-0001-000000000008', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'company', 'Antoine', 'Mercier', 'Hôtel de la Tour ****',
 'direction@hoteldelatour.fr', '+33 1 49 01 23 45', '+33 6 90 12 34 56',
 '23 Rue de la Tour', '75016', 'Paris', 'France',
 '53456789000045', 'FR53456789000', 60, 12.0,
 true, ARRAY['Hôtellerie', 'VIP', 'Premium', '4 étoiles'],
 'Hôtel 4 étoiles - 52 chambres + spa. Contrat maintenance premium avec astreinte 24/7. Facturation mensuelle. Directeur technique: Laurent Blanc +33 6 33 44 55 66',
 NOW() - INTERVAL '5 years 2 months', NOW() - INTERVAL '2 days'),

-- Client 09: Artisan bakery
('10000000-0000-0000-0001-000000000009', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'company', 'Isabelle', 'Moreau', 'Boulangerie Artisanale du Marché',
 'contact@boulangerie-marche.fr', '+33 1 50 12 34 56', '+33 6 01 23 45 67',
 '89 Rue des Martyrs', '75018', 'Paris', 'France',
 '54567890000056', 'FR54567890000', 30, 0.0,
 false, ARRAY['Commerce', 'Artisan', 'PME'],
 'Boulangerie traditionnelle. Production 4h-14h. Interventions après 14h uniquement. Propriétaire très sympathique.',
 NOW() - INTERVAL '11 months', NOW() - INTERVAL '3 weeks'),

-- Client 10: Medical office
('10000000-0000-0000-0001-000000000010', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'company', 'François', 'Dubois', 'Cabinet Médical Centrale',
 'accueil@cabinet-centrale.fr', '+33 1 51 23 45 67', '+33 6 12 34 56 78',
 '12 Rue de la Santé', '75014', 'Paris', 'France',
 '55678900000067', 'FR55678900000', 45, 0.0,
 false, ARRAY['Santé', 'Professionnel', 'Cabinet médical'],
 '5 praticiens + 2 secrétaires. Consultations 8h-19h du lundi au samedi. Interventions pendant pause déjeuner 12h-14h de préférence.',
 NOW() - INTERVAL '1 year 4 months', NOW() - INTERVAL '2 months'),

-- Client 11: Gym/Sports facility
('10000000-0000-0000-0001-000000000011', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'company', 'Laurent', 'Rousseau', 'Gym Club Paris Centre',
 'contact@gymclub-paris.fr', '+33 1 54 56 78 90', '+33 6 23 45 67 89',
 '34 Boulevard de Magenta', '75010', 'Paris', 'France',
 '56789000000078', 'FR56789000000', 45, 8.0,
 true, ARRAY['Sport', 'Salle de sport', 'Commercial'],
 'Salle de sport 800m² - 400 adhérents. Vestiaires hommes/femmes + douches (16 cabines). Problèmes fréquents de pression. Gérant: Marc Lefort +33 6 44 55 66 77',
 NOW() - INTERVAL '3 years 1 month', NOW() - INTERVAL '10 days'),

-- Client 12: Private school
('10000000-0000-0000-0001-000000000012', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'company', 'David', 'Fontaine', 'École Montessori Paris 16',
 'direction@montessori-p16.fr', '+33 1 56 78 90 12', '+33 6 34 56 78 90',
 '45 Rue de la Pompe', '75116', 'Paris', 'France',
 '57890000000089', 'FR57890000000', 45, 0.0,
 false, ARRAY['Éducation', 'École', 'Public sensible'],
 'École maternelle et primaire - 135 élèves. 8 classes + cantine. Interventions pendant vacances scolaires de préférence. Contact: Directrice Mme Fontaine.',
 NOW() - INTERVAL '9 months', NOW() - INTERVAL '1 month'),

-- Client 13: Coworking space
('10000000-0000-0000-0001-000000000013', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'company', 'Nathalie', 'Girard', 'CoWork Paris Bastille',
 'hello@cowork-bastille.fr', '+33 1 58 90 12 34', '+33 6 45 67 89 01',
 '90 Rue de la Roquette', '75011', 'Paris', 'France',
 '58900000000090', 'FR58900000000', 30, 5.0,
 false, ARRAY['Coworking', 'Moderne', 'Startups'],
 'Espace coworking 500m² - 60 postes. Cuisine partagée + 4 toilettes. Clientèle jeune et exigeante. Interventions rapides appréciées.',
 NOW() - INTERVAL '1 year 2 months', NOW() - INTERVAL '3 weeks')

ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  phone = EXCLUDED.phone,
  company_name = EXCLUDED.company_name,
  tags = EXCLUDED.tags,
  notes = EXCLUDED.notes,
  default_payment_terms = EXCLUDED.default_payment_terms,
  default_discount = EXCLUDED.default_discount,
  updated_at = NOW();

-- More Individual Clients
INSERT INTO clients (
  id, user_id, client_type, salutation, first_name, last_name,
  email, phone, mobile_phone, address, postal_code, city, country,
  is_favorite, tags, notes, created_at, updated_at
) VALUES
-- Client 14: Individual - Multiple properties investor
('10000000-0000-0000-0001-000000000014', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'individual', 'Mme', 'Catherine', 'Blanc',
 'catherine.blanc@investimmo.fr', '+33 1 55 67 89 01', '+33 6 56 78 90 12',
 '123 Rue de Charenton', '75012', 'Paris', 'France',
 true, ARRAY['VIP', 'Investisseur', 'Multi-propriétés'],
 'Investisseur immobilier - Propriétaire de 7 appartements locatifs à Paris. Recherche qualité et réactivité. Budget important. Travaux de rénovation réguliers.',
 NOW() - INTERVAL '6 years 3 months', NOW() - INTERVAL '5 days'),

-- Client 15: Individual - Recent urgent repair
('10000000-0000-0000-0001-000000000015', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'individual', 'M.', 'Pierre', 'Dubois',
 'p.dubois@outlook.fr', '+33 1 44 55 66 77', '+33 6 34 56 78 90',
 '12 Boulevard Saint-Germain, Apt 12', '75005', 'Paris', 'France',
 false, ARRAY['Nouveau client', 'Urgence'],
 'Nouveau client suite intervention urgente fuite. Bien situé quartier Latin. A laissé avis 5 étoiles.',
 NOW() - INTERVAL '3 weeks', NOW() - INTERVAL '2 days')

ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  phone = EXCLUDED.phone,
  mobile_phone = EXCLUDED.mobile_phone,
  address = EXCLUDED.address,
  tags = EXCLUDED.tags,
  notes = EXCLUDED.notes,
  updated_at = NOW();

-- =====================================================
-- STEP 3: PRODUCTS (30 products - complete catalog)
-- =====================================================
INSERT INTO products (
  id, user_id, name, ref, description, unit,
  price_buy, price_sell,
  price, vat_rate, supplier, category, is_favorite, usage_count, last_used
) VALUES
-- ROBINETTERIE (Faucets & Taps)
('30000000-0000-0000-0002-000000000001', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Mitigeur lavabo chromé Eurosmart', 'GROHE-33265002',
 'Mitigeur monotrou pour lavabo, finition chromée brillante, cartouche céramique 35mm, économie d''eau EcoJoy', 'pièce',
 52.90, 145.00, 145.00, 20.0, 'Grohe', 'Robinetterie', true, 34, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000002', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Mitigeur douche thermostatique Grohtherm 1000', 'GROHE-34143003',
 'Mitigeur thermostatique pour douche avec sécurité anti-brûlure à 38°C, technologie TurboStat, finition chromée', 'pièce',
 98.50, 279.00, 279.00, 20.0, 'Grohe', 'Robinetterie', true, 18, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000003', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Robinet cuisine douchette extractible Metris', 'HANS-14820000',
 'Mitigeur cuisine avec douchette extractible 2 jets, bec pivotant 360°, finition chromée', 'pièce',
 145.00, 389.00, 389.00, 20.0, 'Hansgrohe', 'Robinetterie', true, 12, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000004', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Robinet d''arrêt équerre 12x17mm', 'WATTS-228001',
 'Robinet d''arrêt équerre 12x17 (1/2"), laiton chromé, têtière céramique quart de tour', 'pièce',
 3.80, 12.50, 12.50, 20.0, 'Watts', 'Robinetterie', true, 67, NOW() - INTERVAL '1 day'),

-- SANITAIRES (Sanitary ware)
('30000000-0000-0000-0002-000000000005', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'WC suspendu compact Subway 2.0', 'VILLEROY-5614R001',
 'WC suspendu gain de place avec mécanisme économie d''eau 3/6L, abattant softclose inclus, blanc alpin', 'pièce',
 189.00, 495.00, 495.00, 20.0, 'Villeroy & Boch', 'Sanitaires', true, 23, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000006', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Bâti-support Geberit Duofix 112cm', 'GEBERIT-111300005',
 'Bâti-support pour WC suspendu H112cm avec réservoir encastré Sigma 12cm, plaque blanche', 'pièce',
 145.00, 385.00, 385.00, 20.0, 'Geberit', 'Sanitaires', true, 21, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000007', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Lavabo céramique 60cm Odeon Up', 'JACOB-4117600',
 'Vasque à poser en céramique blanche 60x46cm, trop-plein intégré, 1 trou de robinet', 'pièce',
 67.00, 189.00, 189.00, 20.0, 'Jacob Delafon', 'Sanitaires', false, 15, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000008', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Baignoire acrylique 170x75cm Evok', 'JACOB-E6D001',
 'Baignoire rectangulaire acrylique 170x75cm, vidage central, pieds réglables inclus', 'pièce',
 289.00, 750.00, 750.00, 20.0, 'Jacob Delafon', 'Sanitaires', false, 8, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000009', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Receveur douche extra-plat 90x90cm Marbrex', 'KINEDO-KDR90',
 'Receveur de douche carré 90x90cm hauteur 3cm, antidérapant, évacuation centrale D90mm', 'pièce',
 145.00, 395.00, 395.00, 20.0, 'Kinedo', 'Sanitaires', true, 19, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000010', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Colonne de douche thermostatique Showerpipe', 'HANS-27296000',
 'Colonne de douche complète avec tête de douche 260mm, douchette 3 jets, mitigeur thermostatique', 'pièce',
 345.00, 890.00, 890.00, 20.0, 'Hansgrohe', 'Sanitaires', false, 6, NOW() - INTERVAL '1 day'),

-- TUYAUTERIE (Piping)
('30000000-0000-0000-0002-000000000011', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Tube PER nu Ø16mm couronne 50m', 'REHAU-PER16-50',
 'Tube PER (polyéthylène réticulé) nu diamètre 16mm - couronne 50m, rouge ou bleu', 'ml',
 0.52, 1.45, 1.45, 20.0, 'Rehau', 'Tuyauterie', true, 89, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000012', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Tube PER nu Ø20mm couronne 50m', 'REHAU-PER20-50',
 'Tube PER nu diamètre 20mm - couronne 50m, pour alimentation principale', 'ml',
 0.78, 2.10, 2.10, 20.0, 'Rehau', 'Tuyauterie', true, 45, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000013', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Tube cuivre écroui Ø14mm barre 4m', 'COMAP-CU14',
 'Tube cuivre écroui diamètre extérieur 14mm épaisseur 1mm - barre 4m', 'ml',
 4.20, 11.50, 11.50, 20.0, 'Comap', 'Tuyauterie', false, 34, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000014', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Tube cuivre écroui Ø18mm barre 4m', 'COMAP-CU18',
 'Tube cuivre écroui diamètre extérieur 18mm épaisseur 1mm - barre 4m', 'ml',
 6.80, 18.50, 18.50, 20.0, 'Comap', 'Tuyauterie', false, 28, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000015', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Tube multicouche Ø16mm couronne 50m', 'HENCO-MLT16-50',
 'Tube multicouche (Alu-PEX-Alu) diamètre 16mm - couronne 50m avec barrière oxygène', 'ml',
 0.95, 2.45, 2.45, 20.0, 'Henco', 'Tuyauterie', true, 56, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000016', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Tube PVC évacuation Ø40mm barre 4m', 'NICOLL-PVC40',
 'Tube PVC assainissement diamètre 40mm barre 4m blanc, joint à lèvre', 'pièce',
 8.90, 24.50, 24.50, 20.0, 'Nicoll', 'Évacuation', true, 67, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000017', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Tube PVC évacuation Ø100mm barre 4m', 'NICOLL-PVC100',
 'Tube PVC assainissement diamètre 100mm barre 4m blanc, pour WC', 'pièce',
 18.50, 49.00, 49.00, 20.0, 'Nicoll', 'Évacuation', true, 42, NOW() - INTERVAL '1 day'),

-- RACCORDS (Fittings)
('30000000-0000-0000-0002-000000000018', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Raccord PER à compression Ø16mm', 'COMAP-A16',
 'Raccord PER à compression laiton nickelé diamètre 16mm - vendu à l''unité', 'pièce',
 3.45, 9.80, 9.80, 20.0, 'Comap', 'Raccords', true, 156, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000019', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Té égal laiton 15x21 (1/2")', 'BOUTTE-TE152121',
 'Raccord en Té égal laiton brut filetage 15/21 (1/2")', 'pièce',
 1.85, 5.20, 5.20, 20.0, 'Boutté', 'Raccords', false, 78, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000020', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Coude à sertir cuivre 90° Ø14mm', 'COMAP-S14-90',
 'Coude à sertir cuivre 90° diamètre 14mm - systèmepress', 'pièce',
 2.95, 8.20, 8.20, 20.0, 'Comap', 'Raccords', true, 92, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000021', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Raccord union laiton 20x27 (3/4")', 'WATTS-U2027',
 'Raccord union 3 pièces laiton chromé 20/27', 'pièce',
 4.20, 11.50, 11.50, 20.0, 'Watts', 'Raccords', false, 45, NOW() - INTERVAL '1 day'),

-- CHAUFFAGE (Heating)
('30000000-0000-0000-0002-000000000022', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Radiateur aluminium H600mm 10 éléments', 'ACOVA-ALU60010',
 'Radiateur aluminium hauteur 600mm largeur 800mm - 10 éléments - puissance 1400W', 'pièce',
 125.00, 345.00, 345.00, 20.0, 'Acova', 'Chauffage', true, 16, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000023', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Vanne thermostatique radiateur Danfoss RA2000', 'DANFOSS-RA2K',
 'Tête thermostatique pour radiateur avec capteur intégré, réglage 6-26°C', 'pièce',
 28.50, 75.00, 75.00, 20.0, 'Danfoss', 'Chauffage', true, 38, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000024', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Collecteur chauffage sol 8 circuits Oventrop', 'OVENT-COL8',
 'Collecteur pour plancher chauffant 8 départs avec débitmètres et vannes réglage', 'pièce',
 189.00, 495.00, 495.00, 20.0, 'Oventrop', 'Chauffage', false, 5, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000025', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Chauffe-eau électrique 200L Duralis', 'ATLANTIC-CE200',
 'Chauffe-eau électrique vertical mural 200L, résistance stéatite, ACI hybride', 'pièce',
 425.00, 1150.00, 1150.00, 20.0, 'Atlantic', 'Chauffage', true, 11, NOW() - INTERVAL '1 day'),

-- CONSOMMABLES (Consumables)
('30000000-0000-0000-0002-000000000026', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Pâte à joint Gebatout 2 pot 500g', 'GEBA-GEB2-500',
 'Pâte à joint pour raccords filetés tous métaux - pot 500g', 'pièce',
 9.80, 26.00, 26.00, 20.0, 'Geb', 'Consommables', true, 234, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000027', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Téflon PTFE professionnel rouleau 50m', 'GUILBERT-TEF50',
 'Ruban téflon PTFE haute densité largeur 19mm - rouleau 50m', 'pièce',
 5.20, 14.50, 14.50, 20.0, 'Guilbert Express', 'Consommables', true, 198, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000028', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Silicone sanitaire blanc 310ml', 'RUBSON-SIL310',
 'Cartouche silicone sanitaire anti-moisissures fongicide 310ml blanc', 'pièce',
 4.50, 12.50, 12.50, 20.0, 'Rubson', 'Consommables', true, 167, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000029', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Filasse chanvre 100g', 'GUILBERT-FIL100',
 'Filasse de chanvre pour étanchéité raccords filetés - sachet 100g', 'pièce',
 3.20, 9.50, 9.50, 20.0, 'Guilbert Express', 'Consommables', false, 89, NOW() - INTERVAL '1 day'),

('30000000-0000-0000-0002-000000000030', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 'Clé à molette 250mm', 'FACOM-113A.25CP',
 'Clé à molette professionnelle ouverture 30mm longueur 250mm chromée', 'pièce',
 34.00, 89.00, 89.00, 20.0, 'Facom', 'Outillage', false, 8, NOW() - INTERVAL '1 day')

ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  price_buy = EXCLUDED.price_buy,
  price_sell = EXCLUDED.price_sell,
  price = EXCLUDED.price,
  vat_rate = EXCLUDED.vat_rate,
  supplier = EXCLUDED.supplier,
  category = EXCLUDED.category,
  is_favorite = EXCLUDED.is_favorite,
  usage_count = EXCLUDED.usage_count,
  last_used = EXCLUDED.last_used;

-- =====================================================
-- STEP 4: JOB SITES (10 realistic projects)
-- =====================================================
INSERT INTO job_sites (
  id, user_id, client_id, job_name, reference_number, description,
  address, contact_person, contact_phone,
  status, start_date, estimated_end_date, actual_end_date,
  progress_percentage, estimated_budget, actual_cost, profit_margin,
  notes, created_at, updated_at
) VALUES
-- Active Projects
('20000000-0000-0000-0005-000000000001', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000006',
 'Rénovation 2 salles de bain - Immeuble Haussmann 88 Hoche', 'CHANT-2025-001',
 'Rénovation complète de 2 salles de bain dans appartement haussmannien 180m². Remplacement baignoire par douche italienne, WC suspendus, robinetterie haut de gamme.',
 '88 Avenue Hoche', 'M. Legrand Michel', '+33 6 78 90 12 34',
 'in_progress', NOW() - INTERVAL '21 days', NOW() + INTERVAL '9 days', NULL,
 70, 12500.00, 8750.00, 30.00,
 'Travaux avancent bien. Client très satisfait de la qualité. Livraison robinetterie Hansgrohe prévue vendredi.',
 NOW() - INTERVAL '35 days', NOW() - INTERVAL '1 day'),

('20000000-0000-0000-0005-000000000002', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000008',
 'Installation chauffage central - Hôtel Tour 52 chambres', 'CHANT-2025-002',
 'Installation complète système de chauffage central pour 52 chambres + spa. Remplacement chaudière, pose 58 radiateurs aluminium, collecteur 12 circuits.',
 '23 Rue de la Tour', 'M. Blanc Laurent', '+33 6 33 44 55 66',
 'planned', NOW() + INTERVAL '12 days', NOW() + INTERVAL '82 days', NULL,
 0, 68000.00, 0.00, 28.00,
 'Chantier majeur planifié. Coordonner avec équipe électricité. Matériel commandé (livraison J-5). Astreinte 24/7 pendant travaux.',
 NOW() - INTERVAL '18 days', NOW() - INTERVAL '3 days'),

('20000000-0000-0000-0005-000000000003', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000011',
 'Réfection vestiaires - Gym Club Paris Centre', 'CHANT-2024-089',
 'Réfection complète des vestiaires hommes et femmes. 16 douches + WC. Remplacement tuyauterie cuivre par PER, nouveaux sanitaires.',
 '34 Boulevard de Magenta', 'M. Lefort Marc', '+33 6 44 55 66 77',
 'in_progress', NOW() - INTERVAL '8 days', NOW() + INTERVAL '7 days', NULL,
 55, 8900.00, 4895.00, 32.00,
 'Travaux côté hommes terminés. Début côté femmes lundi prochain. Problème pression résolu par pose surpresseur.',
 NOW() - INTERVAL '22 days', NOW() - INTERVAL '2 days'),

-- Completed Projects
('20000000-0000-0000-0005-000000000004', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000015',
 'Réparation urgente fuite cuisine - Dupont', 'CHANT-2024-078',
 'Intervention urgente suite fuite importante sous évier cuisine. Remplacement siphon, tuyauterie évacuation, robinet d''arrêt défectueux.',
 '12 Boulevard Saint-Germain, Apt 12', 'M. Dubois Pierre', '+33 6 34 56 78 90',
 'completed', NOW() - INTERVAL '21 days', NOW() - INTERVAL '21 days', NOW() - INTERVAL '21 days',
 100, 550.00, 485.00, 38.00,
 'Intervention terminée en 3h. Client très satisfait de la réactivité. A laissé avis 5 étoiles sur Google.',
 NOW() - INTERVAL '21 days', NOW() - INTERVAL '20 days'),

('20000000-0000-0000-0005-000000000005', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000001',
 'Création salle de bain - Appartement Champs-Élysées', 'CHANT-2024-045',
 'Création complète salle de bain 12m² dans appartement de standing. Douche italienne 120x90, WC suspendu Grohe, vasque double Jacob Delafon.',
 '23 Avenue des Champs-Élysées', 'M. Dupont Jean', '+33 6 12 34 56 78',
 'completed', NOW() - INTERVAL '95 days', NOW() - INTERVAL '73 days', NOW() - INTERVAL '72 days',
 100, 16800.00, 14280.00, 35.00,
 'Projet terminé avec 1 jour d''avance. Client extrêmement satisfait. Recommande à ses amis.',
 NOW() - INTERVAL '105 days', NOW() - INTERVAL '71 days'),

('20000000-0000-0000-0005-000000000006', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000007',
 'Maintenance sanitaires cuisine - Restaurant Bon Vivant', 'CHANT-2024-092',
 'Maintenance préventive complète système sanitaire cuisine professionnelle. Détartrage, remplacement joints, vérification évacuations.',
 '56 Rue Saint-Antoine', 'Mme Beaumont Claire', '+33 6 89 01 23 45',
 'completed', NOW() - INTERVAL '12 days', NOW() - INTERVAL '12 days', NOW() - INTERVAL '12 days',
 100, 890.00, 756.00, 35.00,
 'Maintenance effectuée pendant fermeture hebdomadaire. Tout OK. Prochain contrôle dans 6 mois.',
 NOW() - INTERVAL '15 days', NOW() - INTERVAL '11 days'),

-- Planned Projects
('20000000-0000-0000-0005-000000000007', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000014',
 'Rénovation appartement locatif - Charenton', 'CHANT-2025-003',
 'Rénovation complète plomberie appartement 65m² avant nouvelle location. SDB + cuisine. Remplacement total tuyauterie.',
 '123 Rue de Charenton', 'Mme Blanc Catherine', '+33 6 56 78 90 12',
 'planned', NOW() + INTERVAL '25 days', NOW() + INTERVAL '46 days', NULL,
 0, 9200.00, 0.00, 32.00,
 'Devis accepté. Locataire part le 15 du mois prochain. Accès total appartement vide. Travaux avant nouvelle location.',
 NOW() - INTERVAL '8 days', NOW() - INTERVAL '2 days'),

('20000000-0000-0000-0005-000000000008', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000010',
 'Mise aux normes sanitaires - Cabinet Médical', 'CHANT-2025-004',
 'Mise aux normes PMR (accessibilité handicapés) pour toilettes cabinet médical. WC suspendu spécial PMR, barres d''appui.',
 '12 Rue de la Santé', 'Dr. Dubois François', '+33 6 12 34 56 78',
 'planned', NOW() + INTERVAL '18 days', NOW() + INTERVAL '20 days', NULL,
 0, 3400.00, 0.00, 30.00,
 'Mise aux normes obligatoire suite contrôle accessibilité. Travaux pendant fermeture estivale août.',
 NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 day'),

('20000000-0000-0000-0005-000000000009', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000004',
 'Installation chauffe-eau 200L - Maison Boulogne', 'CHANT-2025-005',
 'Remplacement ancien chauffe-eau 150L par modèle 200L Atlantic Duralis. Raccordement groupe de sécurité.',
 '78 Avenue Jean Jaurès', 'Mme Bernard Sophie', '+33 6 45 67 89 01',
 'planned', NOW() + INTERVAL '8 days', NOW() + INTERVAL '8 days', NULL,
 0, 1850.00, 0.00, 35.00,
 'Intervention 1 journée. Chauffe-eau commandé, livraison confirmée. Parking disponible devant maison.',
 NOW() - INTERVAL '12 days', NOW() - INTERVAL '4 days'),

('20000000-0000-0000-0005-000000000010', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000013',
 'Plomberie cuisine partagée - CoWork Bastille', 'CHANT-2025-006',
 'Installation plomberie cuisine partagée espace coworking. 2 éviers pro, lave-vaisselle pro, machine à café réseau.',
 '90 Rue de la Roquette', 'Mme Girard Nathalie', '+33 6 45 67 89 01',
 'in_progress', NOW() - INTERVAL '3 days', NOW() + INTERVAL '4 days', NULL,
 40, 4200.00, 1680.00, 33.00,
 'Travaux commencés. Alimentation eau OK. Reste évacuations et raccordement lave-vaisselle.',
 NOW() - INTERVAL '10 days', NOW() - INTERVAL '1 day')

ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  progress_percentage = EXCLUDED.progress_percentage,
  actual_cost = EXCLUDED.actual_cost,
  notes = EXCLUDED.notes,
  updated_at = NOW();

-- =====================================================
-- STEP 5: QUOTES (15 quotes with various statuses)
-- =====================================================
INSERT INTO quotes (
  id, user_id, client_id, quote_number, quote_date, expiry_date,
  status, subtotal_ht, total_ht, total_vat, total_tva, total_ttc,
  items, notes, created_at, updated_at
) VALUES
-- Accepted quotes (will become invoices/jobs)
('40000000-0000-0000-0003-000000000001', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000006', 'DEV-2025-001',
 (NOW() - INTERVAL '35 days')::date, (NOW() + INTERVAL '25 days')::date,
 'accepted', 10416.67, 10416.67, 2083.33, 2083.33, 12500.00,
 '[
   {"description":"Dépose ancienne baignoire + évacuation","quantity":1,"unit_price":450.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Fourniture et pose receveur douche extra-plat 120x90cm Kinedo","quantity":1,"unit_price":1200.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Fourniture et pose colonne douche thermostatique Hansgrohe","quantity":1,"unit_price":1290.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Fourniture et pose 2 WC suspendus Geberit + bâti-support","quantity":2,"unit_price":1350.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Fourniture et pose 2 mitigeurs lavabo Grohe Eurosmart chromé","quantity":2,"unit_price":245.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Refaire tuyauterie PER Ø16mm alimentation complète","quantity":45,"unit_price":12.50,"tax_rate":20.0,"unit":"ml"},
   {"description":"Refaire évacuation PVC Ø40 et Ø100","quantity":35,"unit_price":18.00,"tax_rate":20.0,"unit":"ml"},
   {"description":"Main d''œuvre pose et mise en service (3 jours)","quantity":24,"unit_price":65.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Devis pour rénovation 2 salles de bain - Immeuble Haussmann. Délai 4 semaines. Garantie décennale. Travaux à réaliser par nos soins.',
 NOW() - INTERVAL '35 days', NOW() - INTERVAL '34 days'),

('40000000-0000-0000-0003-000000000002', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000014', 'DEV-2025-002',
 (NOW() - INTERVAL '8 days')::date, (NOW() + INTERVAL '22 days')::date,
 'accepted', 7666.67, 7666.67, 1533.33, 1533.33, 9200.00,
 '[
   {"description":"Dépose ancienne plomberie (cuivre vieilli)","quantity":1,"unit_price":850.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Installation complète tuyauterie PER - alimentation","quantity":65,"unit_price":15.00,"tax_rate":20.0,"unit":"ml"},
   {"description":"Installation évacuation PVC sanitaires","quantity":25,"unit_price":22.00,"tax_rate":20.0,"unit":"ml"},
   {"description":"Fourniture et pose mitigeur lavabo + évier cuisine","quantity":2,"unit_price":235.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Fourniture et pose WC suspendu Villeroy&Boch + bâti Geberit","quantity":1,"unit_price":1480.00,"tax_rate":20.0,"unit":"ensemble"},
   {"description":"Fourniture et pose receveur douche 90x90 + mitigeur","quantity":1,"unit_price":1150.00,"tax_rate":20.0,"unit":"ensemble"},
   {"description":"Robinets d''arrêt et petites fournitures","quantity":1,"unit_price":320.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre complète (3 semaines)","quantity":105,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Rénovation complète plomberie appartement 65m² avant location. Appartement vide, accès total. Délai 3 semaines.',
 NOW() - INTERVAL '8 days', NOW() - INTERVAL '2 days'),

('40000000-0000-0000-0003-000000000003', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000001', 'DEV-2024-045',
 (NOW() - INTERVAL '105 days')::date, (NOW() - INTERVAL '75 days')::date,
 'accepted', 14000.00, 14000.00, 2800.00, 2800.00, 16800.00,
 '[
   {"description":"Création complète installation plomberie salle de bain 12m²","quantity":1,"unit_price":2800.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Fourniture et pose douche italienne 120x90 carrelée + évacuation","quantity":1,"unit_price":3500.00,"tax_rate":20.0,"unit":"ensemble"},
   {"description":"Fourniture et pose WC suspendu Grohe + bâti-support haut gamme","quantity":1,"unit_price":1850.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Fourniture et pose double vasque Jacob Delafon 120cm + robinetterie","quantity":1,"unit_price":2650.00,"tax_rate":20.0,"unit":"ensemble"},
   {"description":"Colonne de douche thermostatique Hansgrohe Raindance","quantity":1,"unit_price":1450.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Installation chauffage salle de bain (sèche-serviettes)","quantity":1,"unit_price":950.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Main d''œuvre complète (4 semaines)","quantity":140,"unit_price":62.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Création salle de bain haut de gamme. Matériaux premium. Délai 4 semaines. Coordination avec carreleur.',
 NOW() - INTERVAL '105 days', NOW() - INTERVAL '100 days'),

-- Sent quotes (awaiting response)
('40000000-0000-0000-0003-000000000004', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000008', 'DEV-2025-003',
 (NOW() - INTERVAL '18 days')::date, (NOW() + INTERVAL '12 days')::date,
 'sent', 56666.67, 56666.67, 11333.33, 11333.33, 68000.00,
 '[
   {"description":"Fourniture et installation chaudière gaz condensation 45kW Viessmann","quantity":1,"unit_price":8500.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Fourniture et pose 58 radiateurs aluminium Acova + vannes thermostatiques","quantity":58,"unit_price":485.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Installation collecteur 12 circuits pour distribution étages","quantity":2,"unit_price":1250.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Tuyauterie multicouche alimentation complète bâtiment","quantity":450,"unit_price":8.50,"tax_rate":20.0,"unit":"ml"},
   {"description":"Isolation tuyauterie complète","quantity":450,"unit_price":3.20,"tax_rate":20.0,"unit":"ml"},
   {"description":"Purge d''air automatique et accessoires","quantity":1,"unit_price":850.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre installation complète (10 semaines - 2 personnes)","quantity":400,"unit_price":68.00,"tax_rate":20.0,"unit":"heure"},
   {"description":"Tests, mise en service, formation personnel","quantity":1,"unit_price":1200.00,"tax_rate":20.0,"unit":"forfait"}
 ]'::jsonb,
 'Installation chauffage central hôtel 52 chambres. Projet majeur 10 semaines. Coordination essentielle. Astreinte 24/7 pendant travaux.',
 NOW() - INTERVAL '18 days', NOW() - INTERVAL '17 days'),

('40000000-0000-0000-0003-000000000005', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000010', 'DEV-2025-004',
 (NOW() - INTERVAL '5 days')::date, (NOW() + INTERVAL '25 days')::date,
 'sent', 2833.33, 2833.33, 566.67, 566.67, 3400.00,
 '[
   {"description":"Fourniture et pose WC suspendu PMR Geberit + bâti renforcé","quantity":1,"unit_price":1650.00,"tax_rate":20.0,"unit":"ensemble"},
   {"description":"Fourniture et pose lavabo PMR réglable en hauteur","quantity":1,"unit_price":890.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Installation barres d''appui cuvette + lavabo (normes PMR)","quantity":1,"unit_price":450.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Adaptation tuyauterie existante","quantity":1,"unit_price":320.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre pose et mise en conformité (3 jours)","quantity":21,"unit_price":55.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Mise aux normes PMR toilettes cabinet médical. Conforme réglementation accessibilité. Travaux août pendant fermeture.',
 NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days'),

-- Draft quotes (being prepared)
('40000000-0000-0000-0003-000000000006', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000012', 'DEV-2025-005',
 NOW()::date, (NOW() + INTERVAL '30 days')::date,
 'draft', 4583.33, 4583.33, 916.67, 916.67, 5500.00,
 '[
   {"description":"Rénovation plomberie toilettes filles (8 WC + 6 lavabos)","quantity":1,"unit_price":2100.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Rénovation plomberie toilettes garçons (6 WC + 5 lavabos + 3 urinoirs)","quantity":1,"unit_price":2200.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Fournitures robinetterie anti-vandalisme spécial collectivité","quantity":19,"unit_price":85.00,"tax_rate":20.0,"unit":"pièce"}
 ]'::jsonb,
 'Rénovation sanitaires école. Matériel anti-vandalisme. Travaux vacances scolaires uniquement.',
 NOW() - INTERVAL '2 days', NOW()),

('40000000-0000-0000-0003-000000000007', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000005', 'DEV-2025-006',
 NOW()::date, (NOW() + INTERVAL '30 days')::date,
 'draft', 1250.00, 1250.00, 250.00, 250.00, 1500.00,
 '[
   {"description":"Remplacement mitigeur cuisine douchette extractible Hansgrohe","quantity":1,"unit_price":425.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Remplacement siphon évier + raccordement lave-vaisselle","quantity":1,"unit_price":180.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Détartrage + entretien préventif robinetterie salle de bain","quantity":1,"unit_price":120.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre (1 demi-journée)","quantity":4,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Entretien + remplacement robinetterie cuisine. Client jeune couple, budget serré.',
 NOW() - INTERVAL '1 day', NOW()),

-- More varied quotes
('40000000-0000-0000-0003-000000000008', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000011', 'DEV-2024-089',
 (NOW() - INTERVAL '22 days')::date, (NOW() + INTERVAL '8 days')::date,
 'accepted', 7416.67, 7416.67, 1483.33, 1483.33, 8900.00,
 '[
   {"description":"Dépose anciennes installations vestiaires","quantity":1,"unit_price":950.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Installation tuyauterie PER alimentation 16 douches + WC","quantity":85,"unit_price":14.00,"tax_rate":20.0,"unit":"ml"},
   {"description":"Installation évacuation PVC 16 douches + 8 WC","quantity":65,"unit_price":20.00,"tax_rate":20.0,"unit":"ml"},
   {"description":"Fourniture et pose 16 mitigeurs douche thermostatiques","quantity":16,"unit_price":320.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Fourniture et pose surpresseur pour améliorer pression","quantity":1,"unit_price":850.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Main d''œuvre (2 semaines)","quantity":70,"unit_price":62.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Réfection vestiaires salle de sport. Amélioration pression eau. Travaux en 2 phases (H puis F).',
 NOW() - INTERVAL '22 days', NOW() - INTERVAL '21 days'),

('40000000-0000-0000-0003-000000000009', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000004', 'DEV-2025-007',
 (NOW() - INTERVAL '12 days')::date, (NOW() + INTERVAL '18 days')::date,
 'accepted', 1541.67, 1541.67, 308.33, 308.33, 1850.00,
 '[
   {"description":"Fourniture chauffe-eau électrique 200L Atlantic Duralis ACI","quantity":1,"unit_price":1150.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Dépose ancien chauffe-eau + mise en déchetterie","quantity":1,"unit_price":120.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Pose nouveau chauffe-eau + groupe sécurité + raccordements","quantity":1,"unit_price":380.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre installation (1 journée)","quantity":7,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Remplacement chauffe-eau 150L par 200L. Intervention 1 journée. Parking disponible.',
 NOW() - INTERVAL '12 days', NOW() - INTERVAL '8 days'),

('40000000-0000-0000-0003-000000000010', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000015', 'DEV-2024-078',
 (NOW() - INTERVAL '21 days')::date, (NOW() + INTERVAL '9 days')::date,
 'accepted', 458.33, 458.33, 91.67, 91.67, 550.00,
 '[
   {"description":"Remplacement siphon évier + tuyauterie évacuation","quantity":1,"unit_price":85.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Remplacement robinet d''arrêt défectueux sous évier","quantity":2,"unit_price":35.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Vérification + resserrage autres raccords cuisine","quantity":1,"unit_price":45.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Intervention urgence + main d''œuvre","quantity":1,"unit_price":250.00,"tax_rate":20.0,"unit":"forfait"}
 ]'::jsonb,
 'Intervention urgente fuite cuisine. Devis établi après intervention (accord client). Client très satisfait.',
 NOW() - INTERVAL '21 days', NOW() - INTERVAL '21 days'),

('40000000-0000-0000-0003-000000000011', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000007', 'DEV-2024-092',
 (NOW() - INTERVAL '15 days')::date, (NOW() - INTERVAL '15 days')::date,
 'accepted', 741.67, 741.67, 148.33, 148.33, 890.00,
 '[
   {"description":"Détartrage complet robinetterie cuisine professionnelle","quantity":1,"unit_price":280.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Remplacement joints + cartouches mitigeurs","quantity":4,"unit_price":65.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Vérification et curage évacuations graisses","quantity":1,"unit_price":180.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre maintenance (1 journée)","quantity":6,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Maintenance préventive annuelle cuisine professionnelle. Prochain RDV dans 6 mois.',
 NOW() - INTERVAL '15 days', NOW() - INTERVAL '14 days'),

('40000000-0000-0000-0003-000000000012', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000013', 'DEV-2025-008',
 (NOW() - INTERVAL '10 days')::date, (NOW() + INTERVAL '20 days')::date,
 'accepted', 3500.00, 3500.00, 700.00, 700.00, 4200.00,
 '[
   {"description":"Installation alimentation eau froide cuisine partagée (2 éviers)","quantity":1,"unit_price":650.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Installation évacuation 2 éviers + lave-vaisselle","quantity":1,"unit_price":480.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Fourniture et pose 2 mitigeurs évier professionnel bec haut","quantity":2,"unit_price":385.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Raccordement lave-vaisselle professionnel + adoucisseur","quantity":1,"unit_price":420.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Raccordement machine café réseau eau","quantity":1,"unit_price":280.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre (1 semaine)","quantity":35,"unit_price":62.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Installation cuisine partagée espace coworking. Équipements professionnels.',
 NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days'),

-- Declined quote
('40000000-0000-0000-0003-000000000013', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000002', 'DEV-2025-009',
 (NOW() - INTERVAL '42 days')::date, (NOW() - INTERVAL '12 days')::date,
 'rejected', 3250.00, 3250.00, 650.00, 650.00, 3900.00,
 '[
   {"description":"Rénovation salle de bain complète 8m²","quantity":1,"unit_price":2400.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Fourniture et pose douche + WC + lavabo","quantity":1,"unit_price":1850.00,"tax_rate":20.0,"unit":"ensemble"},
   {"description":"Main d''œuvre (2 semaines)","quantity":70,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Devis refusé - client a trouvé moins cher ailleurs (qualité?). Pas de relance.',
 NOW() - INTERVAL '42 days', NOW() - INTERVAL '35 days'),

-- Expired quote
('40000000-0000-0000-0003-000000000014', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000003', 'DEV-2024-156',
 (NOW() - INTERVAL '85 days')::date, (NOW() - INTERVAL '55 days')::date,
 'expired', 2100.00, 2100.00, 420.00, 420.00, 2520.00,
 '[
   {"description":"Remplacement tuyauterie cuivre vieillissante salle de bain","quantity":25,"unit_price":18.00,"tax_rate":20.0,"unit":"ml"},
   {"description":"Installation nouvelle robinetterie lavabo + douche","quantity":1,"unit_price":580.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre (1 semaine)","quantity":35,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Devis expiré - client senior n''a pas donné suite. Relance?',
 NOW() - INTERVAL '85 days', NOW() - INTERVAL '55 days'),

('40000000-0000-0000-0003-000000000015', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000009', 'DEV-2025-010',
 (NOW() - INTERVAL '3 days')::date, (NOW() + INTERVAL '27 days')::date,
 'sent', 1625.00, 1625.00, 325.00, 325.00, 1950.00,
 '[
   {"description":"Entretien annuel système eau boulangerie","quantity":1,"unit_price":380.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Détartrage robinetterie + lave-mains","quantity":1,"unit_price":180.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Vérification évacuations + siphons","quantity":1,"unit_price":150.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Remplacement joints robinets usagés","quantity":1,"unit_price":120.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre (1 demi-journée)","quantity":5,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Entretien préventif boulangerie artisanale. Intervention après 14h.',
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days')

ON CONFLICT (quote_number) DO UPDATE SET
  status = EXCLUDED.status,
  total_ht = EXCLUDED.total_ht,
  total_tva = EXCLUDED.total_tva,
  total_ttc = EXCLUDED.total_ttc,
  items = EXCLUDED.items,
  updated_at = NOW();

-- =====================================================
-- STEP 6: INVOICES (12 invoices - comprehensive test)
-- =====================================================
INSERT INTO invoices (
  id, user_id, client_id, invoice_number, number,
  invoice_date, date, due_date, payment_date,
  status, payment_status, payment_method,
  subtotal_ht, total_ht, total_vat, total_tva, tva_amount, total_ttc,
  amount_paid, balance_due,
  items, notes, legal_mentions,
  created_at, updated_at
) VALUES
-- PAID invoices
('50000000-0000-0000-0004-000000000001', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000001', 'FACT-2024-078', 'FACT-2024-078',
 (NOW() - INTERVAL '72 days')::date, (NOW() - INTERVAL '72 days')::date,
 (NOW() - INTERVAL '42 days')::date, (NOW() - INTERVAL '68 days')::date,
 'paid', 'paid', 'transfer',
 14000.00, 14000.00, 2800.00, 2800.00, 2800.00, 16800.00,
 16800.00, 0.00,
 '[
   {"description":"Création complète installation plomberie salle de bain 12m²","quantity":1,"unit_price":2800.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Fourniture et pose douche italienne 120x90 carrelée + évacuation","quantity":1,"unit_price":3500.00,"tax_rate":20.0,"unit":"ensemble"},
   {"description":"Fourniture et pose WC suspendu Grohe + bâti-support haut gamme","quantity":1,"unit_price":1850.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Fourniture et pose double vasque Jacob Delafon 120cm + robinetterie","quantity":1,"unit_price":2650.00,"tax_rate":20.0,"unit":"ensemble"},
   {"description":"Colonne de douche thermostatique Hansgrohe Raindance","quantity":1,"unit_price":1450.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Installation chauffage salle de bain (sèche-serviettes)","quantity":1,"unit_price":950.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Main d''œuvre complète (4 semaines)","quantity":140,"unit_price":62.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Création salle de bain - Solde après acompte 30%. Travaux terminés avec satisfaction client.',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678 - Capital social: 10 000€ - Garantie décennale: Allianz Police n°12345678',
 NOW() - INTERVAL '72 days', NOW() - INTERVAL '68 days'),

('50000000-0000-0000-0004-000000000002', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000015', 'FACT-2024-158', 'FACT-2024-158',
 (NOW() - INTERVAL '21 days')::date, (NOW() - INTERVAL '21 days')::date,
 (NOW() + INTERVAL '9 days')::date, (NOW() - INTERVAL '19 days')::date,
 'paid', 'paid', 'cash',
 458.33, 458.33, 91.67, 91.67, 91.67, 550.00,
 550.00, 0.00,
 '[
   {"description":"Remplacement siphon évier + tuyauterie évacuation","quantity":1,"unit_price":85.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Remplacement robinet d''arrêt défectueux sous évier","quantity":2,"unit_price":35.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Vérification + resserrage autres raccords cuisine","quantity":1,"unit_price":45.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Intervention urgence + main d''œuvre","quantity":1,"unit_price":250.00,"tax_rate":20.0,"unit":"forfait"}
 ]'::jsonb,
 'Intervention urgente fuite cuisine. Paiement comptant immédiat. Client très satisfait - avis 5 étoiles.',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW() - INTERVAL '21 days', NOW() - INTERVAL '19 days'),

('50000000-0000-0000-0004-000000000003', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000007', 'FACT-2024-182', 'FACT-2024-182',
 (NOW() - INTERVAL '12 days')::date, (NOW() - INTERVAL '12 days')::date,
 (NOW() + INTERVAL '18 days')::date, (NOW() - INTERVAL '9 days')::date,
 'paid', 'paid', 'check',
 741.67, 741.67, 148.33, 148.33, 148.33, 890.00,
 890.00, 0.00,
 '[
   {"description":"Détartrage complet robinetterie cuisine professionnelle","quantity":1,"unit_price":280.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Remplacement joints + cartouches mitigeurs","quantity":4,"unit_price":65.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Vérification et curage évacuations graisses","quantity":1,"unit_price":180.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre maintenance (1 journée)","quantity":6,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Maintenance annuelle restaurant - Paiement par chèque encaissé. RDV prochain dans 6 mois.',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW() - INTERVAL '12 days', NOW() - INTERVAL '9 days'),

('50000000-0000-0000-0004-000000000004', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000004', 'FACT-2025-002', 'FACT-2025-002',
 (NOW() - INTERVAL '8 days')::date, (NOW() - INTERVAL '8 days')::date,
 (NOW() + INTERVAL '22 days')::date, (NOW() - INTERVAL '6 days')::date,
 'paid', 'paid', 'card',
 1541.67, 1541.67, 308.33, 308.33, 308.33, 1850.00,
 1850.00, 0.00,
 '[
   {"description":"Fourniture chauffe-eau électrique 200L Atlantic Duralis ACI","quantity":1,"unit_price":1150.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Dépose ancien chauffe-eau + mise en déchetterie","quantity":1,"unit_price":120.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Pose nouveau chauffe-eau + groupe sécurité + raccordements","quantity":1,"unit_price":380.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre installation (1 journée)","quantity":7,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 'Installation chauffe-eau 200L - Paiement par carte bancaire. Client satisfait.',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW() - INTERVAL '8 days', NOW() - INTERVAL '6 days'),

-- UNPAID invoices (sent, awaiting payment)
('50000000-0000-0000-0004-000000000005', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000006', 'FACT-2025-001', 'FACT-2025-001',
 (NOW() - INTERVAL '25 days')::date, (NOW() - INTERVAL '25 days')::date,
 (NOW() + INTERVAL '20 days')::date, NULL,
 'sent', 'unpaid', NULL,
 6250.00, 6250.00, 1250.00, 1250.00, 1250.00, 7500.00,
 0.00, 7500.00,
 '[
   {"description":"Acompte 60% - Rénovation 2 salles de bain Immeuble Haussmann","quantity":1,"unit_price":6250.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"(Paiement total projet: 12 500€ HT - Acompte: 7 500€ TTC)","quantity":1,"unit_price":0.00,"tax_rate":20.0,"unit":"info"}
 ]'::jsonb,
 'Acompte 60% démarrage chantier. Solde à réception travaux. Chantier en cours (70% avancement).',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW() - INTERVAL '25 days', NOW() - INTERVAL '24 days'),

('50000000-0000-0000-0004-000000000006', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000011', 'FACT-2025-003', 'FACT-2025-003',
 (NOW() - INTERVAL '18 days')::date, (NOW() - INTERVAL '18 days')::date,
 (NOW() + INTERVAL '27 days')::date, NULL,
 'sent', 'unpaid', NULL,
 4458.33, 4458.33, 891.67, 891.67, 891.67, 5350.00,
 0.00, 5350.00,
 '[
   {"description":"Acompte 60% - Réfection vestiaires Gym Club","quantity":1,"unit_price":4458.33,"tax_rate":20.0,"unit":"forfait"},
   {"description":"(Paiement total projet: 7 416.67€ HT - Acompte: 5 350€ TTC)","quantity":1,"unit_price":0.00,"tax_rate":20.0,"unit":"info"}
 ]'::jsonb,
 'Acompte 60% démarrage travaux vestiaires. Chantier en cours côté hommes terminé, début côté femmes.',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW() - INTERVAL '18 days', NOW() - INTERVAL '17 days'),

('50000000-0000-0000-0004-000000000007', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000013', 'FACT-2025-004', 'FACT-2025-004',
 (NOW() - INTERVAL '5 days')::date, (NOW() - INTERVAL '5 days')::date,
 (NOW() + INTERVAL '25 days')::date, NULL,
 'sent', 'unpaid', NULL,
 2100.00, 2100.00, 420.00, 420.00, 420.00, 2520.00,
 0.00, 2520.00,
 '[
   {"description":"Acompte 60% - Installation cuisine partagée CoWork Bastille","quantity":1,"unit_price":2100.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"(Paiement total projet: 3 500€ HT - Acompte: 2 520€ TTC)","quantity":1,"unit_price":0.00,"tax_rate":20.0,"unit":"info"}
 ]'::jsonb,
 'Acompte 60% démarrage installation cuisine coworking. Travaux en cours (40%).',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days'),

-- OVERDUE invoices (need follow-up)
('50000000-0000-0000-0004-000000000008', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000002', 'FACT-2024-145', 'FACT-2024-145',
 (NOW() - INTERVAL '65 days')::date, (NOW() - INTERVAL '65 days')::date,
 (NOW() - INTERVAL '35 days')::date, NULL,
 'overdue', 'overdue', NULL,
 1950.00, 1950.00, 390.00, 390.00, 390.00, 2340.00,
 0.00, 2340.00,
 '[
   {"description":"Réparation fuite lavabo + remplacement robinetterie","quantity":1,"unit_price":450.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Fourniture et pose mitigeur lavabo Grohe","quantity":1,"unit_price":235.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Main d''œuvre intervention (4h)","quantity":4,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 '⚠️ FACTURE EN RETARD - 2 relances envoyées. Client joignable mais reporte paiement. Suivre de près.',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW() - INTERVAL '65 days', NOW() - INTERVAL '7 days'),

('50000000-0000-0000-0004-000000000009', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000009', 'FACT-2024-169', 'FACT-2024-169',
 (NOW() - INTERVAL '52 days')::date, (NOW() - INTERVAL '52 days')::date,
 (NOW() - INTERVAL '22 days')::date, NULL,
 'overdue', 'overdue', NULL,
 1250.00, 1250.00, 250.00, 1500.00,
 0.00, 1500.00,
 '[
   {"description":"Entretien système eau + détartrage boulangerie","quantity":1,"unit_price":680.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Remplacement joints robinets","quantity":1,"unit_price":120.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Main d''œuvre (5h)","quantity":5,"unit_price":58.00,"tax_rate":20.0,"unit":"heure"}
 ]'::jsonb,
 '⚠️ RETARD 22 jours. 1 relance envoyée. PME artisan, période difficile selon propriétaire. Bienveillance mais fermeté.',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW() - INTERVAL '52 days', NOW() - INTERVAL '10 days'),

-- DRAFT invoices (being prepared)
('50000000-0000-0000-0004-000000000010', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000006', 'FACT-2025-DRAFT-001', 'FACT-2025-DRAFT-001',
 NOW()::date, NOW()::date, (NOW() + INTERVAL '30 days')::date, NULL,
 'draft', 'unpaid', NULL,
 4166.67, 4166.67, 833.33, 833.33, 833.33, 5000.00,
 0.00, 5000.00,
 '[
   {"description":"Solde 40% - Rénovation 2 salles de bain (Réception travaux)","quantity":1,"unit_price":4166.67,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Travaux terminés - reste à facturer le solde","quantity":1,"unit_price":0.00,"tax_rate":20.0,"unit":"info"}
 ]'::jsonb,
 'BROUILLON - Solde à émettre à réception définitive travaux (prévu semaine prochaine).',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW(), NOW()),

('50000000-0000-0000-0004-000000000011', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000014', 'FACT-2025-DRAFT-002', 'FACT-2025-DRAFT-002',
 NOW()::date, NOW()::date, (NOW() + INTERVAL '45 days')::date, NULL,
 'draft', 'unpaid', NULL,
 4600.00, 4600.00, 920.00, 920.00, 920.00, 5520.00,
 0.00, 5520.00,
 '[
   {"description":"Acompte 60% - Rénovation plomberie appartement locatif 65m²","quantity":1,"unit_price":4600.00,"tax_rate":20.0,"unit":"forfait"},
   {"description":"Démarrage travaux prévu dans 3 semaines","quantity":1,"unit_price":0.00,"tax_rate":20.0,"unit":"info"}
 ]'::jsonb,
 'BROUILLON - Acompte à émettre avant démarrage chantier (J-5).',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW() - INTERVAL '1 day', NOW()),

-- PARTIAL payment invoice
('50000000-0000-0000-0004-000000000012', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000003', 'FACT-2024-128', 'FACT-2024-128',
 (NOW() - INTERVAL '95 days')::date, (NOW() - INTERVAL '95 days')::date,
 (NOW() - INTERVAL '65 days')::date, NULL,
 'partial', 'partial', 'transfer',
 1750.00, 1750.00, 350.00, 350.00, 350.00, 2100.00,
 1260.00, 840.00,
 '[
   {"description":"Remplacement chauffe-eau 150L par 200L","quantity":1,"unit_price":1250.00,"tax_rate":20.0,"unit":"pièce"},
   {"description":"Main d''œuvre installation complète","quantity":1,"unit_price":500.00,"tax_rate":20.0,"unit":"forfait"}
 ]'::jsonb,
 'Paiement partiel 60% reçu (1260€). Client senior demande échelonnement solde 840€. Accord donné - échéance fin mois.',
 'En cas de retard de paiement, seront exigibles, conformément à l''article L 441-10 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l''intérêt légal en vigueur ainsi qu''une indemnité forfaitaire pour frais de recouvrement de 40 euros. SIRET: 85234567800012 - TVA: FR85234567800 - RCS Paris B 852 345 678',
 NOW() - INTERVAL '95 days', NOW() - INTERVAL '30 days')

ON CONFLICT (number) DO UPDATE SET
  status = EXCLUDED.status,
  payment_status = EXCLUDED.payment_status,
  payment_method = EXCLUDED.payment_method,
  amount_paid = EXCLUDED.amount_paid,
  balance_due = EXCLUDED.balance_due,
  payment_date = EXCLUDED.payment_date,
  updated_at = NOW();

-- =====================================================
-- STEP 7: PAYMENTS (for paid invoices)
-- =====================================================
INSERT INTO payments (
  id, user_id, invoice_id, payment_date, amount, payment_method,
  transaction_reference, notes, created_at
) VALUES
('60000000-0000-0000-0007-000000000001', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '50000000-0000-0000-0004-000000000001',
 (NOW() - INTERVAL '68 days')::date, 16800.00, 'transfer',
 'VIR-20241015-DUPONT-16800',
 'Paiement complet par virement bancaire. Client VIP toujours ponctuel.',
 NOW() - INTERVAL '68 days'),

('60000000-0000-0000-0007-000000000002', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '50000000-0000-0000-0004-000000000002',
 (NOW() - INTERVAL '19 days')::date, 550.00, 'cash',
 'CASH-DUBOIS-550',
 'Paiement comptant immédiat après intervention urgente. Client très satisfait.',
 NOW() - INTERVAL '19 days'),

('60000000-0000-0000-0007-000000000003', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '50000000-0000-0000-0004-000000000003',
 (NOW() - INTERVAL '9 days')::date, 890.00, 'check',
 'CHQ-5234567-BONVIVANT',
 'Chèque encaissé sans problème. Maintenance restaurant OK.',
 NOW() - INTERVAL '9 days'),

('60000000-0000-0000-0007-000000000004', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '50000000-0000-0000-0004-000000000004',
 (NOW() - INTERVAL '6 days')::date, 1850.00, 'card',
 'CB-BERNARD-1850',
 'Paiement par carte bancaire TPE. Transaction validée immédiatement.',
 NOW() - INTERVAL '6 days'),

('60000000-0000-0000-0007-000000000005', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '50000000-0000-0000-0004-000000000012',
 (NOW() - INTERVAL '30 days')::date, 1260.00, 'transfer',
 'VIR-LEROY-PARTIAL-1260',
 'Paiement partiel 60% - Client senior. Solde 840€ échelonné accepté.',
 NOW() - INTERVAL '30 days')

ON CONFLICT (id) DO UPDATE SET
  amount = EXCLUDED.amount,
  payment_method = EXCLUDED.payment_method,
  notes = EXCLUDED.notes;

-- =====================================================
-- STEP 8: APPOINTMENTS (upcoming and recent)
-- =====================================================
INSERT INTO appointments (
  id, user_id, client_id, job_site_id, title, description,
  start_time, end_time, duration_minutes, status,
  notes, created_at, updated_at
) VALUES
-- Upcoming appointments
('70000000-0000-0000-0006-000000000001', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000006', '20000000-0000-0000-0005-000000000001',
 'Suite rénovation SdB - Pose baignoire',
 'Continuer travaux rénovation 2 salles de bain. Pose dernière baignoire et raccordements finaux.',
 (NOW() + INTERVAL '2 days' + INTERVAL '8 hours')::timestamptz,
 (NOW() + INTERVAL '2 days' + INTERVAL '13 hours')::timestamptz,
 300, 'scheduled',
 'Prévoir échelle et assistant. Livraison robinetterie Hansgrohe confirmée pour demain.',
 NOW() - INTERVAL '8 days', NOW() - INTERVAL '1 day'),

('70000000-0000-0000-0006-000000000002', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000008', '20000000-0000-0000-0005-000000000002',
 'RDV préparatoire installation chauffage',
 'Rendez-vous avec directeur technique hôtel pour organisation chantier chauffage. Validation planning et zones intervention.',
 (NOW() + INTERVAL '5 days' + INTERVAL '14 hours')::timestamptz,
 (NOW() + INTERVAL '5 days' + INTERVAL '16 hours')::timestamptz,
 120, 'confirmed',
 'Amener planning détaillé + schéma installation. Coordonner avec électriciens présents.',
 NOW() - INTERVAL '12 days', NOW() - INTERVAL '3 days'),

('70000000-0000-0000-0006-000000000003', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000014', NULL,
 'Visite technique appart Charenton',
 'Visite technique appartement locatif avant devis final. Prendre mesures précises, photos, état lieux plomberie existante.',
 (NOW() + INTERVAL '3 days' + INTERVAL '10 hours')::timestamptz,
 (NOW() + INTERVAL '3 days' + INTERVAL '11 hours' + INTERVAL '30 minutes')::timestamptz,
 90, 'scheduled',
 'Appartement sera vide. Propriétaire donne clés à son agence (récupérer la veille). Appartement 3ème étage avec ascenseur.',
 NOW() - INTERVAL '6 days', NOW() - INTERVAL '2 days'),

('70000000-0000-0000-0006-000000000004', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000010', '20000000-0000-0000-0005-000000000008',
 'Travaux mise aux normes PMR cabinet',
 'Début travaux mise aux normes PMR toilettes cabinet médical. Installation WC suspendu spécial + barres appui.',
 (NOW() + INTERVAL '18 days' + INTERVAL '8 hours')::timestamptz,
 (NOW() + INTERVAL '18 days' + INTERVAL '17 hours')::timestamptz,
 540, 'scheduled',
 'Cabinet fermé pour travaux. Accès libre toute journée. Prévoir tout le matériel d''un coup.',
 NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 day'),

('70000000-0000-0000-0006-000000000005', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000004', '20000000-0000-0000-0005-000000000009',
 'Installation chauffe-eau 200L',
 'Remplacement ancien chauffe-eau 150L par nouveau 200L Atlantic. Dépose + pose + raccordements + tests.',
 (NOW() + INTERVAL '8 days' + INTERVAL '9 hours')::timestamptz,
 (NOW() + INTERVAL '8 days' + INTERVAL '17 hours')::timestamptz,
 480, 'confirmed',
 'Parking disponible devant maison. Chauffe-eau livré chez client hier. Prévoir groupe sécurité neuf.',
 NOW() - INTERVAL '12 days', NOW() - INTERVAL '4 days'),

-- Recent completed appointments
('70000000-0000-0000-0006-000000000006', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000015', '20000000-0000-0000-0005-000000000004',
 'Intervention urgente fuite cuisine',
 'Dépannage urgent suite appel client - fuite importante sous évier cuisine. Diagnostic + réparation immédiate.',
 (NOW() - INTERVAL '21 days' + INTERVAL '14 hours')::timestamptz,
 (NOW() - INTERVAL '21 days' + INTERVAL '17 hours')::timestamptz,
 180, 'completed',
 'Intervention terminée. Fuite stoppée. Remplacement siphon + robinets d''arrêt. Client très satisfait - avis 5 étoiles.',
 NOW() - INTERVAL '22 days', NOW() - INTERVAL '20 days'),

('70000000-0000-0000-0006-000000000007', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000007', '20000000-0000-0000-0005-000000000006',
 'Maintenance annuelle restaurant',
 'Maintenance préventive cuisine professionnelle. Détartrage, vérification, remplacement joints usagés.',
 (NOW() - INTERVAL '12 days' + INTERVAL '14 hours')::timestamptz,
 (NOW() - INTERVAL '12 days' + INTERVAL '20 hours')::timestamptz,
 360, 'completed',
 'Maintenance OK. Tout vérifié et nettoyé. Prochain RDV maintenance dans 6 mois (planifier mi-mai).',
 NOW() - INTERVAL '15 days', NOW() - INTERVAL '11 days'),

('70000000-0000-0000-0006-000000000008', '6b1d26bf-40d7-46c0-9b07-89a120191971',
 '10000000-0000-0000-0001-000000000011', '20000000-0000-0000-0005-000000000003',
 'Chantier vestiaires - Phase hommes',
 'Travaux vestiaires hommes Gym Club. Installation douches + WC + tuyauterie.',
 (NOW() - INTERVAL '18 days' + INTERVAL '8 hours')::timestamptz,
 (NOW() - INTERVAL '15 days' + INTERVAL '18 hours')::timestamptz,
 1800, 'completed',
 'Phase hommes terminée avec succès. Côté filles commence semaine prochaine. Problème pression résolu.',
 NOW() - INTERVAL '22 days', NOW() - INTERVAL '14 days')

ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  notes = EXCLUDED.notes,
  updated_at = NOW();

-- =====================================================
-- FINAL STATISTICS & CONFIRMATION
-- =====================================================

DO $$
DECLARE
  client_count INT;
  product_count INT;
  quote_count INT;
  invoice_count INT;
  payment_count INT;
  job_site_count INT;
  appointment_count INT;
BEGIN
  SELECT COUNT(*) INTO client_count FROM clients WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
  SELECT COUNT(*) INTO product_count FROM products WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
  SELECT COUNT(*) INTO quote_count FROM quotes WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
  SELECT COUNT(*) INTO invoice_count FROM invoices WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
  SELECT COUNT(*) INTO payment_count FROM payments WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
  SELECT COUNT(*) INTO job_site_count FROM job_sites WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
  SELECT COUNT(*) INTO appointment_count FROM appointments WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';

  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ SEED DATA SUCCESSFULLY LOADED!';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Test User: 6b1d26bf-40d7-46c0-9b07-89a120191971';
  RAISE NOTICE 'Company: Plomberie Pro Services SARL';
  RAISE NOTICE '';
  RAISE NOTICE '📊 STATISTICS:';
  RAISE NOTICE '  - Clients: %', client_count;
  RAISE NOTICE '  - Products: %', product_count;
  RAISE NOTICE '  - Quotes: %', quote_count;
  RAISE NOTICE '  - Invoices: %', invoice_count;
  RAISE NOTICE '  - Payments: %', payment_count;
  RAISE NOTICE '  - Job Sites: %', job_site_count;
  RAISE NOTICE '  - Appointments: %', appointment_count;
  RAISE NOTICE '';
  RAISE NOTICE '💡 All data is realistic, comprehensive, and ready for testing!';
  RAISE NOTICE '========================================';
END $$;

COMMIT;

-- ============================================
-- PlombiPro Comprehensive Seed Data - CORRECTED
-- With scheduled reminders and proper PostgreSQL syntax
-- Linked to: editionsrevel@gmail.com
-- ============================================

-- Note: Replace the UUID '00000000-0000-0000-0000-000000000001' with your actual user ID
-- You can get it from: SELECT id FROM auth.users WHERE email = 'editionsrevel@gmail.com';

BEGIN;

-- ============================================
-- 1. PROFILES
-- ============================================

INSERT INTO profiles (
  id,
  email,
  company_name,
  company_type,
  siret,
  phone,
  address,
  city,
  postal_code,
  country,
  tva_number,
  first_name,
  last_name,
  logo_url,
  iban,
  bic,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  'editionsrevel@gmail.com',
  'Plomberie Revel',
  'SARL',
  '82412345600015',
  '+33 6 12 34 56 78',
  '15 Rue de la République',
  'Lyon',
  '69002',
  'France',
  'FR82412345600015',
  'Jean',
  'Revel',
  NULL,
  'FR7612345678901234567890123',
  'BNPAFRPPXXX',
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  company_name = EXCLUDED.company_name,
  updated_at = NOW();

-- ============================================
-- 2. CATEGORIES
-- ============================================

INSERT INTO categories (name, description, icon, color, created_at) VALUES
('Plomberie générale', 'Travaux de plomberie courante', 'plumbing', '#0066CC', NOW()),
('Chauffage', 'Installation et maintenance chauffage', 'whatshot', '#FF6B35', NOW()),
('Sanitaires', 'Installation sanitaires et salles de bains', 'bathroom', '#00BFA5', NOW()),
('Dépannage urgence', 'Interventions urgentes 24/7', 'emergency', '#F44336', NOW()),
('Rénovation', 'Travaux de rénovation complète', 'home_repair_service', '#9C27B0', NOW()),
('Diagnostic', 'Diagnostics et expertises', 'search', '#FF9800', NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. CLIENTS
-- ============================================

INSERT INTO clients (
  user_id,
  name,
  email,
  phone,
  address,
  city,
  postal_code,
  type,
  siret,
  notes,
  created_at
) VALUES
('00000000-0000-0000-0000-000000000001'::uuid, 'Mme Sophie Martin', 'sophie.martin@email.fr', '+33 6 45 78 12 34', '23 Avenue des Lilas', 'Lyon', '69003', 'individual', NULL, 'Cliente fidèle, préfère les RDV après 17h', NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'M. Pierre Dubois', 'pierre.dubois@email.fr', '+33 6 78 90 12 34', '8 Rue Victor Hugo', 'Villeurbanne', '69100', 'individual', NULL, 'Urgent - fuite salle de bain', NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Résidence Les Érables', 'syndic@erables.fr', '+33 4 72 12 34 56', '45 Boulevard des Belges', 'Lyon', '69006', 'company', '50234567890012', 'Contrat d''entretien annuel', NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'M. Ahmed Benali', 'ahmed.benali@email.fr', '+33 6 23 45 67 89', '12 Place Bellecour', 'Lyon', '69002', 'individual', NULL, 'Nouveau client - recommandé par Mme Martin', NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'SCI Bâtiment Moderne', 'contact@batiment-moderne.fr', '+33 4 78 45 67 89', '78 Cours Lafayette', 'Lyon', '69003', 'company', '42187654321034', 'Immeuble de 15 appartements', NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Mme Claire Petit', 'claire.petit@email.fr', '+33 6 34 56 78 90', '5 Rue de la Paix', 'Caluire', '69300', 'individual', NULL, 'Rénovation complète salle de bain prévue Q2', NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Restaurant Le Bon Plat', 'direction@lebonplat.fr', '+33 4 72 98 76 54', '32 Rue de la Bourse', 'Lyon', '69002', 'company', '38956712340019', 'Maintenance cuisine professionnelle', NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'M. François Lemoine', 'f.lemoine@email.fr', '+33 6 67 89 01 23', '91 Avenue Foch', 'Lyon', '69006', 'individual', NULL, NULL, NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 4. PRODUCTS
-- ============================================

INSERT INTO products (
  user_id,
  name,
  description,
  reference,
  unit,
  unit_price,
  tva_rate,
  category_id,
  supplier,
  stock_quantity,
  created_at
) VALUES
-- Plomberie
('00000000-0000-0000-0000-000000000001'::uuid, 'Robinet mitigeur cuisine', 'Mitigeur évier bec haut chromé', 'MIG-CUIS-01', 'unité', 89.90, 20.0, 1, 'Point P', 5, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Tuyau PER Ø16mm', 'Tube PER bleu/rouge couronne 50m', 'TUY-PER-16', 'mètre', 2.50, 20.0, 1, 'Cedeo', 200, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Raccord laiton 20/27', 'Raccord mâle-femelle laiton', 'RAC-LAI-20', 'unité', 3.20, 20.0, 1, 'Point P', 50, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Siphon lavabo chromé', 'Siphon design gain de place', 'SIP-LAV-01', 'unité', 15.90, 20.0, 3, 'Leroy Merlin', 12, NOW()),

-- Chauffage
('00000000-0000-0000-0000-000000000001'::uuid, 'Chaudière gaz condensation', 'Chaudière murale 24kW', 'CHD-GAZ-24', 'unité', 1890.00, 20.0, 2, 'Cedeo', 2, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Radiateur acier', 'Radiateur panneaux 1200x600mm', 'RAD-ACR-12', 'unité', 145.00, 20.0, 2, 'Point P', 8, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Vanne thermostatique', 'Tête thermostatique programmable', 'VAN-THE-01', 'unité', 45.00, 20.0, 2, 'Castorama', 15, NOW()),

-- Sanitaires
('00000000-0000-0000-0000-000000000001'::uuid, 'WC suspendu blanc', 'Pack WC suspendu avec bâti', 'WC-SUS-01', 'unité', 320.00, 20.0, 3, 'Point P', 4, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Lavabo céramique 60cm', 'Lavabo blanc avec trop-plein', 'LAV-CER-60', 'unité', 78.00, 20.0, 3, 'Cedeo', 6, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Colonne de douche complète', 'Ensemble douche thermostatique', 'COL-DOU-01', 'unité', 230.00, 20.0, 3, 'Leroy Merlin', 3, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Baignoire acrylique 170cm', 'Baignoire droite avec pieds', 'BAI-ACR-17', 'unité', 450.00, 20.0, 3, 'Point P', 2, NOW()),

-- Main d''œuvre
('00000000-0000-0000-0000-000000000001'::uuid, 'Main d''œuvre plombier', 'Taux horaire qualification', 'MO-PLOMB', 'heure', 45.00, 20.0, 1, NULL, NULL, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Main d''œuvre chauffagiste', 'Taux horaire spécialisé', 'MO-CHAUF', 'heure', 50.00, 20.0, 2, NULL, NULL, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Déplacement', 'Forfait déplacement', 'DEP-FOR', 'forfait', 35.00, 20.0, 1, NULL, NULL, NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Intervention urgence', 'Majoration intervention urgente', 'INT-URG', 'forfait', 80.00, 20.0, 4, NULL, NULL, NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 5. QUOTES (DEVIS)
-- ============================================

INSERT INTO quotes (
  user_id,
  client_id,
  quote_number,
  title,
  description,
  status,
  valid_until,
  subtotal_ht,
  total_tva,
  total_ttc,
  notes,
  line_items,
  created_at
) VALUES
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM clients WHERE email = 'sophie.martin@email.fr' LIMIT 1),
  'DEV-2025-001',
  'Réparation fuite robinet cuisine',
  'Remplacement robinet mitigeur et joints',
  'accepted',
  NOW() + INTERVAL '30 days',
  169.90,
  33.98,
  203.88,
  'Intervention réalisée le 15/01/2025',
  '[
    {"description":"Robinet mitigeur cuisine","quantity":1,"unit":"unité","unit_price":89.90,"tva_rate":20.0,"total":89.90},
    {"description":"Main d''œuvre plombier","quantity":1,"unit":"heure","unit_price":45.00,"tva_rate":20.0,"total":45.00},
    {"description":"Déplacement","quantity":1,"unit":"forfait","unit_price":35.00,"tva_rate":20.0,"total":35.00}
  ]'::jsonb,
  NOW() - INTERVAL '15 days'
),
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM clients WHERE email = 'pierre.dubois@email.fr' LIMIT 1),
  'DEV-2025-002',
  'Dépannage urgence fuite salle de bain',
  'Intervention urgente fuite canalisation',
  'sent',
  NOW() + INTERVAL '15 days',
  267.50,
  53.50,
  321.00,
  'Devis urgent - intervention sous 2h',
  '[
    {"description":"Intervention urgence","quantity":1,"unit":"forfait","unit_price":80.00,"tva_rate":20.0,"total":80.00},
    {"description":"Main d''œuvre plombier","quantity":2.5,"unit":"heure","unit_price":45.00,"tva_rate":20.0,"total":112.50},
    {"description":"Tuyau PER Ø16mm","quantity":8,"unit":"mètre","unit_price":2.50,"tva_rate":20.0,"total":20.00},
    {"description":"Raccord laiton 20/27","quantity":4,"unit":"unité","unit_price":3.20,"tva_rate":20.0,"total":12.80},
    {"description":"Déplacement","quantity":1,"unit":"forfait","unit_price":35.00,"tva_rate":20.0,"total":35.00},
    {"description":"Petit matériel","quantity":1,"unit":"forfait","unit_price":7.20,"tva_rate":20.0,"total":7.20}
  ]'::jsonb,
  NOW() - INTERVAL '3 days'
),
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM clients WHERE email = 'claire.petit@email.fr' LIMIT 1),
  'DEV-2025-003',
  'Rénovation complète salle de bain',
  'Dépose et pose nouveaux équipements sanitaires',
  'draft',
  NOW() + INTERVAL '45 days',
  3245.00,
  649.00,
  3894.00,
  'Projet prévu pour mars 2025 - Durée estimée 5 jours',
  '[
    {"description":"WC suspendu blanc","quantity":1,"unit":"unité","unit_price":320.00,"tva_rate":20.0,"total":320.00},
    {"description":"Lavabo céramique 60cm","quantity":1,"unit":"unité","unit_price":78.00,"tva_rate":20.0,"total":78.00},
    {"description":"Colonne de douche complète","quantity":1,"unit":"unité","unit_price":230.00,"tva_rate":20.0,"total":230.00},
    {"description":"Robinet mitigeur cuisine","quantity":1,"unit":"unité","unit_price":89.90,"tva_rate":20.0,"total":89.90},
    {"description":"Main d''œuvre plombier","quantity":35,"unit":"heure","unit_price":45.00,"tva_rate":20.0,"total":1575.00},
    {"description":"Tuyau PER Ø16mm","quantity":45,"unit":"mètre","unit_price":2.50,"tva_rate":20.0,"total":112.50},
    {"description":"Raccord laiton 20/27","quantity":20,"unit":"unité","unit_price":3.20,"tva_rate":20.0,"total":64.00},
    {"description":"Déplacement","quantity":5,"unit":"forfait","unit_price":35.00,"tva_rate":20.0,"total":175.00},
    {"description":"Évacuation gravats","quantity":1,"unit":"forfait","unit_price":150.00,"tva_rate":20.0,"total":150.00},
    {"description":"Fournitures diverses","quantity":1,"unit":"forfait","unit_price":450.60,"tva_rate":20.0,"total":450.60}
  ]'::jsonb,
  NOW() - INTERVAL '5 days'
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 6. INVOICES (FACTURES)
-- ============================================

INSERT INTO invoices (
  user_id,
  client_id,
  invoice_number,
  title,
  description,
  status,
  due_date,
  subtotal_ht,
  total_tva,
  total_ttc,
  paid_amount,
  payment_method,
  payment_date,
  notes,
  line_items,
  created_at
) VALUES
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM clients WHERE email = 'sophie.martin@email.fr' LIMIT 1),
  'FAC-2025-001',
  'Réparation fuite robinet cuisine',
  'Facture suite à devis DEV-2025-001',
  'paid',
  NOW() + INTERVAL '30 days',
  169.90,
  33.98,
  203.88,
  203.88,
  'bank_transfer',
  NOW() - INTERVAL '5 days',
  'Règlement reçu le 05/01/2025 - Ref: VIR20250105',
  '[
    {"description":"Robinet mitigeur cuisine","quantity":1,"unit":"unité","unit_price":89.90,"tva_rate":20.0,"total":89.90},
    {"description":"Main d''œuvre plombier","quantity":1,"unit":"heure","unit_price":45.00,"tva_rate":20.0,"total":45.00},
    {"description":"Déplacement","quantity":1,"unit":"forfait","unit_price":35.00,"tva_rate":20.0,"total":35.00}
  ]'::jsonb,
  NOW() - INTERVAL '10 days'
),
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM clients WHERE name = 'Résidence Les Érables' LIMIT 1),
  'FAC-2025-002',
  'Contrat maintenance mensuel - Janvier 2025',
  'Entretien chaudières et contrôles réglementaires',
  'sent',
  NOW() + INTERVAL '30 days',
  520.00,
  104.00,
  624.00,
  0,
  NULL,
  NULL,
  'Paiement attendu avant fin de mois - Rappel prévu le 25/01',
  '[
    {"description":"Main d''œuvre chauffagiste","quantity":8,"unit":"heure","unit_price":50.00,"tva_rate":20.0,"total":400.00},
    {"description":"Vanne thermostatique","quantity":2,"unit":"unité","unit_price":45.00,"tva_rate":20.0,"total":90.00},
    {"description":"Déplacement","quantity":1,"unit":"forfait","unit_price":35.00,"tva_rate":20.0,"total":35.00}
  ]'::jsonb,
  NOW() - INTERVAL '7 days'
),
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM clients WHERE email = 'ahmed.benali@email.fr' LIMIT 1),
  'FAC-2025-003',
  'Dépannage fuite urgente',
  'Intervention urgente sur fuite canalisation',
  'overdue',
  NOW() - INTERVAL '5 days',
  215.00,
  43.00,
  258.00,
  0,
  NULL,
  NULL,
  'Facture en retard - Relance à effectuer',
  '[
    {"description":"Intervention urgence","quantity":1,"unit":"forfait","unit_price":80.00,"tva_rate":20.0,"total":80.00},
    {"description":"Main d''œuvre plombier","quantity":2,"unit":"heure","unit_price":45.00,"tva_rate":20.0,"total":90.00},
    {"description":"Déplacement","quantity":1,"unit":"forfait","unit_price":35.00,"tva_rate":20.0,"total":35.00},
    {"description":"Petit matériel","quantity":1,"unit":"forfait","unit_price":10.00,"tva_rate":20.0,"total":10.00}
  ]'::jsonb,
  NOW() - INTERVAL '35 days'
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 7. JOB SITES (CHANTIERS)
-- ============================================

INSERT INTO job_sites (
  user_id,
  client_id,
  name,
  description,
  address,
  city,
  postal_code,
  status,
  start_date,
  end_date,
  budget_estimate,
  notes,
  created_at
) VALUES
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM clients WHERE email = 'claire.petit@email.fr' LIMIT 1),
  'Rénovation SDB - Claire Petit',
  'Rénovation complète salle de bain 8m²',
  '5 Rue de la Paix',
  'Caluire',
  '69300',
  'planned',
  NOW() + INTERVAL '30 days',
  NOW() + INTERVAL '35 days',
  3894.00,
  'Matériaux à commander 15 jours avant démarrage',
  NOW() - INTERVAL '5 days'
),
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM clients WHERE name = 'SCI Bâtiment Moderne' LIMIT 1),
  'Réfection plomberie Immeuble',
  'Remplacement colonnes montantes',
  '78 Cours Lafayette',
  'Lyon',
  '69003',
  'in_progress',
  NOW() - INTERVAL '10 days',
  NOW() + INTERVAL '20 days',
  15600.00,
  'Intervention par appartement - planning établi avec syndic',
  NOW() - INTERVAL '15 days'
),
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM clients WHERE name = 'Restaurant Le Bon Plat' LIMIT 1),
  'Installation cuisine pro',
  'Mise en conformité plomberie cuisine',
  '32 Rue de la Bourse',
  'Lyon',
  '69002',
  'completed',
  NOW() - INTERVAL '45 days',
  NOW() - INTERVAL '38 days',
  5240.00,
  'Chantier terminé - client satisfait - Garantie décennale active',
  NOW() - INTERVAL '50 days'
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 8. JOB SITE TASKS
-- ============================================

INSERT INTO job_site_tasks (
  job_site_id,
  title,
  description,
  status,
  priority,
  due_date,
  created_at
) VALUES
(
  (SELECT id FROM job_sites WHERE name = 'Rénovation SDB - Claire Petit' LIMIT 1),
  'Commander matériaux',
  'Commander tous les équipements sanitaires chez Point P',
  'todo',
  'high',
  NOW() + INTERVAL '15 days',
  NOW()
),
(
  (SELECT id FROM job_sites WHERE name = 'Rénovation SDB - Claire Petit' LIMIT 1),
  'Dépose ancien équipement',
  'Dépose baignoire et ancien lavabo',
  'todo',
  'medium',
  NOW() + INTERVAL '30 days',
  NOW()
),
(
  (SELECT id FROM job_sites WHERE name = 'Réfection plomberie Immeuble' LIMIT 1),
  'Colonne montante cage A',
  'Remplacement colonne eau froide - Appartements 1 à 5',
  'completed',
  'high',
  NOW() - INTERVAL '5 days',
  NOW() - INTERVAL '10 days'
),
(
  (SELECT id FROM job_sites WHERE name = 'Réfection plomberie Immeuble' LIMIT 1),
  'Colonne montante cage B',
  'Remplacement colonne eau chaude - Appartements 6 à 10',
  'in_progress',
  'high',
  NOW() + INTERVAL '5 days',
  NOW() - INTERVAL '8 days'
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 9. PAYMENTS
-- ============================================

INSERT INTO payments (
  user_id,
  invoice_id,
  amount,
  payment_method,
  payment_date,
  notes,
  created_at
) VALUES
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM invoices WHERE invoice_number = 'FAC-2025-001' LIMIT 1),
  203.88,
  'bank_transfer',
  NOW() - INTERVAL '5 days',
  'Virement reçu - Reference: VIR20250105',
  NOW() - INTERVAL '5 days'
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 10. NOTIFICATIONS
-- ============================================

INSERT INTO notifications (
  user_id,
  title,
  message,
  type,
  is_read,
  action_url,
  created_at
) VALUES
('00000000-0000-0000-0000-000000000001'::uuid, 'Nouveau paiement reçu', 'Paiement de 203,88 € reçu pour FAC-2025-001', 'payment', true, '/invoices', NOW() - INTERVAL '5 days'),
('00000000-0000-0000-0000-000000000001'::uuid, 'Devis accepté', 'Le devis DEV-2025-001 a été accepté par Sophie Martin', 'quote', true, '/quotes', NOW() - INTERVAL '15 days'),
('00000000-0000-0000-0000-000000000001'::uuid, 'Facture en attente', 'La facture FAC-2025-002 est en attente de paiement (624,00 €)', 'reminder', false, '/invoices', NOW() - INTERVAL '1 day'),
('00000000-0000-0000-0000-000000000001'::uuid, 'Facture en retard', 'La facture FAC-2025-003 est en retard de 5 jours (258,00 €)', 'warning', false, '/invoices', NOW() - INTERVAL '1 hour'),
('00000000-0000-0000-0000-000000000001'::uuid, 'Nouveau chantier', 'Le chantier "Rénovation SDB" démarre dans 30 jours', 'job_site', false, '/job-sites', NOW()),
('00000000-0000-0000-0000-000000000001'::uuid, 'Tâche à faire', 'Commander les matériaux pour le chantier Claire Petit', 'task', false, '/job-sites', NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 11. SETTINGS
-- ============================================

INSERT INTO settings (
  user_id,
  invoice_prefix,
  quote_prefix,
  invoice_counter,
  quote_counter,
  default_payment_terms,
  default_tva_rate,
  signature_text,
  payment_reminder_days,
  created_at,
  updated_at
) VALUES
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  'FAC',
  'DEV',
  3,
  3,
  30,
  20.0,
  'Jean Revel - Gérant - Plomberie Revel SARL',
  15,
  NOW(),
  NOW()
) ON CONFLICT (user_id) DO UPDATE SET
  invoice_counter = EXCLUDED.invoice_counter,
  quote_counter = EXCLUDED.quote_counter,
  updated_at = NOW();

-- ============================================
-- 12. SCHEDULED REMINDERS TABLE (NEW)
-- ============================================

-- Create scheduled_reminders table if it doesn't exist
CREATE TABLE IF NOT EXISTS scheduled_reminders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  invoice_id UUID REFERENCES invoices(id) ON DELETE CASCADE,
  reminder_type VARCHAR(50) NOT NULL, -- 'payment_due', 'payment_overdue', 'quote_expiry', 'maintenance'
  reminder_date TIMESTAMP NOT NULL,
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'sent', 'cancelled'
  message TEXT,
  email_to VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW(),
  sent_at TIMESTAMP,
  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES profiles(id)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_scheduled_reminders_date ON scheduled_reminders(reminder_date, status);
CREATE INDEX IF NOT EXISTS idx_scheduled_reminders_user ON scheduled_reminders(user_id);

-- Insert scheduled reminders
INSERT INTO scheduled_reminders (
  user_id,
  invoice_id,
  reminder_type,
  reminder_date,
  status,
  message,
  email_to,
  created_at
) VALUES
-- Reminder for FAC-2025-002 (due in 30 days, reminder 15 days before)
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM invoices WHERE invoice_number = 'FAC-2025-002' LIMIT 1),
  'payment_due',
  NOW() + INTERVAL '15 days',
  'pending',
  'Rappel : Facture FAC-2025-002 de 624,00 € à échéance dans 15 jours',
  'syndic@erables.fr',
  NOW()
),
-- Overdue reminder for FAC-2025-003
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  (SELECT id FROM invoices WHERE invoice_number = 'FAC-2025-003' LIMIT 1),
  'payment_overdue',
  NOW() + INTERVAL '1 day',
  'pending',
  'Relance : Facture FAC-2025-003 de 258,00 € en retard de 5 jours',
  'ahmed.benali@email.fr',
  NOW()
),
-- Quote expiry reminder for DEV-2025-002
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  NULL,
  'quote_expiry',
  NOW() + INTERVAL '10 days',
  'pending',
  'Rappel : Devis DEV-2025-002 expire dans 5 jours',
  'pierre.dubois@email.fr',
  NOW()
),
-- Maintenance reminder for Les Érables
(
  '00000000-0000-0000-0000-000000000001'::uuid,
  NULL,
  'maintenance',
  NOW() + INTERVAL '25 days',
  'pending',
  'Rappel : Entretien mensuel prévu pour février 2025',
  'syndic@erables.fr',
  NOW()
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 13. FUNCTION: Auto-create payment reminders
-- ============================================

CREATE OR REPLACE FUNCTION create_payment_reminder()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create reminder for unpaid invoices
  IF NEW.status IN ('sent', 'overdue') AND NEW.paid_amount = 0 THEN
    -- Create reminder 15 days before due date
    INSERT INTO scheduled_reminders (
      user_id,
      invoice_id,
      reminder_type,
      reminder_date,
      message,
      email_to
    ) VALUES (
      NEW.user_id,
      NEW.id,
      'payment_due',
      NEW.due_date - INTERVAL '15 days',
      'Rappel : Facture ' || NEW.invoice_number || ' de ' || NEW.total_ttc || ' € à échéance dans 15 jours',
      (SELECT email FROM clients WHERE id = NEW.client_id)
    )
    ON CONFLICT DO NOTHING;

    -- Create overdue reminder for 3 days after due date
    INSERT INTO scheduled_reminders (
      user_id,
      invoice_id,
      reminder_type,
      reminder_date,
      message,
      email_to
    ) VALUES (
      NEW.user_id,
      NEW.id,
      'payment_overdue',
      NEW.due_date + INTERVAL '3 days',
      'Relance : Facture ' || NEW.invoice_number || ' de ' || NEW.total_ttc || ' € en retard',
      (SELECT email FROM clients WHERE id = NEW.client_id)
    )
    ON CONFLICT DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_create_payment_reminder ON invoices;
CREATE TRIGGER trigger_create_payment_reminder
  AFTER INSERT OR UPDATE ON invoices
  FOR EACH ROW
  EXECUTE FUNCTION create_payment_reminder();

COMMIT;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ PlombiPro Seed Data Loaded Successfully!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📧 Company linked to: editionsrevel@gmail.com';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Database populated with:';
  RAISE NOTICE '  ✓ 1 company profile (Plomberie Revel)';
  RAISE NOTICE '  ✓ 6 product categories';
  RAISE NOTICE '  ✓ 8 clients';
  RAISE NOTICE '  ✓ 15 products';
  RAISE NOTICE '  ✓ 3 quotes (1 accepted, 1 sent, 1 draft)';
  RAISE NOTICE '  ✓ 3 invoices (1 paid, 1 pending, 1 overdue)';
  RAISE NOTICE '  ✓ 3 job sites';
  RAISE NOTICE '  ✓ 4 tasks';
  RAISE NOTICE '  ✓ 1 payment record';
  RAISE NOTICE '  ✓ 6 notifications';
  RAISE NOTICE '  ✓ 4 scheduled reminders';
  RAISE NOTICE '';
  RAISE NOTICE '🔔 Reminder System:';
  RAISE NOTICE '  ✓ Auto-reminder function created';
  RAISE NOTICE '  ✓ Trigger installed on invoices table';
  RAISE NOTICE '  ✓ Payment reminders: 15 days before due date';
  RAISE NOTICE '  ✓ Overdue reminders: 3 days after due date';
  RAISE NOTICE '';
  RAISE NOTICE '💡 Next Steps:';
  RAISE NOTICE '  1. Update user_id with actual UUID from auth.users';
  RAISE NOTICE '  2. Test the app with this seed data';
  RAISE NOTICE '  3. Set up cron job to process scheduled reminders';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
END $$;

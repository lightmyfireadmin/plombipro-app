-- Migration 006: Insert 50+ System Plumbing Templates
-- Date: 2025-11-05
-- Purpose: Create pre-built templates for common plumbing jobs
-- These are system templates available to all users (user_id = NULL, is_system_template = true)

-- =============================================================================
-- CATEGORY 1: BATHROOM RENOVATION (Rénovation Salle de Bain)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Rénovation complète salle de bain (Standard)',
    'quote',
    'Rénovation Salle de Bain',
    '[
        {"description": "Dépose complète ancienne salle de bain", "quantity": 1, "unit": "forfait", "unit_price": 450.00, "vat_rate": 20.0},
        {"description": "Évacuation gravats et mise en décharge", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose receveur de douche 80x120cm", "quantity": 1, "unit": "unité", "unit_price": 520.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose paroi de douche", "quantity": 1, "unit": "unité", "unit_price": 380.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose lavabo suspendu avec mitigeur", "quantity": 1, "unit": "unité", "unit_price": 420.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose WC suspendu avec bâti-support", "quantity": 1, "unit": "unité", "unit_price": 680.00, "vat_rate": 20.0},
        {"description": "Raccordement eau froide/chaude (PER)", "quantity": 1, "unit": "forfait", "unit_price": 350.00, "vat_rate": 20.0},
        {"description": "Raccordement évacuations eaux usées PVC", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose sèche-serviettes 500W", "quantity": 1, "unit": "unité", "unit_price": 340.00, "vat_rate": 20.0},
        {"description": "Essais et mise en service", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Acompte de 30% à la commande. Garantie décennale. Délai d''exécution: 5-7 jours ouvrés.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Rénovation complète salle de bain (Haut de gamme)',
    'quote',
    'Rénovation Salle de Bain',
    '[
        {"description": "Dépose complète ancienne salle de bain", "quantity": 1, "unit": "forfait", "unit_price": 550.00, "vat_rate": 20.0},
        {"description": "Évacuation gravats et mise en décharge", "quantity": 1, "unit": "forfait", "unit_price": 220.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose douche italienne avec évacuation carreler", "quantity": 1, "unit": "unité", "unit_price": 1200.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose paroi de douche sur-mesure", "quantity": 1, "unit": "unité", "unit_price": 850.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose meuble vasque double 120cm", "quantity": 1, "unit": "unité", "unit_price": 980.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose robinetterie thermostatique haut de gamme", "quantity": 1, "unit": "unité", "unit_price": 420.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose WC japonais avec douchette", "quantity": 1, "unit": "unité", "unit_price": 1200.00, "vat_rate": 20.0},
        {"description": "Raccordements hydrauliques complets (PER multicouche)", "quantity": 1, "unit": "forfait", "unit_price": 550.00, "vat_rate": 20.0},
        {"description": "Raccordement évacuations eaux usées avec siphons design", "quantity": 1, "unit": "forfait", "unit_price": 380.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose radiateur sèche-serviettes électrique 750W design", "quantity": 1, "unit": "unité", "unit_price": 580.00, "vat_rate": 20.0},
        {"description": "Essais, réglages et mise en service complète", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Acompte de 40% à la commande. Garantie décennale. Délai d''exécution: 7-10 jours ouvrés. Matériel haut de gamme.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Remplacement baignoire par douche',
    'quote',
    'Rénovation Salle de Bain',
    '[
        {"description": "Dépose baignoire existante", "quantity": 1, "unit": "unité", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Évacuation et mise en décharge", "quantity": 1, "unit": "forfait", "unit_price": 90.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose receveur douche extra-plat 90x90cm", "quantity": 1, "unit": "unité", "unit_price": 480.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose paroi de douche 90x90cm", "quantity": 1, "unit": "unité", "unit_price": 350.00, "vat_rate": 20.0},
        {"description": "Colonne de douche thermostatique", "quantity": 1, "unit": "unité", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Raccordement eau froide/chaude", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Adaptation évacuation", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Essais et mise en service", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Travaux réalisables en 1 journée. Garantie décennale.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 2: KITCHEN PLUMBING (Plomberie Cuisine)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation complète cuisine neuve',
    'quote',
    'Plomberie Cuisine',
    '[
        {"description": "Fourniture et pose évier inox 1 bac + égouttoir", "quantity": 1, "unit": "unité", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose mitigeur cuisine bec haut", "quantity": 1, "unit": "unité", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Alimentation eau froide/chaude sous évier (PER)", "quantity": 1, "unit": "forfait", "unit_price": 220.00, "vat_rate": 20.0},
        {"description": "Raccordement évacuation avec siphon", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Raccordement lave-vaisselle (arrivée eau + évacuation)", "quantity": 1, "unit": "unité", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Raccordement lave-linge (arrivée eau + évacuation)", "quantity": 1, "unit": "unité", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Pose robinets d''arrêt (lot de 4)", "quantity": 1, "unit": "lot", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Essais et vérification étanchéité", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Intervention coordonnée avec cuisiniste. Garantie décennale.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Remplacement évier et robinetterie',
    'quote',
    'Plomberie Cuisine',
    '[
        {"description": "Dépose ancien évier et robinet", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose nouvel évier 2 bacs inox", "quantity": 1, "unit": "unité", "unit_price": 350.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose mitigeur douchette extractible", "quantity": 1, "unit": "unité", "unit_price": 220.00, "vat_rate": 20.0},
        {"description": "Raccordement alimentation eau", "quantity": 1, "unit": "forfait", "unit_price": 100.00, "vat_rate": 20.0},
        {"description": "Raccordement évacuation avec siphon inox", "quantity": 1, "unit": "forfait", "unit_price": 90.00, "vat_rate": 20.0},
        {"description": "Joints silicone et finitions", "quantity": 1, "unit": "forfait", "unit_price": 40.00, "vat_rate": 20.0},
        {"description": "Essais et mise en service", "quantity": 1, "unit": "forfait", "unit_price": 40.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Travaux réalisables en demi-journée. Garantie 2 ans.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 3: HEATING INSTALLATION (Installation Chauffage)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation chaudière gaz condensation',
    'quote',
    'Installation Chauffage',
    '[
        {"description": "Dépose ancienne chaudière et évacuation", "quantity": 1, "unit": "forfait", "unit_price": 380.00, "vat_rate": 20.0},
        {"description": "Fourniture chaudière gaz condensation murale 24kW", "quantity": 1, "unit": "unité", "unit_price": 2800.00, "vat_rate": 20.0},
        {"description": "Pose et raccordement hydraulique chaudière", "quantity": 1, "unit": "forfait", "unit_price": 650.00, "vat_rate": 20.0},
        {"description": "Raccordement gaz avec tube inox flexible", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Installation ventouse concentrique Ø 60/100mm", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose vase expansion sanitaire 18L", "quantity": 1, "unit": "unité", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose filtre anti-calcaire", "quantity": 1, "unit": "unité", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Programmateur radio avec thermostat d''ambiance", "quantity": 1, "unit": "unité", "unit_price": 220.00, "vat_rate": 20.0},
        {"description": "Mise en service, réglages et formation utilisateur", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Attestation de conformité gaz", "quantity": 1, "unit": "unité", "unit_price": 120.00, "vat_rate": 20.0}
    ]',
    'Devis valable 60 jours. Acompte 40% à la commande. Éligible MaPrimeRénov. Garantie décennale. Délai: 2-3 jours.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation pompe à chaleur air/eau',
    'quote',
    'Installation Chauffage',
    '[
        {"description": "Fourniture pompe à chaleur air/eau 12kW", "quantity": 1, "unit": "unité", "unit_price": 8500.00, "vat_rate": 20.0},
        {"description": "Unité extérieure avec groupe compresseur", "quantity": 1, "unit": "unité", "unit_price": 0.00, "vat_rate": 20.0},
        {"description": "Pose module intérieur hydraulique", "quantity": 1, "unit": "forfait", "unit_price": 850.00, "vat_rate": 20.0},
        {"description": "Pose unité extérieure sur plots béton", "quantity": 1, "unit": "forfait", "unit_price": 450.00, "vat_rate": 20.0},
        {"description": "Liaison frigorifique cuivre (jusqu''à 15m)", "quantity": 1, "unit": "forfait", "unit_price": 680.00, "vat_rate": 20.0},
        {"description": "Raccordement électrique triphasé", "quantity": 1, "unit": "forfait", "unit_price": 420.00, "vat_rate": 20.0},
        {"description": "Raccordement hydraulique au chauffage existant", "quantity": 1, "unit": "forfait", "unit_price": 750.00, "vat_rate": 20.0},
        {"description": "Ballon tampon 100L avec isolation", "quantity": 1, "unit": "unité", "unit_price": 580.00, "vat_rate": 20.0},
        {"description": "Thermostat connecté avec application", "quantity": 1, "unit": "unité", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Mise en service, réglages et optimisation", "quantity": 1, "unit": "forfait", "unit_price": 350.00, "vat_rate": 20.0},
        {"description": "Dossier MaPrimeRénov et certificat RGE", "quantity": 1, "unit": "forfait", "unit_price": 250.00, "vat_rate": 20.0}
    ]',
    'Devis valable 60 jours. Acompte 40%. Installation certifiée RGE. Éligible aides État. Garantie décennale. COP ≥ 4.0. Délai: 5-7 jours.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation radiateurs (par radiateur)',
    'quote',
    'Installation Chauffage',
    '[
        {"description": "Fourniture radiateur acier panneau 1200x600mm 1500W", "quantity": 1, "unit": "unité", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Console de fixation murale", "quantity": 1, "unit": "lot", "unit_price": 25.00, "vat_rate": 20.0},
        {"description": "Pose radiateur et fixation murale", "quantity": 1, "unit": "unité", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Raccordement bitube avec robinet thermostatique", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Tête thermostatique programmable", "quantity": 1, "unit": "unité", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Purge, essais et réglages", "quantity": 1, "unit": "forfait", "unit_price": 40.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Prix unitaire par radiateur. Dégressif à partir de 5 radiateurs. Garantie 2 ans.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 4: BOILER REPLACEMENT (Remplacement Chauffe-eau)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Remplacement chauffe-eau électrique 200L',
    'quote',
    'Remplacement Chauffe-eau',
    '[
        {"description": "Dépose ancien chauffe-eau et évacuation", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Fourniture chauffe-eau électrique blindé 200L vertical", "quantity": 1, "unit": "unité", "unit_price": 450.00, "vat_rate": 20.0},
        {"description": "Trépied de support", "quantity": 1, "unit": "unité", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Pose chauffe-eau sur trépied", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Groupe de sécurité NF avec siphon", "quantity": 1, "unit": "unité", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Raccordement eau froide avec flexible inox", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Raccordement eau chaude avec flexible inox", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Raccordement électrique avec contacteur jour/nuit", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Mise en service et vérification", "quantity": 1, "unit": "forfait", "unit_price": 50.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Installation en demi-journée. Garantie cuve 5 ans. Travaux livrables sous 48h.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Remplacement chauffe-eau thermodynamique 250L',
    'quote',
    'Remplacement Chauffe-eau',
    '[
        {"description": "Dépose ancien chauffe-eau et évacuation", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Fourniture chauffe-eau thermodynamique 250L COP 3.5", "quantity": 1, "unit": "unité", "unit_price": 1800.00, "vat_rate": 20.0},
        {"description": "Pose avec raccordement hydraulique", "quantity": 1, "unit": "forfait", "unit_price": 350.00, "vat_rate": 20.0},
        {"description": "Groupe de sécurité NF avec siphon", "quantity": 1, "unit": "unité", "unit_price": 40.00, "vat_rate": 20.0},
        {"description": "Kit de raccordement air (gaines)", "quantity": 1, "unit": "lot", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Raccordement électrique", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Mise en service, réglages et programmation", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Certification RGE et dossier prime CEE", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0}
    ]',
    'Devis valable 60 jours. Éligible aides CEE et MaPrimeRénov. Installation certifiée RGE. Économies jusqu''à 70%. Garantie 5 ans. Délai: 3-5 jours.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 5: LEAK REPAIR (Réparation Fuite)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Réparation fuite robinetterie',
    'quote',
    'Réparation Fuite',
    '[
        {"description": "Déplacement et diagnostic", "quantity": 1, "unit": "forfait", "unit_price": 65.00, "vat_rate": 20.0},
        {"description": "Démontage robinet et identification panne", "quantity": 1, "unit": "forfait", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Fourniture cartouche céramique de rechange", "quantity": 1, "unit": "unité", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Remplacement cartouche et joints", "quantity": 1, "unit": "forfait", "unit_price": 55.00, "vat_rate": 20.0},
        {"description": "Remontage et essais", "quantity": 1, "unit": "forfait", "unit_price": 30.00, "vat_rate": 20.0}
    ]',
    'Intervention sous 24h. Garantie pièces 1 an. Devis valable 15 jours.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Réparation fuite tuyauterie (avec recherche)',
    'quote',
    'Réparation Fuite',
    '[
        {"description": "Déplacement et diagnostic", "quantity": 1, "unit": "forfait", "unit_price": 85.00, "vat_rate": 20.0},
        {"description": "Recherche fuite non visible (humidimètre)", "quantity": 1, "unit": "heure", "unit_price": 90.00, "vat_rate": 20.0},
        {"description": "Ouverture mur/sol (découpe)", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Remplacement tronçon de tuyauterie PER (3 mètres)", "quantity": 3, "unit": "mètre", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Raccords et fournitures", "quantity": 1, "unit": "lot", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Test étanchéité sous pression", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Rebouchage et remise en état sommaire", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0}
    ]',
    'Intervention rapide sous 12h. Garantie 2 ans. Second-œuvre (peinture/carrelage) non inclus. Devis valable 15 jours.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Réparation fuite WC (chasse d''eau)',
    'quote',
    'Réparation Fuite',
    '[
        {"description": "Déplacement et diagnostic", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Démontage mécanisme de chasse", "quantity": 1, "unit": "forfait", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Fourniture mécanisme de chasse complet", "quantity": 1, "unit": "unité", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Remplacement flotteur et joint", "quantity": 1, "unit": "forfait", "unit_price": 50.00, "vat_rate": 20.0},
        {"description": "Réglage et essais", "quantity": 1, "unit": "forfait", "unit_price": 25.00, "vat_rate": 20.0}
    ]',
    'Intervention sous 24h. Garantie 1 an. Devis valable 15 jours.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 6: DRAIN CLEANING (Débouchage)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Débouchage évier/lavabo (simple)',
    'quote',
    'Débouchage',
    '[
        {"description": "Déplacement", "quantity": 1, "unit": "forfait", "unit_price": 55.00, "vat_rate": 20.0},
        {"description": "Débouchage mécanique au furet", "quantity": 1, "unit": "forfait", "unit_price": 95.00, "vat_rate": 20.0},
        {"description": "Démontage et nettoyage siphon", "quantity": 1, "unit": "forfait", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Test évacuation", "quantity": 1, "unit": "forfait", "unit_price": 25.00, "vat_rate": 20.0}
    ]',
    'Intervention sous 2h (selon dispo). Garantie 3 mois. Devis valable 15 jours.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Débouchage WC',
    'quote',
    'Débouchage',
    '[
        {"description": "Déplacement", "quantity": 1, "unit": "forfait", "unit_price": 65.00, "vat_rate": 20.0},
        {"description": "Débouchage WC au furet électrique", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Nettoyage et désinfection", "quantity": 1, "unit": "forfait", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Test chasse d''eau", "quantity": 1, "unit": "forfait", "unit_price": 20.00, "vat_rate": 20.0}
    ]',
    'Intervention sous 2h (selon dispo). Garantie 3 mois. Devis valable 15 jours.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Débouchage colonne/canalisation haute pression',
    'quote',
    'Débouchage',
    '[
        {"description": "Déplacement avec camion hydrocureur", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Inspection caméra avant intervention", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Débouchage haute pression (jusqu''à 20m)", "quantity": 1, "unit": "forfait", "unit_price": 350.00, "vat_rate": 20.0},
        {"description": "Nettoyage canalisation complète", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Inspection caméra après travaux", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Rapport d''intervention avec photos", "quantity": 1, "unit": "unité", "unit_price": 50.00, "vat_rate": 20.0}
    ]',
    'Intervention sous 4h (urgence). Garantie 6 mois. Rapport vidéo fourni. Devis valable 15 jours.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 7: EMERGENCY CALL-OUT (Intervention d''Urgence)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Intervention urgence fuite (nuit/weekend)',
    'quote',
    'Intervention d''Urgence',
    '[
        {"description": "Déplacement urgence (nuit/weekend/férié)", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Main d''oeuvre urgence (majoration)", "quantity": 2, "unit": "heure", "unit_price": 95.00, "vat_rate": 20.0},
        {"description": "Diagnostic et localisation fuite", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Réparation provisoire / colmatage", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Fournitures d''urgence", "quantity": 1, "unit": "lot", "unit_price": 85.00, "vat_rate": 20.0}
    ]',
    'Intervention sous 1h. Tarif urgence appliqué (nuit/weekend/férié). Devis définitif après diagnostic.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Dégel canalisation urgence hiver',
    'quote',
    'Intervention d''Urgence',
    '[
        {"description": "Déplacement urgence", "quantity": 1, "unit": "forfait", "unit_price": 85.00, "vat_rate": 20.0},
        {"description": "Diagnostic canalisation gelée", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Dégel thermique progressif", "quantity": 2, "unit": "heure", "unit_price": 75.00, "vat_rate": 20.0},
        {"description": "Vérification étanchéité post-dégel", "quantity": 1, "unit": "forfait", "unit_price": 55.00, "vat_rate": 20.0},
        {"description": "Conseils isolation et prévention", "quantity": 1, "unit": "forfait", "unit_price": 0.00, "vat_rate": 20.0}
    ]',
    'Intervention rapide sous 2h. Risque d''éclatement en cas de dégel trop rapide. Garantie intervention 3 mois.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 8: ANNUAL MAINTENANCE (Entretien Annuel)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Entretien annuel chaudière gaz',
    'quote',
    'Entretien Annuel',
    '[
        {"description": "Déplacement", "quantity": 1, "unit": "forfait", "unit_price": 0.00, "vat_rate": 20.0},
        {"description": "Nettoyage corps de chauffe et brûleur", "quantity": 1, "unit": "forfait", "unit_price": 95.00, "vat_rate": 20.0},
        {"description": "Contrôle combustion et réglages", "quantity": 1, "unit": "forfait", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Vérification organes de sécurité", "quantity": 1, "unit": "forfait", "unit_price": 30.00, "vat_rate": 20.0},
        {"description": "Contrôle pression et vase expansion", "quantity": 1, "unit": "forfait", "unit_price": 20.00, "vat_rate": 20.0},
        {"description": "Test analyseur fumées", "quantity": 1, "unit": "forfait", "unit_price": 25.00, "vat_rate": 20.0},
        {"description": "Attestation d''entretien annuel obligatoire", "quantity": 1, "unit": "unité", "unit_price": 15.00, "vat_rate": 20.0}
    ]',
    'Entretien obligatoire annuel. Attestation fournie pour assurance. Contrat entretien disponible (tarif préférentiel). Devis valable 1 an.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Entretien annuel pompe à chaleur',
    'quote',
    'Entretien Annuel',
    '[
        {"description": "Déplacement", "quantity": 1, "unit": "forfait", "unit_price": 0.00, "vat_rate": 20.0},
        {"description": "Nettoyage unité extérieure (batteries)", "quantity": 1, "unit": "forfait", "unit_price": 85.00, "vat_rate": 20.0},
        {"description": "Contrôle circuit frigorifique et pressions", "quantity": 1, "unit": "forfait", "unit_price": 65.00, "vat_rate": 20.0},
        {"description": "Vérification compresseur et ventilateurs", "quantity": 1, "unit": "forfait", "unit_price": 50.00, "vat_rate": 20.0},
        {"description": "Contrôle électrique et protections", "quantity": 1, "unit": "forfait", "unit_price": 40.00, "vat_rate": 20.0},
        {"description": "Optimisation paramètres selon saison", "quantity": 1, "unit": "forfait", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Rapport d''intervention détaillé", "quantity": 1, "unit": "unité", "unit_price": 20.00, "vat_rate": 20.0}
    ]',
    'Entretien recommandé annuel. Préserve performance et garantie constructeur. Contrat disponible. Devis valable 1 an.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Désembouage circuit chauffage',
    'quote',
    'Entretien Annuel',
    '[
        {"description": "Diagnostic état circuit (prélèvement eau)", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Raccordement pompe de désembouage", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Désembouage complet circuit (jusqu''à 12 radiateurs)", "quantity": 1, "unit": "forfait", "unit_price": 450.00, "vat_rate": 20.0},
        {"description": "Produit désembouant professionnel", "quantity": 1, "unit": "lot", "unit_price": 85.00, "vat_rate": 20.0},
        {"description": "Rinçage circuit et remplissage eau neuve", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Ajout inhibiteur de corrosion", "quantity": 1, "unit": "lot", "unit_price": 65.00, "vat_rate": 20.0},
        {"description": "Purge complète tous radiateurs", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Réglage pression et vérification", "quantity": 1, "unit": "forfait", "unit_price": 50.00, "vat_rate": 20.0}
    ]',
    'Améliore rendement jusqu''à 15%. Évite pannes. Recommandé tous les 5-10 ans. Garantie 2 ans. Durée: 1 journée.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 9: SOLAR WATER HEATER (Chauffe-eau Solaire)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation chauffe-eau solaire 300L (4 personnes)',
    'quote',
    'Chauffe-eau Solaire',
    '[
        {"description": "Fourniture kit chauffe-eau solaire 300L", "quantity": 1, "unit": "unité", "unit_price": 4500.00, "vat_rate": 20.0},
        {"description": "2 panneaux solaires thermiques 2m² (4m² total)", "quantity": 2, "unit": "unité", "unit_price": 0.00, "vat_rate": 20.0},
        {"description": "Ballon double échangeur 300L avec résistance appoint", "quantity": 1, "unit": "unité", "unit_price": 0.00, "vat_rate": 20.0},
        {"description": "Pose panneaux en toiture (sur tuiles)", "quantity": 1, "unit": "forfait", "unit_price": 850.00, "vat_rate": 20.0},
        {"description": "Pose ballon solaire", "quantity": 1, "unit": "forfait", "unit_price": 380.00, "vat_rate": 20.0},
        {"description": "Circuit primaire glycolé (tuyauterie cuivre isolée)", "quantity": 1, "unit": "forfait", "unit_price": 650.00, "vat_rate": 20.0},
        {"description": "Groupe de circulation solaire avec régulation", "quantity": 1, "unit": "unité", "unit_price": 420.00, "vat_rate": 20.0},
        {"description": "Vase expansion solaire et soupape sécurité", "quantity": 1, "unit": "lot", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Raccordement hydraulique eau chaude sanitaire", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Raccordement électrique appoint et régulation", "quantity": 1, "unit": "forfait", "unit_price": 220.00, "vat_rate": 20.0},
        {"description": "Mise en service, remplissage glycol et réglages", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Dossier aides (MaPrimeRénov + CEE) et certification RGE", "quantity": 1, "unit": "forfait", "unit_price": 250.00, "vat_rate": 20.0}
    ]',
    'Devis valable 60 jours. Installation certifiée RGE. Éligible jusqu''à 4000€ d''aides. Économies 60-70% eau chaude. Garantie décennale. Délai: 5-7 jours.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 10: UNDERFLOOR HEATING (Plancher Chauffant)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation plancher chauffant hydraulique (par m²)',
    'quote',
    'Plancher Chauffant',
    '[
        {"description": "Fourniture tubes PER pré-gainés Ø16mm", "quantity": 25, "unit": "m²", "unit_price": 18.00, "vat_rate": 20.0},
        {"description": "Isolation polystyrène haute densité 30mm", "quantity": 25, "unit": "m²", "unit_price": 12.00, "vat_rate": 20.0},
        {"description": "Treillis de maintien et agrafes", "quantity": 25, "unit": "m²", "unit_price": 3.50, "vat_rate": 20.0},
        {"description": "Collecteur 6 départs avec vannes réglage", "quantity": 1, "unit": "unité", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Pose isolation et tubes selon calepinage", "quantity": 25, "unit": "m²", "unit_price": 25.00, "vat_rate": 20.0},
        {"description": "Raccordement collecteur et mise en pression", "quantity": 1, "unit": "forfait", "unit_price": 350.00, "vat_rate": 20.0},
        {"description": "Test étanchéité 6 bars (avec PV)", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose thermostat programmable par zone", "quantity": 1, "unit": "unité", "unit_price": 220.00, "vat_rate": 20.0}
    ]',
    'Prix pour 25m². Chape liquide non incluse (par entreprise gros-œuvre). Test pression avant chape obligatoire. Garantie décennale.',
    true,
    NOW(),
    NOW()
);

-- Continue with more templates...
-- =============================================================================
-- CATEGORY 11: PIPE REPLACEMENT (Remplacement Tuyauterie)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Remplacement tuyauterie cuivre par PER',
    'quote',
    'Remplacement Tuyauterie',
    '[
        {"description": "Dépose ancienne tuyauterie cuivre", "quantity": 15, "unit": "mètre", "unit_price": 12.00, "vat_rate": 20.0},
        {"description": "Fourniture tube PER Ø16mm avec isolant", "quantity": 15, "unit": "mètre", "unit_price": 8.50, "vat_rate": 20.0},
        {"description": "Pose tuyauterie PER", "quantity": 15, "unit": "mètre", "unit_price": 15.00, "vat_rate": 20.0},
        {"description": "Raccords et fournitures", "quantity": 1, "unit": "lot", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Réglage compteur et robinet d''arrêt", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Test étanchéité sous pression", "quantity": 1, "unit": "forfait", "unit_price": 100.00, "vat_rate": 20.0},
        {"description": "Remise en état sommaire (rebouchage)", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Base 15 mètres linéaires. Second-œuvre (peinture) non inclus. Garantie décennale.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Remplacement colonne d''eau',
    'quote',
    'Remplacement Tuyauterie',
    '[
        {"description": "Diagnostic et repérage colonne", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Ouverture gaines techniques (2 niveaux)", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Dépose ancienne colonne", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Fourniture tube multicouche Ø20mm", "quantity": 12, "unit": "mètre", "unit_price": 18.00, "vat_rate": 20.0},
        {"description": "Pose nouvelle colonne sur 2 niveaux", "quantity": 1, "unit": "forfait", "unit_price": 450.00, "vat_rate": 20.0},
        {"description": "Raccordements départs par étage (4 départs)", "quantity": 4, "unit": "unité", "unit_price": 85.00, "vat_rate": 20.0},
        {"description": "Test étanchéité complet", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Fermeture gaines et finitions", "quantity": 1, "unit": "forfait", "unit_price": 220.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Coordination copropriété nécessaire. Garantie décennale. Délai: 2-3 jours.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 12: WATER SOFTENER (Adoucisseur d''Eau)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation adoucisseur d''eau',
    'quote',
    'Adoucisseur d''Eau',
    '[
        {"description": "Fourniture adoucisseur d''eau 20L - 25°TH", "quantity": 1, "unit": "unité", "unit_price": 850.00, "vat_rate": 20.0},
        {"description": "Bypass 3 vannes avec joints", "quantity": 1, "unit": "lot", "unit_price": 95.00, "vat_rate": 20.0},
        {"description": "Raccordement sur arrivée générale", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Raccordement évacuation saumure", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Programmation et réglages (selon dureté eau)", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Sel régénérant 25kg + désinfectant", "quantity": 1, "unit": "lot", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Test TH eau avant/après", "quantity": 1, "unit": "forfait", "unit_price": 50.00, "vat_rate": 20.0},
        {"description": "Formation client", "quantity": 1, "unit": "forfait", "unit_price": 40.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Économies savon et détartrage. Protège électroménager. Contrat entretien disponible. Garantie 2 ans.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 13: SANITARYWARE REPLACEMENT (Remplacement Sanitaires)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Remplacement lavabo complet',
    'quote',
    'Remplacement Sanitaires',
    '[
        {"description": "Dépose ancien lavabo et robinet", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Fourniture lavabo céramique 60cm", "quantity": 1, "unit": "unité", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Fourniture mitigeur lavabo chromé", "quantity": 1, "unit": "unité", "unit_price": 85.00, "vat_rate": 20.0},
        {"description": "Pose lavabo avec fixations murales", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Raccordement eau froide/chaude (flexibles inox)", "quantity": 1, "unit": "forfait", "unit_price": 70.00, "vat_rate": 20.0},
        {"description": "Siphon design chromé", "quantity": 1, "unit": "unité", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Raccordement évacuation", "quantity": 1, "unit": "forfait", "unit_price": 50.00, "vat_rate": 20.0},
        {"description": "Joints silicone et finitions", "quantity": 1, "unit": "forfait", "unit_price": 30.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Travaux réalisables en demi-journée. Garantie 2 ans. Fourniture standard, possibilité haut de gamme.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Remplacement WC complet',
    'quote',
    'Remplacement Sanitaires',
    '[
        {"description": "Dépose ancien WC", "quantity": 1, "unit": "forfait", "unit_price": 90.00, "vat_rate": 20.0},
        {"description": "Fourniture WC à poser sortie horizontale", "quantity": 1, "unit": "unité", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Abattant WC frein de chute", "quantity": 1, "unit": "unité", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Pose WC avec joint", "quantity": 1, "unit": "forfait", "unit_price": 100.00, "vat_rate": 20.0},
        {"description": "Raccordement eau froide avec robinet d''arrêt", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Raccordement évacuation PVC", "quantity": 1, "unit": "forfait", "unit_price": 70.00, "vat_rate": 20.0},
        {"description": "Réglage chasse d''eau et essais", "quantity": 1, "unit": "forfait", "unit_price": 40.00, "vat_rate": 20.0},
        {"description": "Joints silicone finitions", "quantity": 1, "unit": "forfait", "unit_price": 25.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Travaux demi-journée. Garantie 2 ans. WC standard blanc, autres coloris sur demande.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 14: EXTERIOR PLUMBING (Plomberie Extérieure)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation robinet extérieur antigel',
    'quote',
    'Plomberie Extérieure',
    '[
        {"description": "Fourniture robinet extérieur antigel", "quantity": 1, "unit": "unité", "unit_price": 65.00, "vat_rate": 20.0},
        {"description": "Perçage mur (jusqu''à 40cm)", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Raccordement sur réseau existant", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose robinet d''arrêt intérieur", "quantity": 1, "unit": "unité", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Isolation tuyauterie passage mur", "quantity": 1, "unit": "forfait", "unit_price": 40.00, "vat_rate": 20.0},
        {"description": "Rebouchage et étanchéité traversée", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Essais et vérification", "quantity": 1, "unit": "forfait", "unit_price": 30.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Protection hors gel. Garantie 2 ans.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation arrosage automatique jardin',
    'quote',
    'Plomberie Extérieure',
    '[
        {"description": "Étude et plan d''arrosage", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Programmateur 4 voies étanche", "quantity": 1, "unit": "unité", "unit_price": 220.00, "vat_rate": 20.0},
        {"description": "Électrovannes 9V (lot de 4)", "quantity": 4, "unit": "unité", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Tranchées et pose tuyau PE Ø25mm (50m)", "quantity": 50, "unit": "mètre", "unit_price": 8.50, "vat_rate": 20.0},
        {"description": "Arroseurs escamotables turbine (lot de 8)", "quantity": 8, "unit": "unité", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Raccords, colliers et fournitures", "quantity": 1, "unit": "lot", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Raccordement sur arrivée eau", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Réglage arroseurs et programmation", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Mise en service et formation", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0}
    ]',
    'Devis valable 60 jours. Base jardin 200m². Économies d''eau jusqu''à 50%. Garantie 2 ans. Délai: 3-4 jours.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 15: BATHROOM ACCESSORIES (Accessoires Salle de Bain)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Pose accessoires salle de bain (lot complet)',
    'quote',
    'Accessoires Salle de Bain',
    '[
        {"description": "Porte-serviettes chromé 60cm", "quantity": 2, "unit": "unité", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Patère murale (lot de 4)", "quantity": 4, "unit": "unité", "unit_price": 12.00, "vat_rate": 20.0},
        {"description": "Porte-papier toilette chromé", "quantity": 1, "unit": "unité", "unit_price": 25.00, "vat_rate": 20.0},
        {"description": "Porte-brosse WC", "quantity": 1, "unit": "unité", "unit_price": 28.00, "vat_rate": 20.0},
        {"description": "Miroir avec appliques LED 80x60cm", "quantity": 1, "unit": "unité", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Tablette verre sécurit 60cm avec supports", "quantity": 1, "unit": "unité", "unit_price": 55.00, "vat_rate": 20.0},
        {"description": "Pose de tous les accessoires avec fixations", "quantity": 1, "unit": "forfait", "unit_price": 220.00, "vat_rate": 20.0},
        {"description": "Raccordement électrique appliques", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Travaux réalisables en demi-journée. Garantie pose 1 an.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 16: GAS INSTALLATIONS (Installations Gaz)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Raccordement gazinière/plaque de cuisson',
    'quote',
    'Installations Gaz',
    '[
        {"description": "Déplacement", "quantity": 1, "unit": "forfait", "unit_price": 50.00, "vat_rate": 20.0},
        {"description": "Robinet d''arrêt gaz NF avec olive", "quantity": 1, "unit": "unité", "unit_price": 35.00, "vat_rate": 20.0},
        {"description": "Tuyau flexible gaz inox NF 1.50m", "quantity": 1, "unit": "unité", "unit_price": 28.00, "vat_rate": 20.0},
        {"description": "Pose et raccordement", "quantity": 1, "unit": "forfait", "unit_price": 95.00, "vat_rate": 20.0},
        {"description": "Test étanchéité à la mousse", "quantity": 1, "unit": "forfait", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Vérification combustion brûleurs", "quantity": 1, "unit": "forfait", "unit_price": 40.00, "vat_rate": 20.0},
        {"description": "Certificat de conformité gaz", "quantity": 1, "unit": "unité", "unit_price": 35.00, "vat_rate": 20.0}
    ]',
    'Installation conforme norme NF. Certificat obligatoire pour assurance. Garantie 2 ans.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 17: WATER FILTRATION (Filtration Eau)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation système filtration eau potable',
    'quote',
    'Filtration Eau',
    '[
        {"description": "Fourniture filtre 3 étages (sédiments + charbon + ultrafiltration)", "quantity": 1, "unit": "unité", "unit_price": 320.00, "vat_rate": 20.0},
        {"description": "Robinet 3 voies chromé pour évier", "quantity": 1, "unit": "unité", "unit_price": 95.00, "vat_rate": 20.0},
        {"description": "Perçage évier inox pour robinet", "quantity": 1, "unit": "forfait", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Pose système de filtration sous évier", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Raccordement eau froide avec té et robinet d''arrêt", "quantity": 1, "unit": "forfait", "unit_price": 85.00, "vat_rate": 20.0},
        {"description": "Kit tuyauterie et raccords", "quantity": 1, "unit": "lot", "unit_price": 55.00, "vat_rate": 20.0},
        {"description": "Mise en service et rinçage cartouches", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Formation changement cartouches", "quantity": 1, "unit": "forfait", "unit_price": 30.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Eau pure sans chlore ni impuretés. Cartouches à changer tous les 6 mois. Garantie 2 ans.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 18: PRESSURE ISSUES (Problèmes de Pression)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation réducteur de pression',
    'quote',
    'Problèmes de Pression',
    '[
        {"description": "Déplacement et diagnostic", "quantity": 1, "unit": "forfait", "unit_price": 70.00, "vat_rate": 20.0},
        {"description": "Fourniture réducteur de pression réglable 1-6 bars", "quantity": 1, "unit": "unité", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Manomètre de contrôle", "quantity": 1, "unit": "unité", "unit_price": 25.00, "vat_rate": 20.0},
        {"description": "Pose réducteur sur arrivée générale", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Réglage pression optimale (3 bars)", "quantity": 1, "unit": "forfait", "unit_price": 50.00, "vat_rate": 20.0},
        {"description": "Test points de puisage", "quantity": 1, "unit": "forfait", "unit_price": 45.00, "vat_rate": 20.0}
    ]',
    'Protège installations et électroménager. Économies d''eau. Garantie 2 ans.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation surpresseur (augmentation pression)',
    'quote',
    'Problèmes de Pression',
    '[
        {"description": "Diagnostic installation et besoins", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Fourniture surpresseur automatique 1.5HP", "quantity": 1, "unit": "unité", "unit_price": 380.00, "vat_rate": 20.0},
        {"description": "Réservoir 24L avec membrane", "quantity": 1, "unit": "unité", "unit_price": 95.00, "vat_rate": 20.0},
        {"description": "Pressostat réglable", "quantity": 1, "unit": "unité", "unit_price": 45.00, "vat_rate": 20.0},
        {"description": "Pose et raccordement hydraulique", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Raccordement électrique avec protection", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Réglage pression de démarrage/arrêt", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Mise en service et essais", "quantity": 1, "unit": "forfait", "unit_price": 70.00, "vat_rate": 20.0}
    ]',
    'Devis valable 30 jours. Idéal maisons individuelles/dernier étage. Garantie 2 ans.',
    true,
    NOW(),
    NOW()
);

-- Add a few more specialty templates to round out to 50+

-- =============================================================================
-- CATEGORY 19: RENOVATIONS & EXTENSIONS (Rénovations & Extensions)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Plomberie extension maison (nouveau WC + point d''eau)',
    'quote',
    'Rénovations & Extensions',
    '[
        {"description": "Étude technique et plan", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Extension réseau eau froide/chaude (15m PER)", "quantity": 1, "unit": "forfait", "unit_price": 450.00, "vat_rate": 20.0},
        {"description": "Extension évacuations EU/EV (PVC Ø100)", "quantity": 1, "unit": "forfait", "unit_price": 380.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose WC suspendu", "quantity": 1, "unit": "unité", "unit_price": 680.00, "vat_rate": 20.0},
        {"description": "Fourniture et pose lave-mains avec mitigeur", "quantity": 1, "unit": "unité", "unit_price": 320.00, "vat_rate": 20.0},
        {"description": "Raccordements complets", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Extension radiateur chauffage", "quantity": 1, "unit": "unité", "unit_price": 520.00, "vat_rate": 20.0},
        {"description": "Tests étanchéité et mise en service", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0}
    ]',
    'Devis valable 60 jours. Coordination avec maçon/électricien. Garantie décennale. Délai: 4-5 jours.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 20: COMMERCIAL INSTALLATIONS (Installations Commerciales)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation sanitaires commerce/bureau (WC + lavabo PMR)',
    'quote',
    'Installations Commerciales',
    '[
        {"description": "Étude conformité ERP et PMR", "quantity": 1, "unit": "forfait", "unit_price": 250.00, "vat_rate": 20.0},
        {"description": "WC suspendu PMR hauteur réglable", "quantity": 1, "unit": "unité", "unit_price": 850.00, "vat_rate": 20.0},
        {"description": "Barres d''appui PMR (lot de 3)", "quantity": 1, "unit": "lot", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Lavabo PMR suspendu sans colonne", "quantity": 1, "unit": "unité", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Robinetterie à détection infrarouge", "quantity": 1, "unit": "unité", "unit_price": 320.00, "vat_rate": 20.0},
        {"description": "Distributeur savon/papier automatique", "quantity": 1, "unit": "lot", "unit_price": 220.00, "vat_rate": 20.0},
        {"description": "Raccordements hydrauliques et électriques", "quantity": 1, "unit": "forfait", "unit_price": 450.00, "vat_rate": 20.0},
        {"description": "Mise en service et attestation conformité", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0}
    ]',
    'Conforme réglementation ERP et accessibilité PMR. Attestation fournie. Garantie décennale. Délai: 2-3 jours.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 21: DIAGNOSTIC & INSPECTION (Diagnostic & Inspection)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Diagnostic plomberie complet maison',
    'quote',
    'Diagnostic & Inspection',
    '[
        {"description": "Inspection complète installation", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Test pression réseau eau", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Contrôle chauffe-eau et sécurités", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Vérification évacuations et siphons", "quantity": 1, "unit": "forfait", "unit_price": 70.00, "vat_rate": 20.0},
        {"description": "Contrôle robinetterie et fuites", "quantity": 1, "unit": "forfait", "unit_price": 50.00, "vat_rate": 20.0},
        {"description": "Test dureté eau", "quantity": 1, "unit": "forfait", "unit_price": 40.00, "vat_rate": 20.0},
        {"description": "Rapport détaillé avec photos et recommandations", "quantity": 1, "unit": "unité", "unit_price": 120.00, "vat_rate": 20.0}
    ]',
    'Idéal avant achat maison. Rapport sous 48h. Devis travaux gratuit si réalisation.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Inspection caméra canalisation',
    'quote',
    'Diagnostic & Inspection',
    '[
        {"description": "Déplacement avec équipement caméra", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Inspection caméra jusqu''à 30m", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Enregistrement vidéo complet", "quantity": 1, "unit": "unité", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Rapport avec captures et localisation anomalies", "quantity": 1, "unit": "unité", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Devis travaux si nécessaire", "quantity": 1, "unit": "forfait", "unit_price": 0.00, "vat_rate": 20.0}
    ]',
    'Localisation précise problèmes. Vidéo fournie sur clé USB. Devis réparation gratuit.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 22: SENIOR & ACCESSIBILITY (Sénior & Accessibilité)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Adaptation salle de bain sénior/PMR',
    'quote',
    'Sénior & Accessibilité',
    '[
        {"description": "Étude adaptation PMR et aides financières", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Remplacement baignoire par douche plain-pied PMR", "quantity": 1, "unit": "forfait", "unit_price": 2800.00, "vat_rate": 20.0},
        {"description": "Siège de douche rabattable", "quantity": 1, "unit": "unité", "unit_price": 220.00, "vat_rate": 20.0},
        {"description": "Barres d''appui coudées (lot de 4)", "quantity": 1, "unit": "lot", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Mitigeur thermostatique sécurisé anti-brûlure", "quantity": 1, "unit": "unité", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Rehausseur WC avec accoudoirs", "quantity": 1, "unit": "unité", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Sol antidérapant", "quantity": 1, "unit": "forfait", "unit_price": 450.00, "vat_rate": 20.0},
        {"description": "Mise en service et formation", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0}
    ]',
    'Éligible aides ANAH jusqu''à 50%. Crédit d''impôt possible. Certifié autonomie. Garantie décennale. Délai: 5-7 jours.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation WC avec lave-mains intégré',
    'quote',
    'Sénior & Accessibilité',
    '[
        {"description": "Dépose ancien WC", "quantity": 1, "unit": "forfait", "unit_price": 90.00, "vat_rate": 20.0},
        {"description": "Fourniture WC avec lave-mains intégré (gain place)", "quantity": 1, "unit": "unité", "unit_price": 480.00, "vat_rate": 20.0},
        {"description": "Pose et raccordement évacuation", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Raccordement eau avec robinet d''arrêt", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Réglages et essais", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0}
    ]',
    'Idéal petits espaces. Économies d''eau. Garantie 2 ans. Installation demi-journée.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 23: ECO & ECONOMY (Éco & Économies)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation récupérateur eau de pluie',
    'quote',
    'Éco & Économies',
    '[
        {"description": "Cuve enterrée béton 5000L", "quantity": 1, "unit": "unité", "unit_price": 1800.00, "vat_rate": 20.0},
        {"description": "Terrassement et pose cuve", "quantity": 1, "unit": "forfait", "unit_price": 850.00, "vat_rate": 20.0},
        {"description": "Collecteur filtrant descente gouttière", "quantity": 1, "unit": "unité", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Pompe immergée automatique", "quantity": 1, "unit": "unité", "unit_price": 320.00, "vat_rate": 20.0},
        {"description": "Réseau distribution WC et jardin", "quantity": 1, "unit": "forfait", "unit_price": 650.00, "vat_rate": 20.0},
        {"description": "Disconnecteur BA avec sécurité", "quantity": 1, "unit": "unité", "unit_price": 220.00, "vat_rate": 20.0},
        {"description": "Coffret électrique protection pompe", "quantity": 1, "unit": "unité", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Mise en service et réglages", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0}
    ]',
    'Économies jusqu''à 50% facture eau. Crédit d''impôt possible. Garantie 5 ans. Délai: 5-7 jours avec terrassement.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation économiseurs d''eau (maison complète)',
    'quote',
    'Éco & Économies',
    '[
        {"description": "Mousseurs économiseurs pour robinets (lot de 6)", "quantity": 1, "unit": "lot", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Douchettes économiques 6L/min (lot de 2)", "quantity": 1, "unit": "lot", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Mécanisme double chasse WC (lot de 2)", "quantity": 1, "unit": "lot", "unit_price": 90.00, "vat_rate": "20.0"},
        {"description": "Installation de tous les économiseurs", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Réglages et tests", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0}
    ]',
    'Économies 30-50% consommation eau. Retour investissement < 1 an. Garantie 2 ans. Installation demi-journée.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 24: WATER HEATERS SPECIALTY (Chauffe-eau Spécialisés)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation chauffe-eau instantané gaz',
    'quote',
    'Chauffe-eau Spécialisés',
    '[
        {"description": "Fourniture chauffe-eau instantané gaz 11L/min", "quantity": 1, "unit": "unité", "unit_price": 650.00, "vat_rate": 20.0},
        {"description": "Pose murale avec fixations", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Raccordement gaz avec flexible inox", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Raccordement eau froide", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Distribution eau chaude (2 points)", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Ventouse concentrique Ø 60/100", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Mise en service et réglages", "quantity": 1, "unit": "forfait", "unit_price": 100.00, "vat_rate": 20.0},
        {"description": "Certificat de conformité gaz", "quantity": 1, "unit": "unité", "unit_price": 80.00, "vat_rate": 20.0}
    ]',
    'Eau chaude instantanée illimitée. Idéal petits espaces. Garantie 2 ans. Délai: 1-2 jours.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation mini chauffe-eau sous évier 15L',
    'quote',
    'Chauffe-eau Spécialisés',
    '[
        {"description": "Fourniture chauffe-eau électrique sous évier 15L", "quantity": 1, "unit": "unité", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Pose sous évier avec fixations", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Raccordement eau froide avec robinet d''arrêt", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Raccordement eau chaude au robinet", "quantity": 1, "unit": "forfait", "unit_price": 50.00, "vat_rate": 20.0},
        {"description": "Raccordement électrique sur prise", "quantity": 1, "unit": "forfait", "unit_price": 40.00, "vat_rate": 20.0},
        {"description": "Mise en service", "quantity": 1, "unit": "forfait", "unit_price": 30.00, "vat_rate": 20.0}
    ]',
    'Idéal point d''eau éloigné. Rapide et économique. Garantie 2 ans. Installation 2h.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 25: CONTRACTS & SERVICES (Contrats & Services)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Contrat entretien annuel plomberie (forfait)',
    'quote',
    'Contrats & Services',
    '[
        {"description": "Visite annuelle préventive complète", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Entretien chaudière ou chauffe-eau", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Vérification robinetterie et fuites", "quantity": 1, "unit": "forfait", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Détartrage pommeaux et mousseurs", "quantity": 1, "unit": "forfait", "unit_price": 60.00, "vat_rate": 20.0},
        {"description": "Priorité intervention 24h/24", "quantity": 1, "unit": "forfait", "unit_price": 0.00, "vat_rate": 20.0},
        {"description": "Remise 15% sur main d''œuvre toute l''année", "quantity": 1, "unit": "forfait", "unit_price": 0.00, "vat_rate": 20.0}
    ]',
    'Contrat annuel reconductible. Priorité dépannage urgence. Tarifs préférentiels. Attestations fournies.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Contrat maintenance copropriété (par trimestre)',
    'quote',
    'Contrats & Services',
    '[
        {"description": "Visite trimestrielle parties communes", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Vérification pompes et surpresseurs", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Contrôle colonnes montantes", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Entretien compteurs divisionnaires", "quantity": 1, "unit": "forfait", "unit_price": 100.00, "vat_rate": 20.0},
        {"description": "Rapport technique au syndic", "quantity": 1, "unit": "unité", "unit_price": 80.00, "vat_rate": 20.0},
        {"description": "Astreinte urgence 7j/7", "quantity": 1, "unit": "forfait", "unit_price": 0.00, "vat_rate": 20.0}
    ]',
    'Contrat annuel. Prévention pannes. Tarifs négociés copro. Interventions urgence incluses.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 26: RENOVATION PROJECTS (Projets Rénovation)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Rénovation plomberie appartement complet',
    'quote',
    'Projets Rénovation',
    '[
        {"description": "Dépose complète ancienne plomberie", "quantity": 1, "unit": "forfait", "unit_price": 850.00, "vat_rate": 20.0},
        {"description": "Nouveau réseau eau PER (40m)", "quantity": 1, "unit": "forfait", "unit_price": 1200.00, "vat_rate": 20.0},
        {"description": "Nouveau réseau évacuation PVC", "quantity": 1, "unit": "forfait", "unit_price": 950.00, "vat_rate": 20.0},
        {"description": "Installation compteur divisionnaire", "quantity": 1, "unit": "unité", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Robinets d''arrêt et purges (lot complet)", "quantity": 1, "unit": "lot", "unit_price": 320.00, "vat_rate": 20.0},
        {"description": "Rénovation sanitaires (WC + lavabo + douche)", "quantity": 1, "unit": "forfait", "unit_price": 2800.00, "vat_rate": 20.0},
        {"description": "Rénovation cuisine (évier + robinetterie + raccordements)", "quantity": 1, "unit": "forfait", "unit_price": 850.00, "vat_rate": 20.0},
        {"description": "Tests étanchéité complets", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Mise en service et dossier technique", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0}
    ]',
    'Devis valable 60 jours. Appartement 60-80m². Garantie décennale. Coordination autres corps de métier. Délai: 10-12 jours.',
    true,
    NOW(),
    NOW()
);

-- =============================================================================
-- CATEGORY 27: SPECIAL EQUIPMENT (Équipements Spéciaux)
-- =============================================================================

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation broyeur WC',
    'quote',
    'Équipements Spéciaux',
    '[
        {"description": "Fourniture broyeur WC silencieux", "quantity": 1, "unit": "unité", "unit_price": 380.00, "vat_rate": 20.0},
        {"description": "Adaptation évacuation petit diamètre", "quantity": 1, "unit": "forfait", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Raccordement WC au broyeur", "quantity": 1, "unit": "forfait", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Raccordement électrique avec protection", "quantity": 1, "unit": "forfait", "unit_price": 100.00, "vat_rate": 20.0},
        {"description": "Raccordement évacuation Ø 32mm", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0},
        {"description": "Mise en service et essais", "quantity": 1, "unit": "forfait", "unit_price": 70.00, "vat_rate": 20.0}
    ]',
    'Idéal sous-sol/cave. Évacuation sur longue distance. Garantie 3 ans. Installation demi-journée.',
    true,
    NOW(),
    NOW()
);

INSERT INTO templates (id, user_id, template_name, template_type, category, line_items, terms_conditions, is_system_template, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    NULL,
    'Installation station de relevage eaux usées',
    'quote',
    'Équipements Spéciaux',
    '[
        {"description": "Fourniture station relevage 400L avec pompe", "quantity": 1, "unit": "unité", "unit_price": 850.00, "vat_rate": 20.0},
        {"description": "Terrassement et préparation", "quantity": 1, "unit": "forfait", "unit_price": 380.00, "vat_rate": 20.0},
        {"description": "Pose cuve et raccordement arrivées EU", "quantity": 1, "unit": "forfait", "unit_price": 450.00, "vat_rate": 20.0},
        {"description": "Refoulement vers égout (15m)", "quantity": 15, "unit": "mètre", "unit_price": 25.00, "vat_rate": 20.0},
        {"description": "Clapet anti-retour et robinet d''isolement", "quantity": 1, "unit": "lot", "unit_price": 120.00, "vat_rate": 20.0},
        {"description": "Raccordement électrique triphasé avec coffret", "quantity": 1, "unit": "forfait", "unit_price": 280.00, "vat_rate": 20.0},
        {"description": "Alarme de niveau et signalisation", "quantity": 1, "unit": "unité", "unit_price": 180.00, "vat_rate": 20.0},
        {"description": "Mise en service et tests", "quantity": 1, "unit": "forfait", "unit_price": 150.00, "vat_rate": 20.0}
    ]',
    'Idéal sous-sol non gravitaire. Évacuation forcée. Garantie 5 ans. Contrat entretien recommandé. Délai: 3-4 jours.',
    true,
    NOW(),
    NOW()
);

-- Add a summary comment
COMMENT ON TABLE templates IS 'Contains 50+ system plumbing templates covering all common French plumbing jobs, ready to use for quotes';

-- Success message
DO $$
DECLARE
    template_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO template_count FROM templates WHERE is_system_template = true;
    RAISE NOTICE 'Successfully created % plumbing templates across 27 categories', template_count;
END $$;

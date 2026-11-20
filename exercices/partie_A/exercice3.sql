-- Créez une vue matérialisée mv_synthese_segments calculant le nombre de commandes et le CA total par segment client. 
-- Insérez une nouvelle commande test, constatez que la vue est marquée obsolète (stale), puis rafraîchissez-la et vérifiez la mise à jour.

CREATE MATERIALIZED VIEW mv_synthese_segments AS
SELECT 
    segment,
    COUNT(commandes.id) AS nb_commandes,
    SUM(commandes.montant_total) AS ca_total
FROM clients
JOIN commandes ON commandes.client_id = clients.id
GROUP BY clients.segment;

-- Consultation initiale :
SELECT * FROM mv_synthese_segments;

-- Insertion d'une commande test :
INSERT INTO commandes (client_id, date_commande, montant_total, statut)
VALUES (1, '2026-06-01', 500.00, 'LIVREE');

-- Constat : la vue n'a pas bougé, elle est obsolète (stale) :
SELECT * FROM mv_synthese_segments;

-- Rafraîchissement de la vue :
REFRESH MATERIALIZED VIEW mv_synthese_segments;

-- Vérification après mise à jour :
SELECT * FROM mv_synthese_segments;

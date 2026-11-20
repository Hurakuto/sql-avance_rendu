-- Exécutez avec EXPLAIN ANALYZE une requête listant les 10 plus grosses commandes LIVREE passées en 2026 en utilisant YEAR(date_commande) = 2026. 
-- Identifiez les 2 défauts du plan obtenu.

EXPLAIN ANALYZE
SELECT id, client_id, date_commande, montant_total FROM commandes 
WHERE statut = 'LIVREE' AND YEAR(date_commande) = 2026
ORDER BY montant_total DESC
LIMIT 10;

-- Défaut 1 : Non SARGable YEAR(date_commande) rend l'index aveugle et force un scan complet de la table (Table scan / type ALL). Il faut utiliser (date_commande >= '2026-01-01' AND date_commande < '2027-01-01').
-- Défaut 2 : Tri bloquant (Sort / filesort). L'absence d'index ordonné sur montant_total oblige le moteur à charger et trier toutes les lignes en mémoire pour le ORDER BY montant_total DESC.
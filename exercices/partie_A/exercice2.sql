-- Créez un index pertinent sur commandes, activez le partitionnement RANGE, et réécrivez la requête de façon SARGable (sans SELECT *). 
-- Comparez le coût total avant/après et expliquez l'effet du Partition Pruning.

-- la clé bloquait le partionnement
ALTER TABLE commandes DROP FOREIGN KEY fk_commandes_client;

-- partionnement RANGE
ALTER TABLE commandes 
PARTITION BY RANGE COLUMNS (date_commande) (
    PARTITION p_2025 VALUES LESS THAN ('2026-01-01 00:00:00'),
    PARTITION p_2026 VALUES LESS THAN ('2027-01-01 00:00:00'),
    PARTITION p_2027 VALUES LESS THAN ('2028-01-01 00:00:00'),
    PARTITION p_max  VALUES LESS THAN MAXVALUE
);

CREATE INDEX idx_commandes_statut_date_montant ON commandes(statut, date_commande, montant_total DESC, client_id);

EXPLAIN ANALYZE
SELECT id, client_id, date_commande, montant_total 
FROM commandes 
WHERE statut = 'LIVREE' AND date_commande >= '2026-01-01' AND date_commande <  '2027-01-01'
ORDER BY montant_total DESC
LIMIT 10;

-- Comparaison avec l'exercice 1 :
-- Coût et temps : Le coût passe de 3.35 à 1.48 et le temps passe de 0.084ms à 0.042ms (temps et coût divisés par deux).
-- Partition Pruning : Le moteur n'ouvre que la partition p_2026 et ignore toutes les autres partitions (2025, 2027, etc.).
-- Index : On passe d'un simple index lookup avec filtre non SARGable à un Covering Index Range Scan complet.

-- Exercice 1 :
-- -> Limit: 10 row(s)  (cost=3.35 rows=10) (actual time=0.0829..0.084 rows=6 loops=1)
--     -> Sort: commandes.montant_total DESC, limit input to 10 row(s) per chunk  (cost=3.35 rows=26) (actual time=0.0819..0.0824 rows=6 loops=1)
--         -> Filter: (year(commandes.date_commande) = 2026)  (cost=3.35 rows=26) (actual time=0.0598..0.0652 rows=6 loops=1)
--             -> Index lookup on commandes using idx_clients_commandes_livrees (statut='LIVREE')  (cost=3.35 rows=26) (actual time=0.0542..0.0589 rows=26 loops=1)

-- Exercice 2 :
-- -> Limit: 10 row(s)  (cost=1.48 rows=6) (actual time=0.0409..0.042 rows=6 loops=1)
--     -> Sort: commandes.montant_total DESC, limit input to 10 row(s) per chunk  (cost=1.48 rows=6) (actual time=0.0403..0.0408 rows=6 loops=1)
--         -> Filter: ((commandes.statut = 'LIVREE') and (commandes.date_commande >= TIMESTAMP'2026-01-01 00:00:00') and (commandes.date_commande < TIMESTAMP'2027-01-01 00:00:00'))  (cost=1.48 rows=6) (actual time=0.0212..0.026 rows=6 loops=1)
--             -> Covering index range scan on commandes using idx_commandes_statut_date_montant over (statut = 'LIVREE' AND '2026-01-01 00:00:00' <= date_commande < '2027-01-01 00:00:00')  (cost=1.48 rows=6) (actual time=0.0181..0.0211 rows=6 loops=1)

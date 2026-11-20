-- Une startup lance une application de covoiturage temps réel nécessitant : (a) le suivi GPS toutes les 3 secondes de 30 000 véhicules, (b) la facturation bancaire des trajets, (c) la suggestion d'itinéraires/amis communs à 3 degrés de séparation. 
-- Proposez une architecture polyglotte justifiée via CAP/PACELC et les 4 critères de choix.

-- 1. Architecture polyglotte proposée :
-- (a) Suivi GPS temps réel (10 000 écritures/sec) : Base NoSQL Clé-Valeur / Séries Temporelles (ex: Redis ou Cassandra).
-- (b) Facturation bancaire des trajets : Base relationnelle SQL (ex: PostgreSQL ou MySQL InnoDB).
-- (c) Réseau social et amis communs (3 degrés) : Base NoSQL orientée Graphe (ex: Neo4j).

-- 2. Justification CAP / PACELC :
-- (a) GPS -> Profil AP (PACELC : PA/EL) : Privilégie la disponibilité et la faible latence en écriture massive. Perdre temporairement une coordonnée GPS n'est pas critique, mais le flux ne doit jamais bloquer.
-- (b) Facturation -> Profil CP (PACELC : PC/EC) : Cohérence stricte et transactions ACID obligatoires pour éviter toute double facturation ou incohérence monétaire.
-- (c) Réseau social -> Traversée de relations : Les jointures récursives SQL deviennent exponentielles à 3 degrés, alors qu'une base graphe traverse les pointeurs en O(1) par saut.

-- 3. Les 4 critères de choix :
-- Modèle de données : Clé-valeur/Time-Series pour les flux GPS, tabulaire relationnel normalisé pour la comptabilité, noeuds/arêtes pour le graphe d'amis.
-- Garanties transactionnelles : ACID strict pour la facturation bancaire, BASE / consistance éventuelle pour les positions GPS.
-- Volume et vélocité : Très haute vélocité en écriture (10k ops/sec) pour le GPS (scale-out horizontal), volume modéré mais intègre pour les transactions financières.
-- Complexité des requêtes : Requêtes de chemins et d'amis d'amis simples et rapides en graphe (Cypher), calculs comptables précis en SQL.

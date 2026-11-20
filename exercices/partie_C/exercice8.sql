-- Dans le simulateur ACID, reproduisez un Non-Repeatable Read sous READ COMMITTED, puis montrez comment REPEATABLE READ le résout. 
-- Expliquez le rôle du WAL lors d'une coupure serveur en plein virement.

-- Résolution sous REPEATABLE READ :
-- Lorsque Session A relit après le COMMIT de Session B, elle continue de lire son snapshot initial à 15 000 € de façon cohérente : l'anomalie est éliminée.

-- Rôle du WAL lors d'une coupure serveur en plein virement :
-- Le WAL (Write-Ahead Log) enregistre séquentiellement chaque opération sur disque avant d'écrire en base.
-- Lors d'une panne en plein virement (transaction non validée), le moteur utilise le journal au redémarrage pour annuler la transaction incomplète (UNDO/ROLLBACK) et rétablir le solde initial.
-- Si le COMMIT avait été consigné dans le WAL avant le crash, le moteur rejouerait l'opération (REDO) pour garantir la Durabilité.

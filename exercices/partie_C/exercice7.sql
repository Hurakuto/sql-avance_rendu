-- Expliquez le piège de la requête SELECT id, nom FROM employes WHERE id NOT IN (SELECT manager_id FROM employes); et proposez une correction fiable face aux valeurs NULL.

-- Un id NOT IN renvoie toujours UNKNOWN, il faut utiliser NOT EXISTS.
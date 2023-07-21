-- Créé par Mizukuli.
Config = {
    AllowedJobs = {
        'police', -- Possibilité d'ajouter d'autres jobs pour les alertes.
        'bcso'
    },
    GunshotAlert = true,
    ShowCopsMisbehave = true,
    AlertBlipDuration = 30000, -- 30 secondes (temps du blips sur la carte).
    GunshotAlertCooldown = 50000, -- 50 secondes (avant la prochaine alerte de tir par joueur).
    Version = true, -- MAJ Github.
    Framework = "1", -- "1" or "2", en fonction de votre configuration "2" = esx:getSharedObject
    AlertOnCarJack = true, -- Activer ou désactiver l'alerte pour les véhicules avec PNJ. [Ne pas activer "AlertOnCarEntered" si celui-ci est déjà activé.]
    MenuType = 'none', -- Utilisez 'lib' pour le menu lib, 'esx' pour le menu ESX, ou 'none' pour ne pas utiliser de menu.
    AlertOnCarEntered = false, --  Activer ou désactiver l'alerte pour tout les véhicules. [Ne pas activer "AlertOnCarJack" si celui-ci est déjà activé.]
    CustomPlates = {
        "ADMINCAR" -- Mettez la plaque du véhicule en '/car' pour éviter la détection à chaque fois que vous donnez un véhicule à un joueur.
    }
}
-- Créé par Mizukuli.

# Alerts-Police
Police-Alerts 0.00ms

# Vous n'avez aucun droit de vous approprier ce script ni de le vendre. 
# Vous n'êtes pas autorisé à modifier le référentiel et à le republier ;
# Vous pouvez uniquement le forker. Ce script a été créé par Mizukuli#2227.



# installation Son

1: Ajoutez les sons dans votre interact-sound

2: Ajoutez dans le fxmanifest de interact-sound

```lua
files {
    'client/html/sounds/dispatch.ogg',
    'client/html/sounds/panicbutton.ogg',
    'client/html/sounds/bipbip.ogg'
}

```

(Assurez-vous de toujours inclure le dossier "sounds" dans le script "police_alerts")



# installation de notification pour un script de braquage.

1: Ajoutez la logique pour déclencher l'événement de braquage côté serveur dans les scripts de braquage. Vous devez le faire dans chaque script de braquage que vous souhaitez ajouter au système d'alerte :

```lua
-- dans chaque script de braquage coté server

local playerCoords = GetEntityCoords(PlayerPedId())

TriggerServerEvent('police_alerts:sendRobberyAlert', playerCoords)
    
```


(EXEMLE CI-DESSOUS) ;

```lua
--RegisterServerEvent('loffe_robbery:rob')
--AddEventHandler('loffe_robbery:rob', function(store)
--    local src = source
    local playerCoords = GetEntityCoords(GetPlayerPed(src)) -- Obtenez les coordonnées du joueur
--    Config.Shops[store].robbed = true
--    Le reste du code
 --   ...

    -- Ajoutez cette ligne pour envoyer les coordonnées du joueur au moment où le braquage commence
    TriggerEvent('police_alerts:sendRobberyAlert', playerCoords)

    -- Le reste du code
--    ...
--end)
```



# installation alerts véhicles sous mysql-async.

1: code côté serveur :

Vous devez remplacez la requête oxMySQL

```lua
    if xPlayer then
      exports.oxmysql:fetch('SELECT owner FROM owned_vehicles WHERE plate = ?', {plate}, function(result)
        if result[1] and result[1].owner then
          cb(result[1].owner == xPlayer.identifier)
        else
          cb(false)
        end
      end)
    else
      cb(false)
    end
```

Par ce code ;

```lua
    if xPlayer then
        MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate
        }, function(result)
            if result[1] and result[1].owner then
                cb(result[1].owner == xPlayer.identifier)
            else
                cb(false)
            end
        end)
    else
        cb(false)
    end
```

N'oubliez pas d'ajouter la référence MySQL en haut de votre script ;

```lua
local MySQL = require('mysql-async')
```



# installation Defcon dans le Menu Radial.

1: Ajouter la fonction handleDistressOption :

Ouvrez le fichier contenant le script de votre menu radial et ajoutez la fonction handleDistressOption au début du fichier ou dans une section où vous définissez les fonctions globales.

```lua
function handleDistressOption(option)
    if option == "petit" or option == "moyen" or option == "grand" then
        ExecuteCommand("distress " .. option)
    else
        print("Option de détresse non valide")
    end
end
```

2: Ajouter les options de détresse dans le menu radial :

```lua
    {
        id = "police",
        displayName = "Actions Defcon",
        icon = "#police",
        enableMenu =function()
            local Data = ESX.GetPlayerData()
            return (not isDead and Data.job ~= nil and Data.job.name == "police")
        end,
        subMenus = {"police:defcona", "police:defconb",  "police:defconc"}
    },
```

```lua
    ['police:defcona'] = {
        title = "Petit Defcon",
        icon = "#police",
        functionName = "menu:defcona",
    },
    
    ['police:defconb'] = {
        title = "Moyen Defcon",
        icon = "#police",
        functionName = "menu:defconb",
    },
    
    ['police:defconc'] = {
        title = "Grand Defcon",
        icon = "#police",
        functionName = "menu:defconc",
    },
```

3: Ajoutez les événements personnalisés pour les options de détresse :

```lua
RegisterNetEvent("menu:defcona")
AddEventHandler("menu:defcona", function()
    handleDistressOption("petit")
end)

RegisterNetEvent("menu:defconb")
AddEventHandler("menu:defconb", function()
    handleDistressOption("moyen")
end)

RegisterNetEvent("menu:defconc")
AddEventHandler("menu:defconc", function()
    handleDistressOption("grand")
end)
```


# Des mises à jour supplémentaires suivront. N'hésitez pas à me faire part de vos problèmes concernant le script.

# Créé par Mizukuli#2227


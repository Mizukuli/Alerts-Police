ESX = nil
local ConfigLoaded = false
local Config = {}
local gunshotBlipData = {}
local robberyBlipData = {}
local ALERT_BLIP_DURATION = 30000

local function requestConfig()
    TriggerServerEvent('police_alerts:requestConfig')
end

RegisterNetEvent('police_alerts:getConfig')
AddEventHandler('police_alerts:getConfig', function(config)
    Config = config
    ConfigLoaded = true
    ALERT_BLIP_DURATION = Config.AlertBlipDuration or ALERT_BLIP_DURATION
end)

requestConfig()

Citizen.CreateThread(function()
    while not ESX do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    while not ConfigLoaded or not ESX do
        requestConfig()
        Citizen.Wait(5000)
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    requestConfig()
end)

function isPlayerPolice()
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.job then
        for _, allowedJob in ipairs(Config.AllowedJobs) do
            if playerData.job.name == allowedJob then
                return true
            end
        end
    end
    return false
end

local function sendNotification(message, messageType, messageTimeout)
    messageType = messageType or "inform"
    messageTimeout = messageTimeout or 5000
    local notifTitle = "Alerte"
    if messageType == "inform" then
        notifTitle = "Information"
    end
    ESX.ShowNotification(message)
end

local function playSound(soundFile)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", soundFile, 0.25)
end

local function playRobberyNotificationSound()
    playSound("bipbip")
end

local function playUrgencySound(urgency)
    local soundFile = "bipbip"
    if urgency == "petit" then
        soundFile = "dispatch"
    elseif urgency == "moyen" then
        soundFile = "dispatch"
    elseif urgency == "grand" then
        soundFile = "panicbutton"
    end
    playSound(soundFile)
end

local lastGunshotTimestamps = {}

local function alertPoliceOnGunshot(weaponHash)
    local playerPed = PlayerPedId()
    local playerId = GetPlayerServerId(PlayerId())
    local currentTimestamp = GetGameTimer()

    if lastGunshotTimestamps[playerId] and (currentTimestamp - lastGunshotTimestamps[playerId] < Config.GunshotAlertCooldown) then
        return
    end

    lastGunshotTimestamps[playerId] = currentTimestamp

    local coords = GetEntityCoords(playerPed)
    local weapon = ESX.GetWeaponFromHash(weaponHash)
    if weapon and weapon.label then
        local weaponLabel = weapon.label
        TriggerServerEvent('police_alerts:sendGunshotAlert', weaponLabel, coords)
    else
--        print("Erreur : Nom d'arme invalide. Hash d'arme : " .. tostring(weaponHash))
    end
end


Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local weaponHash = GetSelectedPedWeapon(playerPed)

        if IsPedShooting(playerPed) and not IsPedCurrentWeaponSilenced(playerPed) and Config.GunshotAlert then
            if weaponHash and weaponHash ~= -1 then
                alertPoliceOnGunshot(weaponHash)
            end
        end

        Citizen.Wait(100)
    end
end)

RegisterCommand('distress', function(source, args, rawCommand)
    if not ConfigLoaded then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Erreur", "La configuration n'est pas encore chargée. Réessayez dans quelques instants."}
        })
        return
    end

    local playerData = ESX.GetPlayerData()
    if isPlayerPolice(playerData) then
        if args[1] and (args[1] == 'petit' or args[1] == 'moyen' or args[1] == 'grand') then
            local urgency = args[1]
            local coords = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('police_alerts:sendDistress', urgency, coords)
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Erreur", "Utilisation : /distress petit|moyen|grand"}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Erreur", "Vous n'êtes pas autorisé à utiliser cette commande."}
        })
    end
end, false)

RegisterNetEvent('police_alerts:receiveDistress')
AddEventHandler('police_alerts:receiveDistress', function(sender, job, grade, urgency, location)
    local playerData = ESX.GetPlayerData()
    if not isPlayerPolice(playerData) or not sender or not job or not grade or not urgency or not location then
        return
    end

    local distressBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(distressBlip, 161)
    SetBlipScale(distressBlip, 2.0)

    if urgency == 'petit' then
        SetBlipColour(distressBlip, 2) 
    elseif urgency == 'moyen' then
        SetBlipColour(distressBlip, 17)
    elseif urgency == 'grand' then
        SetBlipColour(distressBlip, 1)
    end

    PulseBlip(distressBlip)

    local message = string.format("~r~Appel de détresse reçu de ~s~%s %s (Grade %s) : ~r~Urgence~s~ %s", sender, job, grade, urgency)
    sendNotification(message, "alert")

    playUrgencySound(urgency)

    Citizen.SetTimeout(ALERT_BLIP_DURATION, function()
        RemoveBlip(distressBlip)
    end)
end)

RegisterNetEvent('police_alerts:receiveGunshotAlert')
AddEventHandler('police_alerts:receiveGunshotAlert', function(weaponName, location)
--    print("Client a reçu l'alerte de coup de feu")
    local playerData = ESX.GetPlayerData()
    if not isPlayerPolice(playerData) or not weaponName or not location then
        return
    end

    local gunshotBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(gunshotBlip, 161)
    SetBlipScale(gunshotBlip, 2.0)
    SetBlipColour(gunshotBlip, 54)
    PulseBlip(gunshotBlip)

    table.insert(gunshotBlipData, {blip = gunshotBlip})

    local message = string.format("~r~Coup de feu détecté~s~ : %s", weaponName)
    sendNotification(message, "alert")

    Citizen.SetTimeout(ALERT_BLIP_DURATION, function()
        for i, data in ipairs(gunshotBlipData) do
            if data.blip == gunshotBlip then
                RemoveBlip(gunshotBlip)
                table.remove(gunshotBlipData, i)
                break
            end
        end
    end)
end)

RegisterNetEvent('police_alerts:receiveRobberyAlert')
AddEventHandler('police_alerts:receiveRobberyAlert', function(alertMessage, location)
    if not isPlayerPolice() or not alertMessage or not location then
        return
    end

    local robberyBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(robberyBlip, 161)
    SetBlipScale(robberyBlip, 2.0)
    SetBlipColour(robberyBlip, 54)
    PulseBlip(robberyBlip)

    table.insert(robberyBlipData, {blip = robberyBlip})

    sendNotification(alertMessage, "alert")
    playRobberyNotificationSound()

    Citizen.SetTimeout(ALERT_BLIP_DURATION, function()
        for i, data in ipairs(robberyBlipData) do
            if data.blip == robberyBlip then
                RemoveBlip(robberyBlip)
                table.remove(robberyBlipData, i)
                break
            end
        end
    end)
end)


function GetModelNameFromHash(modelHash)
    if modelHash == nil or type(modelHash) ~= "number" then
        return "CARNOTFOUND"
    end

    local modelName

    if IsModelInCdimage(modelHash) then
        modelName = GetLabelText(GetDisplayNameFromVehicleModel(modelHash))

        if modelName == "NULL" or modelName == "" then
            modelName = GetDisplayNameFromVehicleModel(modelHash)
        end

        if modelName == "NULL" or modelName == "" then
            modelName = "CARNOTFOUND"
        end
    else
        modelName = "CARNOTFOUND"
    end

    return modelName
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isPlayerWhitelisted = isPlayerPolice()

        if (IsPedTryingToEnterALockedVehicle(playerPed) or IsPedJacking(playerPed)) then
            local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

            if vehicle and ((isPlayerWhitelisted and Config.ShowCopsMisbehave) or not isPlayerWhitelisted) then
                local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

                ESX.TriggerServerCallback('police_alerts:isVehicleOwner', function(owner)
                    if not owner then
                        local modelHash = GetEntityModel(vehicle)
                        local vehicleName = GetModelNameFromHash(modelHash)
                        local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z))

--                        print("modelHash : " .. modelHash)
--                        print("vehicleName : " .. vehicleName)
                        
                        DecorSetInt(playerPed, 'isOutlaw', 2)
                        
                        TriggerServerEvent('police_alerts:carJackInProgress', {
                            x = ESX.Math.Round(playerCoords.x, 1),
                            y = ESX.Math.Round(playerCoords.y, 1),
                            z = ESX.Math.Round(playerCoords.z, 1)
                        }, streetName, vehicleName)
                    end
                end, plate)
            end
        end
    end
end)

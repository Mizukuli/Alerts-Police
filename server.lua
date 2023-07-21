-- Créé par Mizukuli.
if Config.Framework == "1" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == "2" then
    ESX = nil
    CreateThread(function()
        while ESX == nil do
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
            Wait(100)
        end
    end)
end

ESX.RegisterServerCallback('police_alerts:isVehicleOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
  
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
end)

RegisterServerEvent('police_alerts:sendDistress')
AddEventHandler('police_alerts:sendDistress', function(urgency, coords)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        local playerName = xPlayer.getName()
        local jobName = xPlayer.job.name
        local jobGrade = xPlayer.job.grade_label
        TriggerClientEvent('police_alerts:receiveDistress', -1, playerName, jobName, jobGrade, urgency, coords)
    end
end)

RegisterServerEvent('police_alerts:sendGunshotAlert')
AddEventHandler('police_alerts:sendGunshotAlert', function(weaponName, coords)
    TriggerClientEvent('police_alerts:receiveGunshotAlert', -1, weaponName, coords)
end)

RegisterServerEvent('police_alerts:carJackInProgress')
AddEventHandler('police_alerts:carJackInProgress', function(targetCoords, streetName, vehicleName)
--    print("Debug: Server received vehicleName =", vehicleName)
    local src = source
    local message = string.format('~r~Vol de voiture en cours à ~s~ %s, véhicule : %s.', streetName, vehicleName)
    TriggerClientEvent('police_alerts:receiveRobberyAlert', -1, message, targetCoords)
end)

RegisterServerEvent('police_alerts:carEntered')
AddEventHandler('police_alerts:carEntered', function(targetCoords, streetName, vehicleName)
    local src = source
    local message = string.format('~r~ Une personne non identifiée est entrée dans un véhicule volé ~s~ %s ~r~à ~s~%s', vehicleName, streetName)

    TriggerClientEvent('police_alerts:receiveRobberyAlert', -1, message, targetCoords)
end)

RegisterServerEvent('police_alerts:sendRobberyAlert')
AddEventHandler('police_alerts:sendRobberyAlert', function(coords)
    local src = source
    local message = "~r~Braquage en cours, vérifiez votre GPS pour la position."
    TriggerClientEvent('police_alerts:receiveRobberyAlert', -1, message, coords)
end)

RegisterServerEvent('police_alerts:requestConfig')
AddEventHandler('police_alerts:requestConfig', function()
    local src = source
    TriggerClientEvent('police_alerts:getConfig', src, Config)
end)

if Config.Version then
    local function GitHubUpdate()
        PerformHttpRequest('https://raw.githubusercontent.com/Mizukuli/Alerts-Police/main/fxmanifest.lua',
            function(error, result, headers)
                local actual = GetResourceMetadata(GetCurrentResourceName(), 'version')

                if not result then print("^6MIZU ALERT^7 - version couldn't be checked") end

                local version = string.sub(result, string.find(result, "%d.%d.%d"))

                if tonumber((version:gsub("%D+", ""))) > tonumber((actual:gsub("%D+", ""))) then
                    print('^6MIZU ALERT^7 - The version ^2' ..
                        version ..
                        '^0 is available, you are still using version ^1' ..
                        actual .. ', ^0Download the new version at: https://github.com/Mizukuli/Alerts-Police')
                else
                    print('^6MIZU ALERT^7 - You are using the latest version of the script.')
                end
            end)
    end
    GitHubUpdate()
end

-- Créé par Mizukuli.

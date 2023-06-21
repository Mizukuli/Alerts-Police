ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

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
    local src = source
    local message = string.format('~r~Vol de voiture en cours à~s~ %s.', streetName)
    TriggerClientEvent('police_alerts:receiveRobberyAlert', -1, message, targetCoords)
end)

RegisterServerEvent('police_alerts:sendGunshotAlert')
AddEventHandler('police_alerts:sendGunshotAlert', function(weaponName, coords)
    TriggerClientEvent('police_alerts:receiveGunshotAlert', -1, weaponName, coords)
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
    local config = {
        AllowedJobs = {
            'police',
            'bcso'
        },
        GunshotAlert = true,
        ShowCopsMisbehave = true,
        AlertBlipDuration = 30000
    }
    TriggerClientEvent('police_alerts:getConfig', src, config)
end)
local QBCore = exports['qb-core']:GetCoreObject()

local whitelistedLicenses = {
    "license:xxxx", -- license
}

RegisterServerEvent('eventtester:logExecution')
AddEventHandler('eventtester:logExecution', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    
    if not player then return end
    
    local isAllowed = false
    for _, allowedLicense in ipairs(whitelistedLicenses) do
        if player.PlayerData.license == allowedLicense then
            isAllowed = true
            break
        end
    end
    
    if not isAllowed then
        print(string.format('^1[Event Tester] Unauthorized attempt by %s (%s)^0', 
            player.PlayerData.name, 
            player.PlayerData.license
        ))
        DropPlayer(src, "Unauthorized event tester usage")
        return
    end
    
    print(string.format('^3[Event Tester] %s (ID: %s) executed:^0', 
        player.PlayerData.name, 
        src
    ))
    print('^3Code: ^0' .. data.code)
    print('^3Success: ^0' .. tostring(data.success))
    if not data.success then
        print('^3Error: ^0' .. tostring(data.message))
    end
    print('^3----------------------------------^0')
end)

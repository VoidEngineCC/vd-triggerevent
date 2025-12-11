local VDCore = exports['vd-core']:GetCoreObject()

-- Your whitelisted license(s) - MUST MATCH CLIENT
local whitelistedLicenses = {
    "license:b1ecf5348bd4d5b3abd09e0272a97059d93e9c8d", -- REPLACE THIS WITH YOUR LICENSE
}

-- Log executions
RegisterServerEvent('eventtester:logExecution')
AddEventHandler('eventtester:logExecution', function(data)
    local src = source
    local player = VDCore.Functions.GetPlayer(src)
    
    if not player then return end
    
    -- Check license
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
    
    -- Log the execution
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

-- Command to get license
VDCore.Commands.Add('getlicense', 'Get your license ID', {}, false, function(source)
    local src = source
    local player = VDCore.Functions.GetPlayer(src)
    if player then
        TriggerClientEvent('VDCore:Notify', src, 'Your license: ' .. player.PlayerData.license, 'success')
        print('^3[License] ' .. player.PlayerData.name .. ': ' .. player.PlayerData.license .. '^0')
    end
end, 'admin')

-- Debug command to test server side
VDCore.Commands.Add('testevent', 'Test event from server', {}, false, function(source)
    local src = source
    local player = VDCore.Functions.GetPlayer(src)
    
    if player then
        print('^2[Test] Player ' .. player.PlayerData.name .. ' executed test event^0')
        TriggerClientEvent('VDCore:Notify', src, 'Test event executed from server', 'success')
    end
end, 'admin')
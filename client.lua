local QBCore = exports['qb-core']:GetCoreObject()
local isAuthorized = false
local isUIOpen = false


local whitelistedLicenses = {
    "license:xxxx", -- licensehere
}

function CheckLicense()
    local PlayerData = QBCore.Functions.GetPlayerData()
    
    if PlayerData and PlayerData.license then
        for _, allowedLicense in ipairs(whitelistedLicenses) do
            if PlayerData.license == allowedLicense then
                return true
            end
        end
    end
    
    return false
end


function ExecuteEventCode(code)
    if not code or code == '' then
        return false, "No code provided"
    end
    

    local func, err = load("return function() " .. code .. " end", "EventTester", "t")
    
    if not func then
        func, err = load("return (function() " .. code .. " end)()", "EventTester", "t")
    end
    
    if not func then
        func, err = load(code, "EventTester", "t")
    end
    
    if func then
        local success, result = pcall(func)
        if success then
            return true, "Event executed successfully"
        else
            return false, "Execution error: " .. tostring(result)
        end
    else
        return false, "Compile error: " .. tostring(err)
    end
end

function ToggleEventTester()
    isAuthorized = CheckLicense()
    if not isAuthorized then
        QBCore.Functions.Notify('You are not authorized to use this tool.', 'error')
        return
    end
    
    if isUIOpen then
        CloseEventTester()
    else
        OpenEventTester()
    end
end

function OpenEventTester()
    isUIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({action = 'show'})
end

function CloseEventTester()
    isUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'hide'})
end

RegisterCommand('eventtester', function()
    ToggleEventTester()
end, false)

RegisterNUICallback('close', function(_, cb)
    CloseEventTester()
    cb('ok')
end)

RegisterNUICallback('executeEvent', function(data, cb)
    local code = data.code
    
    if not code or code == '' then
        SendNUIMessage({
            action = 'notify',
            message = 'Please enter event code',
            type = 'error'
        })
        cb('ok')
        return
    end
    
    print('^3[Event Tester] Executing:^0 ' .. code)
    
    local success, errorMsg = pcall(function()
        local func1 = load("return (function() " .. code .. " end)()")
        if func1 then
            func1()
            return
        end
        
        local func2 = load(code)
        if func2 then
            func2()
        else
            error("Failed to compile code")
        end
    end)
    
    if success then
        SendNUIMessage({
            action = 'notify',
            message = 'Event executed successfully',
            type = 'success'
        })
    else
        SendNUIMessage({
            action = 'notify',
            message = 'Error: ' .. tostring(errorMsg),
            type = 'error'
        })
    end
    
    TriggerServerEvent('eventtester:logExecution', {
        code = code,
        success = success,
        message = errorMsg or "Success",
        source = GetPlayerServerId(PlayerId())
    })
    
    cb('ok')
end)

RegisterNUICallback('getExamples', function(_, cb)
    local examples = {
        "TriggerServerEvent('QBCore:Server:SetMetaData', GetPlayerServerId(PlayerId()), 'hunger', 100)",
        "TriggerEvent('hospital:client:Revive')",
        "TriggerServerEvent('QBCore:Server:AddMoney', 'cash', 1000000)",
        "TriggerEvent('qb-clothing:client:openOutfitMenu')",
        "TriggerServerEvent('txAdmin:menu:tpToWaypoint')",
        "TriggerServerEvent('qb-admin:server:ban', 1, 'Test Ban')",
        "TriggerServerEvent('qb-admin:server:kick', 1, 'Test Kick')",
        "print('Player data:', exports['qb-core']:GetPlayerData())",
        "print('Hello from Event Tester')",
        "TriggerEvent('chat:addMessage', {args = {'[TEST]', 'Test Message'}, color = {255, 0, 0}})",
        "SetEntityCoords(PlayerPedId(), 0.0, 0.0, 70.0)",
        "QBCore.Functions.Notify('Test Notification', 'success')",
        "TriggerServerEvent('qb-phone:server:sendNewMail', 'Test Subject', 'Test Message', {})",
        "TriggerEvent('QBCore:Client:OnPlayerLoaded')",
        "print('Player ID:', GetPlayerServerId(PlayerId()))"
    }
    
    SendNUIMessage({
        action = 'setExamples',
        examples = examples
    })
    
    cb('ok')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        CloseEventTester()
    end
end)

local VDCore = exports['vd-core']:GetCoreObject()
local isAuthorized = false
local isUIOpen = false

-- Your whitelisted license(s) - ADD YOUR LICENSE HERE
local whitelistedLicenses = {
    "license:b1ecf5348bd4d5b3abd09e0272a97059d93e9c8d", -- REPLACE THIS WITH YOUR LICENSE
}

-- Check license
function CheckLicense()
    local PlayerData = VDCore.Functions.GetPlayerData()
    
    if PlayerData and PlayerData.license then
        for _, allowedLicense in ipairs(whitelistedLicenses) do
            if PlayerData.license == allowedLicense then
                return true
            end
        end
    end
    
    return false
end

-- Safe execution with proper error handling
function ExecuteEventCode(code)
    if not code or code == '' then
        return false, "No code provided"
    end
    
    -- Try to execute the code
    local func, err = load("return function() " .. code .. " end", "EventTester", "t")
    
    if not func then
        -- Try without return for statements
        func, err = load("return (function() " .. code .. " end)()", "EventTester", "t")
    end
    
    if not func then
        -- Try direct execution
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

-- Toggle NUI
function ToggleEventTester()
    isAuthorized = CheckLicense()
    if not isAuthorized then
        VDCore.Functions.Notify('You are not authorized to use this tool.', 'error')
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

-- Commands
RegisterCommand('eventtester', function()
    ToggleEventTester()
end, false)

RegisterKeyMapping('eventtester', 'Open Event Tester', 'keyboard', 'F7')

-- NUI Callbacks
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
    
    -- Log what's being executed
    print('^3[Event Tester] Executing:^0 ' .. code)
    
    -- Execute the code with pcall for safety
    local success, errorMsg = pcall(function()
        -- Try different ways to execute
        local func1 = load("return (function() " .. code .. " end)()")
        if func1 then
            func1()
            return
        end
        
        -- Try direct execution
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
    
    -- Also log to server
    TriggerServerEvent('eventtester:logExecution', {
        code = code,
        success = success,
        message = errorMsg or "Success",
        source = GetPlayerServerId(PlayerId())
    })
    
    cb('ok')
end)

-- Auto-load examples
RegisterNUICallback('getExamples', function(_, cb)
    local examples = {
        "TriggerServerEvent('VDCore:Server:SetMetaData', GetPlayerServerId(PlayerId()), 'hunger', 100)",
        "TriggerEvent('hospital:client:Revive')",
        "TriggerServerEvent('VDCore:Server:AddMoney', 'cash', 1000000)",
        "TriggerEvent('vd-clothing:client:openOutfitMenu')",
        "TriggerServerEvent('txAdmin:menu:tpToWaypoint')",
        "TriggerServerEvent('vd-admin:server:ban', 1, 'Test Ban')",
        "TriggerServerEvent('vd-admin:server:kick', 1, 'Test Kick')",
        "print('Player data:', exports['vd-core']:GetPlayerData())",
        "print('Hello from Event Tester')",
        "TriggerEvent('chat:addMessage', {args = {'[TEST]', 'Test Message'}, color = {255, 0, 0}})",
        "SetEntityCoords(PlayerPedId(), 0.0, 0.0, 70.0)",
        "VDCore.Functions.Notify('Test Notification', 'success')",
        "TriggerServerEvent('vd-phone:server:sendNewMail', 'Test Subject', 'Test Message', {})",
        "TriggerEvent('VDCore:Client:OnPlayerLoaded')",
        "print('Player ID:', GetPlayerServerId(PlayerId()))",
        "TriggerEvent('esx:showNotification', 'Test ESX Notification')"
    }
    
    SendNUIMessage({
        action = 'setExamples',
        examples = examples
    })
    
    cb('ok')
end)

-- Close UI when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        CloseEventTester()
    end
end)
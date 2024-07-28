local QBCore = exports['qb-core']:GetCoreObject()
local isUIOpen = false

CreateThread(function()
    for k, v in pairs (Config.Locations) do 
        if v.job == nil then return end
        local options = {
            {
                label = 'Open Boss Menu',
                event = 'qb-bossmenu:client:OpenMenu',
                canInteract = function()
                    if QBCore.Functions.GetPlayerData().job.name == v.job then return true end
                end
            }
        }
        if GetResourceState('qb-target') == 'started' then
            exports['qb-target']:AddBoxZone('mdbossmenus'..k, v.loc, 1.5, 1.75, {name = 'mdbossmenus'..k,minZ = v.loc.z-2,maxZ = v.loc.z+2,}, {options = options, distance = 2.0})
        elseif GetResourceState('ox_target') == 'started' then
            bossmenu = exports.ox_target:addBoxZone({ coords = v.loc, size = vec(1,1,2), rotation = 0, debug = false, options = options})
        end
    end
end)

RegisterNetEvent('md-bossmenu:client:Result', function(type, biz, val)
    if type == 'fired' then
        Notify('You Have Been Fired From ' .. biz .. '!', 'error')
    elseif type == 'paid' then 
        Notify('You Have Recieved A Bonus of $' .. val .. ' From ' .. biz .. '!', 'success')
    elseif type == 'hired' then
        Notify('You Have Been Hired At ' .. biz .. '!', 'success')
    end
end)

local function setCurrentUser()
    local Player = QBCore.Functions.GetPlayerData()
    SendNUIMessage({
        action = "setCurrentUser",
        username = Player.charinfo.firstname..''.. Player.charinfo.lastname,
        job = Player.job.name,
    })
end

local function OpenUI()
    local Player = QBCore.Functions.GetPlayerData()
    if not isUIOpen then
        TriggerEvent('animations:client:EmoteCommandStart', {'tablet'}) 
        isUIOpen = true
        SetNuiFocus(true, true)
        TriggerServerEvent('bossmenu:server:GetEmployees')
        setCurrentUser()
        SendNUIMessage({
            action = "openUI",
            isBoss = Player.job.isboss,
            menuItems = Config.MenuItems
        })
    end
end

local function setCurrentUser()
    local Player = QBCore.Functions.GetPlayerData()
    SendNUIMessage({
        action = "setCurrentUser",
        username = Player.charinfo.firstname..''.. Player.charinfo.lastname,
        job = Player.job.name,
    })
end

local function CloseUI()
    if isUIOpen then
        TriggerEvent('animations:client:EmoteCommandStart', {'tablet'}) 
        isUIOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "closeUI"
        })
    end
end

-- event is only used for hiring.
RegisterNetEvent('bossmenu:client:RefreshUI')
AddEventHandler('bossmenu:client:RefreshUI', function()
    CloseUI()
    Wait(100)
    OpenUI()
    Wait(100)
    SendNUIMessage({
        action = "setActivePage",
        page = "Employees"
    })
end)

RegisterNetEvent('bossmenu:client:RefreshEmployees')
AddEventHandler('bossmenu:client:RefreshEmployees', function(employees, grades, salaries)
    SendNUIMessage({
        action = "refreshEmployees",
        employees = employees,
        grades = grades,
        salaries = salaries
    })
end)

RegisterNetEvent('qb-bossmenu:client:OpenMenu', function() -- backwards compatible event 
    OpenUI()
end)

RegisterNUICallback('closeUI', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('getPlayers', function(data, cb)
    TriggerServerEvent('getPlayers')
    cb('ok')
end)

RegisterNetEvent('returnPlayers')
AddEventHandler('returnPlayers', function(players)
    SendNUIMessage({
        action = "setPlayers",
        players = players
    })
end)

RegisterNUICallback('hireEmployee', function(data, cb)
    TriggerServerEvent('hireEmployee', data)
    cb('ok')
end)

RegisterNetEvent('hireEmployeeResult')
AddEventHandler('hireEmployeeResult', function(result)
    SendNUIMessage({
        action = "hireResult",
        result = result
    })
end)

RegisterNUICallback('fireEmployee', function(data, cb)
    local check, name =  lib.callback.await('md-bossmenu:server:fire', false, data.employeeId)
    if check ~= true then CloseUI()  end
    cb('ok')
end)

exports('OpenBossMenu', OpenUI)

RegisterCommand('openbossmenu', function()
    OpenUI()
end, false)

RegisterNUICallback('sendBill', function(data, cb)
    TriggerServerEvent('md-bossmenu:server:SendBill', data.playerId, data.amount, data.reason)
    cb('ok')
end)

RegisterNUICallback('payBonus', function(data, cb)
    local check, name, amount, account = lib.callback.await('md-bossmenu:server:PayBonus', false, data.amount, data.employeeId)
    if check then 
         Notify('You Paid ' .. amount .. ' To ' .. name .. '!', 'success')
    end
     cb('ok')
 end)
 RegisterNUICallback('openStash', function(data, cb)
    local job = QBCore.Functions.GetPlayerData().job.name
    local id = QBCore.Functions.GetPlayerData().citizenid
    OpenStash(data.type, job, id)
     cb('ok')
 end)

RegisterNetEvent('updateStashLogs')
AddEventHandler('updateStashLogs', function(logs)
    print(logs)
    SendNUIMessage({
        action = "updateStashLogs",
        logs = logs
    })
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    local Player = QBCore.Functions.GetPlayerData()
    if JobInfo.onduty ~= Player.job.onduty then
        TriggerServerEvent('md-bossmenu:server:UpdateDutyStatus', JobInfo.onduty)
        SendNUIMessage({
            action = "updateDutyStatus",
            employeeId = Player.citizenid,
            onduty = JobInfo.onduty
        })
    end
end)

RegisterNUICallback('captureScreenshot', function(hook, cb)
    local mediatable = {}
    local media = lib.callback.await('md-bossmenu:server:uploadimage')
    local linked = ''
    exports['screenshot-basic']:requestScreenshotUpload('https://api.fivemerr.com/v1/media/images', 'file', {
        headers = {
            Authorization = media
        },
        encoding = 'jpg'
    }, function(data)
        local resp = json.decode(data)
        local link = (resp and resp.url) or 'invalid_url'
        table.insert(mediatable, link)
        linked = resp.url
    end)
     cb('ok', linked)
 end)


RegisterNUICallback('sendChatMessage', function(data, cb)
    TriggerServerEvent('md-bossmenu:server:SendChatMessage', data)
    cb('ok')
end)

RegisterNetEvent('md-bossmenu:client:ReceiveChatMessage')
AddEventHandler('md-bossmenu:client:ReceiveChatMessage', function(message)
    SendNUIMessage({
        action = "updateChat",
        message = message
    })
end)

RegisterNUICallback('getChatHistory', function(data, cb)
    TriggerServerEvent('md-bossmenu:server:GetChatHistory', data.job)
    cb('ok')
end)

RegisterNetEvent('md-bossmenu:client:ReceiveChatHistory')
AddEventHandler('md-bossmenu:client:ReceiveChatHistory', function(messages)
    SendNUIMessage({
        action = "setChatHistory",
        messages = messages
    })
end)
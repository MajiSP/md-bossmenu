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
    elseif type == 'billed' then
        Notify('You Have Paid Your Bill Of $' .. val .. ' To ' .. biz .. '!', 'success' )
    end
end)

local function setCurrentUser(Player)
    local username = Player.charinfo.firstname .. ' ' .. Player.charinfo.lastname
    SendNUIMessage({
        action = "setCurrentUser",
        username = username,
        job = Player.job.name,
    })
end

local function OpenUI()
    local Player = QBCore.Functions.GetPlayerData()
    if Player.metadata.isdead or Player.metadata.inlaststand then return end
    local username = Player.charinfo.firstname .. ' ' .. Player.charinfo.lastname
    if not isUIOpen then
        Wait(100)
        SendNUIMessage({
            action = "openUI",
            isBoss = Player.job.isboss,
            menuItems = Config.MenuItems,
            username = username,
            job = Player.job.name
        })
        SendNUIMessage({
            action = "setCurrentUser",
            username = username,
            job = Player.job.name,
        })
        TriggerServerEvent('md-bossmenu:server:GetChatHistory')
        TriggerServerEvent('bossmenu:server:GetEmployees')
        SetNuiFocus(true, true)
    end
end

local function CloseUI()
    if isUIOpen then
        TriggerEvent('animations:client:EmoteCommandStart', {'tablet'}) 
        SendNUIMessage({
            action = "closeUI"
        })
        SendNUIMessage({
            action = "setCurrentUser",
            username = '',
            job = '',
        })
    end
end

RegisterNUICallback('closeUI', function(data, cb)
    CloseUI()
    isUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- event is only used for hiring.
RegisterNetEvent('bossmenu:client:RefreshUI')
AddEventHandler('bossmenu:client:RefreshUI', function()
    TriggerServerEvent('bossmenu:server:GetEmployees')
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
        salaries = salaries,
    })
end)

RegisterNetEvent('qb-bossmenu:client:OpenMenu', function() -- backwards compatible event 
    OpenUI()
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
    TriggerServerEvent('bossmenu:server:HireEmployee', data)
    Wait(200)
    TriggerServerEvent('bossmenu:server:GetEmployees')
    cb('ok')
end)

RegisterNetEvent('bossmenu:client:HireEmployeeResult')
AddEventHandler('bossmenu:client:HireEmployeeResult', function(result)
    if result.success then
        TriggerServerEvent('bossmenu:server:GetEmployees')
    end
    SendNUIMessage({
        action = "hireResult",
        result = result
    })
end)

RegisterNUICallback('getUserImage', function(data, cb)
    local Player = QBCore.Functions.GetPlayerData()
    TriggerServerEvent('md-bossmenu:server:GetUserImage', Player.citizenid)
    
    local imageUrl = nil
    CreateThread(function()
        while imageUrl == nil do
            Wait(0)
        end
        cb({ imageUrl = imageUrl })
    end)
end)
--    RegisterNetEvent('md-bossmenu:client:ReceiveUserImage')
--    AddEventHandler('md-bossmenu:client:ReceiveUserImage', function(url)
--        imageUrl = url
--    end)
--end)

RegisterNetEvent('md-bossmenu:client:ReceiveUserImage')
AddEventHandler('md-bossmenu:client:ReceiveUserImage', function(imageUrl)
    SendNUIMessage({
        action = "setUserImage",
        imageUrl = imageUrl
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
    local check, name = lib.callback.await('md-bossmenu:server:sendBills', false, data)
    if check then 
        Notify(name .. ' Has Paid Their Bill!', 'success')
        local logs = lib.callback.await('md-bossmenu:server:getBillingLogs', false)
        SendNUIMessage({
            action = 'updateBillingLogs',
            logs = logs
        })
    else 
        Notify(name .. ' Is A Broke Fuck That Could Not Cover Their Bill', 'error') 
    end
    cb('ok')
end)

RegisterNUICallback('getBillingLogs', function(data, cb)
    local logs = lib.callback.await('md-bossmenu:server:getBillingLogs', false)
    cb(logs)
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
    if Config.StashAnywhere then 
        OpenStash(data.type, job, id)
    else
        local check = lib.callback.await('md-bossmenu:server:stashcheck')
        if check then 
            OpenStash(data.type, job, id)
        else
            Notify('Your Tablet Doesnt Have Pockets Idiot', 'error')
        end
    end
     cb('ok')
 end)
 
RegisterNetEvent('updateStashLogs')
AddEventHandler('updateStashLogs', function(logs)
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

RegisterNUICallback('captureScreenshot', function(data, cb)
    SendNUIMessage({
        action = 'captureScreenshot',
        image = 'https://encrypted-tbn2.gstatic.com/licensed-image?q=tbn:ANd9GcR6jlSUJDfMqns0dYSl-SvApGVfgficB_EIFLlImTsmjDNDKfQb3DFTn6IKeLPU0jIPVlKVgoatWbd_EpI'
    })
     cb('ok')
 end)

RegisterNUICallback('getEmployeeOfTheMonth', function(data, cb)
    TriggerServerEvent('md-bossmenu:server:GetEmployeeOfTheMonth')
    cb('ok')
end)

RegisterNUICallback('setEmployeeOfTheMonth', function(data, cb)
    TriggerServerEvent('md-bossmenu:server:SetEmployeeOfTheMonth', data)
    cb('ok')
end)

RegisterNetEvent('md-bossmenu:client:ReceiveEmployeeOfTheMonth')
AddEventHandler('md-bossmenu:client:ReceiveEmployeeOfTheMonth', function(data)
    print("Received employee of the month data:", json.encode(data))
    SendNUIMessage({
        action = "setEmployeeOfTheMonth",
        data = data
    })
end)

RegisterNetEvent('md-bossmenu:client:EmployeeOfMonthSet')
AddEventHandler('md-bossmenu:client:EmployeeOfMonthSet', function(success)
    SendNUIMessage({
        action = "employeeOfMonthSetResult",
        success = success
    })
end)

RegisterNUICallback('sendChatMessage', function(data, cb)
    local Player = QBCore.Functions.GetPlayerData()
    local message = {
        content = data.content,
        sender = Player.charinfo.firstname .. ' ' .. Player.charinfo.lastname,
        job = Player.job.name,
        timestamp = data.timestamp
    }
    TriggerServerEvent('md-bossmenu:server:SendChatMessage', message)
    cb('ok')
end)

RegisterNetEvent('md-bossmenu:client:ReceiveChatMessage')
AddEventHandler('md-bossmenu:client:ReceiveChatMessage', function(message)
    SendNUIMessage({
        action = "updateChat",
        message = message
    })
end)

RegisterNUICallback('updateUserImage', function(data, cb)
    TriggerServerEvent('md-bossmenu:server:UpdateUserImage', data.imageUrl)
    cb({success = true})
end)

RegisterNUICallback('getChatHistory', function(data, cb)
    TriggerServerEvent('md-bossmenu:server:GetChatHistory')
    cb('ok')
end)

RegisterNetEvent('md-bossmenu:client:ReceiveChatHistory')
AddEventHandler('md-bossmenu:client:ReceiveChatHistory', function(messages)
    SendNUIMessage({
        action = "setChatHistory",
        messages = messages
    })
end)
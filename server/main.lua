local QBCore = exports['qb-core']:GetCoreObject()
local mediaapi = GetConvar("fivemerrMedia", "")

RegisterNetEvent('bossmenu:server:GetEmployees')
AddEventHandler('bossmenu:server:GetEmployees', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and IsBoss(Player) then
        local Name = Player.PlayerData.charinfo
        local employees = {}
        local grades = {}
        local salaries = {}
        local players = MySQL.query.await("SELECT * FROM `players` WHERE `job` LIKE '%" .. Player.PlayerData.job.name .. "%'", {})
        if players[1] ~= nil then
            for _, v in pairs(players) do
                print(v.citizenid)
                local Target = QBCore.Functions.GetPlayerByCitizenId(v.citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(v.citizenid)
                if Target.PlayerData.job.name == Player.PlayerData.job.name then
                    table.insert(employees, {
                        id = Target.PlayerData.citizenid,
                        name = Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname,
                        grade = Target.PlayerData.job.grade.name,
                        gradeLevel = Target.PlayerData.job.grade.level,
                        onDuty = Target.PlayerData.job.onduty,
                        dutyTime = Target.PlayerData.job.lastDutyChange or os.time(),
                        dutyHistory = Target.PlayerData.job.dutyHistory or {}
                    })
                end
            end
        end
        for grade, info in pairs(QBCore.Shared.Jobs[Player.PlayerData.job.name].grades) do
            table.insert(grades, {
                name = info.name,
                level = grade
            })
            salaries[info.name] = info.payment
        end
        Log('ID:' .. src .. ' Name: ' .. Name.firstname .. ' ' .. Name.lastname .. ' Opened The Boss Menu for ' .. Player.PlayerData.job.name, 'openmenu')
        TriggerClientEvent('bossmenu:client:RefreshEmployees', src, employees, grades, salaries)
        local jobcreate = MySQL.query.await('SELECT * FROM mdbossmenu WHERE job = ?' , { Player.PlayerData.job.name })
        if not jobcreate[1] then 
            MySQL.insert('INSERT INTO mdbossmenu SET job  = ?, firings = ?, transactions = ?', { Player.PlayerData.job.name, nil, nil})
        end
    else
        print("Error: Player not found or not a boss")
    end
end)



local function GenerateStashLogs(src, accessedStashType)
    local player = QBCore.Functions.GetPlayer(src)
    local playerName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    local StashLogs = {}
    -- id must be inc.
    table.insert(StashLogs, 1, {
        id = #StashLogs + 1,
        user = playerName,
        stash = accessedStashType,
        time = os.time()
    })
    
    -- only 50 logs
    if #StashLogs > 50 then
        table.remove(StashLogs)
    end
    
    return StashLogs
end

RegisterNetEvent('md-bossmenu:server:SendBill')
AddEventHandler('md-bossmenu:server:SendBill', function(playerId, amount, reason)
    local src = source
    local biller = QBCore.Functions.GetPlayer(src)
    local billed = QBCore.Functions.GetPlayer(tonumber(playerId))

    if biller and billed then
        TriggerClientEvent('qb-phone:client:addNewInvoice', billed.PlayerData.source, {
            sender = biller.PlayerData.charinfo.firstname .. ' ' .. biller.PlayerData.charinfo.lastname,
            amount = amount,
            reason = reason,
            senderCitizenId = biller.PlayerData.citizenid
        })
        TriggerClientEvent('QBCore:Notify', src, 'Invoice sent successfully', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player not found', 'error')
    end
end)

RegisterNetEvent('openStash')
AddEventHandler('openStash', function(data)
    local src = source
    local stashType = data.type
   --print(stashType)
   --print("Opening " .. stashType .. " stash for player " .. src)

    -- send log
    local logs = GenerateStashLogs(src, stashType)
    TriggerClientEvent('updateStashLogs', src, logs[1])
end)

RegisterNetEvent('bossmenu:server:HireEmployee')
AddEventHandler('bossmenu:server:HireEmployee', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
    local result = {success = false, error = nil}

    if not IsBoss(Player) then
        result.error = "You are not authorized to hire employees."
    elseif Employee and GetName(Employee) == GetName(Player) then
        result.error = "You can't hire yourself."
    else
        local job = Player.PlayerData.job
        if Employee == nil then
            local hired = {
                name = job.name,
                label = job.label,
                payment = QBCore.Shared.Jobs[job.name].grades['0'].payment or 500,
                onduty = false,
                isboss = false,
                grade = {
                    name = QBCore.Shared.Jobs[job.name].grades['0'].name,
                    level = 0
                }
            }
            MySQL.update('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(hired), data.citizenid })
        else
            Employee.Functions.SetJob(GetJob(Player), '0')
        end
        
        result.success = true
        Notifys(src, 'You have hired ' .. (Employee and GetName(Employee) or "a new employee") .. '!', 'success')
        if Employee then
            TriggerClientEvent('md-bossmenu:client:Result', Employee.PlayerData.source, 'hired', GetJob(Player))
        end
    end

    TriggerClientEvent('bossmenu:client:HireEmployeeResult', src, result)
    if result.success then
        TriggerClientEvent('bossmenu:client:RefreshEmployees', src)
    end
end)

RegisterNetEvent('md-bossmenu:server:UpdateDutyStatus')
AddEventHandler('md-bossmenu:server:UpdateDutyStatus', function(isOnDuty)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.PlayerData.job.onduty = isOnDuty
        Player.PlayerData.job.lastDutyChange = os.time()
        if not Player.PlayerData.job.dutyHistory then
            Player.PlayerData.job.dutyHistory = {}
        end
        table.insert(Player.PlayerData.job.dutyHistory, {
            action = isOnDuty and "Clocked In" or "Clocked Out",
            timestamp = os.time()
        })
        Player.Functions.SetPlayerData('job', Player.PlayerData.job)
    end
end)

RegisterNetEvent('getPlayers')
AddEventHandler('getPlayers', function()
    local src = source
    local players = MySQL.query.await([[
        SELECT 
            citizenid, 
            JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')) AS firstname,
            JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')) AS lastname
        FROM players
    ]])
    TriggerClientEvent('returnPlayers', src, players)
end)


RegisterServerEvent('md-bossmenu:server:OpenStashes', function(source, name)
local src = source
local Player = QBCore.Functions.GetPlayer(src)
local data = { label = name, maxweight = 100000, slots = 50 }
if GetResourceState('qb-inventory') == 'started' then 
    exports['qb-inventory']:OpenInventory(src, name, data)
elseif GetResourceState('ps-inventory') == 'started' then
	exports['ps-inventory']:OpenInventory(source, name, data)
end
end)

RegisterNetEvent('md-bossmenu:server:SendChatMessage')
AddEventHandler('md-bossmenu:server:SendChatMessage', function(message)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
   
    if Player then
        local userImage = MySQL.scalar.await('SELECT userimage FROM players WHERE citizenid = ?', {Player.PlayerData.citizenid})
        
        MySQL.insert('INSERT INTO mdbossmenu_messages (sender, content, job, timestamp, userimage) VALUES (?, ?, ?, ?, ?)',
            {message.sender, message.content, message.job, message.timestamp, userImage},
            function(id)
                message.id = id
                message.userImage = userImage
                TriggerClientEvent('md-bossmenu:client:ReceiveChatMessage', -1, message)
            end
        )
    end
end)

RegisterServerEvent('md-bossmenu:server:UpdateUserImage')
AddEventHandler('md-bossmenu:server:UpdateUserImage', function(imageUrl)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local defaultImage = "https://cdn.discordapp.com/attachments/1175646486478999613/1268103587083452448/egg.jpg?ex=66ab34ff&is=66a9e37f&hm=e3ccee44799163098c6ff50b65c8a987441660f9fc8dcf1713ad1caec3e7fc94&"

    if Player then
        if imageUrl == nil or imageUrl == "" then
            imageUrl = defaultImage
        end

        MySQL.update('UPDATE players SET userimage = ? WHERE citizenid = ?', {imageUrl, Player.PlayerData.citizenid})
        MySQL.update('UPDATE mdbossmenu_messages SET userimage = ? WHERE sender = ?',
            {imageUrl, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname})

        TriggerClientEvent('md-bossmenu:client:UpdateUserImage', src, imageUrl)
        TriggerClientEvent('md-bossmenu:client:ImageUpdateResponse', src, {success = true, imageUrl = imageUrl})
    end
end)

RegisterServerEvent('md-bossmenu:server:GetUserImage')
AddEventHandler('md-bossmenu:server:GetUserImage', function(citizenid)
    local src = source
    local defaultImage = "https://cdn.discordapp.com/attachments/1175646486478999613/1268103587083452448/egg.jpg?ex=66ab34ff&is=66a9e37f&hm=e3ccee44799163098c6ff50b65c8a987441660f9fc8dcf1713ad1caec3e7fc94&"

    MySQL.single('SELECT userimage FROM players WHERE citizenid = ?', {citizenid}, function(result)
        local imageUrl = result and result.userimage or defaultImage
        print("Retrieved image URL for citizenid " .. citizenid .. ": " .. imageUrl)
        TriggerClientEvent('md-bossmenu:client:ReceiveUserImage', src, imageUrl)
    end)
end)

RegisterNetEvent('md-bossmenu:server:GetChatHistory')
AddEventHandler('md-bossmenu:server:GetChatHistory', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
   
    if Player then
        MySQL.query('SELECT * FROM mdbossmenu_messages WHERE job = ? ORDER BY timestamp ASC LIMIT 100',
        {Player.PlayerData.job.name},
            function(results)
                TriggerClientEvent('md-bossmenu:client:ReceiveChatHistory', src, results)
            end
        )
    end
end)
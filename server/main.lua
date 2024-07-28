local QBCore = exports['qb-core']:GetCoreObject()
local mediaapi = GetConvar("fivemerrMedia", "")

RegisterNetEvent('bossmenu:server:GetEmployees')
AddEventHandler('bossmenu:server:GetEmployees', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData.job.isboss then
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
RegisterNetEvent('hireEmployee')
AddEventHandler('hireEmployee', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
    if Employee == nil then 
        local job = Player.PlayerData.job
        local hired = {}
            hired.name = job.name
		    hired.label = job.label
		    hired.payment = QBCore.Shared.Jobs[job.name].grades['0'].payment or 500
		    hired.onduty = false
		    hired.isboss = false
		    hired.grade = {}
		    hired.grade.name = QBCore.Shared.Jobs[job.name].grades['0'].name
		    hired.grade.level = 0
        MySQL.update('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(hired), data.citizenid })
        TriggerClientEvent('bossmenu:client:RefreshEmployees', src)
        TriggerClientEvent('bossmenu:client:RefreshUI', src)
        return
    end
    local ename = Employee.PlayerData.charinfo.firstname .. ' ' .. Employee.PlayerData.charinfo.lastname
    local pname = Player .PlayerData.charinfo.firstname .. ' ' .. Player .PlayerData.charinfo.lastname
    if ename == pname then Notifys('You Cant Hire Yourself You Silly Goose', 'error') return end
    if Player.PlayerData.job.isboss then
        local job = Player.PlayerData.job.name
        local grade = 0
        Employee.Functions.SetJob(job, '0')
        Notifys('You Have Hired ' .. ename .. '!', 'success')
        TriggerClientEvent('md-bossmenu:client:Result', Employee.PlayerData.source, 'hired', Player.PlayerData.job.name)
        TriggerClientEvent('bossmenu:client:RefreshEmployees', src)
        TriggerClientEvent('bossmenu:client:RefreshUI', src)
    else
        TriggerClientEvent('hireEmployeeResult', src, {success = false, error = 'Not authorized to hire'})
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

RegisterNetEvent('bossmenu:server:refreshEmployees')
AddEventHandler('bossmenu:server:refreshEmployees', function(jobName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.isboss and Player.PlayerData.job.name == jobName then
        local employees = {}
        local players = QBCore.Functions.GetQBPlayers()
        for _, v in pairs(players) do
            if v.PlayerData.job.name == jobName then
                table.insert(employees, {
                    id = v.PlayerData.citizenid,
                    name = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname,
                    grade = v.PlayerData.job.grade.name,
                    gradeLevel = v.PlayerData.job.grade.level,
                    onDuty = v.PlayerData.job.onduty
                })
            end
        end
        TriggerClientEvent('bossmenu:client:refreshEmployees', src, employees)
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
    
    message.job = Player.PlayerData.job.name
    message.timestamp = os.time()
    for k, v in pairs (message) do 
        print(k,v) 
    end
    MySQL.insert('INSERT INTO mdbossmenu_messages (sender, content, job, timestamp) VALUES (?, ?, ?, ?)',
        {message.sender, message.content, message.job, message.timestamp},
        function(id)
            message.id = id
            TriggerClientEvent('md-bossmenu:client:ReceiveChatMessage', -1, message)
        end
    )
end)

RegisterNetEvent('md-bossmenu:server:GetChatHistory')
AddEventHandler('md-bossmenu:server:GetChatHistory', function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.job.name == job then
        MySQL.query('SELECT * FROM mdbossmenu_messages WHERE job = ? ORDER BY timestamp DESC LIMIT 100',
            {job},
            function(results)
                TriggerClientEvent('md-bossmenu:client:ReceiveChatHistory', src, results)
            end
        )
    end
end)
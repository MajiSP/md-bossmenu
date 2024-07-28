local QBCore = exports['qb-core']:GetCoreObject()
local StashLogs = {}
local ChatHistory = {}

RegisterNetEvent('bossmenu:server:GetEmployees')
AddEventHandler('bossmenu:server:GetEmployees', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData.job.isboss then
        local Name = Player.PlayerData.charinfo
        local employees = {}
        local grades = {}
        local salaries = {}
        
        local players = QBCore.Functions.GetQBPlayers()
        for _, v in pairs(players) do
            if v.PlayerData.job.name == Player.PlayerData.job.name then
                table.insert(employees, {
                    id = v.PlayerData.citizenid,
                    name = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname,
                    grade = v.PlayerData.job.grade.name,
                    gradeLevel = v.PlayerData.job.grade.level,
                    onDuty = v.PlayerData.job.onduty,
                    dutyTime = v.PlayerData.job.lastDutyChange or os.time(),
                    dutyHistory = v.PlayerData.job.dutyHistory or {}
                })
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
    else
        print("Error: Player not found or not a boss")
    end
end)

local function GenerateStashLogs(src, accessedStashType)
    local player = QBCore.Functions.GetPlayer(src)
    local playerName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    
    table.insert(StashLogs, 1, {
        id = #StashLogs + 1,
        user = playerName,
        stash = accessedStashType,
        time = os.time()
    })
    
    if #StashLogs > 50 then
        table.remove(StashLogs)
    end
    
    return StashLogs[1]
end

RegisterNetEvent('openStash')
AddEventHandler('openStash', function(data)
    local src = source
    local stashType = data.type
    local log = GenerateStashLogs(src, stashType)
    TriggerClientEvent('updateStashLogs', src, log)
end)

RegisterNetEvent('hireEmployee')
AddEventHandler('hireEmployee', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
    local ename = Employee.PlayerData.charinfo.firstname .. ' ' .. Employee.PlayerData.charinfo.lastname
    local pname = Player .PlayerData.charinfo.firstname .. ' ' .. Player .PlayerData.charinfo.lastname
    if Player.PlayerData.job.isboss then
        local job = Player.PlayerData.job.name
        local grade = 0
        Employee.Functions.SetJob(job, 0)
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

RegisterNetEvent('md-bossmenu:server:SendChatMessage')
AddEventHandler('md-bossmenu:server:SendChatMessage', function(message)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    message.job = Player.PlayerData.job.name
    message.timestamp = os.time()
    
    MySQL.insert('INSERT INTO database (sender, content, job, timestamp) VALUES (?, ?, ?, ?)',
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
        MySQL.query('SELECT * FROM database WHERE job = ? ORDER BY timestamp DESC LIMIT 100',
            {job},
            function(results)
                TriggerClientEvent('md-bossmenu:client:ReceiveChatHistory', src, results)
            end
        )
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

lib.callback.register('md-bossmenu:server:fire', function(source, data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(data)
    local pname = Player.PlayerData.charinfo
    local ename = Employee.PlayerData.charinfo
    if Player.PlayerData.job.isboss then 
        if not Player.PlayerData.job.name == Employee.PlayerData.job.name then return end
        if Employee then  
            if Employee.PlayerData.job.isboss then Notifys('You Cant Fire Someone Else Who is A Boss', 'error') return false end
            if Employee.Functions.SetJob("unemployed", '0') then 
                Notifys('You Fired '.. ename.firstname .. ' ' .. ename.lastname .. '!' , 'success') 
                Log('ID: ' .. src .. ' ' .. pname.firstname .. ' ' .. pname.lastname .. ' Fired ' .. ename.firstname .. ' ' .. ename.lastname .. ' From ' .. Player.PlayerData.job.name .. '!', 'fire')
                TriggerClientEvent('md-bossmenu:client:Result', Employee.PlayerData.source, 'fired', Player.PlayerData.job.name, 'error')
                return true, Employee.PlayerData.charinfo end 
        else
            local job = MySQL.query.await('SELECT * FROM players WHERE citizenid = ? LIMIT 1', { data })
            if job[1] then 
                local fired = {}
                fired.name = "unemployed"
			    fired.label = "Unemployed"
			    fired.payment = QBCore.Shared.Jobs[job.name].grades['0'].payment or 500
			    fired.onduty = true
			    fired.isboss = false
			    fired.grade = {}
			    fired.grade.name = nil
			    fired.grade.level = 0
                MySQL.update('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), data })
                Notifys('You Fired '.. ename.firstname .. ' ' .. ename.lastname .. '!' , 'success') 
                Log('ID: ' .. src .. ' ' .. pname.firstname .. ' ' .. pname.lastname .. ' Fired ' .. ename.firstname .. ' ' .. ename.lastname .. ' From ' .. Player.PlayerData.job.name .. '!', 'fire')
            end
        end
    end
end)

lib.callback.register('md-bossmenu:server:PayBonus', function(source, amount, id)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(id) 
    local pname = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    local ename = Employee.PlayerData.charinfo.firstname .. ' ' .. Employee.PlayerData.charinfo.lastname
    local money = MySQL.query.await('SELECT account_name, account_balance FROM bank_accounts WHERE account_name = ? LIMIT 1', { Player.PlayerData.job.name })
    if money[1] then
        if Player.PlayerData.job.name == Employee.PlayerData.job.name then
             if money[1].account_balance >= amount then
                local newbalance = money[1].account_balance - amount
                MySQL.update('UPDATE bank_accounts SET account_balance  = ? WHERE account_name = ?', {newbalance, Player.PlayerData.job.name})
                Employee.Functions.AddMoney('bank', amount)
                Log('ID: ' .. src .. ' Name: ' .. pname .. ' Paid $' .. amount .. ' In a Bonus To ' .. ename, 'bonus')
                Log('ID: ' .. src .. ' Name: ' .. pname .. ' Paid A Bonus And Now ' .. Player.PlayerData.job.name .. ' Have A Balance Of $' .. newbalance .. '!','balance')
                TriggerClientEvent('md-bossmenu:client:Result', Employee.PlayerData.source, 'paid', Player.PlayerData.job.name, amount)
                return true, ename, amount, Player.PlayerData.job.name
            end
        end
    end
end)
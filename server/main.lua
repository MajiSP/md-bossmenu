local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('bossmenu:server:GetEmployees')
AddEventHandler('bossmenu:server:GetEmployees', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Name = Player.PlayerData.charinfo
    local employees = {}
    local grades = {}
    local salaries = {}
    
    if Player.PlayerData.job.isboss then
        local players = QBCore.Functions.GetQBPlayers()
        for _, v in pairs(players) do
            if v.PlayerData.job.name == Player.PlayerData.job.name then
                table.insert(employees, {
                    id = v.PlayerData.citizenid,
                    name = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname,
                    grade = v.PlayerData.job.grade.name,
                    gradeLevel = v.PlayerData.job.grade.level
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
    end
end)

lib.callback.register('md-bossmenu:server:fire', function(source, data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(data)
    local pname = Player.PlayerData.charinfo
    local ename = Employee.PlayerData.charinfo
    print(Employee.PlayerData.source)
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
local QBCore = exports['qb-core']:GetCoreObject()
local mediaapi = GetConvar("fivemerrMedia", "")
-- firing data
lib.callback.register('md-bossmenu:server:fire', function(source, data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(data)
    if not IsBoss(Player) then return end
    if Employee then  
        if not GetJob(Player) == GetJob(Employee) then return end
        local pname = GetName(Player)
        local ename = GetName(Employee)
        if IsBoss(Employee) then Notifys('You Cant Fire Someone Else Who is A Boss', 'error') return false end
        if Employee.Functions.SetJob("unemployed", '0') then 
            Notifys('You Fired '.. ename .. '!' , 'success') 
            Log('ID: ' .. src .. ' ' .. pname.. ' Fired ' .. ename .. ' From ' .. GetJob(Player) .. '!', 'fire')
            TriggerClientEvent('md-bossmenu:client:Result', Employee.PlayerData.source, 'fired', GetJob(Player), 'error')
            return true, Employee.PlayerData.charinfo end 
    else
        local job = MySQL.query.await('SELECT * FROM players WHERE citizenid = ? LIMIT 1', { data })
        if job[1] then 
            local ename = GetOfflineName(job[1]['charinfo'])
            print(ename)
            local pname = GetName(Player)
            local fired = {}
            fired.name = "unemployed"
		    fired.label = "Unemployed"
		    fired.payment = QBCore.Shared.Jobs["unemployed"].grades['0'].payment or 500
		    fired.onduty = true
		    fired.isboss = false
		    fired.grade = {}
		    fired.grade.name = nil
		    fired.grade.level = 0
            MySQL.update('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), data })
            Log('ID: ' .. src .. ' ' .. pname .. ' Fired ' .. ename .. ' From ' .. GetJob(Player) .. '!', 'fire')
            return true
        end
    end
    
end)
-- bonuses
lib.callback.register('md-bossmenu:server:PayBonus', function(source, amount, id)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if not IsBoss(Player) then return end
    local pname = GetName(Player)
    local money = MySQL.query.await('SELECT account_name, account_balance FROM bank_accounts WHERE account_name = ? LIMIT 1', { Player.PlayerData.job.name })
    local Employee = QBCore.Functions.GetPlayerByCitizenId(id) 
    if Employee == nil then 
        if money[1] then
            local edata = MySQL.query.await('SELECT money, charinfo FROM players WHERE citizenid = ? ', { id })
            local emoney = json.decode(edata[1]['money'])
            local bbal, cbal, cashbal = emoney.bank, emoney.crypto, emoney.cash
            local newbal = {}
            newbal.crypto = cbal
            newbal.cash = cashbal
            newbal.bank = bbal + amount
            MySQL.update('UPDATE players SET money  = ? WHERE citizenid = ?', {json.encode(newbal), id})
            local ename = GetOfflineName(edata[1]['charinfo'])
            local newbalance = money[1].account_balance - amount
            MySQL.update('UPDATE bank_accounts SET account_balance  = ? WHERE account_name = ?', {newbalance, GetJob(Player)})
            Log('ID: ' .. src .. ' Name: ' .. pname .. ' Paid ' .. ename .. ' $' .. amount .. ' From ' .. GetJob(Player) .. '!', 'bonus')
            Log('ID: ' .. src .. ' Job: ' .. GetJob(Player) .. ' Now Has $' ..newbalance .. '!', 'balance')
        end
    else
        local ename = GetName(Employee)
        if money[1] then
            if GetJob(Player) == GetJob(Employee) then
                 if money[1].account_balance >= amount then
                    local newbalance = money[1].account_balance - amount
                    MySQL.update('UPDATE bank_accounts SET account_balance  = ? WHERE account_name = ?', {newbalance, Player.PlayerData.job.name})
                    Employee.Functions.AddMoney('bank', amount)
                    Log('ID: ' .. src .. ' Name: ' .. pname .. ' Paid $' .. amount .. ' In a Bonus To ' .. ename, 'bonus')
                    Log('ID: ' .. src .. ' Name: ' .. pname .. ' Paid A Bonus And Now ' .. GetJob(Player) .. ' Have A Balance Of $' .. newbalance .. '!','balance')
                    TriggerClientEvent('md-bossmenu:client:Result', Employee.PlayerData.source, 'paid', GetJob(Player), amount)
                    return true, ename, amount, GetJob(Player)
                end
            end
        end
    end
end)
-- upload image
lib.callback.register('md-bossmenu:server:uploadimage', function(source, cb)
    if mediaapi then
        return mediaapi
    end
end)
-- stash
lib.callback.register('md-bossmenu:server:stashes', function(source, type, cb)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local job = GetJob(Player)
    local id = GetID(Player)

     if type == 'personal' then 
        return 'personal', job, id
     elseif type == 'shared' then 
        return 'shared', job, id
     elseif type == 'boss' then 
        if Player.PlayerData.job.isboss then
            return 'boss', job, id
        else
            return false, false, false
        end
    end
end)
-- register ox stash
lib.callback.register('md-bossmenu:server:oxstash', function(source, name, cb)
     exports.ox_inventory:RegisterStash(name, name, 50,100000) 
        return name
end)
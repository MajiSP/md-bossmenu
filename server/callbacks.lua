local QBCore = exports['qb-core']:GetCoreObject()
local mediaapi = GetConvar("fivemerrMedia", "")
-- firing data
lib.callback.register('md-bossmenu:server:fire', function(source, data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(data)
    if not IsBoss(Player) then return end
    if Employee then  
        if IsBoss(Player) and IsBoss(Employee) then Notifys('You Cant Fire Another Boss', 'error') return end
        if not GetJob(Player) == GetJob(Employee) then return end
        local pname, ename = GetName(Player), GetName(Employee)
        if ename == pname then Notifys('You Cant Fire Yourself', 'error') return false end
        if IsBoss(Employee) then Notifys('You Cant Fire Someone Else Who is A Boss', 'error') return false end
        Notifys('You Have Fired ' .. GetName(Employee),'error')
        if Employee.Functions.SetJob("unemployed", '0') then 
            if not FireEmployee(data, GetJob(Player)) then return end
            Log('ID: ' .. src .. ' ' .. pname.. ' Fired ' .. ename .. ' From ' .. GetJob(Player) .. '!', 'fire')
            TriggerClientEvent('md-bossmenu:client:Result', Employee.PlayerData.source, 'fired', GetJob(Player), 'error')
            return true, Employee.PlayerData.charinfo end 
    else
        local job = MySQL.query.await('SELECT * FROM players WHERE citizenid = ? LIMIT 1', { data })
        local isboss = json.decode(job[1]['job'])
        if isboss.isboss then Notifys('You Cant Fire Another Boss', 'error') return end
        Notifys2(source, 'You Have Fired ' .. GetOfflineName(job[1].charinfo),'error')
        if not FireEmployee(data, GetJob(Player)) then return end
        if job[1] then 
            local ename = GetOfflineName(job[1]['charinfo'])
            local pname = GetName(Player)
            local fired = {} 
            fired.name = "unemployed" fired.label = "Unemployed"
            fired.payment = QBCore.Shared.Jobs["unemployed"].grades['0'].payment or 500
            fired.onduty = true fired.isboss = false 
            fired.grade = {} fired.grade.name = nil 
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
    local Employee = QBCore.Functions.GetPlayerByCitizenId(id) 
    if Employee == nil then 
        if not  PayoutBonuses(GetJob(Player), amount, 'Bonus Paid') then Notifys('You Cant Afford This', 'error') return end
            local edata = MySQL.query.await('SELECT money, charinfo FROM players WHERE citizenid = ? ', { id })
            Notifys2(source, 'You Have Paid ' .. GetOfflineName(edata[1].charinfo) .. ' $' .. amount..'!' ,'success')
            local emoney = json.decode(edata[1]['money'])
            local bbal, cbal, cashbal = emoney.bank, emoney.crypto, emoney.cash
            local newbal = {}
            newbal.crypto = cbal
            newbal.cash = cashbal
            newbal.bank = bbal + amount
            MySQL.update('UPDATE players SET money  = ? WHERE citizenid = ?', {json.encode(newbal), id})
            local ename = GetOfflineName(edata[1]['charinfo'])
            Log('ID: ' .. src .. ' Name: ' .. pname .. ' Paid ' .. ename .. ' $' .. amount .. ' From ' .. GetJob(Player) .. '!', 'bonus')
    else
        local ename = GetName(Employee)
        if not  PayoutBonuses(GetJob(Player), amount, 'Bonus Paid') then Notifys('You Cant Afford This', 'error') return end
        if GetJob(Player) == GetJob(Employee) then
                Employee.Functions.AddMoney('bank', amount)
                Log('ID: ' .. src .. ' Name: ' .. pname .. ' Paid $' .. amount .. ' In a Bonus To ' .. ename, 'bonus')
                TriggerClientEvent('md-bossmenu:client:Result', Employee.PlayerData.source, 'paid', GetJob(Player), amount)
            return true, ename, amount, GetJob(Player)
        end
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

lib.callback.register('md-bossmenu:server:sendBills', function(source, data, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Billed = QBCore.Functions.GetPlayer(tonumber(data.playerId))
    if Billed == nil then Notifys('You Cant Bill An Offline Person', 'error') return end
    local commission = Config.Commissions[GetJob(Player)] or Config.DefaultCommission
    local sum = math.floor(data.amount * commission + 0.5)
    if GetName(Player) == GetName(Billed) then Notifys('You Cant Bill Yourself', 'error') return false end
    if GetJob(Player) == GetJob(Billed) and not IsBoss(Player) then Notifys('Why You Billing Your Own People Nerd', 'error') return end
    if Billed.Functions.RemoveMoney('bank', data.amount) or Billed.Functions.RemoveMoney('cash', data.amount) then
        Notifys(GetName(Billed) .. ' Paid Their Bill Of $' .. data.amount .. '!', 'success')
        Player.Functions.AddMoney('bank', sum)
        AddBillMoney(GetJob(Player), data.amount - sum, data.reason)
        MySQL.insert('INSERT INTO mdbossmenu_billings SET cid = ?, job = ?, amount = ?, biller = ?, billed = ?, reason = ?, time = ?', { Player.PlayerData.citizenid, GetJob(Player), data.amount, GetName(Player), GetName(Billed), data.reason, os.time()})
        Log('ID: ' .. src .. ' Name: ' .. GetName(Player) .. ' Billed ' .. GetName(Billed) .. ' $' .. data.amount .. ' For The ' .. GetJob(Player) .. ' For ' .. data.reason .. '!', 'billing')
        TriggerClientEvent('md-bossmenu:client:Result', Billed.PlayerData.source, 'billed', GetJob(Player), data.amount)
        local logs = MySQL.query.await('SELECT * FROM mdbossmenu_billings WHERE job = ? ORDER BY id DESC LIMIT 50', {GetJob(Player)})
        return true, GetName(Billed), logs
    else 
        return false, GetName(Billed)
    end
end)

lib.callback.register('md-bossmenu:server:getBillingLogs', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local logs = MySQL.query.await('SELECT * FROM mdbossmenu_billings WHERE job = ? ORDER BY id DESC LIMIT 50', {GetJob(Player)})
    
    for _, log in ipairs(logs) do
        log.created_at = os.date("!%Y-%m-%dT%H:%M:%SZ", log.created_at)
    end
    
    return logs
end)
lib.callback.register('md-bossmenu:server:stashcheck', function(source, name, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local ped = GetPlayerPed(src)
    if Config.Locations[GetJob(Player)] == nil then Notifys('Your job doesnt have stashes set up', 'error') return false end
    if #(GetEntityCoords(ped) - Config.Locations[GetJob(Player)].loc) > 4.0 then 
        return false
    else
        return true end
end)

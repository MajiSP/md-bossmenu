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

    if Player.PlayerData.job.isboss then 
        if Player.PlayerData.job.name == Employee.PlayerData.job.name then  end
        if not Employee then print('not valid') return end
        if Employee.PlayerData.job.isboss then Notifys('You Cant Fire Someone Else Who is A Boss', 'error') return end
        if Employee.Functions.SetJob("unemployed", '0') then 
            Notifys('You Fired '.. ename.firstname .. ' ' .. ename.lastname .. '!' , 'success') 
            Log('ID: ' .. src .. ' ' .. pname.firstname .. ' ' .. pname.lastname .. ' Fired ' .. ename.firstname .. ' ' .. ename.lastname .. ' From ' .. Player.PlayerData.job.name .. '!', 'fire')
            return true, Employee.PlayerData.charinfo end 
    end
end)
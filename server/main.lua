local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('bossmenu:server:GetEmployees')
AddEventHandler('bossmenu:server:GetEmployees', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.isboss then
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
        TriggerClientEvent('bossmenu:client:RefreshEmployees', src, employees, grades, salaries)
    end
end)

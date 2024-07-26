local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('bossmenu:server:GetEmployees')
AddEventHandler('bossmenu:server:GetEmployees', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.isboss then
        local employees = {}
        local players = QBCore.Functions.GetQBPlayers()
        for _, v in pairs(players) do
            if v.PlayerData.job.name == Player.PlayerData.job.name then
                table.insert(employees, {
                    id = v.PlayerData.citizenid,
                    name = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname,
                    grade = v.PlayerData.job.grade.name,
                    salary = v.PlayerData.job.payment
                })
            end
        end
        TriggerClientEvent('bossmenu:client:RefreshEmployees', src, employees)
    end
end)

local QBCore = exports['qb-core']:GetCoreObject()
local notify = Config.Notify -- qb or ox
local logs = false 
local logapi = ''
local endpoint = 'https://api.fivemerr.com/v1/logs'
local headers = {
            ['Authorization'] = logapi,
            ['Content-Type'] = 'application/json',
    }

CreateThread(function()
if logs then 
    print'^2 Logs Enabled for md-bossmenu'
    if logapi == 'insert string here' then 
        print'^1 homie you gotta set your api on line 4'
    else
        print'^2 API Key Looks Good, Dont Trust Me Though, Im Not Smart'
    end
else
    print'^1 logs disabled for md-bossmenu'
end
end)

function Log(message, type)
if logs == false then return end	
    local buffer = {
        level = "info",
        message = message,
        resource = GetCurrentResourceName(),
        metadata = {
            meta = type,
            playerid = source
        }
    }
     SetTimeout(500, function()
         PerformHttpRequest(endpoint, function(status, _, _, response)
             if status ~= 200 then 
                 if type(response) == 'string' then
                     response = json.decode(response) or response
                 end
             end
         end, 'POST', json.encode(buffer), headers)
         buffer = nil
     end)
end

function Notifys(text, type)
    if notify == 'qb' then
        TriggerClientEvent("QBCore:Notify", source, text, type)
    elseif notify == 'ox' then
        lib.notify(source, { title = text, type = type})
    elseif notify == 'okok' then
        TriggerClientEvent('okokNotify:Alert', source, '', text, 4000, type, false)
    else
        print"dude, it literally tells you what to put in the config"    
    end    
end    

function GetName(player)
    local Player = player
    local name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    return name
 end

 function GetOfflineName(table)
    local name = json.decode(table)
    return name.firstname .. ' ' .. name.lastname
 end
 
 function GetJob(Player)
    return Player.PlayerData.job.name
 end

 function IsBoss(Player)
    if Player.PlayerData.job.isboss then
        return true
    else
        return false
    end
end

function GetID(Player)
    return Player.PlayerData.citizenid
end

local QBCore = exports['qb-core']:GetCoreObject()
local notifytype = Config.Notify 

function Notify(text, type)
	if notifytype =='ox' then
	  lib.notify({title = text, type = type})
        elseif notifytype == 'qb' then
	  QBCore.Functions.Notify(text, type)
	elseif notifytype == 'okok' then
	  exports['okokNotify']:Alert('', text, 4000, type, false)
	else 
       	print"dude, it literally tells you what you need to set it as in the config"
    end   
end

function OpenStash(type, job, id)
	local job = QBCore.Functions.GetPlayerData().job.name
    local id = QBCore.Functions.GetPlayerData().citizenid
	local stash, jobc, idc = lib.callback.await('md-bossmenu:server:stashes', false, type)
	if type ~= stash then return false end
	if job ~=jobc then return false end
	if id ~= idc then return false end
	TriggerServerEvent('openStash', stash)
	if stash == 'personal' then
		if GetResourceState('ps-inventory') == 'started' then 
			if Config.OldQB then 
				TriggerEvent("ps-inventory:client:SetCurrentStash", jobc .. '|' .. idc)
				TriggerServerEvent("ps-inventory:server:OpenInventory", "stash", jobc .. '|' .. idc, {
					maxweight = 100000,
					slots = 50,
				})
			else
				TriggerServerEvent('md-bossmenu:server:OpenStashes', jobc .. '|' .. idc)
			end
		elseif GetResourceState('qb-inventory') == 'started' then
			if Config.OldQB then 
				TriggerEvent("qb-inventory:client:SetCurrentStash", jobc .. '|' .. idc)
				TriggerServerEvent("qb-inventory:server:OpenInventory", "stash", jobc .. '|' .. idc, {
					maxweight = 100000,
					slots = 50,
				})
			else
				TriggerServerEvent('md-bossmenu:server:OpenStashes', jobc .. '|' .. idc)
			end
		elseif GetResourceState('lj-inventory') == 'started' then
			TriggerEvent("inventory:client:SetCurrentStash", jobc .. '|' .. idc)
				TriggerServerEvent("inventory:server:OpenInventory", "stash", jobc .. '|' .. idc, {
					maxweight = 100000,
					slots = 50,
				})
		elseif GetResourceState('ox_inventory') == 'started' then 
			local registered = lib.callback.await('md-bossmenu:server:oxstash', false, jobc .. '|' .. idc)
			exports.ox_inventory:openInventory('stash', {id = registered})
		end
	elseif stash == 'shared' then 
		if GetResourceState('ps-inventory') == 'started' then 
			if Config.OldQB then 
				TriggerEvent("ps-inventory:client:SetCurrentStash", jobc .. '|Shared')
				TriggerServerEvent("ps-inventory:server:OpenInventory", "stash", jobc .. '|Shared', {
					maxweight = 100000,
					slots = 50,
				})
			else
				TriggerServerEvent('md-bossmenu:server:OpenStashes', jobc .. '|Shared')
			end
		elseif GetResourceState('qb-inventory') == 'started' then
			if Config.OldQB then 
				TriggerEvent("qb-inventory:client:SetCurrentStash", jobc .. '|Shared')
				TriggerServerEvent("qb-inventory:server:OpenInventory", "stash", jobc .. '|Shared', {
					maxweight = 100000,
					slots = 50,
				})
			else
				TriggerServerEvent('md-bossmenu:server:OpenStashes', jobc .. '|Shared')
			end
		elseif GetResourceState('lj-inventory') == 'started' then
			TriggerEvent("inventory:client:SetCurrentStash", jobc .. '|Shared')
				TriggerServerEvent("inventory:server:OpenInventory", "stash", jobc .. '|Shared', {
					maxweight = 100000,
					slots = 50,
				})
		elseif GetResourceState('ox_inventory') == 'started' then 
			local registered = lib.callback.await('md-bossmenu:server:oxstash', false, jobc .. '|Shared')
			exports.ox_inventory:openInventory('stash', {id = registered})
		end
	elseif stash == 'boss' then 
		if GetResourceState('ps-inventory') == 'started' then 
			if Config.OldQB then 
				TriggerEvent("ps-inventory:client:SetCurrentStash", jobc .. '| Boss')
				TriggerServerEvent("ps-inventory:server:OpenInventory", "stash", jobc .. '| Boss', {
					maxweight = 100000,
					slots = 50,
				})
			else
				TriggerServerEvent('md-bossmenu:server:OpenStashes', jobc .. '| Boss')
			end
		elseif GetResourceState('qb-inventory') == 'started' then
			if Config.OldQB then 
				TriggerEvent("qb-inventory:client:SetCurrentStash", jobc .. '| Boss')
				TriggerServerEvent("qb-inventory:server:OpenInventory", "stash",jobc .. '| Boss', {
					maxweight = 100000,
					slots = 50,
				})
			else
				TriggerServerEvent('md-bossmenu:server:OpenStashes', jobc .. '| Boss')
			end
		elseif GetResourceState('lj-inventory') == 'started' then
			TriggerEvent("inventory:client:SetCurrentStash", jobc .. '| Boss')
				TriggerServerEvent("inventory:server:OpenInventory", "stash",jobc .. '| Boss', {
					maxweight = 100000,
					slots = 50,
				})
		elseif GetResourceState('ox_inventory') == 'started' then 
			local registered = lib.callback.await('md-bossmenu:server:oxstash', false, jobc .. '| Boss')
			exports.ox_inventory:openInventory('stash', {id = registered})
		end
	else
		Notify('You Cant Open This ', 'error')
	end
end
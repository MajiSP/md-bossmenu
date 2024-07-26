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

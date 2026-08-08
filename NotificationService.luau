--!strict
local Notifications = require(script.Notifications)

local NotificationService = {}

NotificationService.itemsInQueue = 0
NotificationService.notificationQueue = {}::{[string]:typeof(Notifications.new("" , function()
	
end))}




function NotificationService.pushNotificationObject(id:string, overrideFunction:(()->string)?)
	if NotificationService.notificationQueue[id] then 
		NotificationService.notificationQueue[id]:incrementComponent()
		return
	end
	NotificationService.itemsInQueue += 1
	if NotificationService.itemsInQueue > 1 then
		for _, v in NotificationService.notificationQueue do
			v:shiftUp()
		end
		task.wait(.2)
	end
	NotificationService.notificationQueue[id] = Notifications.new(id, NotificationService.onRemovingNotificationCallBack, overrideFunction):init()
end


function NotificationService.clearNotifications(animation)
	for _, v in NotificationService.notificationQueue do
		if not animation then
			v:destroy()
		else
			task.spawn(function()
				v:close()
			end)
		end
	end
	table.clear(NotificationService.notificationQueue)
end


-- private methods -- 

function NotificationService.onRemovingNotificationCallBack(id:string)
	NotificationService.notificationQueue[id] = nil
	NotificationService.itemsInQueue -= 1
end





return NotificationService

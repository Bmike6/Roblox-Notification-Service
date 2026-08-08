--!strict

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local EasingStyles = require(script.Parent.Parent.Parent.Visuals.EasingStyles)

export type Notification = {
	-- fields --
	amount:number,
	notificationID:string,
	clock:number,
	onRemoveCallBack:(notificationID:string)->(),
	notificationUiComponent:Frame,
	clockConnection:RBXScriptConnection,
	overrideTextFunction:(()->string)?,
	
	-- methods --
	new:(id:string)->Notification,
	addUiComponent:(self:Notification)->(),
	init:(self:Notification)->Notification,
	display:(self:Notification)->(),
	shiftUp:(self:Notification)->(),
	incrementComponent:(self:Notification)->(),
	close:(self:Notification)->(),
	destroy:(self:Notification)->(),
}

const NOTIFICATION_SIZE = UDim2.fromScale(.7,.075)
const NOTIFICATION_SHIFT_AMOUNT = UDim2.fromScale(0, .1)
const NOTIFICATION_START_POSITION = UDim2.fromScale(.5,.2)
const NOTIFICATION_START_CLOCK_TIME = 4
const NOTIFICATION_TEXT_SIZE = 35
const NOTIFICATION_DISPLAY_TIME = .2
const NOTIFICATION_SHIFT_TIME = .35
const NOTIFICATION_CLOSE_TIME = .3

local Notifications = {}
Notifications.__index = Notifications

Notifications.representations = {
	testNotification = "This is a test notification for testing!" ,
	testNotification2 = "TSL is the biggest noob known to the world! JK JK",
}::{[string]:string}



function Notifications.new(id:string, onRemovingCallBack:(notificationID:string)->(), overrideFunction:(()->string)?):Notification
	if not Notifications.representations[id] then warn("Invalid noti ID") end
	local self = {}
	self.amount = 1
	self.notificationID = id
	self.onRemoveCallBack = onRemovingCallBack
	self.clock = NOTIFICATION_START_CLOCK_TIME
	self.overrideTextFunction = overrideFunction
	
	return setmetatable(self, Notifications)::Notification
end


function Notifications.destroy(self:Notification)
	self.notificationUiComponent:Destroy()
	-- rbx gc will clean up the rest nothing else we can do /:
end

function Notifications.display(self:Notification)
	local _runserviceConnection
	local alpha = 0
	local runningTime = 0
	
	self.notificationUiComponent.Size = UDim2.fromScale(0,NOTIFICATION_SIZE.Y.Scale)
	self.notificationUiComponent.Parent = (((game.Players.LocalPlayer::Player):FindFirstChild("PlayerGui")::StarterGui)):FindFirstChild("NotificationLayer")
	
	_runserviceConnection = RunService.Heartbeat:Connect(function(delta)
		runningTime += delta
		alpha = math.clamp(runningTime/NOTIFICATION_DISPLAY_TIME, 0, 1)
		if alpha >= 1 and _runserviceConnection then
			_runserviceConnection:Disconnect()
		end
		self.notificationUiComponent.Size = UDim2.fromScale(0,NOTIFICATION_SIZE.Y.Scale):Lerp(NOTIFICATION_SIZE, EasingStyles.Quad.Out(alpha))	
	end)
end

function Notifications.close(self:Notification)
	local _runserviceConnection
	local alpha = 0
	local runningTime = 0	
	_runserviceConnection = RunService.Heartbeat:Connect(function(delta)
		runningTime += delta
		alpha = math.clamp(runningTime/NOTIFICATION_CLOSE_TIME, 0, 1)
		if (alpha >= 1 and _runserviceConnection) or (not self.notificationUiComponent or not self.notificationUiComponent.Parent) and _runserviceConnection then
			_runserviceConnection:Disconnect()
		end
		self.notificationUiComponent.Size = NOTIFICATION_SIZE:Lerp(UDim2.fromScale(0, NOTIFICATION_SIZE.Y.Scale), EasingStyles.Quad.Out(alpha))
	end)
	task.wait(NOTIFICATION_CLOSE_TIME)
	self:destroy()
end

function Notifications.shiftUp(self:Notification)
	local _runserviceConnection
	local alpha = 0
	local runningTime = 0
	local startPosition = self.notificationUiComponent.Position

	_runserviceConnection = RunService.Heartbeat:Connect(function(delta)
		runningTime += delta
		alpha = math.clamp(runningTime/NOTIFICATION_SHIFT_TIME, 0, 1)
		if alpha >= 1 and _runserviceConnection then
			_runserviceConnection:Disconnect()
		end
		self.notificationUiComponent.Position = startPosition:Lerp(startPosition-NOTIFICATION_SHIFT_AMOUNT, EasingStyles.Quad.Out(alpha))	
	end)
end

function Notifications.incrementComponent(self:Notification)
	self.amount += 1
	if self.overrideTextFunction then
		(self.notificationUiComponent:FindFirstChild("TextLabel")::TextLabel).Text = self.overrideTextFunction().." x"..self.amount
	else
		(self.notificationUiComponent:FindFirstChild("TextLabel")::TextLabel).Text = Notifications.representations[self.notificationID].." x"..self.amount
	end
end

function Notifications.init(self:Notification)
	self.clockConnection = RunService.Heartbeat:Connect(function(delta)
		if self.clock <= 0 then 
			self.clockConnection:Disconnect()
			self:close()
			self.onRemoveCallBack(self.notificationID)
		end
		self.clock -= delta
	end)
	self:addUiComponent()
	self:display()
	return self
end

function Notifications.addUiComponent(self:Notification)
	local BackFrame = Instance.new("Frame")
	local Gradient = Instance.new("UIGradient")
	local NotificationText = Instance.new("TextLabel")
	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = 2.5
	NotificationText.BackgroundTransparency = 1
	NotificationText.Size = UDim2.fromScale(1,1)
	NotificationText.Font = Enum.Font.FredokaOne
	NotificationText.TextColor3 = Color3.fromRGB(0,255,0)
	NotificationText.TextSize = NOTIFICATION_TEXT_SIZE
	
	if self.overrideTextFunction then
		NotificationText.Text = self.overrideTextFunction()
	else
		NotificationText.Text = Notifications.representations[self.notificationID]
	end


	NotificationText.Parent = BackFrame
	Stroke.Parent = NotificationText

	BackFrame.AnchorPoint = Vector2.new(.5,.5)
	BackFrame.ClipsDescendants = true
	BackFrame.Position = NOTIFICATION_START_POSITION
	BackFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
	Gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,1,0),
		NumberSequenceKeypoint.new(.5, .5,0),
		NumberSequenceKeypoint.new(1, 1,0),
	})
	BackFrame.Size = NOTIFICATION_SIZE
	Gradient.Parent = BackFrame
	self.notificationUiComponent = BackFrame
end

-- possible methods --

function Notifications.shiftDown(self:Notification)

end

return Notifications

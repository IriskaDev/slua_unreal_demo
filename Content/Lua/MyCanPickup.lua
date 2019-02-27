local Common = require ("Common")
local Dispatcher = require ("Dispatcher")
local InventoryData = require ("InventoryData")
local Events = require ("Events")

local mt = {}

function mt:OnConstruct()
    self["StaticMesh"]:SetStaticMesh(self["CustomMesh"])
end

function mt:ReceiveBeginPlay()
    self:OnConstruct()

    Common.InitPickup(self)
    self["PickupTextWidget"]:SetAlignmentInViewport(FVector2D(0.5, 0.5))
    Dispatcher.AddListener(Events.EVT_ITEM_PICKUP, self.BePickedup, self)
end

function mt:ReceiveEndPlay()
    Dispatcher.RemoveListener(Events.EVT_ITEM_PICKUP, self.BePickedup, self)
end

function mt:Tick()
    local textWidget = self["PickupTextWidget"]
    local controller = Common.GetMyController(self)
    local location = self:K2_GetActorLocation() + FVector(0.0, 0.0, 50.0)
    local vector2 = FVector2D()
    local result, screenLocation = controller:ProjectWorldLocationToScreen(location, vector2, false)
    local visibility = UEnums.ESlateVisibility.Visible
    if not result then
        visibility = UEnums.ESlateVisibility.Hidden
    end

    textWidget:SetVisibility(visibility)
    textWidget:SetPositionInViewport(screenLocation, true)
end

function mt:ReceiveActorBeginOverlap(otherActor)
	if not otherActor or not otherActor.Name == "MainCharacter" then
		return
	end

	self["PickupTextWidget"]:AddToViewport(0)
	self["IsInRange"] = true
end

function mt:ReceiveActorEndOverlap(otherActor)
	if not otherActor or not otherActor.Name == "MainCharacter" then
		return
	end

	self["PickupTextWidget"]:RemoveFromParent()
	self["IsInRange"] = false
end

function mt:BePickedup(picker)
	if not self:GetActorEnableCollision() or not self["IsInRange"] then
		return
	end

	InventoryData.AddItem(self)
	self["PickupTextWidget"]:RemoveFromParent()
	self:SetActorHiddenInGame(true)
	self:SetActorEnableCollision(false)
end

function mt:Use()
	local character = self["MyCharacter"]
    Dispatcher.Dispatch(Events.EVT_CHARACTER_HEALTH_VALUE_MODIFY, character["HealthValue"] + self["AddHealth"])
    Dispatcher.Dispatch(Events.EVT_CHARACTER_ENERGY_VALUE_MODIFY, character["EnergyValue"] + self["AddEnergy"])
    Dispatcher.Dispatch(Events.EVT_CHARACTER_MOOD_VALUE_MODIFY, character["MoodValue"] + self["AddMood"])

	-- InventoryData.RemoveItem(self)
	self:K2_DestroyActor()
end

return mt

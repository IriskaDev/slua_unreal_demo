local Common = require("Common")
local InventoryData = require ("InventoryData")
local Dispatcher = require ("Dispatcher")
local Events = require ("Events")
local hud = {}


function hud:Init(character)
    local ui = slua.loadUI("WidgetBlueprint'/Game/UMG/GameHUD.GameHUD'")
    ui:AddToViewport(0)
    self.ui = ui
    local slots = {}
    local handlers = {}
    local str_connector = {"InventorySlot_C_", 0}
    local concat = table.concat
    for i=0, 4 do
        str_connector[2] = i
        local slot = ui[concat(str_connector)]
        local idx = i + 1
        slots[idx] = slot
        local handler = slot["InventoryButton"].OnClicked:Add(function ()
            self:OnSlotClicked(idx)
        end)
        handlers[idx] = {handler=handler, delegate=slot["InventoryButton"].OnClicked}
    end
    ui["MyCharacter"] = character
    self.slots = slots
    self.handlers = handlers

    local onUseHandler = self.ui["UseButton"].OnClicked:Add(function ()
        self:OnUse()
    end)
    local onDropHandler = self.ui["DropButton"].OnClicked:Add(function () 
        self:OnDrop()
    end)
    local onCancelHandler = self.ui["CancelButton"].OnClicked:Add(function ()
        self:OnCancel()
    end)

    table.insert(handlers, {handler=onUseHandler, delegate=self.ui["UseButton"].OnClicked})
    table.insert(handlers, {handler=onDropHandler, delegate=self.ui["DropButton"].OnClicked})
    table.insert(handlers, {handler=onCancelHandler, delegate=self.ui["CancelButton"].OnClicked})


    Dispatcher.AddListener(Events.EVT_INVENTORY_UPDATED, self.RefreshInventory, self)

    self:RefreshInventory()
    return ui
end

function hud:Destroy()
    Dispatcher.RemoveListener(Events.EVT_INVENTORY_UPDATED, self.RefreshInventory)
    for _, v in pairs(self.handlers) do
        v.delegate:Remove(v.handler)
    end
end

function hud:RefreshInventory()
    print ("On Refresh")
    local slots = self.slots
    local widgetBpLib = import "WidgetBlueprintLibrary"
    for i=1, InventoryData.CAPACITY do
        local slot = slots[i]
        local item = InventoryData.GetItem(i)
        if not item then
            slot["DispalyedImage"]:SetBrush(widgetBpLib.MakeBrushFromTexture(nil, 32, 32))
        else
            slot["DispalyedImage"]:SetBrush(widgetBpLib.MakeBrushFromTexture(item["InventoryImage"], 32, 32))
        end
    end
end

function hud:OnSlotClicked(idx)
    print (string.format("On %d Clicked", idx))
    local item = InventoryData.GetItem(idx)
    if not item then
        return
    end

    self.itemIdx = idx

    self.ui["InventoryActive"] = false
    self.ui["ActionText"] = item.ActionText
    self.ui["ActionMenu"]:SetVisibility(UEnums.ESlateVisibility.Visible)
end

function hud:OnUse()
    local item = InventoryData.GetItem(self.itemIdx)
    InventoryData.RemoveItem(item)
    item:Use()

    self:OnCancel()
end

function hud:OnDrop()
    -- print ("ondrop")
    local item = InventoryData.GetItem(self.itemIdx)
    InventoryData.RemoveItem(item)
    item:SetActorHiddenInGame(false)
    item:SetActorEnableCollision(true)
    local character = self.ui["MyCharacter"]
    local transform = character["DropLocation"]:K2_GetComponentToWorld()
    item:K2_SetActorTransform(transform, false, nil, false)

    self:OnCancel()
end

function hud:OnCancel()
    self.ui["InventoryActive"] = true
    self.ui["ActionMenu"]:SetVisibility(UEnums.ESlateVisibility.Hidden)
end

function hud:SetHealth(val)
    self.ui["ProgressBar_0"]:SetPercent(val)
end

function hud:SetEnergy(val)
    self.ui["ProgressBar_1"]:SetPercent(val)
end

function hud:SetMood(val)
    self.ui["ProgressBar_2"]:SetPercent(val)
end

return hud
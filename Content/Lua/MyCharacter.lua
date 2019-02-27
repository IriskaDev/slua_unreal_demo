local Common                    = require ("Common")
local Dispatcher                = require ("Dispatcher")
local Events                    = require ("Events")
local InventoryData             = require ("InventoryData")

local mt = {}

local threshole = 0.0000000000001
local abs = math.abs

function mt:ReceiveBeginPlay()
    self:OnConstruction()
    self.bCanEverTick = true
    self.bUsingMotionController = true
    self:LoadHUD()
    self:HMDSetup()
    self.fBaseTurnRate = 45.0
    self.fBaseLookupRate = 45.0
    self.openMenu = false
    self.fpCamera = nil
    self.vGunOffset = FVector(100, 0, -10)
    self.name = "MainCharacter"

    Dispatcher.AddListener(Events.EVT_CHARACTER_HEALTH_VALUE_MODIFY, self.SetHealth, self)
    Dispatcher.AddListener(Events.EVT_CHARACTER_ENERGY_VALUE_MODIFY, self.SetEnergy, self)
    Dispatcher.AddListener(Events.EVT_CHARACTER_MOOD_VALUE_MODIFY, self.SetMood, self)
end

function mt:ReceiveEndPlay()
    self.hud:Destroy()
    if self.timer then
        CppInterface.ClearTimer(self.timer)
        self.timer = nil
    end

    Dispatcher.RemoveListener(Events.EVT_CHARACTER_HEALTH_VALUE_MODIFY, self.SetHealth)
    Dispatcher.RemoveListener(Events.EVT_CHARACTER_ENERGY_VALUE_MODIFY, self.SetEnergy)
    Dispatcher.RemoveListener(Events.EVT_CHARACTER_MOOD_VALUE_MODIFY, self.SetMood)
end

function mt:Tick(dt)
    -- print ("Delta Time: ", dt)
    -- local pos = self:K2_GetActorLocation()
end

function mt:OnConstruction()
    self["FP_Gun"]:K2_AttachToComponent(self["Mesh2P"], "GripPoint", 
        UEnums.EAttachmentRule.SnapToTarget,
        UEnums.EAttachmentRule.SnapToTarget,
        UEnums.EAttachmentRule.SnapToTarget,
        true)
end

function mt:LoadHUD()
    self.hud = require ("MyGameHUD")
    self["GameHUDWidget"] = self.hud:Init(self)
    self.hud:SetHealth(self["HealthValue"])
    self.hud:SetEnergy(self["EnergyValue"])
    self.hud:SetMood(self["MoodValue"])
end

function mt:HMDSetup()
    self.bUseControllerRotationYaw = true
    local enabled = self:GetHMD().IsHeadMountedDisplayEnabled()
    if not enabled then
        return
    end
    self.bUseControllerRotationYaw = false
    if not self.bUsingMotionController then
        return
    end

    local mesh2P = self["Mesh2P"]
    mesh2P:SetHiddenInGame(true, true)
    local vrGun = self["VR_Gun"]
    vrGun:SetHiddenInGame(false, false)
end

function mt:GetHMD()
    if not self.HMD then
        self.HMD = import "HeadMountedDisplayFunctionLibrary"
    end
    return self.HMD
end

function mt:GetGameplayStatics()
    if not self.gamePlayStatics then
        self.gamePlayStatics = import "GameplayStatics"
    end
    return self.gamePlayStatics
end

function mt:GetForwardVector()
    local enabled = self:GetHMD().IsHeadMountedDisplayEnabled()
    local forward
    if not enabled then
        forward = self:GetActorForwardVector()
    else
        forward = self["FirstPersonCamera"]:GetForwardVector()
    end
    return forward
end

function mt:GetRightVector()
    local enabled = self:GetHMD().IsHeadMountedDisplayEnabled()
    local right
    if not enabled then
        right = self:GetActorRightVector()
    else
        right = self["FirstPersonCamera"]:GetRightVector()
    end
    return right
end

function mt:InpAxisEvt_LookUpRate_K2Node_InputAxisEvent_62(val)
    if self.openMenu then
        return
    end
    if abs(val) <= threshole then
        return
    end
    local dt = self:GetGameplayStatics().GetWorldDeltaSeconds(self:GetWorld())
    local yaw = val * dt * self.fBaseLookupRate
    self:AddControllerYawInput(yaw)
end

function mt:InpAxisEvt_TurnRate_K2Node_InputAxisEvent_34(val)
    if self.openMenu then
        return 
    end
    if abs(val) <= threshole then
        return
    end
    local dt = self:GetGameplayStatics().GetWorldDeltaSeconds(self:GetWorld())
    local pitch = val * dt * self.fBaseTurnRate
    self:AddControllerPitchInput(pitch)
end

function mt:InpAxisEvt_Turn_K2Node_InputAxisEvent_157(val)
    if self.openMenu then
        return
    end
    if abs(val) <= threshole then
        return 
    end
    self:AddControllerYawInput(val)
end

function mt:InpAxisEvt_LookUp_K2Node_InputAxisEvent_172(val)
    if self.openMenu then
        return
    end
    if abs(val) <= threshole then
        return 
    end
    self:AddControllerPitchInput(val)
end

function mt:InpAxisEvt_MoveForward_K2Node_InputAxisEvent_181(val)
    if self.openMenu then
        return 
    end
    if abs(val) <= threshole then
        return
    end
    local forward = self:GetForwardVector()
    self:AddMovementInput(forward, val, false)
end

function mt:InpAxisEvt_MoveRight_K2Node_InputAxisEvent_192(val)
    if self.openMenu then
        return 
    end
    if abs(val) < threshole then
        return 
    end
    local right = self:GetRightVector()
    self:AddMovementInput(right, val, false)
end

-- function mt:InpActEvt_Fire_K2Node_InputActionEvent_1()
-- end

function mt:Fire()
    if self.openMenu then
        return
    end

    local projectile = slua.loadClass("Blueprint'/Game/FirstPersonBP/Blueprints/FirstPersonProjectile.FirstPersonProjectile'")
    local mesh2P = self["Mesh2P"]
    mesh2P:GetAnimInstance():Montage_Play(self["AnimFire"],1.0, UEnums.EMontagePlayReturnType.MontageLength, 0, true);
    local location, rotation = self:GetProjectileSpawnTransform()
    local ball = self:GetWorld():SpawnActor(projectile, location, rotation, nil)
    self:GetGameplayStatics().PlaySoundAtLocation(self:GetWorld(), self["SoundFire"], self:K2_GetActorLocation(), FRotator(0,0,0),1,1,0,nil,nil,nil)
end

function mt:GetProjectileSpawnTransform()
    if self["UsingMotionControllers?"] then
        return self["VR_Marker"]:K2_GetComponentLocation(), self["VR_Marker"]:K2_GetComponentRotation()
    end

    kismetMath = import "KismetMathLibrary"
    local fpCamera = self["FirstPersonCamera"]
    local worldRotation = fpCamera:K2_GetComponentRotation()
    local v = kismetMath.GreaterGreater_VectorRotator(self.vGunOffset, worldRotation)
    local location = v + self["Sphere"]:K2_GetComponentLocation()
    return location, worldRotation
end

function mt:OnJump()
    if self.openMenu then
        return
    end
    self:Jump()
    self:SetEnergy(self["EnergyValue"] - 0.05)
end

function mt:OnStopJump()
    self:StopJumping()
end

function mt:OnPickup()
    if false then
        return
    end

    local itemCnt = InventoryData.GetCurrenyItemCount()
    if itemCnt >= InventoryData.CAPACITY then
        return
    end

    Dispatcher.Dispatch(Events.EVT_ITEM_PICKUP, self)
end

function mt:OnInventory()
    if self.openMenu then
        self:CloseInventory()
    else
        self:OpenInventory()
    end
end

function mt:OpenInventory()
    if self.timer then
        CppInterface.ClearTimer(self.timer)
        self.timer = nil
    end

    self.openMenu = true
    self["GameHUDWidget"]["InventoryMenu"]:SetVisibility(UEnums.ESlateVisibility.Visible)
    self:EnableMouseCursor()
    self["GameHUDWidget"]:PlayAnimation(self["GameHUDWidget"]["InventoryIn"], 
        0.0, 1, 0, 1.0)
end

function mt:CloseInventory()
    self.openMenu = false
    self:DisableMouseCursor()
    self["GameHUDWidget"]:PlayAnimation(self["GameHUDWidget"]["InventoryOut"],
        0.0, 1, 0, 1.0)

    if self.timer then
        CppInterface.ClearTimer(self.timer)
        self.timer = nil
    end

    local delay = function ()
        self["GameHUDWidget"]["InventoryMenu"]:SetVisibility(UEnums.ESlateVisibility.Hidden)
        CppInterface.ClearTimer(self.timer)
        self.timer = nil
    end

    self.timer = CppInterface.SetTimer(1.5, false, delay)
end

function mt:EnableMouseCursor()
    local controller = Common.GetMyController(self)
    controller.bShowMouseCursor = true
    local ahud = controller:GetHUD()
    ahud["ShowCrosshairs"] = false
end

function mt:DisableMouseCursor()
    local controller = Common.GetMyController(self)
    controller.bShowMouseCursor = false
    local ahud = controller:GetHUD()
    ahud["ShowCrosshairs"] = true
end

function mt:SetHealth(val)
    self["HealthValue"] = val
    self.hud:SetHealth(val)
end

function mt:SetEnergy(val)
    self["EnergyValue"] = val
    self.hud:SetEnergy(val)
end

function mt:SetMood(val)
    self["MoodValue"] = val
    self.hud:SetMood(val)
end

return mt

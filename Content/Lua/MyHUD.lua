

local hud = {}

function hud:ReceiveDrawHUD(sizeX, sizeY)
    if self:GetHMD().IsHeadMountedDisplayEnabled() then
        return
    end

    local halfX = math.floor(sizeX / 2)
    local halfY = math.floor(sizeY / 2)
    local halfY = halfY + 20

    local color = FLinearColor()
    color.R = 1.0
    color.G = 1.0
    color.B = 1.0
    color.A = 1.0
    self:DrawTexture(self["CrossTexture"], halfX, halfY, 16.0, 16.0, 0.0, 0.0, 1.0, 1.0, 
        color, UEnums.EBlendMode.BLEND_Translucent, 1.0, true, 0.0, FVector2D(0.0, 0.0))
end

function hud:GetHMD()
    if not self.HMD then
        self.HMD = import "HeadMountedDisplayFunctionLibrary"
    end
    return self.HMD
end

return hud


local mt = {}

function mt:ReceiveBeginPlay()
    self.bCanEverTick = true
end

function mt:ReceiveHit(myComp, other, otherComp, selfMoved, hitLocation, hitNormal, normalImpulse, hit)
    if not otherComp:IsSimulatingPhysics("None") then
        return
    end

    local impulse = self:GetVelocity() * 1000
    local location = self:K2_GetActorLocation()

    otherComp:AddImpulseAtLocation(impulse, location, "None")

    self:K2_DestroyActor()
end

return mt

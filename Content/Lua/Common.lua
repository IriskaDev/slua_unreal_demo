

local common = {}
Common = common

function Common.Test()
    print ("Common test")
end

function Common.InitPickup(tbl)
    tbl.bCanEverTick = true
    tbl["PickupTextWidget"] = slua.loadUI("WidgetBlueprint'/Game/UMG/PickupText.PickupText'")
    -- tbl["PickupTextWidget"]["PickupActor"] = tbl["ItemInfo"].Item
    tbl["PickupTextWidget"]["PickupText"] = tbl.PickupText
    -- tbl["ItemInfo"].Item = tbl
    local gameplay = import "GameplayStatics"
    tbl["MyCharacter"] = gameplay.GetPlayerCharacter(tbl:GetWorld(), 0)
end

function Common.GetMyCharacter(tbl)
    local gameplay = import "GameplayStatics"
    return gameplay.GetPlayerCharacter(tbl:GetWorld(), 0)
end

function Common.GetMyController(tbl)
    local gameplay = import "GameplayStatics"
    return gameplay.GetPlayerController(tbl:GetWorld(), 0)
end

return common


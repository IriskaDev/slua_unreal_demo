local Common = require ("Common")
local Dispatcher = require ("Dispatcher")
local Events = require ("Events")
local fire = {}

function fire:ReceiveBeginPlay()
    self["ChildActor"]:Activate(false)
    self["MyCharacter"] = Common.GetMyCharacter(self)
    local delaystart = function ()
        local loop = function ()
            self:IncMood()
        end
        self.loopTimer = CppInterface.SetTimer(1.5, true, loop)
        self:ClearTimerByName("delaystartTimer")
    end
    self.delaystartTimer = CppInterface.SetTimer(2.0, false, delaystart)

    local destroy = function ()
        self["ChildActor"]:Deactivate()
        self:K2_DestroyActor()
        self:ClearTimerByName("destroyTimer")
    end

    self.destroyTimer = CppInterface.SetTimer(20.0, false, destroy)
end

function fire:ClearTimerByName(timername)
    if self[timername] then
        CppInterface.ClearTimer(self[timername])
        self[timername] = nil
    end
end

function fire:ReceiveEndPlay()
    self:ClearTimerByName("delaystartTimer")
    self:ClearTimerByName("loopTimer")
    self:ClearTimerByName("destroyTimer")
end

function fire:IncMood()
    if not self["IsInRange"] then
        return
    end

    local mood = self["MyCharacter"]["MoodValue"] + 0.05
    mood = mood > 1.0 and 1.0 or mood
    mood = mood < 0.0 and 0.0 or mood
    Dispatcher.Dispatch(Events.EVT_CHARACTER_MOOD_VALUE_MODIFY, mood)
end

function fire:ReceiveActorBeginOverlap(otherActor)
    if not otherActor or not otherActor.Name == "MainCharacter" then
        return
    end

    self["IsInRange"] = true
end

function fire:ReceiveActorEndOverlap(otherActor)
    if not otherActor or not otherActor.Name == "MainCharacter" then
        return
    end

    self["IsInRange"] = false
end

return fire
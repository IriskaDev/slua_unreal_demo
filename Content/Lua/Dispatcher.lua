
local dispatcher = {}
Dispatcher = dispatcher

local eventMap = {}

function dispatcher.AddListener(evt, listener, ...)
    local funcs = eventMap[evt]
    if not funcs then
        funcs = {}
        eventMap[evt] = funcs
    end

    local id = tostring(listener)
    if funcs[id] then
        -- event duplicated
        return
    end

    local t = {}
    t.event = evt
    t.func = listener
    t.argsLen = select('#', ...)
    t.args = {...}
    funcs[id] = t
end

function dispatcher.RemoveListener(evt, listener)
    local funcs = eventMap[evt]
    if not funcs then
        return
    end

    local id = tostring(listener)
    if not funcs[id] then
        return
    end
    funcs[id] = nil
end

function dispatcher.Dispatch(evt, ...)
    local funcs = eventMap[evt]
    if not funcs then
        return
    end

    local args = {...}
    local argsLen = select ('#', ...)
    for _, v in pairs(funcs) do
        local evtArgs = {}
        local argsCnt = 0
        local presetArgs = v.args
        for i=1, v.argsLen do
            table.insert(evtArgs, presetArgs[i])
        end
        for i=1, argsLen do
            table.insert(evtArgs, args[i])
        end
        v.func(table.unpack(evtArgs, 1, argsLen + v.argsLen))
    end
end

return dispatcher
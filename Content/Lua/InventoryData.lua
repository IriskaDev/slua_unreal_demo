local Dispatcher = require ("Dispatcher")
local Events = require ("Events")

local data = {}
InventoryData = data

data.inventory = {}
data.CAPACITY = 5

function data.GetCurrenyItemCount()
    local cnt = 0
    for _, v in pairs (data.inventory) do
        cnt = cnt + 1
    end
    return cnt
end

function data.AddItem(item)
    local inventory = data.inventory
    local idx = 0
    for i=1,data.CAPACITY do
        if not inventory[i] then
            idx = i
            break
        end
    end
    if idx == 0 then
        print ("No empty slot")
        return
    end

    inventory[idx] = item
    print (string.format("Item <%s> Added", tostring(item)))
    Dispatcher.Dispatch(Events.EVT_INVENTORY_UPDATED)
end

function data.RemoveItem(item)
    local inventory = data.inventory
    for i=1, data.CAPACITY do
        if inventory[i] == item then
            inventory[i] = nil
            break
        end
    end
    Dispatcher.Dispatch(Events.EVT_INVENTORY_UPDATED)
end

function data.GetItem(idx)
    return data.inventory[idx]
end

return data

local config = require 'config.server'

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    exports.ox_inventory:RegisterShop('vapeStore', {
        name = config.shopConfig.name,
        inventory = config.shopConfig.items
    })
end)

exports('useVape', function(event, _, inventory, _, _)
    if event == 'usedItem' then
        TriggerEvent("InteractSound_SV:PlayWithinDistance", inventory.player.source, 5.0, "vaping", 0.3)
        lib.callback.await('randol:client:useVape', false, inventory.player.source)
    end
end)

lib.callback.register('randol_vape:server:syncSmoke', function(_, pedNet, pos)
    for _, v in pairs(GetPlayers()) do
		TriggerClientEvent("randol_vape:client:syncSmoke", v, pedNet, pos)
        return true
    end

    return false
end)

RegisterNetEvent("randol_vape:server:syncSmoke", function(pedNet, pos)
	for _, v in pairs(GetPlayers()) do
		TriggerClientEvent("randol_vape:client:syncSmoke", v, pedNet, pos)
    end
end)

RegisterNetEvent('randol_vape:server:makeVape', function()
    local src = source

    local metadata = { durability = 0 }
    exports.ox_inventory:RemoveItem(src, 'electronickit', 1)
    exports.ox_inventory:RemoveItem(src, 'steel', 2)
    exports.ox_inventory:RemoveItem(src, 'glass', 2)
    exports.ox_inventory:AddItem(src, 'vape', 1, metadata)
end)

local durabilityincrease = 20

exports.ox_inventory:registerHook('swapItems', function(payload)
    if payload.action ~= 'swap' or payload.fromInventory ~= payload.toInventory then return true end
    if not payload.source or payload.source ~= payload.toInventory then return end

    local item = payload.fromSlot
    local item2 = payload.toSlot

    if item2.name == 'vape' and item.name == 'vapejuice' then
        local meta = item2.metadata
        local durability = meta?.durability or 0

        if durability + durabilityincrease > 100 then return true end

        SetTimeout(10, function()
            durability = durability + durabilityincrease

            local success = exports.ox_inventory:RemoveItem(payload.fromInventory, item.name, 1, item.metadata, item.slot)

            if success then
                exports.ox_inventory:SetDurability(payload.fromInventory, item2.slot, durability)
            end
        end)

        return false
    end
end, {
    itemFilter = {
        vapejuice = true,
        vape = true
    }
})
local qbCore = exports['qb-core']:GetCoreObject()
local playerState = LocalPlayer.state
local vapeClouds = nil

lib.callback.register('randol_vape:client:useVape', function()
	local pos, pedNet = GetEntityCoords(cache.ped), PedToNet(cache.ped)

	if qbCore.Functions.GetPlayerData().metadata.isdead then return end

	if playerState.isVaping then
		return lib.notify({
            title = 'Vape Status',
            description = 'You already took a hit!',
            type = 'error',
            duration = 7500,
            icon = 'fas fa-smoking'
        })
	end

	if lib.progressCircle({
		label = 'Puffing Vape...',
		duration = 7500,
		useWhileDead = false,
		canCancel = true,
		disable = { combat = true },
		anim = { dict = "amb@world_human_smoking@male@male_b@base", clip = "base", flag = 49 },
		prop = { model = 'ba_prop_battle_vape_01', bone = 28422, pos = vec3(-0.0290, 0.0070, -0.0050), rot = vec3(91.0, 270.0, -360.0) }
	}) then
		local isSynced = lib.callback.await('randol_vape:server:syncSmoke', false, pedNet, pos)
		if isSynced then
			playerState.isVaping = true
			SetTimeout(10000, function()
				playerState.isVaping = false

                lib.notify({
                    title = 'Vape Status',
                    description = 'You\'re feeling extra good!',
                    type = 'success',
                    duration = 7500,
                    icon = 'fas fa-smoking'
                })

				TriggerServerEvent('hud:server:RelieveStress', math.random(5, 25))
			end)
		end
	end
end)

RegisterNetEvent("randol_vape:client:syncSmoke", function(netPed, pos)
	local plyPos = GetEntityCoords(cache.ped)
	local pedNet = NetToPed(netPed)

	if #(plyPos - pos) < 150.0 then
		lib.requestNamedPtfxAsset('core')
		SetPtfxAssetNextCall("core")
		vapeClouds = StartParticleFxLoopedOnEntityBone("exp_grd_bzgas_smoke", pedNet, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetPedBoneIndex(pedNet, 20279), 0.5, false, false, false)
		SetParticleFxLoopedAlpha(vapeClouds, 1.0) -- Not sure if this actually makes it more visible?
		SetTimeout(5000, function()
			StopParticleFxLooped(vapeClouds, false)
			RemoveParticleFxFromEntity(pedNet)
			RemoveParticleFx("exp_grd_bzgas_smoke", true)
		end)
	end
end)

local function CraftVape()
	local materials = exports.ox_inventory:Search('count', {'steel', 'glass', 'electronickit'})
	if not materials then return end

	if materials.steel < 2 or materials.glass < 2 or materials.electronickit < 1 then
        return lib.notify({
            title = 'Smoke On The Water',
            description = 'You don\'t have enough materials!',
            type = 'error',
            duration = 7500,
            icon = 'fas fa-cannabis'
        })
    end

	if lib.progressCircle({
		duration = 5000,
		label = "Crafting a vape..",
		position = 'bottom',
		useWhileDead = false,
		canCancel = false,
		disable = { move = true, combat = true },
		anim = { dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", clip = "machinic_loop_mechandplayer", flag = 49 }
	}) then
		TriggerServerEvent('randol_vape:server:makeVape')
	end
end

local function OpenCraft()
    lib.registerContext({
		id = 'randol_craft_vape',
		title = 'Craft Station',
		options = {
			{
				title = "Craft Vape",
				description = "Requires:  \n2x Steel | 2x Glass | 1x Electronic Kit",
				icon = "fa-solid fa-square-up-right",
				onSelect = CraftVape
			},
		}
    })
	lib.showContext('randol_craft_vape')
end

local Renewed = exports['Renewed-Lib']:getLib()

local function VapeCraft()
	Renewed.addPed({
		model = 'a_m_m_hillbilly_02',
		dist = 25,
		coords = vector3(-1169.061, -1573.205, 3.664),
		heading = 126.668,
		scenario = 'WORLD_HUMAN_SMOKING_POT',
		freeze = true,
		invincible = true,
		tempevents = true,
		id = 'randol_vape_ped',

		target = {
			{
				icon = "fa-solid fa-screwdriver",
				label = "Craft Station",
				onSelect = OpenCraft,
				canInteract = function(_, distance)
					return distance <= 1.5
				end
			},
			{
				icon = "fa-solid fa-basket-shopping",
				label = "Vape Store",
				onSelect = function()
                    exports.ox_inventory:openInventory('shop', 'vapeStore')
				end,
				canInteract = function(_, distance)
					return distance <= 1.5
				end
			},
		}
	})
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    VapeCraft()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    VapeCraft()
end)
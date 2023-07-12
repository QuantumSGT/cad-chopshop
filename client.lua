-- Locals
local QBCore = exports["qb-core"]:GetCoreObject()

local HotVehPlate = nil
local HotVehModel = nil
local ChopShop = Config.ChopShopLocations
local ChopShopPed = Config.ChopShopPeds
local chopTable = nil

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	TriggerServerEvent("cad-chopshop:clientjoined")
end)

RegisterNetEvent('cad-chopshop:notifyOwner', function(x, y, z, randomVeh, currentplate)
	HotVehModel = randomVeh
	HotVehPlate = currentplate
	local streetName, crossingRoad = GetStreetNameAtCoord(x, y, z)
	local street = string.format('%s - %s', GetStreetNameFromHashKey(streetName), GetStreetNameFromHashKey(crossingRoad))
	local zone = GetLabelText(GetNameOfZone(x, y, z))
	chopTable = vector2(x, y)
	PlaySoundFrontend( -1, "Start_Squelch", "CB_RADIO_SFX", 0)
	randomVeh = randomVeh:gsub("^%l", string.upper)
	TriggerEvent('chat:addMessage', {
        template = '<div class="chat-message twitch"><i class="fas fa-car"></i> <b><span style="color: #7d7d7d">{0}</span>&nbsp;</b><div style="margin-top: 5px; font-weight: 300;">{1}</div></div>',
        args = { "Chopshop", "Hot vehicle " .. randomVeh .. " available at " .. zone .. " on " .. street .. " with plate number: " .. HotVehPlate }
    })
end)

RegisterNetEvent('cad-chopshop:informClients', function()
	HotVehPlate = nil
	HotVehModel = nil
	PlaySoundFrontend( -1, "End_Squelch", "CB_RADIO_SFX", 0)
	TriggerEvent('chat:addMessage', {
        template = '<div class="chat-message twitch"><i class="fas fa-car"></i> <b><span style="color: #7d7d7d">{0}</span>&nbsp;</b><div style="margin-top: 5px; font-weight: 300;">{1}</div></div>',
        args = { "Chopshop", "The hot vehicle is no longer needed. Wait for another hot vehicle" }
	})
end)

RegisterNetEvent('cad-chopshop:HowToMsg', function()
	QBCore.Functions.Notify("Bring the hot vehicle in front me and you will know.", 'success', 5000)
	if chopTable then
		SetNewWaypoint(chopTable.x, chopTable.y)
	end
end)

-- Functions

function ShowHelpNotification(msg, thisFrame, beep, duration)
	AddTextEntry('QBHelpNotification', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('QBHelpNotification', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('QBHelpNotification')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end

-- Threads

CreateThread(function()
	for _, data in pairs(ChopShopPed) do
		exports['qb-target']:SpawnPed({
			model = 'g_m_y_mexgoon_03',
			coords = vector4(data.x, data.y, data.z, data.w),
			minusOne = true,
			freeze = true,
			invincible = true,
			blockevents = true,
			scenario = 'WORLD_HUMAN_SMOKING',
			options = {
				{
					type = "client",
					event = "cad-chopshop:HowToMsg",
					icon = 'fa fa-clipboard',
					label = 'Chopshop'
				}
			},
			spawnNow = true,
			distance = 1.5,
		})
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		local inRange = false
		local pPed = PlayerPedId()
		local plyCoords = GetEntityCoords(pPed)
		local isInChopRange = false
		for _, coord in pairs(ChopShop) do
			local distance = #(plyCoords-vector3(coord.x, coord.y, coord.z))
			if distance < 4 then
				if IsPedInAnyVehicle(pPed, true) then
					isInChopRange = true
					inRange = true
				end
			end
		end
		if isInChopRange then
			local pVehicle = GetVehiclePedIsIn(pPed, false)
			local pSeat = (GetPedInVehicleSeat(pVehicle, -1) == pPed)
			local pVehModel = GetDisplayNameFromVehicleModel(GetEntityModel(pVehicle))
			local pPlate = GetVehicleNumberPlateText(pVehicle)
			ShowHelpNotification("Press ~INPUT_CONTEXT~ to chop the vehicle", true, true, 10000)
			if IsControlJustReleased(0, 46) and pSeat then
				if (pPlate == HotVehPlate) or (pVehModel:lower() == HotVehModel) then
					SetVehicleDoorsLocked(pVehicle, 2)
					SetVehicleEngineOn(pVehicle, false, false, true)
					SetVehicleUndriveable(pVehicle, false)
					SetVehicleDoorOpen(pVehicle, 0, false, true)
					Wait(1000)
					TriggerEvent('InteractSound_CL:PlayOnOne', 'chop', 0.4)
					SetVehicleDoorBroken(pVehicle, 0, false)
					Wait(1000)
					SetVehicleDoorOpen(pVehicle, 1, false, true)
					Wait(1000)
					TriggerEvent('InteractSound_CL:PlayOnOne', 'chop', 0.4)
					SetVehicleDoorBroken(pVehicle, 1, false)
					Wait(1000)
					SetVehicleDoorOpen(pVehicle, 2, false, true)
					Wait(1000)
					TriggerEvent('InteractSound_CL:PlayOnOne', 'chop', 0.4)
					SetVehicleDoorBroken(pVehicle, 2, false)
					Wait(1000)
					SetVehicleDoorOpen(pVehicle, 3, false, true)
					Wait(1000)
					TriggerEvent('InteractSound_CL:PlayOnOne', 'chop', 0.4)
					SetVehicleDoorBroken(pVehicle, 3, false)
					Wait(1000)
					SetVehicleDoorOpen(pVehicle, 4, false, true)
					Wait(1000)
					TriggerEvent('InteractSound_CL:PlayOnOne', 'chop', 0.4)
					SetVehicleDoorBroken(pVehicle, 4, false)
					Wait(1000)
					SetVehicleDoorOpen(pVehicle, 5, false, true)
					Wait(1000)
					TriggerEvent('InteractSound_CL:PlayOnOne', 'chop', 0.4)
					SetVehicleDoorBroken(pVehicle, 5, false)
					SetEntityAsMissionEntity(pVehicle, true, true)
					DeleteEntity(pVehicle)
					if DoesEntityExist(pVehicle) then DeleteEntity(pVehicle) end
					Wait(math.random(500, 2000))
					local chance = math.random()
					if chance < 0.15 then
						TriggerServerEvent('cad-chopshop:recievereward', "rare1")
					elseif chance > 0.85 then
						TriggerServerEvent('cad-chopshop:recievereward', "rare2")
					else
						TriggerServerEvent('cad-chopshop:recievereward', "normal")
					end
					QBCore.Functions.Notify('The vehicle has been chopped', 'error')
					TriggerServerEvent('cad-chopshop:vehicleChopped')
					HotVehPlate = nil
					HotVehModel = nil
				else
					QBCore.Functions.Notify('This is not the hot vehicle', 'error')
				end
			end
		end
		if not inRange then
			Wait(1000) --  1secs
		end
	end
end)

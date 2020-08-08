ESX	= nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if PlayerData.job ~= nil and PlayerData.job.name == 'mechanic' then		
			local playerPed = GetPlayerPed(-1)
			local coords = GetEntityCoords(playerPed)
			
			for k,v in pairs(Config.Zones) do
				for i = 1, #v.Pos, 1 do
					if(GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < 1.5 and IsPedSittingInAnyVehicle(playerPed)) then
						DrawTxt(_U('change_plate') .. ' (' .. Config.Price .. '$)')
						if IsControlJustPressed(1,51) then 
							CustomVehiclePlate()
						end	
					end
				end
			end
		end
	end
end)

function CustomVehiclePlate()
	local playerPed = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	local vehiclePlate = GetVehicleNumberPlateText(vehicle)
	
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'vehicleplatechanger',{
        title = (_U('menu_title'))
    },
    function(data, menu)
        local desiredPlate = data.value
        if desiredPlate == nil then
            ESX.ShowAdvancedNotification('Mécanicien', 'Changement de plaque', _U('nil_plate'), 'CHAR_CARSITE2', 1, false, true, 140)
		elseif string.len(desiredPlate) > 7 then
			ESX.ShowAdvancedNotification('Mécanicien', 'Changement de plaque', _U('plate_length'), 'CHAR_CARSITE2', 1, false, true, 140)
        else
            menu.close()						
			ESX.TriggerServerCallback('esx_vehicleplatechanger:isPlateAvailable', function(isPlateAvailable)						
				if isPlateAvailable then				
					ESX.TriggerServerCallback('esx_vehicleplatechanger:changeVehiclePlate', function(isPlateChanged)						
						if isPlateChanged then
							ESX.ShowAdvancedNotification('Mécanicien', 'Changement de plaque', _U('plate_done'), 'CHAR_CARSITE2', 1, false, true, 140)
							ESX.ShowAdvancedNotification('Mécanicien', 'Changement de plaque', _U('plate_done2'), 'CHAR_CARSITE2', 1, false, true, 140)
							SetVehicleNumberPlateText(vehicle, desiredPlate)
						else
							ESX.ShowAdvancedNotification('Mécanicien', 'Changement de plaque', _U('plate_error'), 'CHAR_CARSITE2', 1, false, true, 140)
						end
					end, string.upper(desiredPlate), vehiclePlate)
				else
					ESX.ShowAdvancedNotification('Mécanicien', 'Changement de plaque', _U('plate_not_available'), 'CHAR_CARSITE2', 1, false, true, 140)
				end
			end, string.upper(desiredPlate))
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

function DrawTxt(text)
	SetTextComponentFormat('STRING')
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
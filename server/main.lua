ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_vehicleplatechanger:isPlateAvailable', function(source, cb, plate)
	isPlateAvailable = true
    MySQL.Async.fetchAll(
      "SELECT plate FROM owned_vehicles WHERE plate = @plate",
	  { ['@plate'] = plate },
      function (results)
		if results[1] ~= nil then
			if results[1].plate == plate then
				isPlateAvailable = false
			end	
		end
        cb(isPlateAvailable)
      end
    )
end)

ESX.RegisterServerCallback('esx_vehicleplatechanger:changeVehiclePlate', function(source, cb, plate, oldPlate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local plate = plate
	local oldPlate = oldPlate:sub(1, -2)
	local isPlateUpdated = false
	--print('nouvelle plaque : ' .. plate .. ' ancienne plaque : ' .. oldPlate)
	
	MySQL.Async.fetchAll(
      "SELECT REPLACE(vehicle, @oldPlate, @plate) as vehicleUpdated FROM owned_vehicles WHERE plate = @oldPlate AND owner = @identifier",
	  { ['@plate'] = plate, ['@oldPlate'] = oldPlate, ['@identifier'] = xPlayer.identifier },
      function (results)
		if results[1] ~= nil then
			local updatedVehicle = results[1].vehicleUpdated
			local societyAccount
			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
				societyAccount = account
			end)

			if Config.Price < societyAccount.money then
				societyAccount.removeMoney(Config.Price)
				MySQL.Async.execute("UPDATE owned_vehicles SET vehicle= @updatedVehicle, plate = @plate WHERE plate=@oldPlate AND owner = @identifier",
				{ ['@plate'] = plate, ['@oldPlate'] = oldPlate, ['@identifier'] = xPlayer.identifier, ['@updatedVehicle'] = updatedVehicle },
				function()
					isPlateUpdated = true
					cb(isPlateUpdated)
				end)
			else
				TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'Mécanicien', 'Changement de plaque', _U('not_enough_money'), 'CHAR_CARSITE2', 1, false, true, 140)
			end
		else
			TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, 'Mécanicien', 'Changement de plaque', _U('plate_error'), 'CHAR_CARSITE2', 1, false, true, 140)
		end
      end
    )
end)
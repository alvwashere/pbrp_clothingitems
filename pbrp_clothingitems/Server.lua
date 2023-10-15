local ClothesList = {}

function RegisterClothes()
	for i = 1, #Config do
		ESX.RegisterUsableItem(Config[i].itemName, function(source)
			local xPlayer = ESX.GetPlayerFromId(source)

			xPlayer.removeInventoryItem(Config[i].itemName, 1)
			TriggerClientEvent('pbrpClothingItems', source, i, Config[i].label)
			updateClothes(Config[i].itemName, source)
		end)
	end
end

Citizen.CreateThread(function()
	RegisterClothes()
	readClothes()
end)

readClothes = function() MySQL.Async.fetchAll('SELECT * FROM users', {}, function(result) for k, v in pairs(result) do if v.clothes then ClothesList[v.identifier] = v.clothes end end end) end 

updateClothes = function(outfit, src)
	local xPlayer = ESX.GetPlayerFromId(src)

	local ident = xPlayer.identifier
	if ClothesList[ident] then xPlayer.addInventoryItem(ClothesList[ident], 1) end
	ClothesList[ident] = outfit
	MySQL.Async.execute('UPDATE users SET clothes = @clothes WHERE identifier = @identifier', {
		['clothes'] = outfit,
		['identifier'] = ident,
	})
end

ESX.RegisterServerCallback('pbrpClothingItems:GetClothes', function(source, cb)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(ClothesList[xPlayer.identifier])
end)

RegisterCommand('deleteoutfit', function(source, args)
	local xPlayer = ESX.GetPlayerFromId(source)
	local ident = xPlayer.identifier
	if ClothesList[ident] then
		ClothesList[ident] = nil
		MySQL.Async.execute('UPDATE users SET clothes = NULL WHERE identifier = @identifier', {
			['identifier'] = ident,
		})
	end
end)

RegisterCommand('changeback', function(source, args)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local ident = xPlayer.identifier
	if ClothesList[ident] then
  		xPlayer.addInventoryItem(ClothesList[ident], 1)
  		Citizen.Wait(100)
		ClothesList[ident] = nil
  		Citizen.Wait(100)
		MySQL.Async.execute('UPDATE users SET clothes = NULL WHERE identifier = @identifier', {
			['identifier'] = ident,
		})
		Citizen.Wait(100)
        TriggerClientEvent("illenium-appearance:client:reloadSkin", source)
	end
end)

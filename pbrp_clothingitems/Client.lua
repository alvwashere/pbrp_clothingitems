RegisterNetEvent('esx:playerLoaded', function(playerData)
	LocalPlayer.state:set('isLoggedIn', true, true)
end)

updateClothing = function()
	local playerPed = PlayerPedId()
	ESX.TriggerServerCallback('pbrpClothingItems:GetClothes', function(outfitname) 
		for i = 1, #Config do 
			if Config[i].itemName == outfitname then 
				for k, v in pairs(Config[i].set) do 
					SetPedComponentVariation(playerPed, v.c1, v.c2, v.c3, 0) 
				end 
			end 
		end 
	end)
end

RegisterNetEvent('pbrpClothingItems')
AddEventHandler('pbrpClothingItems', function(number, label)
	local playerPed = PlayerPedId()
	for k, v in pairs(Config[number].set) do SetPedComponentVariation(playerPed, v.c1, v.c2, v.c3, 0) end
	ESX.ShowNotification("You've put on " .. label, 'success', 1500)
end)

Citizen.CreateThread(function()
	Wait(5000)
	while not LocalPlayer.state['isLoggedIn'] do
		Wait(1000)
	end
	Wait(2000) 
	updateClothing()
end)

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

vehiclemodel = 'komoda' --model of the car 
itemname = 'freecar' -- item name


ESX.RegisterUsableItem(itemname, function(source)
    TriggerEvent('jkr_freecar', source)
end)


RegisterNetEvent('jkr_freecar')
AddEventHandler('jkr_freecar', function()
    local src = source --check who uses the item
    local model = vehiclemodel
	local xPlayer = ESX.GetPlayerFromId(src)
    local pos = GetEntityCoords(GetPlayerPed(src))

    local plate = "FRE " .. math.random(100, 999) -- plate of the car
    
    MySQL.Async.fetchScalar('SELECT plate FROM owned_vehicles WHERE plate=@plate', { --- cheack data base if the plate already exist
        ['@plate'] = plate
    }, function(plateExists)
        if plateExists then
            repeat
                plate = "FRE " .. math.random(100, 999)
                MySQL.Async.fetchScalar('SELECT plate FROM owned_vehicles WHERE plate=@plate', {
                    ['@plate'] = plate
                }, function(plateTaken)
                    plateExists = plateTaken
                end)
            until not plateExists
        end
        
        local vehicle = CreateVehicle(model, pos, true, true)-- it will spawn the vehicle in player location
        SetPedIntoVehicle(GetPlayerPed(src), vehicle, -1) -- it will teleport the player to the spawn vehicle
        SetVehicleNumberPlateText(vehicle, plate) --set the vehicle plate
		
        --makes the car own who ever uses the item
        MySQL.update('INSERT INTO owned_vehicles (owner, plate, vehicle, type, job, category, name, image) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {xPlayer.identifier, plate, json.encode({model = GetHashKey(model), plate = plate}), 'car', 'civ', 'sports', 'Komoda', 'https://wiki.rage.mp/images/thumb/4/47/Komoda.png/800px-Komoda.png'}, function(rowsChanged)
       ---message
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {'Server', 'You now own this vehicle with plate ' .. plate}
            })
        end)
    end)
end)
local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-vineyard:server:getGrapes', function()
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = math.random(Config.GrapeAmount.min, Config.GrapeAmount.max)
    Player.Functions.AddItem("grape", amount)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['grape'], "add")
end)

QBCore.Functions.CreateCallback('qb-vineyard:server:loadIngredients', function(source, cb)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local grape = Player.Functions.GetItemByName('grapejuice')
	if not Player.PlayerData.items then
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = Lang:t("error.no_items")})
        cb(false)
        return
    end
    if not grape or grape.amount < 23 then
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = Lang:t("error.invalid_items")})
        cb(false)
        return
    end
    Player.Functions.RemoveItem("grapejuice", 23, false)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['grapejuice'], "remove")
    cb(true)
end)

QBCore.Functions.CreateCallback('qb-vineyard:server:grapeJuice', function(source, cb)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local grape = Player.Functions.GetItemByName('grape')
	if not Player.PlayerData.items then
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = Lang:t("error.no_items")})
        cb(false)
    end
    if not grape or grape.amount < 16 then
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = Lang:t("error.invalid_items")})
        cb(false)
    end
    Player.Functions.RemoveItem("grape", 16, false)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['grape'], "remove")
    cb(true)
end)

RegisterNetEvent('qb-vineyard:server:receiveWine', function()
	local Player = QBCore.Functions.GetPlayer(tonumber(source))
    local amount = math.random(Config.WineAmount.min, Config.WineAmount.max)
	Player.Functions.AddItem("wine", amount, false)
	TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['wine'], "add")
end)

RegisterNetEvent('qb-vineyard:server:receiveGrapeJuice', function()
	local Player = QBCore.Functions.GetPlayer(tonumber(source))
    local amount = math.random(Config.GrapeJuiceAmount.min, Config.GrapeJuiceAmount.max)
	Player.Functions.AddItem("grapejuice", amount, false)
	TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['grapejuice'], "add")
end)

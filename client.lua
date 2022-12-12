local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}
local startZones = {}
local grapeZones = {}
local wineZones = {}
local juiceZones = {}

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
	QBCore.Functions.GetPlayerData(function(PlayerData)
		PlayerJob = PlayerData.job
	end)
end)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

local tasking = false
local startVineyard = false
local random = 0
local pickedGrapes = 0
local blip = 0
local winetimer = Config.wineTimer
local grapeLocations = Config.grapeLocations
local loadIngredients = false
local wineStarted = false
local finishedWine = false

local function log(debugMessage)
	print(('^6[^3qb-vineyard^6]^0 %s'):format(debugMessage))
end

local function CreateBlip()
	if tasking then
		blip = AddBlipForCoord(grapeLocations[random].x,grapeLocations[random].y,grapeLocations[random].z)
	end
    SetBlipSprite(blip, 465)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drop Off")
    EndTextCommandSetBlipName(blip)
end

local function nextTask()
	if tasking then return end
	random = math.random(#grapeLocations)
	tasking = true
	CreateBlip()
end

local function getVineyard(totalGrapes)
	if not tasking then return 5000 end
	nextTask()
	pickedGrapes = pickedGrapes + 1
	if pickedGrapes ~= totalGrapes then return 5 end
	nextTask()
	startVineyard = false
	pickedGrapes = 0
	lib.notify({description= {Lang:t("text.end_shift")}, type = "inform"})
	return 20000
end

local function startVinyard()
	local amount = math.random(Config.PickAmount.min, Config.PickAmount.max)
	lib.notify({description= {Lang:t("text.start_shift")}, type = "inform"})
	while startVineyard do
		Wait(getVineyard(amount))
	end
end

local function DeleteBlip()
	if not DoesBlipExist(blip) then return end
	RemoveBlip(blip)
end

local function pickProcess()
	if lib.progressCircle({label = Lang:t("progress.pick_grapes"), duration = math.random(6000,8000), canCancel = true, disable = {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	},}
	) then
		tasking = false
        TriggerServerEvent("qb-vineyard:server:getGrapes")
		DeleteBlip()
	else
		lib.notify({description= {Lang:t("task.cancel_task")}, type = "error"})
	end
	ClearPedTasks(PlayerPedId())
end

local function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(1)
    end
end

local function PickAnim()
    local ped = PlayerPedId()
    LoadAnim('amb@prop_human_bum_bin@idle_a')
    TaskPlayAnim(ped, 'amb@prop_human_bum_bin@idle_a', 'idle_a', 6.0, -6.0, -1, 47, 0, 0, 0, 0)
end

local function exitZone(self)
	if not Config.Debug then return end
	lib.notify({description= {Lang:t("text.zone_exited", self.id)}, type = "inform"})
end

local function enterZone(self)
	if not Config.Debug then return end
	lib.notify({description= {Lang:t("text.zone_entered", self.id)}, type = "inform"})
end

local function insideGrapeZone()
	exports['qb-core']:DrawText(Lang:t("task.start_task"),'right')
	if not IsPedInAnyVehicle(PlayerPedId()) and IsControlJustReleased(0,38) then
		PickAnim()
		pickProcess()
		exports['qb-core']:HideText()
		random = 0
	end
end


grapeZones = lib.zones.poly({
	points = grapeLocations,
	thickness = 2,
	debug = Config.Debug,
	onExit = exitZone(),
	onEnter = enterZone(),
	inside = function()
		CreateThread(function()
			while true do
				insideGrapeZone()
				Wait(1)
				grapeZones:remove()
			end
		end)
	end
})

local function StartWineProcess()
    CreateThread(function()
        wineStarted = true
        while winetimer > 0 do
            winetimer = winetimer - 1
            Wait(1000)
		end
		wineStarted = false
		finishedWine = true
		winetimer = Config.wineTimer
    end)
end


local function PrepareAnim()
    local ped = PlayerPedId()
    LoadAnim('amb@code_human_wander_rain@male_a@base')
    TaskPlayAnim(ped, 'amb@code_human_wander_rain@male_a@base', 'static', 6.0, -6.0, -1, 47, 0, 0, 0, 0)
end

local function grapeJuiceProcess()
	if lib.progressCircle({label = Lang:t("progress.process_grapes"), duration = math.random(15000,20000), canCancel = true, disable = {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	},}) then
		TriggerServerEvent("qb-vineyard:server:receiveGrapeJuice")
	else
		lib.notify({description= {Lang:t("task.cancel_task")}, type = "error"})
	end
	ClearPedTasks(PlayerPedId())
end

local function insideStartZone()
	if not IsControlJustReleased(0,38) or startVineyard then return end
	startVineyard = true
	startVinyard()
	startZones:remove()
end

startZones = lib.zones.poly({
	points = Config.Vineyard.start.zones,
	thickness = 2,
	debug = Config.Debug,
	onExit = exitZone(),
	onEnter = enterZone(),
	inside = function()
		exports['qb-core']:DrawText(Lang:t("task.start_task"),'right')
		CreateThread(function()
			insideStartZone()
			Wait(1)
		end)
	end
})

local function workWine()
	if wineStarted then
		exports['qb-core']:DrawText(Lang:t("task.countdown", { time = winetimer }), 'right')
		Wait(1000)
		return
	end

	if loadIngredients then
		if finishedWine then
			exports['qb-core']:DrawText(Lang:t("task.get_wine"), 'right')
			if IsControlJustPressed(0, 38) and not LocalPlayer.state.inv_busy then
				TriggerServerEvent("qb-vineyard:server:receiveWine")
				finishedWine = false
				loadIngredients = false
				wineStarted = false
				wineZones:remove()
			end
			return
		end
		exports['qb-core']:DrawText(Lang:t("task.wine_process"), 'right')
		if IsControlJustPressed(0, 38) and not LocalPlayer.state.inv_busy then
			StartWineProcess()
		end
		return
	end
	exports['qb-core']:DrawText(Lang:t("task.load_ingrediants"), 'right')
	if IsControlJustPressed(0, 38) and not LocalPlayer.state.inv_busy then
		QBCore.Functions.TriggerCallback('qb-vineyard:server:loadIngredients', function(result)
			if result then loadIngredients = true end
		end)
	end
end

wineZones = lib.zones.poly({
	points = Config.Vineyard.wine.zones,
	thickness = 2,
	debug = Config.Debug,
	onExit = exitZone(),
	onEnter = enterZone(),
	inside = function()
		CreateThread(function()
			while true do
				workWine()
				Wait(1)
			end
		end)
	end
})

local function juiceWork()
	if IsControlJustPressed(0, 38) and not LocalPlayer.state.inv_busy then
		QBCore.Functions.TriggerCallback('qb-vineyard:server:grapeJuice', function(result)
			if result then PrepareAnim() grapeJuiceProcess() end
		end)
		juiceZones:remove()
		return false
	end
	return true
end

juiceZones = lib.zones.poly({
	points = Config.Vineyard.grapejuice.zones,
	thickness = 2,
	debug = Config.Debug,
	onExit = exitZone(),
	onEnter = enterZone(),
	inside = function()
		exports['qb-core']:DrawText(Lang:t("task.make_grape_juice"),'right')
		CreateThread(function()
			while juiceWork() do
				Wait(1)
			end
		end)
	end
})
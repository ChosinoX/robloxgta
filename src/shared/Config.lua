local Config = {}

Config.WorldSeed = 24051992
Config.StartingCash = 2500
Config.VehicleSpawnCooldown = 8

Config.Vehicles = {
	{ id = "comet", name = "Comet", color = Color3.fromRGB(220, 45, 45), speed = 92, acceleration = 2.8, gamePass = nil },
	{ id = "rancher", name = "Rancher", color = Color3.fromRGB(45, 105, 55), speed = 72, acceleration = 2.2, gamePass = nil },
	{ id = "taxi", name = "Downtown Taxi", color = Color3.fromRGB(245, 190, 35), speed = 78, acceleration = 2.4, gamePass = nil },
	-- Replace 0 with a published game-pass ID to make this a premium vehicle.
	{ id = "inferno", name = "Inferno GT", color = Color3.fromRGB(255, 110, 20), speed = 118, acceleration = 3.7, gamePass = 0 },
}

Config.Monetization = {
	-- IDs stay disabled until replaced with IDs from Creator Dashboard.
	CashProducts = {
		{ productId = 0, name = "$10,000", cash = 10000 },
		{ productId = 0, name = "$50,000", cash = 50000 },
	},
	VIPGamePassId = 0,
	VIPCashMultiplier = 1.5,
}

return Config

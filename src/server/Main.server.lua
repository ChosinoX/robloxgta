local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local WorldBuilder = require(script.Parent.WorldBuilder)
local VehicleService = require(script.Parent.VehicleService)
local NPCService = require(script.Parent.NPCService)

WorldBuilder.build()
local vehicles = Instance.new("Folder")
vehicles.Name = "Vehicles"
vehicles.Parent = workspace

local remotes = Instance.new("Folder")
remotes.Name = "CostaVerdeRemotes"
remotes.Parent = ReplicatedStorage
local spawnVehicle = Instance.new("RemoteEvent")
spawnVehicle.Name = "SpawnVehicle"
spawnVehicle.Parent = remotes

local cashStore = DataStoreService:GetDataStore("CostaVerdeCash_v1")
local lastSpawn = {}

local function setUpPlayer(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = Config.StartingCash
	cash.Parent = leaderstats
	local ok, saved = pcall(cashStore.GetAsync, cashStore, tostring(player.UserId))
	if ok and type(saved) == "number" then
		cash.Value = saved
	end
end

Players.PlayerAdded:Connect(setUpPlayer)
for _, player in ipairs(Players:GetPlayers()) do setUpPlayer(player) end
Players.PlayerRemoving:Connect(function(player)
	local cash = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Cash")
	if cash then pcall(cashStore.SetAsync, cashStore, tostring(player.UserId), cash.Value) end
	lastSpawn[player] = nil
end)

spawnVehicle.OnServerEvent:Connect(function(player, vehicleId)
	if typeof(vehicleId) ~= "string" or (lastSpawn[player] and os.clock() - lastSpawn[player] < Config.VehicleSpawnCooldown) then return end
	local spec = VehicleService.find(vehicleId)
	if not spec then return end
	if spec.gamePass and spec.gamePass > 0 then
		local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, spec.gamePass)
		if not ok or not owns then
			MarketplaceService:PromptGamePassPurchase(player, spec.gamePass)
			return
		end
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	lastSpawn[player] = os.clock()
	for _, old in ipairs(vehicles:GetChildren()) do
		if old:GetAttribute("OwnerUserId") == player.UserId then old:Destroy() end
	end
	VehicleService.create(spec, root.CFrame * CFrame.new(10, 2, -18), player)
end)

MarketplaceService.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
	for _, product in ipairs(Config.Monetization.CashProducts) do
		if product.productId > 0 and receipt.ProductId == product.productId then
			local cash = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Cash")
			if cash then cash.Value += product.cash end
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

NPCService.start(VehicleService)

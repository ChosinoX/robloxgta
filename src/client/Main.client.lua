local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage.Shared.Config)
local spawnVehicle = ReplicatedStorage:WaitForChild("CostaVerdeRemotes"):WaitForChild("SpawnVehicle")

local gui = Instance.new("ScreenGui")
gui.Name = "CostaVerdeHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(360, 64)
title.Position = UDim2.fromOffset(24, 22)
title.BackgroundTransparency = 1
title.Text = "COSTA VERDE\nCITY • COUNTRY • FREEDOM"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(255, 215, 72)
title.Parent = gui

local cash = Instance.new("TextLabel")
cash.Size = UDim2.fromOffset(220, 45)
cash.Position = UDim2.new(1, -244, 0, 24)
cash.BackgroundColor3 = Color3.fromRGB(17, 22, 29)
cash.BackgroundTransparency = 0.15
cash.Font = Enum.Font.GothamBold
cash.TextSize = 24
cash.TextColor3 = Color3.fromRGB(104, 239, 133)
cash.Parent = gui
Instance.new("UICorner", cash).CornerRadius = UDim.new(0, 10)

local cashValue = player:WaitForChild("leaderstats"):WaitForChild("Cash")
local function updateCash() cash.Text = string.format("$%s", cashValue.Value) end
cashValue.Changed:Connect(updateCash)
updateCash()

local open = Instance.new("TextButton")
open.Size = UDim2.fromOffset(210, 54)
open.Position = UDim2.new(0, 24, 1, -78)
open.BackgroundColor3 = Color3.fromRGB(235, 78, 51)
open.Text = "GARAGE  [G]"
open.Font = Enum.Font.GothamBlack
open.TextSize = 20
open.TextColor3 = Color3.new(1, 1, 1)
open.Parent = gui
Instance.new("UICorner", open).CornerRadius = UDim.new(0, 12)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(440, 410)
panel.Position = UDim2.new(0.5, -220, 0.5, -205)
panel.BackgroundColor3 = Color3.fromRGB(18, 23, 31)
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)

local heading = Instance.new("TextLabel")
heading.Size = UDim2.new(1, -40, 0, 65)
heading.Position = UDim2.fromOffset(20, 8)
heading.BackgroundTransparency = 1
heading.Text = "CHOOSE YOUR RIDE"
heading.Font = Enum.Font.GothamBlack
heading.TextSize = 25
heading.TextColor3 = Color3.new(1, 1, 1)
heading.Parent = panel

for index, spec in ipairs(Config.Vehicles) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -40, 0, 58)
	button.Position = UDim2.fromOffset(20, 68 + (index - 1) * 68)
	button.BackgroundColor3 = spec.color
	button.Text = string.format("%s     TOP SPEED %d", spec.name:upper(), spec.speed)
	if spec.gamePass and spec.gamePass > 0 then button.Text ..= "   ★ PREMIUM" end
	button.Font = Enum.Font.GothamBold
	button.TextSize = 17
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Parent = panel
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)
	button.Activated:Connect(function()
		spawnVehicle:FireServer(spec.id)
		panel.Visible = false
	end)
end

local shop = Instance.new("TextButton")
shop.Size = UDim2.new(1, -40, 0, 45)
shop.Position = UDim2.new(0, 20, 1, -60)
shop.BackgroundColor3 = Color3.fromRGB(49, 143, 92)
shop.Text = "GET CASH"
shop.Font = Enum.Font.GothamBold
shop.TextSize = 17
shop.TextColor3 = Color3.new(1, 1, 1)
shop.Parent = panel
Instance.new("UICorner", shop).CornerRadius = UDim.new(0, 9)
shop.Activated:Connect(function()
	local product = Config.Monetization.CashProducts[1]
	if product and product.productId > 0 then
		MarketplaceService:PromptProductPurchase(player, product.productId)
	else
		shop.Text = "ADD PRODUCT IDS IN CONFIG"
	end
end)

local function toggle()
	panel.Visible = not panel.Visible
	if panel.Visible then
		panel.Size = UDim2.fromOffset(400, 370)
		TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Back), { Size = UDim2.fromOffset(440, 410) }):Play()
	end
end
open.Activated:Connect(toggle)
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.G then toggle() end
end)

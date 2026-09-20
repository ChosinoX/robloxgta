local TweenService = game:GetService("TweenService")
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local NPCService = {}

local function pedestrian(parent, index, rng)
	local model = Instance.new("Model")
	model.Name = "Citizen"
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Anchored = true
	root.Transparency = 1
	root.Position = Vector3.new(rng:NextInteger(-620, 620), 4, rng:NextInteger(-720, 520))
	root.Parent = model
	model.PrimaryPart = root
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2, 4, 1.3)
	body.Anchored = false
	body.CanCollide = false
	body.Color = Color3.fromHSV((index * 0.13) % 1, 0.55, 0.85)
	body.CFrame = root.CFrame * CFrame.new(0, 2, 0)
	body.Parent = model
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = body
	weld.Parent = body
	model.Parent = parent

	task.spawn(function()
		while model.Parent do
			local destination = Vector3.new(rng:NextInteger(-620, 620), 4, rng:NextInteger(-720, 520))
			local distance = (destination - root.Position).Magnitude
			local tween = TweenService:Create(model.PrimaryPart, TweenInfo.new(distance / 12, Enum.EasingStyle.Linear), { CFrame = CFrame.lookAt(destination, destination + (destination - root.Position)) })
			tween:Play()
			tween.Completed:Wait()
			task.wait(rng:NextNumber(0.5, 2))
		end
	end)
end

function NPCService.start(vehicleService)
	local folder = Instance.new("Folder")
	folder.Name = "NPCs"
	folder.Parent = workspace
	local rng = Random.new(Config.WorldSeed + 10)
	for index = 1, 24 do
		pedestrian(folder, index, rng)
	end

	for index = 1, 10 do
		local spec = Config.Vehicles[(index % 3) + 1]
		local lane = -600 + ((index - 1) % 7) * 200
		local car = vehicleService.create(spec, CFrame.lookAt(Vector3.new(lane + 8, 4, -650), Vector3.new(lane + 8, 4, 0)), nil)
		car:SetAttribute("NPCThrottle", 0.55)
	end
end

return NPCService

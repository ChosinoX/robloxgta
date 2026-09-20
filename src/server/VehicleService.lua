local RunService = game:GetService("RunService")
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local VehicleService = {}
local activeControllers = {}

local function addPart(model, name, size, offset, color, material)
	local root = model.PrimaryPart
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = root.CFrame * CFrame.new(offset)
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.CanCollide = name ~= "Cabin"
	item.Massless = name ~= "Body"
	item.Parent = model
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = item
	weld.Parent = item
	return item
end

function VehicleService.create(spec, spawnCFrame, owner)
	local model = Instance.new("Model")
	model.Name = spec.name
	model:SetAttribute("OwnerUserId", owner and owner.UserId or 0)

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(7, 1.6, 12)
	body.CFrame = spawnCFrame
	body.Color = spec.color
	body.Material = Enum.Material.Metal
	body.CustomPhysicalProperties = PhysicalProperties.new(1.2, 0.5, 0.1)
	body.Parent = model
	model.PrimaryPart = body

	addPart(model, "Cabin", Vector3.new(6, 2.5, 5.5), Vector3.new(0, 2, 0.5), spec.color:Lerp(Color3.new(1, 1, 1), 0.12), Enum.Material.Glass)
	for _, offset in ipairs({ Vector3.new(-3.5, -0.4, -3.6), Vector3.new(3.5, -0.4, -3.6), Vector3.new(-3.5, -0.4, 3.6), Vector3.new(3.5, -0.4, 3.6) }) do
		local wheel = addPart(model, "Wheel", Vector3.new(1.2, 3, 3), offset, Color3.fromRGB(25, 25, 25), Enum.Material.Rubber)
		wheel.Shape = Enum.PartType.Cylinder
		wheel.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	end

	local seat = Instance.new("VehicleSeat")
	seat.Name = "DriverSeat"
	seat.Size = Vector3.new(3, 1, 3)
	seat.CFrame = body.CFrame * CFrame.new(0, 1.8, 1)
	seat.Parent = model
	local seatWeld = Instance.new("WeldConstraint")
	seatWeld.Part0 = body
	seatWeld.Part1 = seat
	seatWeld.Parent = seat

	model.Parent = workspace:FindFirstChild("Vehicles") or workspace
	body:SetNetworkOwner(nil)
	activeControllers[model] = { spec = spec, speed = 0 }
	return model
end

RunService.Heartbeat:Connect(function(dt)
	for model, controller in pairs(activeControllers) do
		if not model.Parent or not model.PrimaryPart then
			activeControllers[model] = nil
			continue
		end
		local seat = model:FindFirstChild("DriverSeat")
		local root = model.PrimaryPart
		local throttle = model:GetAttribute("NPCThrottle") or (seat and seat.ThrottleFloat or 0)
		local steer = model:GetAttribute("NPCSteer") or (seat and seat.SteerFloat or 0)
		local target = throttle * controller.spec.speed
		controller.speed += math.clamp(target - controller.speed, -controller.spec.acceleration * 25 * dt, controller.spec.acceleration * 25 * dt)
		if math.abs(throttle) < 0.05 then
			controller.speed *= math.max(0, 1 - 1.8 * dt)
		end
		local turn = steer * math.clamp(math.abs(controller.speed) / 25, 0, 1) * 1.7
		root.AssemblyLinearVelocity = root.CFrame.LookVector * controller.speed + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
		root.AssemblyAngularVelocity = Vector3.new(0, -turn * math.sign(controller.speed), 0)
	end
end)

function VehicleService.find(vehicleId)
	for _, spec in ipairs(Config.Vehicles) do
		if spec.id == vehicleId then
			return spec
		end
	end
	return nil
end

return VehicleService

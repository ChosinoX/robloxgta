local Lighting = game:GetService("Lighting")

local WorldBuilder = {}

local function part(parent, name, size, position, color, material)
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.Size = size
	item.Position = position
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function building(parent, x, z, width, depth, height, color)
	local block = part(parent, "Building", Vector3.new(width, height, depth), Vector3.new(x, height / 2 + 2, z), color, Enum.Material.Concrete)
	for floor = 1, math.floor(height / 10) do
		for _, side in ipairs({ -1, 1 }) do
			local window = part(block, "Window", Vector3.new(width * 0.55, 3.5, 0.15), Vector3.new(x, floor * 10, z + side * (depth / 2 + 0.08)), Color3.fromRGB(100, 185, 220), Enum.Material.Glass)
			window.CanCollide = false
		end
	end
end

local function tree(parent, position)
	part(parent, "Trunk", Vector3.new(2, 10, 2), position + Vector3.new(0, 5, 0), Color3.fromRGB(92, 62, 38), Enum.Material.Wood)
	local crown = part(parent, "Crown", Vector3.new(9, 9, 9), position + Vector3.new(0, 12, 0), Color3.fromRGB(45, 125, 55), Enum.Material.Grass)
	crown.Shape = Enum.PartType.Ball
end

function WorldBuilder.build()
	if workspace:FindFirstChild("CostaVerdeWorld") then
		return workspace.CostaVerdeWorld
	end

	local world = Instance.new("Folder")
	world.Name = "CostaVerdeWorld"
	world.Parent = workspace

	part(world, "Ground", Vector3.new(2200, 4, 2200), Vector3.new(0, -2, 0), Color3.fromRGB(72, 126, 63), Enum.Material.Grass)
	part(world, "Ocean", Vector3.new(2200, 3, 500), Vector3.new(0, -0.5, -1250), Color3.fromRGB(24, 110, 170), Enum.Material.Water)

	local roads = Instance.new("Folder")
	roads.Name = "Roads"
	roads.Parent = world
	for x = -600, 600, 200 do
		part(roads, "Road", Vector3.new(56, 0.6, 1300), Vector3.new(x, 1, -100), Color3.fromRGB(46, 48, 52), Enum.Material.Asphalt)
	end
	for z = -700, 500, 200 do
		part(roads, "Road", Vector3.new(1300, 0.65, 56), Vector3.new(0, 1.1, z), Color3.fromRGB(46, 48, 52), Enum.Material.Asphalt)
	end

	local city = Instance.new("Folder")
	city.Name = "City"
	city.Parent = world
	local rng = Random.new(24051992)
	for x = -500, 500, 200 do
		for z = -600, 400, 200 do
			for _, offset in ipairs({ Vector3.new(70, 0, 70), Vector3.new(-70, 0, -70) }) do
				building(city, x + offset.X, z + offset.Z, rng:NextInteger(55, 95), rng:NextInteger(55, 95), rng:NextInteger(35, 125), Color3.fromHSV(rng:NextNumber(), 0.18, rng:NextNumber(0.55, 0.85)))
			end
		end
	end

	local country = Instance.new("Folder")
	country.Name = "Countryside"
	country.Parent = world
	for index = 1, 75 do
		tree(country, Vector3.new(rng:NextInteger(720, 1030), 1, rng:NextInteger(-900, 900)))
	end
	for index = 1, 12 do
		local x = rng:NextInteger(-1050, -750)
		local z = rng:NextInteger(-900, 900)
		local mountain = part(country, "Mountain", Vector3.new(rng:NextInteger(180, 330), rng:NextInteger(220, 480), rng:NextInteger(180, 330)), Vector3.new(x, 40, z), Color3.fromRGB(85, 91, 72), Enum.Material.Rock)
		mountain.Shape = Enum.PartType.Ball
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "DowntownSpawn"
	spawn.Size = Vector3.new(16, 1, 16)
	spawn.Position = Vector3.new(0, 3, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Color = Color3.fromRGB(65, 170, 255)
	spawn.Parent = world

	Lighting.ClockTime = 16.5
	Lighting.Brightness = 2.5
	Lighting.EnvironmentDiffuseScale = 0.4
	Lighting.EnvironmentSpecularScale = 0.7
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.25
	atmosphere.Haze = 1.4
	atmosphere.Color = Color3.fromRGB(205, 225, 255)
	atmosphere.Parent = Lighting

	return world
end

return WorldBuilder

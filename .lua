--// FRUIT ESP PRO (SMART DETECTION)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local FruitList = {}
local KnownFruit = {}

-------------------------------------------------
-- FRUIT NAME CHECK (SMART)
-------------------------------------------------

local function IsFruit(obj)

	local name = obj.Name:lower()

	return name:find("fruit")
		or name:find("blox")
		or name:find("devil")
end

-------------------------------------------------
-- COLOR SYSTEM (RARITY STYLE)
-------------------------------------------------

local function GetFruitColor(name)

	name = name:lower()

	if name:find("dragon") or name:find("leopard") or name:find("kitsune") then
		return Color3.fromRGB(255, 80, 80) -- Mythic

	elseif name:find("dough") or name:find("venom") or name:find("spirit") then
		return Color3.fromRGB(180, 0, 255) -- Legendary

	elseif name:find("light") or name:find("ice") or name:find("magma") then
		return Color3.fromRGB(0, 170, 255) -- Rare

	else
		return Color3.fromRGB(255,255,255) -- Normal
	end
end

-------------------------------------------------
-- CREATE ESP
-------------------------------------------------

local function CreateESP(fruit)

	local color = GetFruitColor(fruit.Name)

	local highlight = Instance.new("Highlight")
	highlight.Name = "FruitESP"
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.4
	highlight.Parent = fruit

	local bill = Instance.new("BillboardGui")
	bill.Name = "Distance"
	bill.Size = UDim2.new(0,140,0,30)
	bill.AlwaysOnTop = true
	bill.StudsOffset = Vector3.new(0,3,0)
	bill.Adornee = fruit
	bill.Parent = fruit

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.new(1,1,1)
	txt.TextStrokeTransparency = 0
	txt.Font = Enum.Font.GothamBold
	txt.TextScaled = true
	txt.Text = fruit.Name
	txt.Parent = bill

end

-------------------------------------------------
-- REGISTER FRUIT
-------------------------------------------------

local function RegisterFruit(part)

	if not part then return end
	if KnownFruit[part] then return end

	KnownFruit[part] = true
	table.insert(FruitList, part)

	CreateESP(part)

	part.AncestryChanged:Connect(function(_, parent)
		if not parent then
			KnownFruit[part] = nil
		end
	end)
end

-------------------------------------------------
-- INITIAL SCAN
-------------------------------------------------

for _,v in ipairs(workspace:GetDescendants()) do
	if IsFruit(v) then
		local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
		RegisterFruit(part)
	end
end

-------------------------------------------------
-- NEW SPAWN DETECTOR
-------------------------------------------------

workspace.DescendantAdded:Connect(function(v)
	if IsFruit(v) then
		local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
		RegisterFruit(part)
	end
end)

-------------------------------------------------
-- DISTANCE UPDATE
-------------------------------------------------

RunService.RenderStepped:Connect(function()

	local char = player.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for i = #FruitList, 1, -1 do
		local fruit = FruitList[i]

		if not fruit or not fruit.Parent then
			table.remove(FruitList, i)
			continue
		end

		local gui = fruit:FindFirstChild("Distance")
		if gui then
			local dist = (root.Position - fruit.Position).Magnitude
			gui.TextLabel.Text = fruit.Name.." ["..math.floor(dist).."m]"
		end
	end

end)

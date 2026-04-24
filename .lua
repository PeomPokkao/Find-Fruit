local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local Fruits = {}
local Added = {}

-------------------------------------------------
-- CHECK FRUIT (เอาแค่มีคำว่า fruit)
-------------------------------------------------

local function IsFruit(v)
	return v.Name:lower():find("fruit")
end

-------------------------------------------------
-- ADD ESP
-------------------------------------------------

local function AddESP(part)

	if not part or Added[part] then return end
	Added[part] = true
	table.insert(Fruits, part)

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255,255,255)
	highlight.OutlineColor = Color3.fromRGB(255,255,255)
	highlight.FillTransparency = 0.5
	highlight.Parent = part

	local bill = Instance.new("BillboardGui")
	bill.Size = UDim2.new(0,120,0,25)
	bill.AlwaysOnTop = true
	bill.StudsOffset = Vector3.new(0,3,0)
	bill.Adornee = part
	bill.Parent = part

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.new(1,1,1)
	txt.TextStrokeTransparency = 0
	txt.TextScaled = true
	txt.Font = Enum.Font.GothamBold
	txt.Text = part.Name
	txt.Parent = bill

end

-------------------------------------------------
-- SCAN ครั้งเดียว
-------------------------------------------------

for _,v in ipairs(workspace:GetDescendants()) do
	if IsFruit(v) then
		local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
		AddESP(part)
	end
end

-------------------------------------------------
-- เจอใหม่ก็ค่อยเพิ่ม
-------------------------------------------------

workspace.DescendantAdded:Connect(function(v)
	if IsFruit(v) then
		local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
		AddESP(part)
	end
end)

-------------------------------------------------
-- UPDATE ระยะ
-------------------------------------------------

RunService.RenderStepped:Connect(function()

	local char = player.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for i = #Fruits,1,-1 do
		local f = Fruits[i]

		if not f or not f.Parent then
			table.remove(Fruits,i)
			continue
		end

		local gui = f:FindFirstChildOfClass("BillboardGui")
		if gui then
			local dist = (root.Position - f.Position).Magnitude
			gui.TextLabel.Text = f.Name.." ["..math.floor(dist).."m]"
		end
	end

end)

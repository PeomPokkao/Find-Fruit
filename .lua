--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Remote
local Rem = Instance.new("RemoteEvent")
Rem.Name = "FruitESP"
Rem.Parent = ReplicatedStorage

local enabled = {}

-- หา Part เอาไว้ติด UI
local function getBasePart(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
end

-- สร้าง UI
local function setup(plr)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ESP_UI"
    gui.Parent = plr:WaitForChild("PlayerGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,150,0,50)
    btn.Position = UDim2.new(0,20,0,100)
    btn.Text = "ESP: OFF"
    btn.Parent = gui

    local ls = Instance.new("LocalScript")
    ls.Parent = gui

    ls.Source = [[
        local Rem = game.ReplicatedStorage:WaitForChild("FruitESP")
        local btn = script.Parent:FindFirstChildOfClass("TextButton")

        local enabled = false
        local objects = {}

        local function getPart(obj)
            if obj:IsA("Model") then
                return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            elseif obj:IsA("BasePart") then
                return obj
            end
        end

        local function createESP(obj)
            if not obj or objects[obj] then return end
            local part = getPart(obj)
            if not part then return end

            local h = Instance.new("Highlight")
            h.FillTransparency = 0.5
            h.Parent = obj

            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0,100,0,40)
            bill.AlwaysOnTop = true
            bill.StudsOffset = Vector3.new(0,2,0)
            bill.Adornee = part
            bill.Parent = obj

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1,0,1,0)
            text.BackgroundTransparency = 1
            text.TextScaled = true
            text.Text = obj.Name
            text.TextColor3 = Color3.new(1,1,0)
            text.Parent = bill

            objects[obj] = {h, bill}
        end

        local function removeESP(obj)
            if objects[obj] then
                for _,v in pairs(objects[obj]) do
                    v:Destroy()
                end
                objects[obj] = nil
            end
        end

        local function clear()
            for obj,_ in pairs(objects) do
                removeESP(obj)
            end
        end

        btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            btn.Text = enabled and "ESP: ON" or "ESP: OFF"
            Rem:FireServer(enabled)
        end)

        Rem.OnClientEvent:Connect(function(action, data)
            if action == "SET" then
                clear()
                if enabled then
                    for _,v in pairs(data) do
                        createESP(v)
                    end
                end
            elseif action == "ADD" then
                if enabled then createESP(data) end
            elseif action == "REMOVE" then
                removeESP(data)
            end
        end)
    ]]
end

-- Player join
Players.PlayerAdded:Connect(setup)

-- Toggle
Rem.OnServerEvent:Connect(function(plr, state)
    enabled[plr] = state
    if state then
        Rem:FireClient(plr, "SET", CollectionService:GetTagged("Fruit"))
    else
        Rem:FireClient(plr, "SET", {})
    end
end)

-- Update
CollectionService:GetInstanceAddedSignal("Fruit"):Connect(function(obj)
    for plr, on in pairs(enabled) do
        if on then Rem:FireClient(plr, "ADD", obj) end
    end
end)

CollectionService:GetInstanceRemovedSignal("Fruit"):Connect(function(obj)
    for plr, on in pairs(enabled) do
        if on then Rem:FireClient(plr, "REMOVE", obj) end
    end
end)

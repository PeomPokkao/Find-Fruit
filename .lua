--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--// RemoteEvent
local Rem = Instance.new("RemoteEvent")
Rem.Name = "FruitESP"
Rem.Parent = ReplicatedStorage

--// เก็บสถานะ
local enabled = {}

--// สร้าง UI ให้ทุกคน
local function setupPlayer(plr)
    local playerGui = plr:WaitForChild("PlayerGui")

    local gui = Instance.new("ScreenGui")
    gui.Name = "FruitESP_UI"
    gui.Parent = playerGui

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0,150,0,50)
    button.Position = UDim2.new(0,20,0,100)
    button.Text = "ESP: OFF"
    button.Parent = gui

    -- LocalScript ฝัง
    local localScript = Instance.new("LocalScript")
    localScript.Parent = gui

    localScript.Source = [[
        local Rem = game.ReplicatedStorage:WaitForChild("FruitESP")
        local button = script.Parent:FindFirstChildOfClass("TextButton")

        local enabled = false
        local objects = {}

        local function createESP(fruit)
            if not fruit or objects[fruit] then return end

            local h = Instance.new("Highlight")
            h.FillTransparency = 0.5
            h.Parent = fruit

            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0,100,0,40)
            bill.AlwaysOnTop = true
            bill.StudsOffset = Vector3.new(0,2,0)
            bill.Parent = fruit

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1,0,1,0)
            text.BackgroundTransparency = 1
            text.TextScaled = true
            text.Text = fruit.Name
            text.TextColor3 = Color3.new(1,1,0)
            text.Parent = bill

            objects[fruit] = {h, bill}
        end

        local function removeESP(fruit)
            if objects[fruit] then
                for _,v in pairs(objects[fruit]) do
                    v:Destroy()
                end
                objects[fruit] = nil
            end
        end

        local function clearAll()
            for f,_ in pairs(objects) do
                removeESP(f)
            end
        end

        button.MouseButton1Click:Connect(function()
            enabled = not enabled
            button.Text = enabled and "ESP: ON" or "ESP: OFF"
            Rem:FireServer(enabled)
        end)

        Rem.OnClientEvent:Connect(function(action, data)
            if action == "SET" then
                clearAll()
                if enabled then
                    for _,f in pairs(data) do
                        createESP(f)
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

--// Player join
Players.PlayerAdded:Connect(function(plr)
    setupPlayer(plr)
end)

--// รับ toggle จากทุกคน
Rem.OnServerEvent:Connect(function(plr, state)
    enabled[plr] = state

    if state then
        local fruits = CollectionService:GetTagged("Fruit")
        Rem:FireClient(plr, "SET", fruits)
    else
        Rem:FireClient(plr, "SET", {})
    end
end)

--// อัปเดตผลไม้
CollectionService:GetInstanceAddedSignal("Fruit"):Connect(function(f)
    for plr, on in pairs(enabled) do
        if on then
            Rem:FireClient(plr, "ADD", f)
        end
    end
end)

CollectionService:GetInstanceRemovedSignal("Fruit"):Connect(function(f)
    for plr, on in pairs(enabled) do
        if on then
            Rem:FireClient(plr, "REMOVE", f)
        end
    end
end)

local NebulaLibrary = {}
NebulaLibrary.__index = NebulaLibrary

local UserInputService = game:GetService("UserInputService")

local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

function NebulaLibrary:CreateWindow(title, settings)
    self.Settings = {
        Theme = settings.Theme or "Dark",
        Watermark = settings.Watermark or false,
        Notifications = settings.Notifications or false,
        Keybind = settings.Keybind or Enum.KeyCode.RightControl,
        Font = Enum.Font.Gotham,
        TextSize = 14,
    }

    self.ScreenGui = Create("ScreenGui", {
        Name = "NebulaLibrary",
        ResetOnSpawn = false,
        Parent = game.CoreGui
    })

    self.MainFrame = Create("Frame", {
        Parent = self.ScreenGui,
        BackgroundColor3 = self.Settings.Theme == "Dark" and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(245, 245, 245),
        Size = UDim2.new(0, 450, 0, 350),
        Position = UDim2.new(0.5, -225, 0.5, -175),
        AnchorPoint = Vector2.new(0.5, 0.5)
    })

    Create("UICorner", {Parent = self.MainFrame})
    Create("UIStroke", {
        Parent = self.MainFrame,
        Color = self.Settings.Theme == "Dark" and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(200, 200, 200),
        Thickness = 2
    })

    local titleBar = Create("TextLabel", {
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Text = title,
        Font = self.Settings.Font,
        TextSize = 16,
        TextColor3 = self.Settings.Theme == "Dark" and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,0,0)
    })

    if self.Settings.Watermark then
        local watermark = Create("TextLabel", {
            Parent = self.ScreenGui,
            Size = UDim2.new(0, 140, 0, 20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Text = "Nebula Library",
            Font = self.Settings.Font,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(130, 130, 255),
            TextStrokeTransparency = 0.8
        })
    end

    if self.Settings.Notifications then
        function self:Notify(title, msg, duration)
            local notif = Create("TextLabel", {
                Parent = self.ScreenGui,
                Size = UDim2.new(0, 240, 0, 35),
                Position = UDim2.new(0.5, -120, 0, -40),
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                Text = title .. ": " .. msg,
                Font = self.Settings.Font,
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            })
            Create("UICorner", {Parent = notif})
            task.delay(duration or 3, function()
                notif:Destroy()
            end)
        end
    else
        self.Notify = function() end
    end

    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.Settings.Keybind then
            self.MainFrame.Visible = not self.MainFrame.Visible
        end
    end)

    return self
end

function NebulaLibrary:CreateTab(name)
    local tab = Create("Frame", {
        Name = name,
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.new(0, 10, 0, 40)
    })

    Create("TextLabel", {
        Parent = tab,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = "Tab: " .. name,
        Font = self.Settings.Font,
        TextSize = self.Settings.TextSize,
        TextColor3 = self.Settings.Theme == "Dark" and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,0,0)
    })

    return tab
end

function NebulaLibrary.new()
    local self = setmetatable({}, NebulaLibrary)
    return self
end

return NebulaLibrary

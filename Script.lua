--// PLAYER UTILITY PANEL V5
--// Fixed HipHeight / feet sinking issue
--// Minimize "-" + right-side show button
--// Tabs + Movement + Visual + Player + Utility + Settings
--// FPS Overlay + Hide/Show + RightShift
--// LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    Gravity = 196.2,
    SprintSpeed = 32,
    FOV = 70,
    Zoom = 12,
    Transparency = 0,
    HipHeight = nil,

    Noclip = false,
    Fly = false,
    InfiniteJump = false,
    LowGravity = false,
    Sprint = false,
    Fullbright = false,
    GodMode = false,
    AntiAFK = false,
}

local showFPS = false
local flyConnection = nil

--==================================================
-- CHARACTER
--==================================================

local character
local humanoid
local root
local defaultHipHeight = nil

local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")

    -- IMPORTANT:
    -- Keep the character's real/default HipHeight.
    -- This prevents the feet from sinking into the floor.
    defaultHipHeight = humanoid.HipHeight
    settings.HipHeight = defaultHipHeight

    humanoid.WalkSpeed = settings.WalkSpeed
    humanoid.JumpPower = settings.JumpPower
end

updateCharacter()

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    updateCharacter()
end)

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "PlayerUtilityPanel"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = player:WaitForChild("PlayerGui")

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 460, 0, 350)
Main.Position = UDim2.new(0.5, -230, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚙ Player Utility Panel"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Close button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -40, 0, 3)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 90, 90)
Close.TextSize = 28
Close.Font = Enum.Font.GothamBold
Close.Parent = TopBar

-- Minimize button
local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 35, 0, 35)
Minimize.Position = UDim2.new(1, -78, 0, 3)
Minimize.BackgroundTransparency = 1
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(220, 220, 220)
Minimize.TextSize = 25
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = TopBar

-- Small button on the right side of the screen.
-- It appears when the panel is minimized/hidden.
local ShowPanelButton = Instance.new("TextButton")
ShowPanelButton.Name = "ShowPanelButton"
ShowPanelButton.Size = UDim2.new(0, 42, 0, 42)
ShowPanelButton.Position = UDim2.new(1, -52, 0.5, -21)
ShowPanelButton.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
ShowPanelButton.BorderSizePixel = 0
ShowPanelButton.Text = ">"
ShowPanelButton.TextColor3 = Color3.new(1, 1, 1)
ShowPanelButton.TextSize = 22
ShowPanelButton.Font = Enum.Font.GothamBold
ShowPanelButton.Visible = false
ShowPanelButton.ZIndex = 200
ShowPanelButton.Parent = Gui

local ShowCorner = Instance.new("UICorner")
ShowCorner.CornerRadius = UDim.new(0, 10)
ShowCorner.Parent = ShowPanelButton

local function hidePanel()
    Main.Visible = false
    ShowPanelButton.Visible = true
end

local function showPanel()
    Main.Visible = true
    ShowPanelButton.Visible = false
end

Close.MouseButton1Click:Connect(function()
    hidePanel()
end)

Minimize.MouseButton1Click:Connect(function()
    hidePanel()
end)

ShowPanelButton.MouseButton1Click:Connect(function()
    showPanel()
end)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- TAB BAR
--==================================================

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 115, 1, -52)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 10)
TabCorner.Parent = TabBar

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 6)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.VerticalAlignment = Enum.VerticalAlignment.Top
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabBar

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -140, 1, -52)
Content.Position = UDim2.new(0, 135, 0, 48)
Content.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
Content.BorderSizePixel = 0
Content.Parent = Main

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = Content

--==================================================
-- GUI FUNCTIONS
--==================================================

local tabs = {}
local tabButtons = {}

local function createTab(name, icon)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 42)
    button.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
    button.BorderSizePixel = 0
    button.Text = icon .. "  " .. name
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium
    button.Parent = TabBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(
            0,
            0,
            0,
            layout.AbsoluteContentSize.Y + 10
        )
    end)

    tabs[name] = page
    tabButtons[name] = button

    button.MouseButton1Click:Connect(function()
        for n, p in pairs(tabs) do
            p.Visible = false
            tabButtons[n].BackgroundColor3 =
                Color3.fromRGB(38, 38, 45)
        end

        page.Visible = true
        button.BackgroundColor3 =
            Color3.fromRGB(60, 90, 150)
    end)

    return page
end

local function label(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, 28)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(180, 180, 180)
    l.TextSize = 12
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function button(parent, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 38)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 13
    b.Font = Enum.Font.GothamMedium
    b.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = b

    return b
end

local function textbox(parent, title, default)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 48)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = title
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.TextSize = 13
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = holder

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.4, 0, 0, 34)
    box.Position = UDim2.new(0.6, 0, 0, 7)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
    box.BorderSizePixel = 0
    box.Text = tostring(default)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.TextSize = 13
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = holder

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = box

    return box
end

local function toggleButton(parent, name, initial, callback)
    local state = initial

    local b = button(parent, name .. ": OFF")

    local function refresh()
        b.Text = name .. ": " .. (state and "ON" or "OFF")

        if state then
            b.BackgroundColor3 = Color3.fromRGB(55, 120, 75)
        else
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
        end
    end

    b.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        callback(state)
    end)

    refresh()

    return b
end

--==================================================
-- CREATE TABS
--==================================================

local Movement = createTab("Movement", "🏃")
local Visual = createTab("Visual", "👁")
local PlayerTab = createTab("Player", "👤")
local Utility = createTab("Utility", "🔧")
local SettingsTab = createTab("Settings", "⚙")

--==================================================
-- MOVEMENT
--==================================================

label(Movement, "Movement Settings")

local speedBox = textbox(
    Movement,
    "WalkSpeed",
    settings.WalkSpeed
)

speedBox.FocusLost:Connect(function()
    local value = tonumber(speedBox.Text)

    if value then
        settings.WalkSpeed = value

        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end)

local jumpBox = textbox(
    Movement,
    "JumpPower",
    settings.JumpPower
)

jumpBox.FocusLost:Connect(function()
    local value = tonumber(jumpBox.Text)

    if value then
        settings.JumpPower = value

        if humanoid then
            humanoid.JumpPower = value
        end
    end
end)

local flySpeedBox = textbox(
    Movement,
    "Fly Speed",
    settings.FlySpeed
)

flySpeedBox.FocusLost:Connect(function()
    local value = tonumber(flySpeedBox.Text)

    if value then
        settings.FlySpeed = value
    end
end)

local gravityBox = textbox(
    Movement,
    "Gravity",
    settings.Gravity
)

gravityBox.FocusLost:Connect(function()
    local value = tonumber(gravityBox.Text)

    if value then
        settings.Gravity = value

        if not settings.LowGravity then
            workspace.Gravity = value
        end
    end
end)

local sprintBox = textbox(
    Movement,
    "Sprint Speed",
    settings.SprintSpeed
)

sprintBox.FocusLost:Connect(function()
    local value = tonumber(sprintBox.Text)

    if value then
        settings.SprintSpeed = value
    end
end)

toggleButton(Movement, "Noclip", false, function(state)
    settings.Noclip = state
end)

toggleButton(Movement, "Fly", false, function(state)
    settings.Fly = state
end)

toggleButton(Movement, "Infinite Jump", false, function(state)
    settings.InfiniteJump = state
end)

toggleButton(Movement, "Low Gravity", false, function(state)
    settings.LowGravity = state

    if state then
        workspace.Gravity = 50
    else
        workspace.Gravity = settings.Gravity
    end
end)

toggleButton(Movement, "Sprint", false, function(state)
    settings.Sprint = state
end)

--==================================================
-- VISUAL
--==================================================

label(Visual, "Visual Settings")

local fovBox = textbox(
    Visual,
    "FOV",
    settings.FOV
)

fovBox.FocusLost:Connect(function()
    local value = tonumber(fovBox.Text)

    if value then
        settings.FOV = value
        camera.FieldOfView = value
    end
end)

local zoomBox = textbox(
    Visual,
    "Camera Zoom",
    settings.Zoom
)

zoomBox.FocusLost:Connect(function()
    local value = tonumber(zoomBox.Text)

    if value then
        settings.Zoom = value
        player.CameraMaxZoomDistance = value
    end
end)

local transparencyBox = textbox(
    Visual,
    "Character Transparency",
    settings.Transparency
)

transparencyBox.FocusLost:Connect(function()
    local value = tonumber(transparencyBox.Text)

    if value then
        value = math.clamp(value, 0, 1)
        settings.Transparency = value
    end
end)

toggleButton(Visual, "Fullbright", false, function(state)
    settings.Fullbright = state

    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 1000
    end
end)

--==================================================
-- PLAYER
--==================================================

label(PlayerTab, "Character")

-- Use the character's actual default HipHeight.
local hipBox = textbox(
    PlayerTab,
    "HipHeight",
    settings.HipHeight
)

hipBox.FocusLost:Connect(function()
    local value = tonumber(hipBox.Text)

    if value and humanoid then
        settings.HipHeight = value
        humanoid.HipHeight = value
    end
end)

toggleButton(PlayerTab, "God Mode", false, function(state)
    settings.GodMode = state

    if humanoid then
        if state then
            humanoid:SetAttribute(
                "OriginalMaxHealth",
                humanoid.MaxHealth
            )

            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        else
            local original =
                humanoid:GetAttribute("OriginalMaxHealth")

            if original then
                humanoid.MaxHealth = original
                humanoid.Health = original
            end
        end
    end
end)

local resetButton = button(
    PlayerTab,
    "🔄 Reset Character"
)

resetButton.MouseButton1Click:Connect(function()
    if humanoid then
        humanoid.Health = 0
    end
end)

--==================================================
-- UTILITY
--==================================================

label(Utility, "Utility")

local FPSLabel = label(
    Utility,
    "FPS: --"
)

-- FPS overlay outside the main panel
local FPSOverlay = Instance.new("TextLabel")
FPSOverlay.Name = "FPSOverlay"
FPSOverlay.Size = UDim2.new(0, 110, 0, 32)
FPSOverlay.Position = UDim2.new(0, 10, 0, 10)
FPSOverlay.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
FPSOverlay.BackgroundTransparency = 0.15
FPSOverlay.BorderSizePixel = 0
FPSOverlay.Text = "FPS: --"
FPSOverlay.TextColor3 = Color3.new(1, 1, 1)
FPSOverlay.TextSize = 14
FPSOverlay.Font = Enum.Font.GothamBold
FPSOverlay.Visible = false
FPSOverlay.ZIndex = 100
FPSOverlay.Parent = Gui

local FPSCorner = Instance.new("UICorner")
FPSCorner.CornerRadius = UDim.new(0, 8)
FPSCorner.Parent = FPSOverlay

local ShowFPSButton = button(
    Utility,
    "📊 Show FPS: OFF"
)

ShowFPSButton.MouseButton1Click:Connect(function()
    showFPS = not showFPS

    FPSOverlay.Visible = showFPS

    if showFPS then
        ShowFPSButton.Text = "📊 Show FPS: ON"
        ShowFPSButton.BackgroundColor3 =
            Color3.fromRGB(55, 120, 75)
    else
        ShowFPSButton.Text = "📊 Show FPS: OFF"
        ShowFPSButton.BackgroundColor3 =
            Color3.fromRGB(45, 45, 53)
    end
end)

local PositionLabel = label(
    Utility,
    "Position: --"
)

toggleButton(
    Utility,
    "Anti-AFK",
    false,
    function(state)
        settings.AntiAFK = state
    end
)

--==================================================
-- FPS COUNTER
--==================================================

local frames = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()
    frames += 1

    local now = tick()

    if now - lastTime >= 1 then
        local fps = frames

        frames = 0
        lastTime = now

        FPSLabel.Text = "FPS: " .. fps

        if showFPS then
            FPSOverlay.Text = "FPS: " .. fps
        end
    end

    if root then
        local p = root.Position

        PositionLabel.Text = string.format(
            "Position: %.1f, %.1f, %.1f",
            p.X,
            p.Y,
            p.Z
        )
    end
end)

--==================================================
-- SETTINGS
--==================================================

label(
    SettingsTab,
    "Interface"
)

local HideButton = button(
    SettingsTab,
    "👁 Hide GUI"
)

HideButton.MouseButton1Click:Connect(function()
    hidePanel()
end)

local ResetSettingsButton = button(
    SettingsTab,
    "🔄 Reset Settings"
)

ResetSettingsButton.MouseButton1Click:Connect(function()

    settings.WalkSpeed = 16
    settings.JumpPower = 50
    settings.FlySpeed = 50
    settings.Gravity = 196.2
    settings.SprintSpeed = 32
    settings.FOV = 70
    settings.Zoom = 12
    settings.Transparency = 0

    -- IMPORTANT:
    -- Restore the real default HipHeight,
    -- never force it to 0.
    if humanoid then
        settings.HipHeight = defaultHipHeight
    end

    settings.Noclip = false
    settings.Fly = false
    settings.InfiniteJump = false
    settings.LowGravity = false
    settings.Sprint = false
    settings.Fullbright = false
    settings.GodMode = false
    settings.AntiAFK = false

    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid.HipHeight = defaultHipHeight
    end

    workspace.Gravity = 196.2
    camera.FieldOfView = 70
    player.CameraMaxZoomDistance = 12

    speedBox.Text = "16"
    jumpBox.Text = "50"
    flySpeedBox.Text = "50"
    gravityBox.Text = "196.2"
    sprintBox.Text = "32"
    fovBox.Text = "70"
    zoomBox.Text = "12"
    transparencyBox.Text = "0"

    if humanoid then
        hipBox.Text = tostring(defaultHipHeight)
    end

    if character then
        for _, obj in ipairs(character:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = 0
            end
        end
    end

    Lighting.Brightness = 2
    Lighting.GlobalShadows = true
end)

--==================================================
-- RIGHT SHIFT
--==================================================

UserInputService.InputBegan:Connect(function(
    input,
    processed
)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then
            hidePanel()
        else
            showPanel()
        end
    end
end)

--==================================================
-- INFINITE JUMP
--==================================================

UserInputService.JumpRequest:Connect(function()
    if settings.InfiniteJump and humanoid then
        humanoid:ChangeState(
            Enum.HumanoidStateType.Jumping
        )
    end
end)

--==================================================
-- NOCLIP
--==================================================

RunService.Stepped:Connect(function()
    if settings.Noclip and character then
        for _, obj in ipairs(character:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = false
            end
        end
    end
end)

--==================================================
-- SPRINT
--==================================================

RunService.RenderStepped:Connect(function()
    if humanoid then
        if settings.Sprint then
            humanoid.WalkSpeed = settings.SprintSpeed
        else
            humanoid.WalkSpeed = settings.WalkSpeed
        end
    end
end)

--==================================================
-- FLY
--==================================================

local function stopFly()

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if root then
        local bv = root:FindFirstChild("FlyVelocity")

        if bv then
            bv:Destroy()
        end

        local bg = root:FindFirstChild("FlyGyro")

        if bg then
            bg:Destroy()
        end
    end
end

local function startFly()

    stopFly()

    if not root then
        return
    end

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "FlyGyro"
    bodyGyro.MaxTorque = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    bodyGyro.P = 10000
    bodyGyro.Parent = root

    flyConnection = RunService.RenderStepped:Connect(
        function()

            if not settings.Fly or not root then
                stopFly()
                return
            end

            local direction = Vector3.zero

            if UserInputService:IsKeyDown(
                Enum.KeyCode.W
            ) then
                direction += camera.CFrame.LookVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.S
            ) then
                direction -= camera.CFrame.LookVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.A
            ) then
                direction -= camera.CFrame.RightVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.D
            ) then
                direction += camera.CFrame.RightVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.Space
            ) then
                direction += Vector3.new(0, 1, 0)
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.LeftControl
            ) then
                direction -= Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                direction = direction.Unit
            end

            bodyVelocity.Velocity =
                direction * settings.FlySpeed

            bodyGyro.CFrame = camera.CFrame
        end
    )
end

RunService.RenderStepped:Connect(function()

    if settings.Fly and not flyConnection then
        startFly()

    elseif not settings.Fly and flyConnection then
        stopFly()
    end

end)

--==================================================
-- ANTI-AFK
--==================================================

player.Idled:Connect(function()

    if settings.AntiAFK then
        VirtualUser:CaptureController()

        VirtualUser:ClickButton2(
            Vector2.new(0, 0)
        )
    end

end)

--==================================================
-- CHARACTER TRANSPARENCY
--==================================================

RunService.RenderStepped:Connect(function()

    if character then

        for _, obj in ipairs(
            character:GetDescendants()
        ) do

            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier =
                    settings.Transparency
            end

        end

    end

end)

--==================================================
-- CAMERA
--==================================================

camera.FieldOfView = settings.FOV
player.CameraMaxZoomDistance = settings.Zoom

--==================================================
-- DEFAULT TAB
--==================================================

Movement.Visible = true

tabButtons["Movement"].BackgroundColor3 =
    Color3.fromRGB(60, 90, 150)

--==================================================
-- DONE
--==================================================

print("Player Utility Panel V4 loaded!")
print("RightShift = Hide / Show GUI")
print("Utility > Show FPS = FPS Overlay")
print("HipHeight uses the character's default value.")

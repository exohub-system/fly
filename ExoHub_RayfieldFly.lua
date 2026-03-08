-- ╔═══════════════════════════════════╗
--   EXO HUB | FLY SCRIPT
--   Rayfield UI | discord.gg/6QzV9pTWs
-- ╚═══════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- ══════════════════════════════════════
--  FLY STATE
-- ══════════════════════════════════════
local flyEnabled = false
local noclipEnabled = false
local flySpeed = 50
local flyConn = nil
local noclipConn = nil
local bodyGyro = nil
local bodyVel = nil

local function startFly()
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 9e4
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.Velocity = Vector3.zero
    bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVel.P = 9e4
    bodyVel.Parent = hrp

    local cam = workspace.CurrentCamera
    flyConn = RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end

        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

        if dir.Magnitude > 0 then
            bodyVel.Velocity = dir.Unit * flySpeed
        else
            bodyVel.Velocity = Vector3.zero
        end

        bodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    local char = lp.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp then
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            if bodyVel then bodyVel:Destroy() bodyVel = nil end
        end
        if hum then hum.PlatformStand = false end
    end
end

local function startNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local char = lp.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    local char = lp.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- re-apply on respawn
lp.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then startFly() end
    if noclipEnabled then startNoclip() end
end)

-- ══════════════════════════════════════
--  RAYFIELD WINDOW
-- ══════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name = "EXO HUB",
    Icon = "wind",
    LoadingTitle = "EXO HUB",
    LoadingSubtitle = "discord.gg/6QzV9pTWs",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = false,
    },
    Discord = {
        Enabled = true,
        Invite = "6QzV9pTWs",
        RememberJoins = true,
    },
    KeySystem = false,
})

-- ══════════════════════════════════════
--  TAB
-- ══════════════════════════════════════
local Tab = Window:CreateTab("✈️  Fly", "wind")

Tab:CreateSection("Movement")

-- FLY TOGGLE
Tab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        flyEnabled = value
        if flyEnabled then
            startFly()
            Rayfield:Notify({
                Title = "EXO HUB",
                Content = "Fly enabled — WASD to move, Space/Shift for up/down",
                Duration = 4,
                Image = "wind",
            })
        else
            stopFly()
            Rayfield:Notify({
                Title = "EXO HUB",
                Content = "Fly disabled",
                Duration = 2,
                Image = "wind",
            })
        end
    end,
})

-- NOCLIP TOGGLE
Tab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(value)
        noclipEnabled = value
        if noclipEnabled then
            startNoclip()
            Rayfield:Notify({
                Title = "EXO HUB",
                Content = "NoClip enabled — walk through walls",
                Duration = 3,
                Image = "ghost",
            })
        else
            stopNoclip()
            Rayfield:Notify({
                Title = "EXO HUB",
                Content = "NoClip disabled",
                Duration = 2,
                Image = "ghost",
            })
        end
    end,
})

Tab:CreateSection("Speed")

-- FLY SPEED SLIDER
Tab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = " studs/s",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(value)
        flySpeed = value
    end,
})

Tab:CreateSection("Info")

Tab:CreateParagraph({
    Title = "Controls",
    Content = "WASD — Move\nSpace — Go Up\nLeft Shift — Go Down\nK — Toggle UI",
})

Tab:CreateParagraph({
    Title = "EXO HUB",
    Content = "discord.gg/6QzV9pTWs\nFree forever. Always updating.",
})

print("[EXO HUB] Fly Script loaded | discord.gg/6QzV9pTWs")

-- // Services
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // Tables
local Flags = {}
local Connections = {}
local Defaults = {
    Gravity = workspace.Gravity,
    FOV = 70, -- Standard Roblox FOV
    WalkSpeed = 16,
    JumpPower = 50,
    HipHeight = 0,
    ClockTime = Lighting.ClockTime
}

local Main = {}
local UI = getgenv().arigato.Utilities.UI

-- // Management Functions
local function Cleanup(tbl)
    for key, value in pairs(tbl) do
        if typeof(value) == "RBXScriptConnection" then
            value:Disconnect()
            tbl[key] = nil
        elseif typeof(value) == 'thread' then
            task.cancel(value)
            tbl[key] = nil
        elseif type(value) == 'table' then
            Cleanup(value)
        end
    end
end

local function Thread(featurePath, featureFunc, isEnabled, ...)
    local pathParts = featurePath:split(".")
    local currentTable = Flags 

    for i = 1, #pathParts - 1 do
        local part = pathParts[i]
        if not currentTable[part] then currentTable[part] = {} end
        currentTable = currentTable[part]
    end

    local flagKey = pathParts[#pathParts]
    local activeThread = currentTable[flagKey]

    if isEnabled then
        if activeThread then task.cancel(activeThread) end
        currentTable[flagKey] = task.spawn(featureFunc, ...)
    else
        if activeThread then
            task.cancel(activeThread)
            currentTable[flagKey] = nil
        end
    end
end

-- // Script Functions
local function FuncTPW()
    while true do
        local delta = RunS.Heartbeat:Wait()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if char and hum and hum.Health > 0 then
            if hum.MoveDirection.Magnitude > 0 then
                local speed = Library.Options.TPWValue.Value
                -- Using TranslateBy prevents the "stacking" physics bug
                char:TranslateBy(hum.MoveDirection * speed * delta * 10)
            end
        end
    end
end

local function FuncNoclip()
    while true do
        RunS.Stepped:Wait()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end

-- // UI Functions
local function AddSliderToggle(Config)
    local Toggle = Config.Group:AddToggle(Config.Id, { Text = Config.Text, Default = false })
        
    local Slider = Config.Group:AddSlider(Config.Id .. "Value", { 
        Text = Config.Text, 
        Default = Config.Default, 
        Min = Config.Min, 
        Max = Config.Max, 
        Rounding = Config.Rounding or 0, 
        Compact = true, 
        Visible = false
    })

    Toggle:OnChanged(function()
        Slider:SetVisible(Toggle.Value)
    end)
end


function Main:AddPlayerTab(Window)
    local PlayerTab = Window:AddTab("Player", "user")

    PlayerTab:UpdateWarningBox({
        Title = "Warning",
        Text = "⚠️ Use in caution.",
        IsNormal = true,
        Visible = true,
        LockSize = true,
    })

    local GB = {
        Left = {
            General = PlayerTab:AddLeftGroupbox("General", "file-stack"),
            Server = PlayerTab:AddLeftGroupbox("Server", "server"),
        },
        Right = {
            Game = PlayerTab:AddRightGroupbox("Game", "earth"),
            AntiMod = PlayerTab:AddRightGroupbox("Anti-Mod", "shield"),
        },
    }

    -- // General
    AddSliderToggle({ Group = GB.Left.General, Id = "WS", Text = "WalkSpeed", Default = 16, Min = 16, Max = 250 })
    AddSliderToggle({ Group = GB.Left.General, Id = "TPW", Text = "TPWalk", Default = 2, Min = 1, Max = 50 })
    AddSliderToggle({ Group = GB.Left.General, Id = "JP", Text = "JumpPower", Default = 50, Min = 50, Max = 500 })
    AddSliderToggle({ Group = GB.Left.General, Id = "HH", Text = "HipHeight", Default = 2, Min = 0, Max = 10, Rounding = 1 })
    AddSliderToggle({ Group = GB.Left.General, Id = "Grav", Text = "Gravity", Default = 196, Min = 0, Max = 500 })
    AddSliderToggle({ Group = GB.Left.General, Id = "Zoom", Text = "Camera Zoom", Default = 128, Min = 128, Max = 10000 })
    AddSliderToggle({ Group = GB.Left.General, Id = "FOV", Text = "Field of View", Default = 70, Min = 30, Max = 120 })
    AddSliderToggle({ Group = GB.Left.General, Id = "LimitFPS", Text = "Limit FPS", Default = 60, Min = 30, Max = 240 })

    GB.Left.General:AddToggle("Noclip", { Text = "Noclip" })
    GB.Left.General:AddToggle("Disable3DRender", { Text = "Disable 3D Rendering" })

    -- // Server
    GB.Left.Server:AddToggle("AntiAFK", { Text = "Anti AFK", Default = true })
    GB.Left.Server:AddToggle("AntiKick", { Text = "Anti Kick (Client)" })
    GB.Left.Server:AddToggle("AutoReconnect", { Text = "Auto Reconnect" })

    GB.Left.Server:AddButton({ Text = "Serverhop", Func = function() 
        local Servers = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end})
    GB.Left.Server:AddButton({ Text = "Rejoin", Func = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
    GB.Left.Server:AddButton({ Text = "Copy Discord", Func = function() setclipboard("https://discord.gg/") end })

    GB.Left.Server:AddToggle("AutoServerhop", { Text = "Auto Serverhop" })
    GB.Left.Server:AddSlider("AutoHopMins", { Text = "Minutes", Default = 30, Min = 0, Max = 300, Compact = true })

    -- // Game
    GB.Right.Game:AddToggle("Fullbright", { Text = "Fullbright" })
    GB.Right.Game:AddToggle("NoFog", { Text = "No Fog" })

    AddSliderToggle({ Group = GB.Right.Game, Id = "OverrideTime", Text = "Time Of Day", Default = 12, Min = 0, Max = 24, Rounding = 1 })

    -- // AntiMod
    GB.Right.AntiMod:AddToggle("AntiMod", { Text = "Anti Mod" })
    GB.Right.AntiMod:AddDropdown("AntiModAction", { 
        Text = "Action on Mod Join", 
        Values = {"Kick", "Panic"}, 
        Default = 1 
    })

    -- // Func
    Library.Toggles.TPW:OnChanged(function(v) Thread("TPW", FuncTPW, v) end)
    Library.Toggles.Noclip:OnChanged(function(v) Thread("Noclip", FuncNoclip, v) end)

    Connections.StatLoop = RunS.Stepped:Connect(function()
        local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Hum then
            if Library.Toggles.WS.Value then Hum.WalkSpeed = Library.Options.WSValue.Value end
            if Library.Toggles.JP.Value then Hum.JumpPower = Library.Options.JPValue.Value Hum.UseJumpPower = true end
            if Library.Toggles.HH.Value then Hum.HipHeight = Library.Options.HHValue.Value end
        end
        workspace.Gravity = Library.Toggles.Grav.Value and Library.Options.GravValue.Value or Defaults.Gravity
        if Library.Toggles.FOV.Value then workspace.CurrentCamera.FieldOfView = Library.Options.FOVValue.Value end
        if Library.Toggles.Zoom.Value then LocalPlayer.CameraMaxZoomDistance = Library.Options.ZoomValue.Value end
    end)

    -- Lighting Connection
    task.spawn(function()
        while task.wait() do
            if Library.Toggles.Fullbright.Value then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.GlobalShadows = false
            elseif Library.Toggles.OverrideTime.Value then
                Lighting.ClockTime = Library.Options.OverrideTimeValue.Value
            end
            if Library.Toggles.NoFog.Value then Lighting.FogEnd = 9e9 end
            if Library.Unloaded then break end
        end
    end)

    LocalPlayer.Idled:Connect(function()
        if Library.Toggles.AntiAFK.Value then
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end
    end)

    -- FPS Cap
    Library.Options.LimitFPSValue:OnChanged(function()
        if Library.Toggles.LimitFPS.Value then setfpscap(Library.Options.LimitFPSValue.Value) end
    end)
    Library.Toggles.LimitFPS:OnChanged(function(v)
        if not v then setfpscap(999) end
    end)

    -- 3D Render
    Library.Toggles.Disable3DRender:OnChanged(function(v) RunS:Set3dRenderingEnabled(not v) end)
end

function Main:AddConfigTab(Window)
    local GameName = getgenv().arigato.GameName or "Universal"

    UI.ThemeManager:SetFolder("arigato")
    UI.SaveManager:SetFolder("arigato/" .. GameName)

    local ConfigTab = Window:AddTab("Config", "cog")
    local MenuGroup = ConfigTab:AddLeftGroupbox("Menu", "wrench")
    
    MenuGroup:AddToggle("KeybindMenuOpen", {
        Default = UI.Library.KeybindFrame.Visible,
        Text = "Open Keybind Menu",
        Callback = function(value) UI.Library.KeybindFrame.Visible = value end,
    })
    MenuGroup:AddToggle("ShowCustomCursor", {
        Text = "Custom Cursor",
        Default = false,
        Callback = function(Value) UI.Library.ShowCustomCursor = Value end,
    })
    MenuGroup:AddDropdown("NotificationSide", {
        Values = { "Left", "Right" },
        Default = "Right",
        Text = "Notification Side",
        Callback = function(Value) UI.Library:SetNotifySide(Value) end,
    })
    MenuGroup:AddDropdown("DPIDropdown", {
        Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
        Default = "100%",
        Text = "DPI Scale",
        Callback = function(Value)
            Value = Value:gsub("%%", "")
            UI.Library:SetDPIScale(tonumber(Value))
        end,
    })
    
    MenuGroup:AddDivider()
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "Insert", NoUI = true, Text = "Menu keybind" })
    UI.Library.ToggleKeybind = UI.Library.Options.MenuKeybind

    MenuGroup:AddButton("Unload", function()
        Cleanup(Flags)
        Cleanup(Connections)
        local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Hum then
            Hum.WalkSpeed = Defaults.WalkSpeed
            Hum.JumpPower = Defaults.JumpPower
            Hum.HipHeight = Defaults.HipHeight
        end
        workspace.Gravity = Defaults.Gravity
        workspace.CurrentCamera.FieldOfView = Defaults.FOV
        Lighting.ClockTime = Defaults.ClockTime
        RunS:Set3dRenderingEnabled(true)
        task.wait(0.05)
        UI.Library:Unload()
    end)

    UI.SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    UI.SaveManager:IgnoreThemeSettings()

    UI.SaveManager:BuildConfigSection(ConfigTab)
    UI.ThemeManager:ApplyToTab(ConfigTab)

    task.spawn(function()
        UI.SaveManager:LoadAutoloadConfig()
    end)
end

return Main
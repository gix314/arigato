-- // Services
local RunS = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local StarterPlr = game:GetService("StarterPlayer")

-- // Tables
local Defaults = {
    Gravity = workspace.Gravity,
    FOV = 70,
    ClockTime = Lighting.ClockTime
}

local Main = {}
local UI = getgenv().arigato.Utilities.UI

-- // Management Functions
arigato.Cleanup = function()
    local function DeepClean(tbl)
        for key, value in pairs(tbl) do
            if typeof(value) == "RBXScriptConnection" then
                value:Disconnect()
                tbl[key] = nil
            elseif typeof(value) == 'thread' then
                task.cancel(value)
                tbl[key] = nil
            elseif type(value) == 'table' then
                DeepClean(value)
            end
        end
    end

    DeepClean(arigato.Flags)
    DeepClean(arigato.Connections)
end

arigato.Thread = function(featurePath, featureFunc, isEnabled, ...)
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
function AddSliderToggle(Config)
    local Toggle = Config.Group:AddToggle(Config.Id, { 
        Text = Config.Text, 
        Default = Config.DefaultToggle or false 
    })
    
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

    return Toggle, Slider
end


function Main:AddPlayerTab(Window)
    local PlayerTab = Window:AddTab("Player", "user")

    local GB = {
        Left = {
            General = PlayerTab:AddLeftGroupbox("General", "user-cog"),
            Server = PlayerTab:AddLeftGroupbox("Server", "server"),
        },
        Right = {
            Game = PlayerTab:AddRightGroupbox("Game", "earth"),
            AntiMod = PlayerTab:AddRightGroupbox("Anti-Mod", "shield"),
        },
    }

    -- // General
    AddSliderToggle({ Group = GB.Left.General, Id = "WS", Text = "WalkSpeed", Default = 16, Min = 16, Max = 250 })
    local TPW_T, TPW_S = AddSliderToggle({ Group = GB.Left.General, Id = "TPW", Text = "TPWalk", Default = 1, Min = 1, Max = 10, Rounding = 1 })
    AddSliderToggle({ Group = GB.Left.General, Id = "JP", Text = "JumpPower", Default = 50, Min = 0, Max = 500 })
    AddSliderToggle({ Group = GB.Left.General, Id = "HH", Text = "HipHeight", Default = 2, Min = 0, Max = 10, Rounding = 1 })
    GB.Left.General:AddToggle("Noclip", { Text = "Noclip" })
    GB.Left.General:AddToggle("Disable3DRender", { Text = "Disable 3D Rendering" })
    AddSliderToggle({ Group = GB.Left.General, Id = "Grav", Text = "Gravity", Default = 196, Min = 0, Max = 500, Rounding = 1})
    AddSliderToggle({ Group = GB.Left.General, Id = "Zoom", Text = "Camera Zoom", Default = 128, Min = 128, Max = 10000 })
    AddSliderToggle({ Group = GB.Left.General, Id = "FOV", Text = "Field of View", Default = 70, Min = 30, Max = 120 })
    local FPS_T, FPS_S = AddSliderToggle({ Group = GB.Left.General, Id = "LimitFPS", Text = "Set Max FPS", DefaultToggle = true, Default = 60, Min = 30, Max = 240 })

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
    Library.Toggles.TPW:OnChanged(function(v)
        TPW_S:SetVisible(TPW_T.Value)
        arigato.Thread("TPW", FuncTPW, v)
    end)
    Library.Toggles.Noclip:OnChanged(function(v) arigato.Thread("Noclip", FuncNoclip, v) end)

    arigato.Connections.Player_General = RunS.Stepped:Connect(function()
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
        if FPS_T.Value then
            setfpscap(FPS_S.Value) 
        end
    end)
    Library.Toggles.LimitFPS:OnChanged(function(v)
        FPS_S:SetVisible(FPS_T.Value)
        if not v then
            setfpscap(999)
        else
--            setfpscap(FPS_S.Value)
        end
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

    local Watermark = Library:AddDraggableLabel("N/A")

    local FrameTimer = tick()
    local FrameCounter = 0;
    local FPS = 60;
    
    local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
        FrameCounter += 1;
    
        if (tick() - FrameTimer) >= 1 then
            FPS = FrameCounter;
            FrameTimer = tick();
            FrameCounter = 0;
        end;
    
        Watermark:SetText(('arigato | '..GameName..' | %s fps | %s ms'):format(
            math.floor(FPS),
            math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
        ));
    end);

    MenuGroup:AddToggle("WatermarkVisible", {
	    Default = false,
	    Text = "Show Watermark",
	    Callback = function(value)
		    Watermark:SetVisible(value)
	    end,
    })
    
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
        arigato.Cleanup()
        local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Hum then
            Hum.WalkSpeed = StarterPlr.CharacterWalkSpeed
            Hum.JumpPower = StarterPlr.CharacterJumpPower
            Hum.HipHeight = 2
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
        task.wait(0.1)
        UI.SaveManager:LoadAutoloadConfig()
    end)
end

return Main
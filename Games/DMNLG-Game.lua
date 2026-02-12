-- // Library
local arigato = getgenv().arigato
local UI = arigato.Utilities.UI
local Main = arigato.Utilities.Main

local Plrs = game:GetService('Players')
local Plr = Plrs.LocalPlayer
local RunS = game:GetService("RunService")

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = true
Library.ShowToggleFrameInKeybinds = true

-- // Variables
local EvidenceFound = {
    MaxEMF = 0,
    EMF5 = false,
    LaserProjector = false,
    GhostWriting = false,
    Fingerprint = false,
    Withered = false
}

--[[local Fonts = {}

for _, font in ipairs(Enum.Font:GetEnumItems()) do
    table.insert(Fonts, font.Name)
end

table.sort(Fonts)]]

local function GetFont(fontEnum)
    local mapping = {
        [Enum.Font.SourceSans] = 0, -- UI
        [Enum.Font.Roboto] = 1,     -- System
        [Enum.Font.Monospace] = 2,  -- Plex
        [Enum.Font.Fantasy] = 3     -- Cascadia
    }
    return mapping[fontEnum] or 0
end

-- // ESP Functions
local ESP_Cache = {
    Boxes = {},
    Names = {},
    Tracers = {},
}

local CurrentTargets = {}

-- // HELPERS
local function GetBoxCorners(part)
    local cf = part.CFrame
    local size = part.Size
    local corners = {
        cf * CFrame.new(-size.X/2,  size.Y/2,  0),
        cf * CFrame.new( size.X/2,  size.Y/2,  0),
        cf * CFrame.new(-size.X/2, -size.Y/2,  0),
        cf * CFrame.new( size.X/2, -size.Y/2,  0)
    }
    return corners
end

local function GetDrawBox(obj)
    if ESP_Cache.Boxes[obj] then return ESP_Cache.Boxes[obj] end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Transparency = 1
    box.Visible = false
    ESP_Cache.Boxes[obj] = box
    return box
end

local function GetDrawText(obj)
    if ESP_Cache.Names[obj] then return ESP_Cache.Names[obj] end
    local txt = Drawing.new("Text")
    txt.Size = 13
    txt.Outline = true
    txt.Center = true
    txt.Visible = false
    ESP_Cache.Names[obj] = txt
    return txt
end

local function ClearESP()
    for category, drawings in pairs(ESP_Cache) do
        for obj, drawing in pairs(drawings) do
            if drawing then
                drawing:Remove()
            end
        end
        table.clear(drawings)
    end
end

-- // Script Functions
local function Func_UnlockPerk()
    local ws = workspace
    while Toggles.UnlockPerk.Value do
        local allAttributes = ws:GetAttributes()
        for name, value in pairs(allAttributes) do
            if value ~= true and name:sub(1, 5) == "Perk_" and name ~= "Perk_TheEmperor" then
                ws:SetAttribute(name, true)
            end
        end
        task.wait(1)
    end
end

local function Func_FuseBox()
    local map = workspace:WaitForChild('Map', 5)
    local fuseBox = map and map:WaitForChild('FuseBox', 5)
    local prompt = fuseBox and fuseBox:FindFirstChild("ItemPrompt", true)
    
    if not fuseBox or not prompt then return end

    while Toggles.FuseBox.Value do
        if fuseBox:GetAttribute("Uninteractable") == false then
            fireproximityprompt(prompt)
        end
        task.wait(0.5)
    end
end

local function Func_Lights()
    local map = workspace:WaitForChild('Map', 5)
    if not map then return end
    
    local roomsFolder = map:WaitForChild('Rooms', 5)
    local fuseBox = map:WaitForChild('FuseBox', 5)
    
    while Toggles.Lights.Value do
        if fuseBox:GetAttribute("Uninteractable") == true then
            local rooms = roomsFolder:GetChildren()
            
            for i = 1, #rooms do
                local room = rooms[i]
                local lightSwitch = room:FindFirstChild("LightSwitch")
                
                if lightSwitch then
                    local onPart = lightSwitch:FindFirstChild("On")
                    local prompt = lightSwitch:FindFirstChild("ItemPrompt")
                    
                    if onPart and prompt and onPart.Transparency == 1 then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end
        task.wait(1)
    end
end

-- // UI Setup
local Window = Library:CreateWindow({
	Title = "arigato",
	Footer = "Demonology | BUILD 0.0.0.1 | DEV",
	NotifySide = "Right",
    Icon = 102363496463572,
	ShowCustomCursor = false,
	AutoShow = true,
	Center = true,
	EnableSidebarResize = true,
    Font = Enum.Font.Roboto,
})

local Tabs = {
	Main = Window:AddTab("Main", "box"),
}

local GB = {
	Main = {
		Left = {
			Auto = Tabs.Main:AddLeftGroupbox("Automation", "repeat"),
            Modifiers = Tabs.Main:AddLeftGroupbox("Modifiers", "sliders-horizontal"),
            Items = Tabs.Main:AddLeftGroupbox("Items", "backpack"),
		},
		Right = {
            Status = Tabs.Main:AddRightGroupbox("Status", "info"),
			ESP = Tabs.Main:AddRightGroupbox("ESP", "sliders-horizontal"),
		},
	},
}

local Status_HUD = Library:AddDraggableLabel("Initializing HUD...")

GB.Main.Right.Status:AddToggle("HUDVisible", {
    Text = "Enable Status Panel",
    Default = true,
})

GB.Main.Right.Status:AddSlider("StatusDelay", {
    Text = "Refresh Delay (s)",
    Default = 0.1,
    Min = 0.1,
    Max = 2,
    Rounding = 1,
})

-- // Main - Left - Automation
GB.Main.Left.Auto:AddToggle("FuseBox", {
    Text = "Auto Fuse Box",
    Default = false,
    Tooltip = "Always enable fuse box if disabled.\nNOTE: Not useful at all.",
})

GB.Main.Left.Auto:AddToggle("Lights", {
    Text = "Auto Enable Lights",
    Default = false,
    Tooltip = "Always keep the lights on.\nNOTE: why even bother using this",
})

GB.Main.Left.Modifiers:AddToggle("UnlockPerk", {
    Text = "Unlock Perks",
    Default = false,
    Tooltip = "Working:\nThe Strength (more stamina)\nNot Working:\nThe Emperor (additional item slot)\nUnknown: Other perks left",
})

-- // Main - Right - ESP
GB.Main.Right.ESP:AddToggle("Toggle_ESP", {
    Text = "ESP Enabled",
    Default = false,
})

GB.Main.Right.ESP:AddDropdown("Selected_ESP", {
    Text = "Select ESP Target (s)",
    Values = {"Ghost", "Items", "Players", "Orb", "Handprints"},
    Default = 1,
    Multi = true,
    Searchable = true,
})

local T_NameESP = GB.Main.Right.ESP:AddToggle("Name", {
    Text = "Name ESP",
    Default = false,
})

GB.Main.Right.ESP:AddDropdown("NameESP_Font", {
    Text = "Select Font",
    Values = {"SourceSans", "Roboto", "Monospace", "Fantasy"},
    Default = "SourceSans",
    Multi = false,
})

GB.Main.Right.ESP:AddInput("NameESP_Size", {
	Default = 28,
	Numeric = true,
	Finished = false,
	ClearTextOnFocus = true,
	Text = "Text Size",
	Placeholder = "Number..",
})

local CP_NameESP = T_NameESP:AddColorPicker("Color_NameESP", {
    Default = Color3.fromRGB(255,255,255),
    Title = "Select a color",
})

local T_BoxESP = GB.Main.Right.ESP:AddToggle("Box", {
    Text = "Box ESP",
    Default = false,
})

local CP_BoxESP = T_BoxESP:AddColorPicker("Color_BoxESP", {
    Default = Color3.fromRGB(255,255,255),
    Title = "Select a color",
})

-- // Status Update
task.spawn(function()
    while task.wait(tonumber(Options.StatusDelay.Value)) do
        local StatusLines = {} 
        local Ghost = workspace:FindFirstChild("Ghost")

        local char = Plr.Character
        local playerLoc = Plr:GetAttribute("CurrentRoom") or "Unknown"
        local playerEnergy = Plr:GetAttribute("Energy") or "Unknown"
        table.insert(StatusLines, "Player Location: " .. playerLoc)
        table.insert(StatusLines, "Energy: " .. playerEnergy)

        if Ghost then
            local isHunting = Ghost:GetAttribute("Hunting")
            local gGender = Ghost:GetAttribute("Gender") or "N/A"
            local gFav = Ghost:GetAttribute("FavoriteRoom") or "N/A"
            local gCur = Ghost:GetAttribute("CurrentRoom") or "N/A"
            
            if not EvidenceFound.LaserDetected then
                if Ghost:GetAttribute("InLaser") == true and Ghost:GetAttribute("LaserVisible") == true then
                    EvidenceFound.LaserDetected = true
                end
            end

            local stateText = isHunting and "<font color='#FF0000'>HUNTING</font>" or "<font color='#00b7ff'>Idle</font>"
            table.insert(StatusLines, "Ghost: " .. stateText)
            table.insert(StatusLines, "Gender: " .. gGender)
            table.insert(StatusLines, "Fav Room: " .. gFav)
            table.insert(StatusLines, "Cur Room: " .. gCur)

            local laserDisp = EvidenceFound.LaserDetected and "<font color='#00FF00'>Yes</font>" or "No"
            table.insert(StatusLines, "Laser Projector: " .. laserDisp)
        else
            table.insert(StatusLines, "Ghost: <font color='#AAAAAA'>Waiting...</font>")
        end

        local lowestTemp = 100
        local coldestRoomName = "N/A"
        
        local roomsFolder = workspace.Map:FindFirstChild("Rooms")
        if roomsFolder then
            for _, room in pairs(roomsFolder:GetChildren()) do
                local temp = tonumber(room:GetAttribute("Temperature"))
                if temp and temp < lowestTemp then
                    lowestTemp = temp
                    coldestRoomName = room.Name
                end
            end
        end

        local tDisplay = (coldestRoomName ~= "N/A") and string.format("%.2f°C (%s)", lowestTemp, coldestRoomName) or "N/A"
        
        if lowestTemp < 0 then
            tDisplay = "<font color='#00EBFF'>" .. tDisplay .. " [FREEZING]</font>"
        end
        table.insert(StatusLines, "Lowest Temperature: " .. tDisplay)

        table.insert(StatusLines, "Ghost Orb: " .. (workspace:FindFirstChild("GhostOrb") and "<font color='#00FF00'>Yes</font>" or "No"))
        if not EvidenceFound.Fingerprint then
            local fin = workspace:FindFirstChild("Handprints")
            if fin and #fin:GetChildren() > 0 then
                EvidenceFound.Fingerprint = true
            end
        end
        local fingerDisp = EvidenceFound.Fingerprint and "<font color='#00FF00'>Yes</font>" or "No"
        table.insert(StatusLines, "Handprints: " .. fingerDisp)

        local allItems = workspace.Items:GetChildren()
        for _, p in pairs(Plrs:GetPlayers()) do
            if p.Character then
                for _, obj in pairs(p.Character:GetChildren()) do
                    if obj:GetAttribute("ItemName") then table.insert(allItems, obj) end
                end
            end
        end

        for _, item in pairs(allItems) do
            local itemName = item:GetAttribute("ItemName")
            
            if not EvidenceFound.EMF5 then
                if itemName == "EMF Reader" then
                    local r = item:GetAttribute("ReadingLevel") or 0
                    if r >= 5 then
                        EvidenceFound.EMF5 = true
                        EvidenceFound.MaxEMF = 5
                    elseif r > EvidenceFound.MaxEMF then
                        EvidenceFound.MaxEMF = r
                    end
                end
            end

            if not EvidenceFound.WritingFound and itemName == "Spirit Book" then
                if item:GetAttribute("PhotoRewardType") == "GhostWriting" then
                    EvidenceFound.WritingFound = true
                end
            end

            if not EvidenceFound.WitheredFound and itemName == "Flower Pot" then
                if item:GetAttribute("PhotoRewardType") == "WitheredFlowers" then
                    EvidenceFound.Withered = true
                end
            end
        end

        local emfColor = EvidenceFound.EMF5 and "#00FF00" or "#FF0000"
        table.insert(StatusLines, string.format("EMF: <font color='%s'>%d</font>", emfColor, EvidenceFound.MaxEMF))
        
        table.insert(StatusLines, "Ghost Writing: " .. (EvidenceFound.WritingFound and "<font color='#00FF00'>Yes</font>" or "No"))
        table.insert(StatusLines, "Withered: " .. (EvidenceFound.WitheredFound and "<font color='#00FF00'>Yes</font>" or "No"))

        Status_HUD:SetText(table.concat(StatusLines, "\n"))
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not Toggles.Toggle_ESP.Value then 
            CurrentTargets = {}
            continue 
        end

        local newTargets = {}
        local Selected = Options.Selected_ESP.Value

        if Selected["Players"] then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(newTargets, {Instance = p.Character.HumanoidRootPart, Name = p.Name, Type = "Player"})
                end
            end
        end

        if Selected["Items"] and workspace:FindFirstChild("Items") then
            for _, itm in pairs(workspace.Items:GetChildren()) do
                table.insert(newTargets, {Instance = itm, Name = itm:GetAttribute("ItemName") or "Item", Type = "Item"})
            end
        end
        
        if Selected["Ghost"] and workspace:FindFirstChild("Ghost") then
             table.insert(newTargets, {Instance = workspace.Ghost, Name = "Ghost", Type = "Ghost"})
        end

        local HPFolder = workspace:FindFirstChild("Handprints")
        if Selected["Handprints"] and HPFolder then
            for _, printObj in ipairs(HPFolder:GetChildren()) do
                table.insert(newTargets, {Instance = printObj, Name = "Print", Type = "Handprint"})
            end
        end

        if Selected["Ghost Orb"] then
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name == "GhostOrb" or obj.Name == "Ghost Orb" then
                    table.insert(newTargets, {Instance = obj, Name = "Orb", Type = "GhostOrb"})
                end
            end
        end

        CurrentTargets = newTargets
    end
end)

arigato.Connections.ESP = RunS.RenderStepped:Connect(function()
    if not Toggles.Toggle_ESP.Value then
        for _, category in pairs(ESP_Cache) do
            for _, drawing in pairs(category) do
                drawing.Visible = false
            end
        end
        return
    end

    local Camera = workspace.CurrentCamera
    
    for _, data in pairs(CurrentTargets) do
        local obj = data.Instance
        if not obj or not obj.Parent then continue end

        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        
        local nameDrawing = GetDrawText(obj)
        if onScreen and Toggles.Name.Value then
            nameDrawing.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
            nameDrawing.Text = data.Name
            nameDrawing.Color = Options.Color_NameESP.Value
            nameDrawing.Visible = true
            nameDrawing.Size = tonumber(Options.NameESP_Size.Value) or 13
            nameDrawing.Font = GetFont(Enum.Font[Options.NameESP_Font.Value] or Enum.Font.SourceSans)
        else
            nameDrawing.Visible = false
        end

        local boxDrawing = GetDrawBox(obj)
        if onScreen and Toggles.Box.Value then
            local distance = (Camera.CFrame.Position - part.Position).Magnitude
            local size = (1 / distance) * 1000
            
            boxDrawing.Size = Vector2.new(size, size * 1.2)
            boxDrawing.Position = Vector2.new(screenPos.X - (size/2), screenPos.Y - (size/2))
            boxDrawing.Color = Options.Color_BoxESP.Value
            boxDrawing.Visible = true
        else
            boxDrawing.Visible = false
        end
    end
    for category, drawings in pairs(ESP_Cache) do
        for obj, drawing in pairs(drawings) do
            if not obj or not obj.Parent then
                drawing:Remove()
                drawings[obj] = nil
            end
        end
    end
end)

-- // ESP
local GH = Instance.new('Highlight')
GH.Adornee = workspace:FindFirstChild("Ghost")
GH.Parent = workspace:FindFirstChild("Ghost")
GH.FillTransparency = 1
GH.OutlineColor = Color3.fromRGB(255, 0, 0)

-- // Callbacks
Toggles.FuseBox:OnChanged(function(v)
    arigato.Thread('FuseBox', Func_FuseBox, v)
end)

Toggles.Lights:OnChanged(function(v)
    arigato.Thread('Lights', Func_Lights, v)
end)

Toggles.UnlockPerk:OnChanged(function(v)
    arigato.Thread('UnlockPerk', Func_UnlockPerk, v)
end)

Main:AddPlayerTab(Window)
Main:AddConfigTab(Window)

Library:OnUnload(function()
	ClearAllESP()
end)
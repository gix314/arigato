local arigato = getgenv().arigato
local UI = arigato.Utilities.UI
local Main = arigato.Utilities.Main

local Window = Library:CreateWindow({
	Title = "arigato",
	Footer = "Demonology | BUILD 0.0.0.1 | DEV",
	NotifySide = "Right",
	ShowCustomCursor = false,
	AutoShow = true,
	Center = true,
	EnableSidebarResize = true,
    Font = Enum.Font.Jura,
})

local Tabs = {
	Main = Window:AddTab("Main", "user"),
    Player = Window:AddTab("Player", "user-cog"),
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
    Player = {
        Left = {
            Modifiers = Tabs.Player:AddLeftGroupbox("Modifiers", "settings-2"),
        },
        Right = {

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
    Tooltip = "Always keep the lights on.",
})

GB.Main.Left.Modifiers:AddToggle("UnlockPerk", {
    Text = "Unlock Perks",
    Default = false,
    Tooltip = "Working:\n- The Strength\nNot Working:\n- The Emperor\nUnknown: Other perks left",
})

GB.Main.Left.Modifiers:AddToggle("Fullbright", {
    Text = "Fullbright",
    Default = false,
    Tooltip = "Fuck the game's lighting",
})

-- // Main - Right - ESP
GB.Main.Right.ESP:AddToggle("Toggle_ESP", {
    Text = "ESP Enabled",
    Default = false,
})

GB.Main.Right.ESP:AddDropdown("Selected_ESP", {
    Text = "Select ESP Target (s)",
    Values = {"Ghost", "Items", "Players", "Ghost Orb", "Fingerprints"},
    Default = 1,
    Multi = true,
    Searchable = true,
})

local T_NameESP = GB.Main.Right.ESP:AddToggle("Name", {
    Text = "Name ESP",
    Default = false,
})

GB.Main.Right.ESP:AddDropdown("NameESP_Font", {
    Text = "Select Text Font",
    Values = Fonts,
    Default = 16,
    Multi = false,
    Searchable = true,
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

-- // Player - Left
Tabs.Player:UpdateWarningBox({
    Title = "Warning",
    Text = "⚠️ Use in caution.",
    IsNormal = false,
    Visible = true,
    LockSize = true,
})

GB.Player.Left.Modifiers:AddToggle("WS", {
    Text = "Walkspeed",
    Default = false,
    Risky = false,
})

GB.Player.Left.Modifiers:AddSlider("WSValue", {
    Text = "Value",
    Default = 16,
    Min = 0,
    Max = 200,
    Rounding = 0,
})

GB.Player.Left.Modifiers:AddToggle("JP", {
    Text = "JumpPower",
    Default = false,
    Risky = false,
})

GB.Player.Left.Modifiers:AddSlider("JPValue", {
    Text = "Value",
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 0,
})

GB.Player.Left.Modifiers:AddToggle("TPW", {
    Text = "TPWalk",
    Default = false,
    Risky = false,
})

GB.Player.Left.Modifiers:AddSlider("TPWValue", {
    Text = "Value",
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 0,
})

Main:AddConfigTab(Window)
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

Main:AddConfigTab(Window)
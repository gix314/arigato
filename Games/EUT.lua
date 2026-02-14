-- // Library
local arigato = getgenv().arigato
local UI = arigato.Utilities.UI
local Main = arigato.Utilities.Main

local Plrs = game:GetService('Players')
local Plr = Plrs.LocalPlayer

local RunS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = true
Library.ShowToggleFrameInKeybinds = true

-- // Variables
local Remotes = {
    ChipSpin = RS:WaitForChild("remotes"):WaitForChild("gamble"),
    XPClick = RS:WaitForChild("remotes"):WaitForChild("click_xp"),
}

-- // Functions
local function Func_ClickXP()
    while Toggles.ClickXP.Value do
        Remotes.XPClick:FireServer()
        task.wait()
    end
end

local function Func_ChipSpin()
    while Toggles.ChipSpin.Value do
        Remotes.ChipSpin:InvokeServer()
        task.wait()
    end
end

local function Func_CollectMangoes()
    while Toggles.CollectMangoes.Value do
        if #workspace.objects.mangotree.mangoes:GetChildren() > 0 then
            for _,v in pairs(workspace.objects.mangotree.mangoes:GetChildren()) do
                v.CFrame = Plr.Character.HumanoidRootPart.CFrame
            end
        end
        task.wait()
    end
end

-- // UI Setup
local Window = Library:CreateWindow({
	Title = "arigato",
	Footer = "EUT | BUILD 0.0.0.1 | DEV",
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
		},
		Right = {

		},
	},
}

GB.Main.Left.Auto:AddToggle("ClickXP", {
    Text = "Auto Click XP",
    Default = false,
})

GB.Main.Left.Auto:AddToggle("ChipSpin", {
    Text = "Auto Chip Spin",
    Default = false,
})

GB.Main.Left.Auto:AddToggle("CollectMangoes", {
    Text = "Auto Collect Mangoes",
    Default = false,
})

-- // Callbacks

Toggles.ClickXP:OnChanged(function(v)
    arigato.Thread('ClickXP', Func_ClickXP, v)
end)

Toggles.ChipSpin:OnChanged(function(v)
    arigato.Thread('ChipSpin', Func_ChipSpin, v)
end)

Toggles.CollectMangoes:OnChanged(function(v)
    arigato.Thread('CollectMangoes', Func_CollectMangoes, v)
end)

Main:AddPlayerTab(Window)
Main:AddConfigTab(Window)

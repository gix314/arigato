local Main = {}
local UI = getgenv().arigato.Utilities.UI

function Main:AddConfigTab(Window)
    local GameName = getgenv().arigato.GameName or "Universal"
    local ConfigTab = Window:AddTab("Config", "cog")
    local MenuGroup = ConfigTab:AddLeftGroupbox("Menu")
    
    MenuGroup:AddToggle("KeybindMenuOpen", {
        Default = UI.Library.KeybindFrame.Visible,
        Text = "Open Keybind Menu",
        Callback = function(value)
            UI.Library.KeybindFrame.Visible = value
        end,
    })
    MenuGroup:AddToggle("ShowCustomCursor", {
        Text = "Custom Cursor",
        Default = false,
        Callback = function(Value)
            UI.Library.ShowCustomCursor = Value
        end,
    })
    MenuGroup:AddDropdown("NotificationSide", {
        Values = { "Left", "Right" },
        Default = "Right",

        Text = "Notification Side",

        Callback = function(Value)
            UI.Library:SetNotifySide(Value)
        end,
    })
    MenuGroup:AddDropdown("DPIDropdown", {
        Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
        Default = "100%",

        Text = "DPI Scale",

        Callback = function(Value)
            Value = Value:gsub("%%", "")
            local DPI = tonumber(Value)

            UI.Library:SetDPIScale(DPI)
        end,
    })
    MenuGroup:AddDivider()
    MenuGroup:AddLabel("Menu bind")
        :AddKeyPicker("MenuKeybind", { Default = "Insert", NoUI = true, Text = "Menu keybind" })

    MenuGroup:AddButton("Unload", function()
        UI.Library:Unload()
    end)
    
    UI.Library.ToggleKeybind = UI.Library.Options.MenuKeybind

    UI.SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    UI.SaveManager:IgnoreThemeSettings()
    UI.SaveManager:BuildConfigSection(ConfigTab)
    UI.ThemeManager:ApplyToTab(ConfigTab)

    UI.ThemeManager:SetFolder("arigato")
    UI.SaveManager:SetFolder("arigato/" .. GameName)
    
    UI.SaveManager:LoadAutoloadConfig()
end

return Main
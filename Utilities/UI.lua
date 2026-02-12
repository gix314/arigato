local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

return {
    Library = Library,
    ThemeManager = ThemeManager,
    SaveManager = SaveManager
}

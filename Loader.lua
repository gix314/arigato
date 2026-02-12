repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.GameId ~= 0

local Branch = ...
local Source = "https://raw.githubusercontent.com/gix314/arigato/" .. Branch .. "/"

local function LoadScript(Path)
    local Success, Result = pcall(function()
        return loadstring(game:HttpGet(Source .. Path .. ".lua"))()
    end)
    
    if not Success then
        warn("Failed to load script: " .. Path .. " | Error: " .. Result)
        return nil
    end
    return Result
end

getgenv().arigato = {
    Utilities = {},
    Flags = {},
    Connections = {},
    GameName = "Universal"
}

arigato.Utilities.UI = LoadScript("Utilities/UI")
arigato.Utilities.Main = LoadScript("Utilities/Main")

local Games = {
    [18794863104] = {Name = "Demonology", Script = "Games/DMNLG-Game"},
}

local GameData = Games[game.PlaceId]

if GameData then
    getgenv().arigato.GameName = GameData.Name 
    
    arigato.Utilities.UI.Library:Notify({
        Title = "arigato",
        Description = "Supported game detected: " .. GameData.Name .. "\nAttempt to load script..",
        Time = 5
    })
    LoadScript(GameData.Script)
else
    getgenv().arigato.GameName = "Universal"
    
    arigato.Utilities.UI.Library:Notify({
        Title = "arigato",
        Description = "Unsupported game detected, loading Universal script..",
        Time = 5
    })
    LoadScript("Games/Universal")
end
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.GameId ~= 0

local Branch = "main"
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
    Utilities = {}
}

arigato.Utilities.UI = LoadScript("Utilities/UI")
arigato.Utilities.Main = LoadScript("Utilities/Main")

local Games = {
    [18794863104] = {Name = "Demonology", Script = "Games/DMNLG-Game"},
}

local GameData = Games[game.PlaceId]

if GameData then
    arigato.Utilities.UI.Library:Notify({
        Title = "arigato",
        Description = "Detected supported game: " .. GameData.Name .. "\nAttempt to load script..",
        Time = 5
    })
    LoadScript(GameData.Script)
else
    arigato.Utilities.UI.Library:Notify({
        Title = "arigato",
        Description = "Detected unsupported game.\nLoading Universal script..",
        Time = 5
    })
    LoadScript("Games/Universal")
end

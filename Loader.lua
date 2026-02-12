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
    ["18794863104"] = "Games/DMNLG-Game",
}

local GameScript = Games[game.PlaceId] or "Games/Universal"
LoadScript(GameScript)

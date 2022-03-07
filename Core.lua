local addonName, Dev = ...
local P = Dev.pixelPerfectFuncs

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

function eventFrame:ADDON_LOADED(arg1)
    if arg1 == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
        if type(DevDB) ~= "table" then DevDB = {} end
        if type(DevDB["show"]) ~= "boolean" then DevDB["show"] = true end
        if type(DevDB["scale"]) ~= "number" then DevDB["scale"] = 1 end
        
        if type(DevInstanceDebuffs) ~= "table" then
            DevInstanceDebuffs = {
                ["trackings"] = {
                    -- [id] = {enabled, name, {}},
                },
            }
        end

        Dev:UpdateScale()
        Dev:Fire("UpdateVisibility")
    end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

-------------------------------------------------
-- functions
-------------------------------------------------
function Dev:UpdateScale()
    P:SetRelativeScale(DevDB["scale"])
    P:SetEffectiveScale(DevTooltip)
    P:SetEffectiveScale(DevMainFrame)
end

-------------------------------------------------
-- slash command
-------------------------------------------------
SLASH_DEV1 = "/dev"
function SlashCmdList.DEV(msg, editbox)
    -- local command, rest = msg:match("^(%S*)%s*(.-)$")
    -- if command == "options" or command == "opt" then
    -- elseif command == "reset" then
    --     if rest == "position" then
    --     end
    -- end
    DevDB["show"] = not DevDB["show"]
    Dev:Fire("UpdateVisibility")
end
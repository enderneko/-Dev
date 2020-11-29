local addonName, Dev = ...

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

function eventFrame:ADDON_LOADED(arg1)
    if arg1 == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
        if type(DevDB) ~= "table" then DevDB = {} end
        if type(DevInstanceDebuffs) ~= "table" then
            DevInstanceDebuffs = {
                ["trackings"] = {
                    -- [id] = {enabled, name},
                },
            }
        end

        Dev:Fire("UpdateVisibility")
    end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)
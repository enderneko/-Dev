local addonName, Dev = ...
DevTools = Dev

local P = Dev.pixelPerfectFuncs

Dev.isAsian = LOCALE_zhCN or LOCALE_zhTW or LOCALE_koKR
Dev.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
Dev.isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
Dev.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

function eventFrame:ADDON_LOADED(arg1)
    if arg1 == addonName then
        eventFrame:UnregisterEvent("ADDON_LOADED")
        if type(DevDB) ~= "table" then DevDB = {} end
        if type(DevDB["show"]) ~= "boolean" then DevDB["show"] = true end
        if type(DevDB["scale"]) ~= "number" then DevDB["scale"] = 1 end

        if type(DevInstance) ~= "table" then
            DevInstance = {
                ["instances"] = {
                    -- [id] = {name=string, enabled=boolean}
                },
                ["debuffs"] = {
                    -- [sourceName] = {spellId=spellname}
                },
                ["casts"] = {
                    -- [sourceName] = {spellId=spellname}
                }
            }
        end

        -- convert old
        if type(DevInstanceDebuffs) == "table" then
            for id, t in pairs(DevInstanceDebuffs["trackings"]) do
                DevInstance["instances"][id] = {["name"]=t[2], ["enabled"]=t[1]}
                DevInstance["debuffs"][id] = t[3]
                DevInstance["casts"][id] = {}
            end
            DevInstanceDebuffs = nil
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
local _, Dev = ...
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local currentInstanceName, currentInstanceID
local LoadInstances, LoadEnemies, LoadDebuffs

local instanceDebuffs = CreateFrame("Frame", "DevInstanceDebuffsFrame", nil, "BackdropTemplate")
LPP:PixelPerfectScale(instanceDebuffs)
instanceDebuffs:Hide()
instanceDebuffs:SetSize(530, 400)
instanceDebuffs:SetPoint("CENTER")
instanceDebuffs:SetFrameStrata("LOW")
instanceDebuffs:SetMovable(true)
instanceDebuffs:SetUserPlaced(true)
instanceDebuffs:SetClampedToScreen(true)
instanceDebuffs:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
instanceDebuffs:SetBackdropColor(.05, .05, .05, .9)
instanceDebuffs:SetBackdropBorderColor(0, 0, 0, 1)
instanceDebuffs:EnableMouse(true)
instanceDebuffs:RegisterForDrag("LeftButton")
instanceDebuffs:SetScript("OnDragStart", function()
    instanceDebuffs:StartMoving()
end)
instanceDebuffs:SetScript("OnDragStop", function()
    instanceDebuffs:StopMovingOrSizing()
    LPP:PixelPerfectPoint(instanceDebuffs)
end)

local init
instanceDebuffs:SetScript("OnShow", function()
    if not init then
        init = true
        LoadInstances()
    end
end)
instanceDebuffs:SetScript("OnHide", function()
    DevTooltip:Hide()
end)

local title = instanceDebuffs:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
title:SetPoint("TOP", 0, -3)
title:SetText("Instance Debuffs")
title:SetTextColor(.9, .9, .1)

local instanceIDText = instanceDebuffs:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
instanceIDText:SetPoint("TOPLEFT", 5, -20)

local instanceNameText = instanceDebuffs:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
instanceNameText:SetPoint("LEFT", instanceIDText, "RIGHT", 10, 0)

local statusText = instanceDebuffs:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
statusText:SetPoint("LEFT", instanceNameText, "RIGHT", 10, 0)

-- reset
local resetBtn = Dev:CreateButton(instanceDebuffs, "Reset", "red", {45, 20}, false, false, "Shift + Left-Click to reset & reload")
resetBtn:SetPoint("TOPRIGHT")
resetBtn:SetScript("OnClick", function()
    if IsShiftKeyDown() then
        DevInstanceDebuffs = nil
        ReloadUI()
    end
end)

-- aadd & track
local addBtn = Dev:CreateButton(instanceDebuffs, "Add Current Instance", "red", {170, 20})
addBtn:SetPoint("TOPLEFT", 5, -40)
addBtn:SetScript("OnClick", function()
    if currentInstanceName and currentInstanceID then
        if not DevInstanceDebuffs["trackings"][currentInstanceID] then
            DevInstanceDebuffs["trackings"][currentInstanceID] = {true, currentInstanceName, {}}
            LoadInstances()
            instanceDebuffs:PLAYER_ENTERING_WORLD()
        end
    end
end)

local tips = instanceDebuffs:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
tips:SetPoint("LEFT", addBtn, "RIGHT", 5, 0)
tips:SetText("[Right-Click] track/untrack, [Shift+Left-Click] delete")

-------------------------------------------------
-- instance list
-------------------------------------------------
local instanceListFrame = CreateFrame("Frame", nil, instanceDebuffs, "BackdropTemplate")
Dev:StylizeFrame(instanceListFrame)
instanceListFrame:SetPoint("TOPLEFT", addBtn, "BOTTOMLEFT", 0, -5)
instanceListFrame:SetPoint("BOTTOMRIGHT", instanceDebuffs, "BOTTOMLEFT", 175, 5)

Dev:CreateScrollFrame(instanceListFrame)
local currentInstanceHighlight = CreateFrame("Frame", nil, instanceDebuffs, "BackdropTemplate")
currentInstanceHighlight:SetFrameLevel(10)
Dev:StylizeFrame(currentInstanceHighlight, {0,0,0,0}, {.2, 1, .2})

local instanceButtons = {}
local selectedInstance
LoadInstances = function()
    wipe(instanceButtons)
    instanceListFrame.scrollFrame:Reset()

    local last
    for id, t in pairs(DevInstanceDebuffs["trackings"]) do
        local b = Dev:CreateButton(instanceListFrame.scrollFrame.content, id.." "..t[2], "red-hover", {20, 20}, true)
        tinsert(instanceButtons, b)

        b:GetFontString():ClearAllPoints()
        b:GetFontString():SetPoint("LEFT", 5, 0)
        b:GetFontString():SetPoint("RIGHT", -5, 0)
        b:GetFontString():SetJustifyH("LEFT")

        if not t[1] then
            b:GetFontString():SetTextColor(.4, .4, .4, 1)
        end

        if last then
            b:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 1)
        else
            b:SetPoint("TOPLEFT", 1, -1)
        end
        b:SetPoint("RIGHT", -1, 0)

        last = b

        b:RegisterForClicks("AnyUp")
        b:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                currentInstanceHighlight:Hide()
                currentInstanceHighlight:ClearAllPoints()
                if IsShiftKeyDown() then -- delete
                    DevInstanceDebuffs["trackings"][id] = nil
                    LoadInstances()
                    if selectedInstance == id then
                        LoadEnemies(nil)
                        LoadDebuffs(nil)
                    end
                    if id == currentInstanceID then
                        statusText:SetText("")
                        instanceDebuffs:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
                    end
                else -- show enemies
                    selectedInstance = id
                    currentInstanceHighlight:Show()
                    currentInstanceHighlight:SetAllPoints(b)
                    LoadEnemies(DevInstanceDebuffs["trackings"][id][3])
                    LoadDebuffs(nil)
                end
            elseif button == "RightButton" then -- track/untrack
                t[1] = not t[1]
                if t[1] then
                    b:GetFontString():SetTextColor(1, 1, 1, 1)
                else
                    b:GetFontString():SetTextColor(0.4, 0.4, 0.4, 1)
                end

                if id == currentInstanceID then
                    if t[1] then
                        statusText:SetText("|cff55ff55TRACKING")
                        print("|cff77ff00START TRACKING DEBUFFS!")
                        instanceDebuffs:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
                    else
                        statusText:SetText("")
                        print("|cffff7700STOP TRACKING DEBUFFS!")
                        instanceDebuffs:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
                    end
                end
            end
        end)
    end

    instanceListFrame.scrollFrame:SetContentHeight(20, #instanceButtons, -1)
end

-------------------------------------------------
-- enemy list
-------------------------------------------------
local enemyListFrame = CreateFrame("Frame", nil, instanceDebuffs, "BackdropTemplate")
Dev:StylizeFrame(enemyListFrame)
enemyListFrame:SetPoint("TOPLEFT", instanceListFrame, "TOPRIGHT", 5, 0)
enemyListFrame:SetPoint("BOTTOMRIGHT", instanceListFrame, "BOTTOMRIGHT", 175, 0)

Dev:CreateScrollFrame(enemyListFrame)
local currentEnemyHighlight = CreateFrame("Frame", nil, instanceDebuffs, "BackdropTemplate")
currentEnemyHighlight:SetFrameLevel(10)
Dev:StylizeFrame(currentEnemyHighlight, {0,0,0,0}, {.2, 1, .2})

local enemyButtons = {}
LoadEnemies = function(instanceTable)
    wipe(enemyButtons)
    enemyListFrame.scrollFrame:Reset()
    currentEnemyHighlight:Hide()
    currentEnemyHighlight:ClearAllPoints()

    if not instanceTable then return end

    local last
    for enemy, t in pairs(instanceTable) do
        local b = Dev:CreateButton(enemyListFrame.scrollFrame.content, enemy, "red-hover", {20, 20}, true)
        tinsert(enemyButtons, b)

        b:GetFontString():ClearAllPoints()
        b:GetFontString():SetPoint("LEFT", 5, 0)
        b:GetFontString():SetPoint("RIGHT", -5, 0)
        b:GetFontString():SetJustifyH("LEFT")

        if last then
            b:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 1)
        else
            b:SetPoint("TOPLEFT", 1, -1)
        end
        b:SetPoint("RIGHT", -1, 0)

        last = b

        b:RegisterForClicks("AnyUp")
        b:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                currentEnemyHighlight:Hide()
                currentEnemyHighlight:ClearAllPoints()
                if IsShiftKeyDown() then
                    instanceTable[enemy] = nil
                    LoadDebuffs(nil)
                    LoadEnemies(instanceTable)
                else
                    currentEnemyHighlight:Show()
                    currentEnemyHighlight:SetAllPoints(b)
                    LoadDebuffs(t)
                end
            end
        end)
    end

    enemyListFrame.scrollFrame:SetContentHeight(20, #enemyButtons, -1)
end

-------------------------------------------------
-- debuff list
-------------------------------------------------
local debuffListFrame = CreateFrame("Frame", nil, instanceDebuffs, "BackdropTemplate")
Dev:StylizeFrame(debuffListFrame)
debuffListFrame:SetPoint("TOPLEFT", enemyListFrame, "TOPRIGHT", 5, 0)
debuffListFrame:SetPoint("BOTTOMRIGHT", enemyListFrame, "BOTTOMRIGHT", 175, 0)

Dev:CreateScrollFrame(debuffListFrame)
local currentDebuffHighlight = CreateFrame("Frame", nil, instanceDebuffs, "BackdropTemplate")
currentDebuffHighlight:SetFrameLevel(10)
Dev:StylizeFrame(currentDebuffHighlight, {0,0,0,0}, {.2, 1, .2})

local debuffButtons = {}
LoadDebuffs = function(enemyTable)
    wipe(debuffButtons)
    debuffListFrame.scrollFrame:Reset()
    currentDebuffHighlight:Hide()
    currentDebuffHighlight:ClearAllPoints()
    DevTooltip:Hide()

    if not enemyTable then return end

    local last
    for id, name in pairs(enemyTable) do
        local icon = select(3, GetSpellInfo(id))
        local b = Dev:CreateButton(debuffListFrame.scrollFrame.content, "|T"..icon..":0|t "..id.." "..name, "red-hover", {20, 20}, true)
        tinsert(debuffButtons, b)

        b:GetFontString():ClearAllPoints()
        b:GetFontString():SetPoint("LEFT", 5, 0)
        b:GetFontString():SetPoint("RIGHT", -5, 0)
        b:GetFontString():SetJustifyH("LEFT")

        if last then
            b:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 1)
        else
            b:SetPoint("TOPLEFT", 1, -1)
        end
        b:SetPoint("RIGHT", -1, 0)

        last = b

        b:RegisterForClicks("AnyUp")
        b:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                currentDebuffHighlight:Hide()
                currentDebuffHighlight:ClearAllPoints()
                if IsShiftKeyDown() then
                    enemyTable[id] = nil
                    LoadDebuffs(enemyTable)
                else
                    currentDebuffHighlight:Show()
                    currentDebuffHighlight:SetAllPoints(b)
                    DevTooltip:SetOwner(instanceDebuffs, "ANCHOR_NONE")
                    DevTooltip:SetPoint("LEFT", instanceDebuffs, "RIGHT", 1, 0)
                    DevTooltip:SetHyperlink("spell:"..id)
                    DevTooltip:Show()
                end
            end
        end)
    end

    debuffListFrame.scrollFrame:SetContentHeight(20, #debuffButtons, -1)
end

-------------------------------------------------
-- main button
-------------------------------------------------
local instanceDebuffsBtn = Dev:CreateMainButton(2, 254886, function(self)
    DevDB["showInstanceDebuffs"] = not DevDB["showInstanceDebuffs"]
    if DevDB["showInstanceDebuffs"] then
        self.tex:SetDesaturated(false)
        instanceDebuffs:Show()
    else
        self.tex:SetDesaturated(true)
        instanceDebuffs:Hide()
    end
end)

local function UpdateVisibility()
    if DevDB["showInstanceDebuffs"] then
        instanceDebuffs:Show()
        instanceDebuffsBtn.tex:SetDesaturated(false)
    end
end
Dev:RegisterCallback("UpdateVisibility", "DevInstanceDebuffs_UpdateVisibility", UpdateVisibility)


-------------------------------------------------
-- event
-------------------------------------------------
local units = {
    ["player"] = true,
    ["party1"] = true,
    ["party2"] = true,
    ["party3"] = true,
    ["party4"] = true,
}

instanceDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
-- instanceDebuffs:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

function instanceDebuffs:PLAYER_ENTERING_WORLD()
    if IsInInstance() then
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
        instanceIDText:SetText("ID: |cffff5500"..instanceID)
        instanceNameText:SetText("Name: |cffff5500"..name)
        currentInstanceName, currentInstanceID = name, instanceID
        if DevInstanceDebuffs["trackings"][currentInstanceID] and DevInstanceDebuffs["trackings"][currentInstanceID][1] then
            statusText:SetText("|cff55ff55TRACKING")
            print("|cff77ff00START TRACKING DEBUFFS!")
            instanceDebuffs:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        else
            statusText:SetText("")
            instanceDebuffs:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    else
        currentInstanceName, currentInstanceID = nil, nil
        instanceNameText:SetText("Name:")
        instanceIDText:SetText("ID:")
        statusText:SetText("")
        instanceDebuffs:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

-- https://wowpedia.fandom.com/wiki/UnitFlag
local OBJECT_AFFILIATION_MINE = 0x00000001
local OBJECT_AFFILIATION_PARTY = 0x00000002
local OBJECT_AFFILIATION_RAID = 0x00000004
local OBJECT_REACTION_HOSTILE = 0x00000040
local OBJECT_REACTION_NEUTRAL = 0x00000020

local function IsFriend(unitFlags)
    if not unitFlags then return false end
    return (bit.band(unitFlags, OBJECT_AFFILIATION_MINE) ~= 0) or (bit.band(unitFlags, OBJECT_AFFILIATION_RAID) ~= 0) or (bit.band(unitFlags, OBJECT_AFFILIATION_PARTY) ~= 0)
end

local function IsEnemy(unitFlags)
    if not unitFlags then return false end
    return (bit.band(unitFlags, OBJECT_REACTION_HOSTILE) ~= 0) or (bit.band(unitFlags, OBJECT_REACTION_NEUTRAL) ~= 0)
end

function instanceDebuffs:COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, auraType, amount = ...
    if event ~= "SPELL_AURA_APPLIED" or auraType ~= "DEBUFF" then
        return
    end

    if IsEnemy(sourceFlags) and IsFriend(destFlags) and currentInstanceName and currentInstanceID and spellId then
        if not sourceName then sourceName = "UNKNOWN" end
        if type(DevInstanceDebuffs["trackings"][currentInstanceID][3][sourceName]) ~= "table" then DevInstanceDebuffs["trackings"][currentInstanceID][3][sourceName] = {} end
        DevInstanceDebuffs["trackings"][currentInstanceID][3][sourceName][spellId] = spellName
    end
end

instanceDebuffs:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
    else
        self[event](self, ...)
    end
end)
local _, Dev = ...
local P = Dev.pixelPerfectFuncs

local currentInstanceName, currentInstanceID
local LoadInstances, LoadEnemies, LoadDebuffs, LoadCasts, Export
local RegisterEvents, UnregisterEvents

local instanceSpells = CreateFrame("Frame", "DevInstanceSpellsFrame", DevMainFrame, "BackdropTemplate")
instanceSpells:Hide()
instanceSpells:SetSize(725, 400)
instanceSpells:SetPoint("CENTER")
instanceSpells:SetFrameStrata("LOW")
instanceSpells:SetMovable(true)
instanceSpells:SetUserPlaced(true)
instanceSpells:SetClampedToScreen(true)
instanceSpells:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
instanceSpells:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
instanceSpells:SetBackdropBorderColor(0, 0, 0, 1)
instanceSpells:EnableMouse(true)
instanceSpells:RegisterForDrag("LeftButton")
instanceSpells:SetScript("OnDragStart", function()
    instanceSpells:StartMoving()
end)
instanceSpells:SetScript("OnDragStop", function()
    instanceSpells:StopMovingOrSizing()
    P:PixelPerfectPoint(instanceSpells)
end)

local init
instanceSpells:SetScript("OnShow", function()
    if not init then
        init = true
        LoadInstances()
    end
end)
-- instanceSpells:SetScript("OnHide", function()
--     DevTooltip:Hide()
-- end)

-- title
local title = instanceSpells:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
title:SetPoint("TOP", 0, -3)
title:SetText("Instance Spell Collector")
title:SetTextColor(.9, .9, .1)

local instanceIDText = instanceSpells:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
instanceIDText:SetPoint("TOPLEFT", 5, -20)

local instanceNameText = instanceSpells:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
instanceNameText:SetPoint("LEFT", instanceIDText, "RIGHT", 10, 0)

local statusText = instanceSpells:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
statusText:SetPoint("LEFT", instanceNameText, "RIGHT", 10, 0)

-- reset
local resetBtn = Dev:CreateButton(instanceSpells, "Reset", "red", {45, 20}, false, false, "Ctrl + Left-Click to reset & reload")
resetBtn:SetPoint("TOPRIGHT")
resetBtn:SetScript("OnClick", function()
    if IsControlKeyDown() then
        DevInstance = nil
        ReloadUI()
    end
end)

-- aadd & track
local addBtn = Dev:CreateButton(instanceSpells, "Add Current Instance", "red", {175, 20})
addBtn:SetPoint("TOPLEFT", 5, -40)
addBtn:SetScript("OnClick", function()
    if currentInstanceName and currentInstanceID then
        if not DevInstance["instances"][currentInstanceID] then
            DevInstance["instances"][currentInstanceID] = {["name"]=currentInstanceName, ["enabled"]=true}
            DevInstance["debuffs"][currentInstanceID] = {}
            DevInstance["casts"][currentInstanceID] = {}
            LoadInstances()
            instanceSpells:PLAYER_ENTERING_WORLD()
        end
    end
end)

-- tips
local tips = instanceSpells:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
tips:SetPoint("LEFT", addBtn, "RIGHT", 5, 0)
tips:SetText("[Right-Click] track/untrack, [Ctrl-Click] delete")

-------------------------------------------------
-- instance list
-------------------------------------------------
local instanceListFrame = CreateFrame("Frame", nil, instanceSpells, "BackdropTemplate")
Dev:StylizeFrame(instanceListFrame)
instanceListFrame:SetPoint("TOPLEFT", addBtn, "BOTTOMLEFT", 0, -5)
instanceListFrame:SetPoint("BOTTOMRIGHT", instanceSpells, "BOTTOMLEFT", 180, 5)

Dev:CreateScrollFrame(instanceListFrame)
local currentInstanceHighlight = CreateFrame("Frame", nil, instanceSpells, "BackdropTemplate")
currentInstanceHighlight:SetFrameLevel(10)
Dev:StylizeFrame(currentInstanceHighlight, {0,0,0,0}, {.2, 1, .2})

local sotredInstances = {}
local instanceButtons = {}
local selectedInstance
LoadInstances = function()
    wipe(sotredInstances)
    wipe(instanceButtons)
    instanceListFrame.scrollFrame:Reset()

    for id in pairs(DevInstance["instances"]) do
        tinsert(sotredInstances, id)
    end
    table.sort(sotredInstances)

    local last
    for _, id in pairs(sotredInstances) do
        local b = Dev:CreateButton(instanceListFrame.scrollFrame.content, id.." "..DevInstance["instances"][id]["name"], "red-hover", {20, 20}, true)
        tinsert(instanceButtons, b)

        b:GetFontString():ClearAllPoints()
        b:GetFontString():SetPoint("LEFT", 5, 0)
        b:GetFontString():SetPoint("RIGHT", -5, 0)
        b:GetFontString():SetJustifyH("LEFT")

        if not DevInstance["instances"][id]["enabled"] then
            b:GetFontString():SetTextColor(0.4, 0.4, 0.4, 1)
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
                if IsControlKeyDown() then -- delete
                    if id == currentInstanceID then
                        statusText:SetText("")
                        instanceSpells:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
                        if DevInstance["instances"][id]["enabled"] then print("|cffff7700STOP TRACKING DEBUFFS!") end
                    end
                    DevInstance["instances"][id] = nil
                    DevInstance["debuffs"][id] = nil
                    DevInstance["casts"][id] = nil
                    LoadInstances()
                    if selectedInstance == id then
                        LoadEnemies()
                    end
                else -- show enemies
                    selectedInstance = id
                    currentInstanceHighlight:Show()
                    currentInstanceHighlight:SetAllPoints(b)
                    currentInstanceHighlight:SetParent(b)
                    LoadEnemies(DevInstance["debuffs"][id], DevInstance["casts"][id])
                end
                LoadDebuffs()
                LoadCasts()
                Export()
            elseif button == "RightButton" then -- track/untrack
                DevInstance["instances"][id]["enabled"] = not DevInstance["instances"][id]["enabled"]
                if DevInstance["instances"][id]["enabled"] then
                    b:GetFontString():SetTextColor(1, 1, 1, 1)
                else
                    b:GetFontString():SetTextColor(0.4, 0.4, 0.4, 1)
                end

                if id == currentInstanceID then
                    if DevInstance["instances"][id]["enabled"] then
                        statusText:SetText("|cff55ff55TRACKING")
                        print("|cff77ff00START TRACKING DEBUFFS!")
                        RegisterEvents()
                    else
                        statusText:SetText("")
                        print("|cffff7700STOP TRACKING DEBUFFS!")
                        UnregisterEvents()
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
local enemyListFrame = CreateFrame("Frame", nil, instanceSpells, "BackdropTemplate")
Dev:StylizeFrame(enemyListFrame)
enemyListFrame:SetPoint("TOPLEFT", instanceListFrame, "TOPRIGHT", 5, 0)
enemyListFrame:SetPoint("BOTTOMRIGHT", instanceListFrame, "BOTTOMRIGHT", 180, 0)

Dev:CreateScrollFrame(enemyListFrame)
local currentEnemyHighlight = CreateFrame("Frame", nil, instanceSpells, "BackdropTemplate")
currentEnemyHighlight:SetFrameLevel(10)
Dev:StylizeFrame(currentEnemyHighlight, {0,0,0,0}, {.2, 1, .2})

local sortedEnemies = {}
local enemyButtons = {}
LoadEnemies = function(debuffs, casts)
    wipe(enemyButtons)
    wipe(sortedEnemies)
    enemyListFrame.scrollFrame:Reset()
    currentEnemyHighlight:Hide()
    currentEnemyHighlight:ClearAllPoints()

    if not (debuffs and casts) then return end

    -- sort
    local enemies = {}
    for k in pairs(debuffs) do
        enemies[k] = true
    end
    for k in pairs(casts) do
        enemies[k] = true
    end
    for k in pairs(enemies) do
        tinsert(sortedEnemies, k)
    end
    table.sort(sortedEnemies, function(a, b)
        if strfind(a, "|cff") and not strfind(b, "|cff") then
            return true
        elseif not strfind(a, "|cff") and strfind(b, "|cff") then
            return false
        elseif strfind(a, "*") and not strfind(b, "*") then
            return false
        elseif not strfind(a, "*") and strfind(b, "*") then
            return true
        else
            return a < b
        end
    end)

    local last
    for _, enemy in ipairs(sortedEnemies) do
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
            if IsControlKeyDown() then
                currentEnemyHighlight:Hide()
                currentEnemyHighlight:ClearAllPoints()
                debuffs[enemy] = nil
                LoadEnemies(debuffs, casts)
                LoadDebuffs()
                LoadCasts()
            else
                currentEnemyHighlight:Show()
                currentEnemyHighlight:SetAllPoints(b)
                currentEnemyHighlight:SetParent(b)
                LoadDebuffs(debuffs[enemy])
                LoadCasts(casts[enemy])
            end
            Export(debuffs[enemy], casts[enemy])
        end)
    end

    enemyListFrame.scrollFrame:SetContentHeight(20, #enemyButtons, -1)
end

-------------------------------------------------
-- debuff list
-------------------------------------------------
local debuffListFrame = CreateFrame("Frame", nil, instanceSpells, "BackdropTemplate")
Dev:StylizeFrame(debuffListFrame)
debuffListFrame:SetPoint("TOPLEFT", enemyListFrame, "TOPRIGHT", 5, 0)
debuffListFrame:SetPoint("BOTTOMRIGHT", enemyListFrame, "BOTTOMRIGHT", 180, 0)

Dev:CreateScrollFrame(debuffListFrame)
local currentDebuffHighlight = CreateFrame("Frame", nil, instanceSpells, "BackdropTemplate")
currentDebuffHighlight:SetFrameLevel(10)
Dev:StylizeFrame(currentDebuffHighlight, {0,0,0,0}, {0.2, 1, 0.2})

local sortedDebuffs = {}
local debuffButtons = {}
LoadDebuffs = function(debuffs)
    wipe(debuffButtons)
    wipe(sortedDebuffs)
    debuffListFrame.scrollFrame:Reset()
    currentDebuffHighlight:Hide()
    currentDebuffHighlight:ClearAllPoints()
    DevTooltip:Hide()

    if not debuffs then return end

    for id in pairs(debuffs) do
        tinsert(sortedDebuffs, id)
    end
    table.sort(sortedDebuffs)

    local last
    for _, id in ipairs(sortedDebuffs) do
        local icon = select(3, GetSpellInfo(id))
        local b = Dev:CreateButton(debuffListFrame.scrollFrame.content, "|T"..icon..":16:16:0:0:16:16|t "..id.." "..debuffs[id], "red-hover", {20, 20}, true)
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
                if IsControlKeyDown() then
                    debuffs[id] = nil
                    LoadDebuffs(debuffs)
                else
                    currentDebuffHighlight:Show()
                    currentDebuffHighlight:SetAllPoints(b)
                    currentDebuffHighlight:SetParent(b)
                    Export(id..", -- "..debuffs[id])
                end
            end
        end)

        -- tooltip
        b:HookScript("OnEnter", function()
            DevTooltip:SetOwner(instanceSpells, "ANCHOR_NONE")
            DevTooltip:SetPoint("TOPLEFT", b, "TOPRIGHT", 1, 0)
            DevTooltip:SetSpellByID(id)
            DevTooltip:Show()
        end)

        b:HookScript("OnLeave", function()
            DevTooltip:Hide()
        end)
    end

    debuffListFrame.scrollFrame:SetContentHeight(20, #debuffButtons, -1)
end

-------------------------------------------------
-- cast list
-------------------------------------------------
local castListFrame = CreateFrame("Frame", nil, instanceSpells, "BackdropTemplate")
Dev:StylizeFrame(castListFrame)
castListFrame:SetPoint("TOPLEFT", debuffListFrame, "TOPRIGHT", 5, 0)
castListFrame:SetPoint("BOTTOMRIGHT", debuffListFrame, "BOTTOMRIGHT", 180, 0)

Dev:CreateScrollFrame(castListFrame)
local currentCastHighlight = CreateFrame("Frame", nil, instanceSpells, "BackdropTemplate")
currentCastHighlight:SetFrameLevel(10)
Dev:StylizeFrame(currentCastHighlight, {0,0,0,0}, {0.2, 1, 0.2})

local sortedCasts = {}
local castButtons = {}
LoadCasts = function(casts)
    wipe(sortedCasts)
    wipe(castButtons)
    castListFrame.scrollFrame:Reset()
    currentCastHighlight:Hide()
    currentCastHighlight:ClearAllPoints()
    DevTooltip:Hide()

    if not casts then return end

    for id in pairs(casts) do
        tinsert(sortedCasts, id)
    end
    table.sort(sortedCasts)

    local last
    for _, id in ipairs(sortedCasts) do
        local icon = select(3, GetSpellInfo(id))
        local b = Dev:CreateButton(castListFrame.scrollFrame.content, "|T"..icon..":16:16:0:0:16:16|t "..id.." "..casts[id], "red-hover", {20, 20}, true)
        tinsert(castButtons, b)

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
                currentCastHighlight:Hide()
                currentCastHighlight:ClearAllPoints()
                if IsControlKeyDown() then
                    casts[id] = nil
                    LoadCasts(casts)
                else
                    currentCastHighlight:Show()
                    currentCastHighlight:SetAllPoints(b)
                    currentCastHighlight:SetParent(b)
                    Export(id..", -- "..casts[id])
                end
            end
        end)

        -- tooltip
        b:HookScript("OnEnter", function()
            DevTooltip:SetOwner(instanceSpells, "ANCHOR_NONE")
            DevTooltip:SetPoint("TOPLEFT", b, "TOPRIGHT", 1, 0)
            DevTooltip:SetSpellByID(id)
            DevTooltip:Show()
        end)

        b:HookScript("OnLeave", function()
            DevTooltip:Hide()
        end)
    end

    castListFrame.scrollFrame:SetContentHeight(20, #castButtons, -1)
end

-------------------------------------------------
-- export
-------------------------------------------------
local exportFrame = CreateFrame("Frame", nil, instanceSpells, "BackdropTemplate")
Dev:StylizeFrame(exportFrame)
exportFrame:SetPoint("TOPLEFT", castListFrame, "TOPRIGHT", 10, 0)
exportFrame:SetPoint("BOTTOMRIGHT", castListFrame, "BOTTOMRIGHT", 185, 0)
exportFrame:Hide()

local exportFrameEditBox = Dev:CreateScrollEditBox(exportFrame)
exportFrameEditBox:SetPoint("TOPLEFT", 5, -5)
exportFrameEditBox:SetPoint("BOTTOMRIGHT", -5, 5)

exportFrame:SetScript("OnHide", function()
    exportFrame:Hide()
end)

local exportFrameCloseBtn = Dev:CreateButton(exportFrame, "Close", "red", {45, 20})
exportFrameCloseBtn:SetPoint("BOTTOMRIGHT", exportFrame, "TOPRIGHT", 0, -1)
exportFrameCloseBtn:SetScript("OnClick", function()
    exportFrame:Hide()
end)

local function ToString(data1, data2)
    local sorted = {}
    local result

    if data1 then
        for id in pairs(data1) do
            tinsert(sorted, id)
        end
        table.sort(sorted)

        result = "-- debuffs\n"
        for _, id in ipairs(sorted) do
            result = result..id..", -- "..data1[id].."\n"
        end
    end

    if data2 then
        wipe(sorted)
        for id in pairs(data2) do
            tinsert(sorted, id)
        end
        table.sort(sorted)

        if result then
            result = result .. "\n-- casts\n"
        else
            result = "-- casts\n"
        end

        for _, id in ipairs(sorted) do
            result = result..id..", -- "..data2[id].."\n"
        end
    end

    return result
end

Export = function(data1, data2)
    if data1 then
        exportFrame:Show()
    else
        exportFrame:Hide()
        return
    end

    if type(data1) == "string" then
        exportFrameEditBox:SetText(data1)
    else
        exportFrameEditBox:SetText(ToString(data1, data2))
    end

    C_Timer.After(0.1, function()
        exportFrameEditBox.scrollFrame:SetVerticalScroll(0)
    end)
end

-------------------------------------------------
-- tips
-------------------------------------------------
local instanceTip = instanceSpells:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
instanceTip:SetPoint("TOPLEFT", instanceListFrame, "BOTTOMLEFT", 0, -7)
instanceTip:SetText("[instanceID instanceName]")
instanceTip:SetTextColor(0.77, 0.77, 0.77)

local enemyTip = instanceSpells:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
enemyTip:SetPoint("TOPLEFT", enemyListFrame, "BOTTOMLEFT", 0, -7)
enemyTip:SetText("[encounterID enemyName]")
enemyTip:SetTextColor(0.77, 0.77, 0.77)

local debuffTip = instanceSpells:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
debuffTip:SetPoint("TOPLEFT", debuffListFrame, "BOTTOMLEFT", 0, -7)
debuffTip:SetText("Debuffs: [spellID spellName]")
debuffTip:SetTextColor(0.77, 0.77, 0.77)

local castTip = instanceSpells:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
castTip:SetPoint("TOPLEFT", castListFrame, "BOTTOMLEFT", 0, -7)
castTip:SetText("Casts: [spellID spellName]")
castTip:SetTextColor(0.77, 0.77, 0.77)

-------------------------------------------------
-- main button
-------------------------------------------------
local instanceDebuffsBtn = Dev:CreateMainButton(3, 254886, function(self)
    DevDB["showInstanceDebuffs"] = not DevDB["showInstanceDebuffs"]
    if DevDB["showInstanceDebuffs"] then
        self.tex:SetDesaturated(false)
        instanceSpells:Show()
    else
        self.tex:SetDesaturated(true)
        instanceSpells:Hide()
    end
end)

local function UpdateVisibility()
    if DevDB["showInstanceDebuffs"] then
        instanceSpells:Show()
        instanceDebuffsBtn.tex:SetDesaturated(false)
    end
end
Dev:RegisterCallback("UpdateVisibility", "DevInstanceDebuffs_UpdateVisibility", UpdateVisibility)

-------------------------------------------------
-- functions
-------------------------------------------------
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

-------------------------------------------------
-- event
-------------------------------------------------
instanceSpells:RegisterEvent("PLAYER_ENTERING_WORLD")

RegisterEvents = function()
    instanceSpells:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    instanceSpells:RegisterEvent("ENCOUNTER_START")
    instanceSpells:RegisterEvent("ENCOUNTER_END")
    instanceSpells:RegisterEvent("UNIT_SPELLCAST_START")
    instanceSpells:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
end

UnregisterEvents = function()
    instanceSpells:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    instanceSpells:UnregisterEvent("ENCOUNTER_START")
    instanceSpells:UnregisterEvent("ENCOUNTER_END")
    instanceSpells:UnregisterEvent("UNIT_SPELLCAST_START")
    instanceSpells:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
end

function instanceSpells:PLAYER_ENTERING_WORLD()
    if IsInInstance() then
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
        instanceIDText:SetText("ID: |cffff5500"..instanceID)
        instanceNameText:SetText("Name: |cffff5500"..name)
        currentInstanceName, currentInstanceID = name, instanceID
        if DevInstance["instances"][currentInstanceID] and DevInstance["instances"][currentInstanceID]["enabled"] then
            statusText:SetText("|cff55ff55TRACKING")
            print("|cff77ff00START TRACKING DEBUFFS!")
            RegisterEvents()
        else
            statusText:SetText("")
            UnregisterEvents()
        end
    else
        currentInstanceName, currentInstanceID = nil, nil
        instanceNameText:SetText("Name:")
        instanceIDText:SetText("ID:")
        statusText:SetText("")
        UnregisterEvents()
    end
end

local currentEncounterID, currentEncounterName = "* ", nil
function instanceSpells:ENCOUNTER_START(encounterID, encounterName)
    currentEncounterID = encounterID.." "
    currentEncounterName = encounterName
end

function instanceSpells:ENCOUNTER_END()
    currentEncounterID = "* "
    currentEncounterName = nil
end

local function Save(index, sourceName, spellId, spellName)
    -- save enemy-spell
    sourceName = currentEncounterID..sourceName
    if type(DevInstance[index][currentInstanceID][sourceName]) ~= "table" then
        DevInstance[index][currentInstanceID][sourceName] = {}
    end
    DevInstance[index][currentInstanceID][sourceName][spellId] = spellName

    if currentEncounterID and currentEncounterName then
        -- save encounter-spell
        local currentEncounter = "|cff27ffff"..currentEncounterID..currentEncounterName
        if type(DevInstance[index][currentInstanceID][currentEncounter]) ~= "table" then
            DevInstance[index][currentInstanceID][currentEncounter] = {}
        end
        DevInstance[index][currentInstanceID][currentEncounter][spellId] = spellName
    else
        -- save mobs-spell
        local mobs = "|cff27ffff* MOBS"
        if type(DevInstance[index][currentInstanceID][mobs]) ~= "table" then
            DevInstance[index][currentInstanceID][mobs] = {}
        end
        DevInstance[index][currentInstanceID][mobs][spellId] = spellName
    end
end

--! CASTS
function instanceSpells:UNIT_SPELLCAST_START(unit, _, spellId)
    if not (currentInstanceName and currentInstanceID and spellId) then return end
    if not UnitIsEnemy("player", unit) then return end
    -- if not (UnitIsEnemy("player", unit) and UnitIsFriend("player", unit.."target")) then return end
    
    local sourceName = UnitName(unit)
    if not sourceName then return end

    Save("casts", sourceName, spellId, GetSpellInfo(spellId))
end

function instanceSpells:UNIT_SPELLCAST_CHANNEL_START(unit, _, spellId)
    instanceSpells:UNIT_SPELLCAST_START(unit, _, spellId)
end

--! DEBUFFS
function instanceSpells:COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, auraType, amount = ...
    if event ~= "SPELL_AURA_APPLIED" or auraType ~= "DEBUFF" then return end

    if not (currentInstanceName and currentInstanceID and spellId) then return end

    -- !NOTE: some debuffs are SELF-APPLIED but caster == nil
    if (IsEnemy(sourceFlags) or (sourceFlags == 1297 and not sourceName)) and IsFriend(destFlags) then
        if not sourceName then sourceName = "UNKNOWN" end
        Save("debuffs", sourceName, spellId, spellName)
    end
end

instanceSpells:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
    else
        self[event](self, ...)
    end
end)
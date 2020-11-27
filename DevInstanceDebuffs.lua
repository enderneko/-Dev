local _, Dev = ...
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local instanceDebuffs = CreateFrame("Frame", "DevInstanceDebuffs", nil, "BackdropTemplate")
LPP:PixelPerfectScale(instanceDebuffs)
instanceDebuffs:Hide()
instanceDebuffs:SetSize(200, 400)
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

local title = instanceDebuffs:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
title:SetPoint("TOP", 0, -3)
title:SetText("Instance Debuffs")
title:SetTextColor(.9, .9, .1)

local instanceNameText = instanceDebuffs:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
instanceNameText:SetPoint("TOPLEFT", 5, -20)

local instanceIDText = instanceDebuffs:CreateFontString(nil, "OVERLAY", "DEV_FONT_NORMAL")
instanceIDText:SetPoint("TOPLEFT", instanceNameText, "BOTTOMLEFT", 0, -5)

local addBtn = Dev:CreateButton(instanceDebuffs, "Add Current Instance", "red", {190, 20})
addBtn:SetPoint("TOPLEFT", 5, -60)

local instanceListFrame = CreateFrame("Frame", nil, instanceDebuffs, "BackdropTemplate")
Dev:StylizeFrame(instanceListFrame)
instanceListFrame:SetPoint("TOPLEFT", addBtn, "BOTTOMLEFT", 0, -5)
instanceListFrame:SetPoint("BOTTOMRIGHT", -5, 5)

Dev:CreateScrollFrame(instanceListFrame)

local instanceButtons = {}

local function LoadInstances()
    wipe(instanceButtons)
    instanceListFrame.scrollFrame:Reset()

    local last
    for id, t in pairs(DevInstanceDebuffs["instances"]) do
        local b = Dev:CreateButton(instanceListFrame.scrollFrame.content, id.." "..t[2], "red-hover", {20, 20}, true)
        tinsert(instanceButtons, b)
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
    end

    instanceListFrame.scrollFrame:SetContentHeight(20, #instanceButtons, -1)
end

instanceDebuffs:SetScript("OnShow", function()
    LoadInstances()
end)

----------------------------------------------------------------------------
-- main button
----------------------------------------------------------------------------
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


----------------------------------------------------------------------------
-- event
----------------------------------------------------------------------------
local units = {
    ["player"] = true,
    ["party1"] = true,
    ["party2"] = true,
    ["party3"] = true,
    ["party4"] = true,
}

instanceDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
-- instanceDebuffs:RegisterEvent("UNIT_AURA")

local currentInstanceName, currentInstanceID 
function instanceDebuffs:PLAYER_ENTERING_WORLD()
    if IsInInstance() then
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
        instanceNameText:SetText("Name: "..name)
        instanceIDText:SetText("ID: "..instanceID)
        if false then
            instanceDebuffs:RegisterEvent("UNIT_AURA")
            currentInstanceName, currentInstanceID = name, instanceID
            if type(DevInstanceDebuffs[currentInstanceName]) ~= "table" then DevInstanceDebuffs[currentInstanceName] = {} end
        else
            instanceDebuffs:UnregisterEvent("UNIT_AURA")
        end
    else
        instanceNameText:SetText("Name:")
        instanceIDText:SetText("ID:")
        instanceDebuffs:UnregisterEvent("UNIT_AURA")
    end
end

function instanceDebuffs:UNIT_AURA(unit)
    if units[unit] and currentInstanceName and currentInstanceID then
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitDebuff(unit, i)
            if not name then break end

            if not unit[source] then
                local sourceName = (source and UnitName(source) or "unknown") or "unknown"
                if type(DevInstanceDebuffs[currentInstanceName][sourceName]) ~= "table" then DevInstanceDebuffs[currentInstanceName][sourceName] = {} end
                DevInstanceDebuffs[currentInstanceName][sourceName][spellId] = name
            end
        end
    end
end


instanceDebuffs:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)
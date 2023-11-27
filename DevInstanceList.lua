local _, Dev = ...

local instanceListFrame = CreateFrame("Frame", "DevInstanceListFrame", DevMainFrame, "BackdropTemplate")
instanceListFrame:Hide()
instanceListFrame:SetPoint("CENTER", UIParent)
instanceListFrame:SetSize(400, 500)
Dev:StylizeFrame(instanceListFrame)

local closeBtn = Dev:CreateButton(instanceListFrame, "Close", "red", {20, 20})
closeBtn:SetPoint("BOTTOMLEFT", instanceListFrame, "TOPLEFT", 0, -1)
closeBtn:SetPoint("BOTTOMRIGHT", instanceListFrame, "TOPRIGHT", 0, -1)
closeBtn:SetScript("OnClick", function()
    instanceListFrame:Hide()
end)

local scroll = Dev:CreateScrollEditBox(instanceListFrame)
scroll:SetAllPoints(instanceListFrame)

local function AddLines(tier, isRaid)
    for iIndex = 1, 77 do
        -- instance
        local iId, iName = EJ_GetInstanceByIndex(iIndex, isRaid)
        if not iId or not iName then
            break
        end

        scroll.eb:Insert("["..iId.."] = { -- "..iName.."\n")

        -- general
        scroll.eb:Insert("    [\"general\"] = {\n    },\n")

        -- boss
        EJ_SelectInstance(iId)
        for bIndex = 1, 77 do
            local bName, _, bId = EJ_GetEncounterInfoByIndex(bIndex)
            if not bName or not bId then
                break
            end
            
            scroll.eb:Insert("    ["..bId.."] = { -- "..bName.."\n    },\n")
        end

        scroll.eb:Insert("},\n\n")
    end
end

function Dev:ShowInstanceList(tier)
    scroll.eb:SetText("")
    instanceListFrame:Show()
    
    if not tier or tier == "" then tier = EJ_GetNumTiers() end

    EJ_SelectTier(tier)
    AddLines(tier, true)
    AddLines(tier, false)

    scroll.eb:SetCursorPosition(0)
end
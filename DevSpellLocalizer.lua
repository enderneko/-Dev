local _, Dev = ...

local function GetSpellName(id)
    if C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(id)
        if info then
            return info.name
        end
    else
        return GetSpellInfo(id)
    end
end

local spellLocalizerFrame = CreateFrame("Frame", "DevSpellLocalizerFrame", DevMainFrame, "BackdropTemplate")
spellLocalizerFrame:Hide()
spellLocalizerFrame:SetMovable(true)
spellLocalizerFrame:SetUserPlaced(true)
spellLocalizerFrame:SetPoint("CENTER", UIParent)
spellLocalizerFrame:SetSize(400, 500)
Dev:StylizeFrame(spellLocalizerFrame)

local scroll = Dev:CreateScrollEditBox(spellLocalizerFrame)
scroll:SetAllPoints(spellLocalizerFrame)
scroll.eb:SetScript("OnEditFocusGained", function()
    scroll.eb:HighlightText()
end)

---------------------------------------------------------------------
-- normal
---------------------------------------------------------------------
local localizeBtn = Dev:CreateButton(spellLocalizerFrame, "Normal", "blue", {175, 20})
localizeBtn:SetPoint("BOTTOMLEFT", spellLocalizerFrame, "TOPLEFT", 0, -1)

localizeBtn:RegisterForDrag("LeftButton")
localizeBtn:SetClampedToScreen(true)
localizeBtn:SetScript("OnDragStart", function()
    spellLocalizerFrame:StartMoving()
end)
localizeBtn:SetScript("OnDragStop", function()
    spellLocalizerFrame:StopMovingOrSizing()
end)

localizeBtn:SetScript("OnClick", function()
    local text = scroll.eb:GetText()
    if text == "" then return end

    scroll.eb:SetText("")

    local t = {strsplit("\n", text)}

    local n = 0
    local spacing = ""

    for i, line in pairs(t) do
        line = strtrim(line)

        if line:find("[%[%]{}=]") then
            spacing = "    "
        else
            local match = line:match("\"?-?%d+\"?")

            if match then
                local oldLine = match
                line = line:gsub("[^%d]", "")

                local id = tonumber(line)
                if id then
                    local name = GetSpellName(abs(id))
                    if name then
                        line = spacing..oldLine..", -- "..name
                    else
                        line = nil
                    end
                else
                    line = nil
                end
            end
        end
        t[i] = line

        if line then
            n = n + 1
            if n == 1 then
                scroll.eb:Insert(line)
            else
                scroll.eb:Insert("\n"..line)
            end
        end
    end
    -- texplore(t)
    scroll.eb:SetFocus(true)
    scroll.eb:HighlightText()
end)

---------------------------------------------------------------------
-- key
---------------------------------------------------------------------
local localizeBtn2 = Dev:CreateButton(spellLocalizerFrame, "Key", "blue", {175, 20})
localizeBtn2:SetPoint("BOTTOMLEFT", localizeBtn, "BOTTOMRIGHT", -1, 0)

localizeBtn2:RegisterForDrag("LeftButton")
localizeBtn2:SetClampedToScreen(true)
localizeBtn2:SetScript("OnDragStart", function()
    spellLocalizerFrame:StartMoving()
end)
localizeBtn2:SetScript("OnDragStop", function()
    spellLocalizerFrame:StopMovingOrSizing()
end)

localizeBtn2:SetScript("OnClick", function()
    local text = scroll.eb:GetText()
    if text == "" then return end

    scroll.eb:SetText("")

    local t = {strsplit("\n", text)}

    local n = 0

    for i, line in pairs(t) do
        line = strtrim(line)

        local match = line:match("%[%d+%].+")

        if match then
            local oldLine = match
            oldLine = oldLine:gsub("%-%-.+$", "")
            oldLine = strtrim(oldLine)

            line = line:match("%[(%d+)%].+")

            local id = tonumber(line)
            if id then
                local name = GetSpellName(id)
                if name then
                    line = oldLine.." -- "..name
                else
                    line = nil
                end
            else
                line = nil
            end
        end

        t[i] = line

        if line then
            n = n + 1
            if n == 1 then
                scroll.eb:Insert(line)
            else
                scroll.eb:Insert("\n"..line)
            end
        end
    end
    -- texplore(t)
    scroll.eb:SetFocus(true)
    scroll.eb:HighlightText()
end)

---------------------------------------------------------------------
-- close
---------------------------------------------------------------------
local closeBtn = Dev:CreateButton(spellLocalizerFrame, "Close", "red", {50, 20})
closeBtn:SetPoint("BOTTOMLEFT", localizeBtn2, "BOTTOMRIGHT", -1, 0)
closeBtn:SetPoint("BOTTOMRIGHT", spellLocalizerFrame, "TOPRIGHT", 0, -1)
closeBtn:SetScript("OnClick", function()
    spellLocalizerFrame:Hide()
end)

function Dev:ShowSpellLocalizer()
    scroll.eb:SetText("")
    spellLocalizerFrame:Show()
    
    scroll.eb:SetCursorPosition(0)
end
local _, Dev = ...

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

local localizeBtn = Dev:CreateButton(spellLocalizerFrame, "Localize", "blue", {350, 20})
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
            line = line:match("\"?-?%d+\"?")

            local oldLine = line
            line = line:gsub("[^%d]", "")

            local id = tonumber(line)
            if id then
                local name = GetSpellInfo(abs(id))
                if name then
                    line = spacing..oldLine..", -- "..name
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

local closeBtn = Dev:CreateButton(spellLocalizerFrame, "Close", "red", {50, 20})
closeBtn:SetPoint("BOTTOMLEFT", localizeBtn, "BOTTOMRIGHT", -1, 0)
closeBtn:SetPoint("BOTTOMRIGHT", spellLocalizerFrame, "TOPRIGHT", 0, -1)
closeBtn:SetScript("OnClick", function()
    spellLocalizerFrame:Hide()
end)

function Dev:ShowSpellLocalizer()
    scroll.eb:SetText("")
    spellLocalizerFrame:Show()
    
    scroll.eb:SetCursorPosition(0)
end
local _, Dev = ...

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local function Convert01_256(r, g, b)
    return floor(r * 255), floor(g * 255), floor(b * 255)
end

local function Convert256_Hex(r, g, b)
    local result = ""

    for key, value in pairs({r, g, b}) do
        local hex = ""

        while(value > 0)do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub("0123456789ABCDEF", index, index) .. hex
        end

        if(string.len(hex) == 0)then
            hex = "00"

        elseif(string.len(hex) == 1)then
            hex = "0" .. hex
        end

        result = result .. hex
    end

    return result
end

---------------------------------------------------------------------
-- frame
---------------------------------------------------------------------
local colorConverterFrame = CreateFrame("Frame", "DevColorConverter", DevMainFrame, "BackdropTemplate")
colorConverterFrame:Hide()
colorConverterFrame:SetMovable(true)
colorConverterFrame:SetUserPlaced(true)
colorConverterFrame:SetPoint("CENTER", UIParent)
colorConverterFrame:SetSize(400, 500)
Dev:StylizeFrame(colorConverterFrame)

local scroll = Dev:CreateScrollEditBox(colorConverterFrame)
scroll:SetAllPoints(colorConverterFrame)
scroll.eb:SetScript("OnEditFocusGained", function()
    scroll.eb:HighlightText()
end)

local convert_01_hex = Dev:CreateButton(colorConverterFrame, "01 -> hex", "blue", {350, 20})
convert_01_hex:SetPoint("BOTTOMLEFT", colorConverterFrame, "TOPLEFT", 0, -1)

convert_01_hex:RegisterForDrag("LeftButton")
convert_01_hex:SetClampedToScreen(true)
convert_01_hex:SetScript("OnDragStart", function()
    colorConverterFrame:StartMoving()
end)
convert_01_hex:SetScript("OnDragStop", function()
    colorConverterFrame:StopMovingOrSizing()
end)

convert_01_hex:SetScript("OnClick", function()
    local text = scroll.eb:GetText()
    if text == "" then return end

    scroll.eb:SetText("")

    local t = {strsplit("\n", text)}

    local n = 0

    for i, line in pairs(t) do
        line = strtrim(line)
        line = line:gsub("[^%d,%.]", "")

        local pre = "("..line..") -> "
        local result = ""

        if line:find(",") then
            local r, g, b = strsplit(",", line)
            if r and g and b then
                r = tonumber(r)
                g = tonumber(g)
                b = tonumber(b)
                if r and g and b then
                    result = strlower(Convert256_Hex(Convert01_256(r, g, b)))
                end
            end
        end

        line = pre..result

        n = n + 1
        if n == 1 then
            scroll.eb:Insert(line)
        else
            scroll.eb:Insert("\n"..line)
        end
    end
    scroll.eb:SetFocus(true)
    scroll.eb:HighlightText()
end)

local closeBtn = Dev:CreateButton(colorConverterFrame, "Close", "red", {50, 20})
closeBtn:SetPoint("BOTTOMLEFT", convert_01_hex, "BOTTOMRIGHT", -1, 0)
closeBtn:SetPoint("BOTTOMRIGHT", colorConverterFrame, "TOPRIGHT", 0, -1)
closeBtn:SetScript("OnClick", function()
    colorConverterFrame:Hide()
end)

function Dev:ShowColorConverter()
    scroll.eb:SetText("")
    colorConverterFrame:Show()
    
    scroll.eb:SetCursorPosition(0)
end
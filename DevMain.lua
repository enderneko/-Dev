local _, Dev = ...
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local devMainFrame = CreateFrame("Frame", "DevMainFrame", nil, "BackdropTemplate")
LPP:PixelPerfectScale(devMainFrame)
devMainFrame:Hide()
devMainFrame:SetPoint("TOP")
devMainFrame:SetFrameStrata("HIGH")
devMainFrame:SetMovable(true)
devMainFrame:SetUserPlaced(false)
devMainFrame:SetClampedToScreen(true)
devMainFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
devMainFrame:SetBackdropColor(1, 0, 0, .7)
devMainFrame:EnableMouse(true)
devMainFrame:RegisterForDrag("LeftButton")
devMainFrame:SetScript("OnDragStart", function()
    devMainFrame:StartMoving()
    devMainFrame:SetUserPlaced(false)
end)
devMainFrame:SetScript("OnDragStop", function()
    devMainFrame:StopMovingOrSizing()
    LPP:PixelPerfectPoint(devMainFrame)
end)
devMainFrame:SetScript("OnShow", function()
    LPP:PixelPerfectPoint(devMainFrame)
end)

-------------------------------------------------
-- point and size
-------------------------------------------------
local ICON_SIZE = 27
local buttons = {}
local function UpdateDevMain()
    for i, b in pairs(buttons) do
        if i == 1 then
            b:SetPoint("TOPLEFT", 5, -5)
        else
            b:SetPoint("LEFT", buttons[i-1], "RIGHT", 5, 0)
        end
    end

    local n = #buttons
    devMainFrame:SetWidth(n*ICON_SIZE+(n-1)*5+10)
    devMainFrame:SetHeight(ICON_SIZE+10)
    devMainFrame:Show()
end

-------------------------------------------------
-- create button
-------------------------------------------------
function Dev:CreateMainButton(index, icon, func)
    local b = CreateFrame("Button", nil, devMainFrame)
    buttons[index] = b
    b:SetSize(ICON_SIZE, ICON_SIZE)
    b.tex = b:CreateTexture(nil, "ARTWORK")
    b.tex:SetTexture(icon)
    b.tex:SetAllPoints(b)
    b.tex:SetDesaturated(true)
    b:SetScript("OnClick", function()
        func(b)
    end)

    b:RegisterForDrag("LeftButton")
    b:SetScript("OnDragStart", function()
        devMainFrame:StartMoving()
        devMainFrame:SetUserPlaced(false)
    end)
    b:SetScript("OnDragStop", function()
        devMainFrame:StopMovingOrSizing()
        LPP:PixelPerfectPoint(devMainFrame)
    end)
    UpdateDevMain()

    return b
end

-------------------------------------------------
-- init buttons
-------------------------------------------------
-- CreateButton(461790, Dev.ShowDevButtons)
-- CreateButton(254886, Dev.ShowInstanceDebuffs)
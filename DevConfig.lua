local _, Dev = ...
local P = Dev.pixelPerfectFuncs

local devConfigFrame = CreateFrame("Frame", "DevConfigFrame", DevMainFrame, "BackdropTemplate")
devConfigFrame:Hide()
devConfigFrame:SetSize(137, 60)
devConfigFrame:SetPoint("TOPLEFT", DevMainFrame, "BOTTOMLEFT", 0, -5)
devConfigFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
devConfigFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
devConfigFrame:SetBackdropBorderColor(0, 0, 0, 1)

-- scale
local scaleSlider = Dev:CreateSlider("Scale", devConfigFrame, 0.5, 2.5, 127, 0.25, nil, function(value)
    DevDB["scale"] = value
    Dev:UpdateScale()
end)
scaleSlider:SetPoint("TOPLEFT", 5, -20)

-------------------------------------------------
-- scripts
-------------------------------------------------
devConfigFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
devConfigFrame:SetScript("OnEvent", function()
    devConfigFrame:Hide()
end)

devConfigFrame:SetScript("OnShow", function()
    scaleSlider:SetValue(DevDB["scale"])
end)

-------------------------------------------------
-- main button
-------------------------------------------------
local devConfigBtn = Dev:CreateMainButton(1, 136243, function(self)
    if InCombatLockdown() then
        return
    end

    if devConfigFrame:IsShown() then
        self.tex:SetDesaturated(true)
        devConfigFrame:Hide()
    else
        self.tex:SetDesaturated(false)
        devConfigFrame:Show()
    end
end)
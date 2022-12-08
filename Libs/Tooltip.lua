local accentColor = {0.6, 0.1, 0.1, 1}

-----------------------------------------
-- Tooltip
-----------------------------------------
local function CreateTooltip(name)
	local tooltip = CreateFrame("GameTooltip", name, nil, "DevTooltipTemplate,BackdropTemplate")
	tooltip:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	tooltip:SetBackdropColor(.1, .1, .1, .9)
	tooltip:SetBackdropBorderColor(unpack(accentColor))
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        tooltip:RegisterEvent("TOOLTIP_DATA_UPDATE")
        tooltip:SetScript("OnEvent", function()
            -- Interface\FrameXML\GameTooltip.lua line924
            tooltip:RefreshData()
        end)
    end

	tooltip:SetScript("OnTooltipCleared", function()
		-- reset border color
		tooltip:SetBackdropBorderColor(unpack(accentColor))
	end)

	-- tooltip:SetScript("OnTooltipSetItem", function()
	-- 	-- color border with item quality color
	-- 	tooltip:SetBackdropBorderColor(_G[name.."TextLeft1"]:GetTextColor())
	-- end)

	tooltip:SetScript("OnHide", function()
		-- SetX with invalid data may or may not clear the tooltip's contents.
		tooltip:ClearLines()
	end)
end


CreateTooltip("DevTooltip")
CreateTooltip("DevScanningTooltip")
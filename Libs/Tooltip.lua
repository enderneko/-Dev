local class = select(2, UnitClass("player"))
local classColor = {.7, .7, .7, 1}
if class then
	classColor[1], classColor[2], classColor[3] = GetClassColor(class)
end

-----------------------------------------
-- Tooltip
-----------------------------------------
local function CreateTooltip(name)
	local tooltip = CreateFrame("GameTooltip", name, nil, "DevTooltipTemplate,BackdropTemplate")
	tooltip:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	tooltip:SetBackdropColor(.1, .1, .1, .9)
	tooltip:SetBackdropBorderColor(unpack(classColor))
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
		tooltip:SetBackdropBorderColor(unpack(classColor))
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
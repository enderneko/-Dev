local _, Dev = ...
local P = Dev.pixelPerfectFuncs

local MACRO_PREFIX = "!Dev-" --! if use _ in macro name, icon can't be saved. why?
local BUTTON_WIDTH = 100
local BUTTON_HEIGHT = 20
local SPACING = 3

local escapeSequences = {
    [ "\a" ] = "\\a", -- Bell
    [ "\b" ] = "\\b", -- Backspace
    [ "\t" ] = "\\t", -- Horizontal tab
    [ "\n" ] = "\\n", -- Newline
    [ "\v" ] = "\\v", -- Vertical tab
    [ "\f" ] = "\\f", -- Form feed
    [ "\r" ] = "\\r", -- Carriage return
    [ "\\" ] = "\\\\", -- Backslash
    [ "\"" ] = "\\\"", -- Quotation mark
    [ "|" ]  = "||",
}

--{name/addonName, type, action, dependOnAddon, hasEditBox}
local buttons = {
    -- {"Abstract data", "script", "texplore(\"Abstract\", Abstract.data, 10)", "Abstract"},
    -- {"wipe AbstractDB", "script", "AbstractDB=nil;ReloadUI()", "Abstract", false, "green"},
    {"wipe CellDB", "script", "CellDB=nil;ReloadUI()", "Cell", false, "green"},
    {"AW_DEMO", "script", "BigFootInfinite.AW:ShowDemo()", "BigFootInfinite", false, "blue"},
    -- {"wipe TIC_DB", "script", "TIC_DB=nil;ReloadUI()", "TooltipItemCount", false, "green"},
    -- {"wipe IVSP", "script", "IVSP_Config=nil;IVSP_Custom=nil;ReloadUI()", "IcyVeinsStatPriority", false, "green"},
    -- {"CellDB debuffs", "script", "texplore(CellDB[\"raidDebuffs\"])", "TableExplorer"},
    -- {"Cell.unitButtons", "script", "texplore(Cell.unitButtons)", "Cell"},
    -- {"CellDB indicators", "script", "texplore(Cell.vars.currentLayoutTable.indicators)", "Cell"},
    -- {"Invite", "macro", "/invite Programming-影之哀伤\n/invite Luascript-影之哀伤"},

    -- general ------------------------
    {"|cff77ff77ClearChat", "script", "DEFAULT_CHAT_FRAME:Clear()"},
    {"|cff77ff77ReloadUI", "script", "ReloadUI()"},
    {"|cff77ff77fstack", "macro", "/fstack"},
    {"backgroud", "function", function()
        if not THE_BACKGROUND then
            THE_BACKGROUND = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            THE_BACKGROUND:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
            THE_BACKGROUND:SetBackdropColor(0.3, 0.3, 0.3, 1)
            THE_BACKGROUND:SetAllPoints(UIParent)
            THE_BACKGROUND:SetFrameStrata("BACKGROUND")
            THE_BACKGROUND:SetFrameLevel(0)
            THE_BACKGROUND:Hide()
        end
        if THE_BACKGROUND:IsShown() then
            THE_BACKGROUND:Hide()
        else
            THE_BACKGROUND:Show()
        end
    end},
    {"|cff77ffffcollectgarbage", "script", "collectgarbage(\"collect\")"},
    -- {"RunScript", "script", "$", nil, true},
    -- {"GetSpellInfo", "script", "print(GetSpellInfo($))", nil, true},
    {"|cffffff77GetInstanceInfo", "script", "print(GetInstanceInfo())"},
    {"|cffffff77EncounterJournal", "function", function()
        if not IsAddOnLoaded("Blizzard_EncounterJournal") then LoadAddOn("Blizzard_EncounterJournal") end
        ShowUIPanel(EncounterJournal)
        print("encounterID:", EncounterJournal.encounterID, "instanceID:", EncounterJournal.instanceID)
    end},
    {"|cffffff77InstanceList", "function", function(tier)
        Dev:ShowInstanceList(tier)
    end, nil, true},
    {"|cff77ffffSpellLocalizer", "function", function()
        Dev:ShowSpellLocalizer()
    end},
    {"|cff77ffffGetSpellInfo", "function", function(spellId)
        DevTools_Dump({GetSpellInfo(spellId)})
    end, nil, true},
    {"InterfaceUsage", "macro", "/iu", "InterfaceUsage"},
    {"APIInterface", "macro", "/apii", "APIInterface"},
    {"TextureViewer", "macro", "/texview", "TextureViewer"},
    {"TextureAtlasViewer", "macro", "/tav", "TextureAtlasViewer"},
    {"TextureBrowser", "macro", "/tb", "TextureBrowser"},
    {"|cffffff77EventTrace", "macro", "/eventtrace"},
    {"ViragDevTool", "macro", "/vdt", "ViragDevTool"},
    {"WowLua" ,"macro", "/wowlua", "WowLua"},
    {"TableExplorer", "script", "texplore($)", "TableExplorer", true},
    {"TableViewer" ,"function", function(t)
        if not t or t == "" then return end
        DevTableViewerTable = nil
        RunScript("DevTableViewerTable="..t)
        if type(DevTableViewerTable) == "table" then
            local text = ""
            for k, v in pairs(DevTableViewerTable) do
                k = tostring(k)
                v = tostring(v)
                k = k:gsub( "[%z\1-\31\"\\|\127-\255]", escapeSequences )
                v = v:gsub( "[%z\1-\31\"\\|\127-\255]", escapeSequences )
                text = text .. t.."[\""..k.."\"] = \""..v.."\"\n"
            end
            Dev.dialog:SetText(text)
            Dev.dialog:Show()
        end
    end, nil, true},
    {"TableSaver" ,"function", function(t)
        if not t or t == "" then return end
        RunScript("DevTableSaver="..t)
    end, nil, true},
}

local devButtonsFrame = CreateFrame("Frame", "DevButtonsFrame", DevMainFrame, "BackdropTemplate")
devButtonsFrame:Hide()
devButtonsFrame:SetPoint("LEFT", 100, 0)
devButtonsFrame:SetFrameStrata("LOW")
devButtonsFrame:SetMovable(true)
devButtonsFrame:SetUserPlaced(true)
devButtonsFrame:SetClampedToScreen(true)
devButtonsFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
devButtonsFrame:SetBackdropColor(0, 0, 0, .7)
devButtonsFrame:SetBackdropBorderColor(0, 0, 0, 1)
devButtonsFrame:EnableMouse(true)
devButtonsFrame:RegisterForDrag("LeftButton")
devButtonsFrame:SetScript("OnDragStart", function()
    devButtonsFrame:StartMoving()
end)
devButtonsFrame:SetScript("OnDragStop", function()
    devButtonsFrame:StopMovingOrSizing()
    P:PixelPerfectPoint(devButtonsFrame)
end)
devButtonsFrame:SetScript("OnShow", function()
    -- P:PixelPerfectPoint(devButtonsFrame)
end)

local title = devButtonsFrame:CreateFontString(nil, "OVERLAY", "DEV_FONT_TITLE")
title:SetPoint("TOP", 0, -3)
title:SetText("Dev Buttons")
title:SetTextColor(.9, .9, .1)

Dev.dialog = Dev:CreateScrollEditBox(devButtonsFrame)
Dev.dialog:SetPoint("CENTER", UIParent)
Dev.dialog:SetSize(500, 400)
Dev.dialog:Hide()
Dev.dialog.close = Dev:CreateButton(Dev.dialog, "×", "red", {20, 20})
Dev.dialog.close:SetPoint("BOTTOMLEFT", Dev.dialog, "TOPLEFT", 0, -1)
Dev.dialog.close:SetScript("OnClick", function()
    Dev.dialog:Hide()
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

function eventFrame:PLAYER_ENTERING_WORLD()
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")

    if InCombatLockdown() then
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    else
        eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end

    local last, numEB = nil, 0
    for i, t in pairs(buttons) do
        local bName, bType, bAction, bDependOnAddon, bHasEditBox, color = unpack(t)
        local b = Dev:CreateButton(devButtonsFrame, bName, color or "red", {BUTTON_WIDTH, BUTTON_HEIGHT}, false, true)

        if not bDependOnAddon or IsAddOnLoaded(bDependOnAddon) then
            if bType == "macro" then
                -- https://wow.gamepedia.com/SecureActionButtonTemplate
                b:SetAttribute("type1", "macro") -- left click causes macro
                b:SetAttribute("macrotext1", bAction) -- text for macro on left click
            end

            if bType == "script" then
                if bHasEditBox then
                    b.eb = Dev:CreateEditBox(b, BUTTON_WIDTH, BUTTON_HEIGHT)
                    b.eb:SetBackdropBorderColor(1, 0, 0, 1)
                    b.eb:SetPoint("TOP", b, "BOTTOM")
                    b.hasEditBox = true
                    numEB = numEB + 1
                end

                b:SetScript("OnClick", function(self, button, down)
                    if not down then return end
                    if bHasEditBox then
                        local p = b.eb:GetText()
                        local script = string.gsub(bAction, "%$", p)
                        RunScript(script)
                    else
                        RunScript(bAction)
                    end
                end)
            end

            if bType == "function" then
                if bHasEditBox then
                    b.eb = Dev:CreateEditBox(b, BUTTON_WIDTH, BUTTON_HEIGHT)
                    b.eb:SetBackdropBorderColor(1, 0, 0, 1)
                    b.eb:SetPoint("TOP", b, "BOTTOM")
                    b.hasEditBox = true
                    numEB = numEB + 1
                end

                b:SetScript("OnClick", function(self, button, down)
                    if not down then return end
                    if b.eb then
                        bAction(b.eb:GetText())
                    else
                        bAction()
                    end
                end)
            end
        else
            b:SetEnabled(false)
        end

        if i == 1 then
            b:SetPoint("TOPLEFT", SPACING, -20)
        else
            if last.hasEditBox then
                b:SetPoint("TOPLEFT", last.eb, "BOTTOMLEFT", 0, -SPACING)
            else
                b:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -SPACING)
            end
        end
        last = b
    end

    devButtonsFrame:SetSize(BUTTON_WIDTH + SPACING * 2, #buttons * (BUTTON_HEIGHT + SPACING) + 20 + numEB * BUTTON_HEIGHT)
end

eventFrame.PLAYER_REGEN_ENABLED = eventFrame.PLAYER_ENTERING_WORLD

eventFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

-------------------------------------------------
-- main button
-------------------------------------------------
local devButtonsBtn = Dev:CreateMainButton(2, 461790, function(self)
    if InCombatLockdown() then
        return
    end

    DevDB["showDevButtons"] = not DevDB["showDevButtons"]
    if DevDB["showDevButtons"] then
        self.tex:SetDesaturated(false)
        devButtonsFrame:Show()
    else
        self.tex:SetDesaturated(true)
        devButtonsFrame:Hide()
    end
end)

local function UpdateVisibility()
    if DevDB["showDevButtons"] then
        devButtonsFrame:Show()
        devButtonsBtn.tex:SetDesaturated(false)
    end
end
Dev:RegisterCallback("UpdateVisibility", "DevButtons_UpdateVisibility", UpdateVisibility)
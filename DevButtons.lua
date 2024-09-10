local _, Dev = ...
local P = Dev.pixelPerfectFuncs

local MACRO_PREFIX = "!Dev-" --! if use _ in macro name, icon can't be saved. why?
local BUTTON_WIDTH = 100
local BUTTON_HEIGHT = 20
local BUTTON_SPACING = 3

local DEV_TYPE_COLOR="|cff88ff88"
local DEV_TABLEREF_COLOR="|cffffcc00"
local DEV_CUTOFF_COLOR="|cffff0000"
local DEV_TABLEKEY_COLOR="|cff88ccff"
local DEV_NIL_COLOR = "|cffb2b2b2"

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded

---------------------------------------------------------------------
-- frame
---------------------------------------------------------------------
local devButtonsFrame = CreateFrame("Frame", "DevButtonsFrame", DevMainFrame, "BackdropTemplate")
devButtonsFrame:Hide()
devButtonsFrame:SetPoint("LEFT", 100, 0)
devButtonsFrame:SetFrameStrata("LOW")
devButtonsFrame:SetHeight(20)
devButtonsFrame:SetMovable(true)
devButtonsFrame:SetUserPlaced(true)
devButtonsFrame:SetClampedToScreen(true)
devButtonsFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
devButtonsFrame:SetBackdropColor(0, 0, 0, 0.7)
-- devButtonsFrame:SetBackdropBorderColor(0, 0, 0, 1)
devButtonsFrame:EnableMouse(true)
devButtonsFrame:RegisterForDrag("LeftButton")
devButtonsFrame:SetScript("OnDragStart", function()
    devButtonsFrame:StartMoving()
end)
devButtonsFrame:SetScript("OnDragStop", function()
    devButtonsFrame:StopMovingOrSizing()
end)

local title = devButtonsFrame:CreateFontString(nil, "OVERLAY", "DEV_FONT_TITLE")
title:SetPoint("TOP", 0, -3)
title:SetText("Dev Buttons")
title:SetTextColor(0.9, 0.9, 0.1)

Dev.dialog = Dev:CreateScrollEditBox(devButtonsFrame)
Dev.dialog:SetPoint("CENTER", UIParent)
Dev.dialog:SetSize(500, 400)
Dev.dialog:Hide()
Dev.dialog.close = Dev:CreateButton(Dev.dialog, "×", "red", {20, 20})
Dev.dialog.close:SetPoint("BOTTOMLEFT", Dev.dialog, "TOPLEFT", 0, -1)
Dev.dialog.close:SetScript("OnClick", function()
    Dev.dialog:Hide()
end)

---------------------------------------------------------------------
-- text frame
---------------------------------------------------------------------
local textFrame = CreateFrame("Frame", "DevInstanceListFrame", DevMainFrame, "BackdropTemplate")
textFrame:Hide()
textFrame:SetPoint("CENTER", UIParent)
textFrame:SetSize(400, 500)
Dev:StylizeFrame(textFrame)

local closeBtn = Dev:CreateButton(textFrame, "Close", "red", {20, 20})
closeBtn:SetPoint("BOTTOMLEFT", textFrame, "TOPLEFT", 0, -1)
closeBtn:SetPoint("BOTTOMRIGHT", textFrame, "TOPRIGHT", 0, -1)
closeBtn:SetScript("OnClick", function()
    textFrame:Hide()
end)

local scroll = Dev:CreateScrollEditBox(textFrame)
scroll:SetAllPoints(textFrame)

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
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

local function PrintTableWithKeyNames(t, keys, extra)
    print("--------------------------------------------------")
    if extra then
        print(extra)
    end

    for i, k in ipairs(keys) do
        local v = t[i]
        k = "\""..k.."\""

        if not v then
            print(string.format(DEV_TABLEKEY_COLOR.."[%s]|r="..DEV_NIL_COLOR.."nil", k))
        else
            local vType = type(v)

            if vType == "string" then
                if v:match(".*|H.*|h.*") then
                    print(string.format(DEV_TABLEKEY_COLOR.."[%s]|r=%s", k, v))
                else
                    print(string.format(DEV_TABLEKEY_COLOR.."[%s]|r=\"%s\"", k, v))
                end
            elseif vType == "number" or vType == "boolean" then
                print(string.format(DEV_TABLEKEY_COLOR.."[%s]|r=%s", k, tostring(v)))
            else
                print(string.format(DEV_TABLEKEY_COLOR.."[%s]|r="..DEV_TYPE_COLOR.."<"..vType..">", k))
            end
        end
    end
    print("--------------------------------------------------")
end

local function CreateDevButton(parent, t)
    local bName, bType, bAction, bDependOnAddon, bHasEditBox, color, isModifierKeyRequired = unpack(t)

    local bg = Dev:CreateFrame(nil, parent, BUTTON_WIDTH + BUTTON_SPACING * 2, BUTTON_HEIGHT + BUTTON_SPACING, isTransparent)
    Dev:StylizeFrame(bg, {0, 0, 0, 0.7}, {0, 0, 0, 0})
    bg:Show()

    local b = Dev:CreateButton(bg, bName, color or "red", {BUTTON_WIDTH, BUTTON_HEIGHT}, false, true)
    b:SetPoint("TOPLEFT", BUTTON_SPACING, 0)

    if not bDependOnAddon or IsAddOnLoaded(bDependOnAddon) then
        if bType == "macro" then
            -- https://wow.gamepedia.com/SecureActionButtonTemplate
            b:SetAttribute("type1", "macro") -- left click causes macro
            b:SetAttribute("macrotext1", bAction) -- text for macro on left click

        elseif bType == "script" then
            if bHasEditBox then
                b.eb = Dev:CreateEditBox(b, BUTTON_WIDTH, BUTTON_HEIGHT)
                b.eb:SetBackdropBorderColor(unpack(b.hoverColor))
                b.eb:SetPoint("TOPLEFT", b, "BOTTOMLEFT")
                bg:SetHeight(BUTTON_HEIGHT * 2 + BUTTON_SPACING)
            end

            b:SetScript("OnClick", function(self, button, down)
                if not down then return end
                if isModifierKeyRequired and not IsModifierKeyDown() then return end
                if bHasEditBox then
                    local p = b.eb:GetText()
                    local script = string.gsub(bAction, "%$", p)
                    RunScript(script)
                else
                    RunScript(bAction)
                end
            end)

        elseif bType == "function" then
            if bHasEditBox then
                b.eb = Dev:CreateEditBox(b, BUTTON_WIDTH, BUTTON_HEIGHT)
                b.eb:SetBackdropBorderColor(unpack(b.hoverColor))
                b.eb:SetPoint("TOP", b, "BOTTOM")
                bg:SetHeight(BUTTON_HEIGHT * 2 + BUTTON_SPACING)
            end

            b:SetScript("OnClick", function(self, button, down)
                if not down then return end
                if isModifierKeyRequired and not IsModifierKeyDown() then return end
                if b.eb then
                    bAction(b.eb:GetText())
                else
                    bAction(b)
                end
            end)
        end
    else
        b:SetEnabled(false)
    end

    return bg
end

local function GetSpellName(id)
    if C_Spell.GetSpellName then
        return C_Spell.GetSpellName(id)
    else
        return GetSpellInfo(id)
    end
end

---------------------------------------------------------------------
-- buttons
---------------------------------------------------------------------
-- {name/addonName, type, action, dependOnAddon, hasEditBox}
local buttons = {
    -- general
    {
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
        {"|cff7fff00ColorConverter", "function", function()
            Dev:ShowColorConverter()
        end},
        {"|cff7fff00SpellLocalizer", "function", function()
            Dev:ShowSpellLocalizer()
        end},
        {"|cff7fff00GetItemIcons", "function", function(b)
            if type(DevItemIcons) ~= "table" then return end

            b:SetEnabled(false)

            local index = 1
            local isProcessing = false
            local num = #DevItemIcons

            b:SetScript("OnUpdate", function()
                if not isProcessing then
                    isProcessing = true

                    local value = DevItemIcons[index]
                    if value and type(value) == "number" then
                        local icon = select(5, C_Item.GetItemInfoInstant(value))
                        if icon then
                            value = value .. ":" .. icon
                        else
                            value = value .. ":nil"
                        end
                        DevItemIcons[index] = value

                        b:SetFormattedText("%.2f%%", index / num * 100)
                        index = index + 1
                        isProcessing = false
                    else
                        b:SetScript("OnUpdate", nil)
                        b:SetText("|cffff77ffGetItemIcons")
                        b:SetEnabled(true)
                    end
                end
            end)
        end},
        {"|cff77ffffSpellInfo", "function", function(spellId)
            spellId = tonumber(spellId)
            if spellId then
                local keys = {"name", "rank", "icon", "castTime", "minRange", "maxRange", "spellID", "originalIcon"}
                PrintTableWithKeyNames(C_Spell.GetSpellInfo(spellId), keys, C_Spell.GetSpellLink(spellId))
            end
        end, nil, true},
        {"|cff77ffffItemInfo", "function", function(itemId)
            itemId = tonumber(itemId)
            if itemId then
                local keys = {"itemName", "itemLink", "itemQuality", "itemLevel", "itemMinLevel", "itemType", "itemSubType", "itemStackCount", "itemEquipLoc",
                    "itemTexture", "sellPrice", "classID", "subclassID", "bindType", "expansionID", "setID", "isCraftingReagent"}
                PrintTableWithKeyNames({C_Item.GetItemInfo(itemId)}, keys)
            end
        end, nil, true},
        {"|cff77ffffAchievementInfo", "function", function(achievementId)
            achievementId = tonumber(achievementId)
            if achievementId then
                local keys = {"id", "name", "points", "completed", "month", "day", "year", "description", "flags", "icon", "rewardText", "isGuild",
                    "wasEarnedByMe", "earnedBy", "isStatistic", "numCriteria"}
                local t = {GetAchievementInfo(achievementId)}
                tinsert(t, GetAchievementNumCriteria(achievementId))
                PrintTableWithKeyNames(t, keys, GetAchievementLink(achievementId))
            end
        end, nil, true},
    },

    -- others
    {
        {"|cff77ffffCLEU", "function", function(subEvent)
            if not DevCLEUFrame then
                DevCLEUFrame = CreateFrame("Frame")
                DevCLEUFrame:SetScript("OnEvent", function()
                    local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg1, arg2, arg3, arg4, arg5, arg6, arg7 = CombatLogGetCurrentEventInfo()
                    if DevCLEUFrame.subEvent then
                        if DevCLEUFrame.subEvent == subEvent then
                            print(timestamp, sourceName, destName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
                        end
                    else
                        print(timestamp, subEvent, sourceName, destName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
                    end
                end)
            end

            if strtrim(subEvent) ~= "" then
                DevCLEUFrame.subEvent = subEvent
            else
                DevCLEUFrame.subEvent = nil
            end

            if DevCLEUFrame.enabled then
                if DevCLEUFrame.subEvent then
                    print("|cff77ffffCLEU|r:disabled, subEvent:" .. DevCLEUFrame.subEvent)
                else
                    print("|cff77ffffCLEU|r:disabled")
                end
                DevCLEUFrame:UnregisterAllEvents()
            else
                print("|cff77ffffCLEU|r:enabled")
                DevCLEUFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            end
            DevCLEUFrame.enabled = not DevCLEUFrame.enabled
        end, nil, true},
        {"|cffffdeadFrameTemplates", "function", function()
            if TemplatePreviewParent then
                if TemplatePreviewParent:IsShown() then
                    TemplatePreviewParent:Hide()
                    UIParent:Show()
                else
                    TemplatePreviewParent:Show()
                    UIParent:Hide()
                end
                return
            end

            UIParent:Hide()

            local frameList = {
                "BaseBasicFrameTemplate",
                "BasicFrameTemplate",
                "BasicFrameTemplateWithInset",
                "ButtonFrameTemplate",
                "ButtonFrameTemplateMinimizable",
                "ChatConfigBorderBoxTemplate",
                "ChatConfigBoxTemplate",
                "ChatConfigBoxWithHeaderTemplate",
                "ChatConfigCheckBoxTemplate",
                -- "CovenantListWideFrameTemplate",
                -- "CovenantMissionBaseFrameTemplate",
                "DefaultPanelTemplate",
                "DefaultPanelTemplate",
                "EtherealFrameTemplate",
                "FloatingBorderedFrame",
                -- "GarrisonMissionBaseFrameTemplate",
                "GlowBorderTemplate",
                "GlowBoxTemplate",
                "HelpFrameContainerFrameTemplate",
                "InsetFrameTemplate",
                "InsetFrameTemplate2",
                "InsetFrameTemplate3",
                "InsetFrameTemplate4",
                -- "KeyBindingFrameBindingButtonTemplate",
                -- "KeyBindingFrameBindingButtonTemplateWithLabel",
                "PortraitFrameTemplate",
                "PortraitFrameTemplateMinimizable",
                "PortraitFrameTemplateNoCloseButton",
                "SimplePanelTemplate",
                "ThinBorderTemplate",
                "TooltipBorderedFrameTemplate",
                "TranslucentFrameTemplate",
                "UIPanelDialogTemplate",
            }

            local width, height = 210, 110
            local spacing = 15

            local parent = CreateFrame("Frame", "TemplatePreviewParent")
            parent:SetAllPoints()
            parent:SetScale(768 / GetScreenHeight())

            local function Create(k, template)
                local f = CreateFrame("Frame", "TemplatePreviewFrame"..k, parent, template)
                f:SetSize(width, height)

                local fs = f:CreateFontString(nil, "OVERLAY", "DEV_FONT_TITLE")
                fs:SetPoint("BOTTOMLEFT", 5, 10)
                fs:SetPoint("BOTTOMRIGHT", -5, 10)
                fs:SetNonSpaceWrap(true)
                fs:SetText(template)

                if k == 1 then
                    f:SetPoint("TOPLEFT", 10, -10)
                elseif k % 7 == 1 then
                    f:SetPoint("TOPLEFT", _G["TemplatePreviewFrame"..(k-7)], "TOPRIGHT", spacing, 0)
                else
                    f:SetPoint("TOPLEFT", _G["TemplatePreviewFrame"..(k-1)], "BOTTOMLEFT", 0, -spacing)
                end
            end

            for k, template in pairs(frameList) do
                pcall(Create, k, template)
            end
        end},
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
    },

    -- custom
    {
        {"reset Cell", "script", "CellDB=nil;CellCharacterDB=nil;ReloadUI()", "Cell", false, "green", true},
        {"RaidDebuffs", "function", function(id)
            id = id and tonumber(id)
            if not (id and Cell.snippetVars.loadedDebuffs[id]) then return end

            local result = ""
            local t = Cell.snippetVars.loadedDebuffs[id]

            for boss, debuffs in pairs(t) do
                result = result .. "[" .. boss .. "] = {\n"
                -- enabled
                for _, dt in pairs(debuffs["enabled"]) do
                    local name = GetSpellName(dt.id)
                    if name then
                        local id = dt.trackByID and ("\""..dt.id.."\"") or dt.id
                        result = result .. "    " .. id .. ", -- " .. name .. "\n"
                    end
                end
                -- disabled
                for _, dt in pairs(debuffs["disabled"]) do
                    local name = GetSpellName(dt.id)
                    if name then
                        local id = dt.trackByID and ("\"-"..dt.id.."\"") or -dt.id
                        result = result .. "    " .. id .. ", -- " .. name .. "\n"
                    end
                end

                result = result .. "},\n"
            end

            scroll:SetText(result)
            textFrame:Show()
        end, "Cell", true, "blue"},
        {"AW_DEMO", "script", "BigFootInfinite.AW:ShowDemo()", "BigFootInfinite", false, "blue"},
        {"BFI Config Mode", "script", "BFI.Fire(\"ConfigMode\")", "BigFootInfinite", false, "yellow"},
        {"BFI Movers", "macro", "/bfi mover", "BigFootInfinite", false, "yellow"},
        {"BFI.current", "script", "texplore(BigFootInfinite.vars.currentConfigTable)", "BigFootInfinite", false, "blue"},
        {"wipe BFI", "script", "BFIConfig=nil;BFIPlayer=nil;BFIGuild=nil;ReloadUI()", "BigFootInfinite", false, "green", true},
    },
    -- {"Abstract data", "script", "texplore(\"Abstract\", Abstract.data, 10)", "Abstract"},
    -- {"wipe AbstractDB", "script", "AbstractDB=nil;ReloadUI()", "Abstract", false, "green"},
    -- {"wipe TIC_DB", "script", "TIC_DB=nil;ReloadUI()", "TooltipItemCount", false, "green"},
    -- {"wipe IVSP", "script", "IVSP_Config=nil;IVSP_Custom=nil;ReloadUI()", "IcyVeinsStatPriority", false, "green"},
    -- {"CellDB debuffs", "script", "texplore(CellDB[\"raidDebuffs\"])", "TableExplorer"},
    -- {"Cell.unitButtons", "script", "texplore(Cell.unitButtons)", "Cell"},
    -- {"CellDB indicators", "script", "texplore(Cell.vars.currentLayoutTable.indicators)", "Cell"},
    -- {"Invite", "macro", "/invite Programming-影之哀伤\n/invite Luascript-影之哀伤"},
}

---------------------------------------------------------------------
-- events
---------------------------------------------------------------------
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

    local last, lastColumn
    local columns = #buttons

    for i, column in pairs(buttons) do
        for j, t in pairs(column) do
            local b, hasEditBox = CreateDevButton(devButtonsFrame, t)

            if j == 1 then
                if lastColumn then
                    b:SetPoint("TOPLEFT", lastColumn, "TOPRIGHT")
                else
                    b:SetPoint("TOPLEFT", devButtonsFrame, "BOTTOMLEFT")
                end
                lastColumn = b
            else
                b:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
            end
            last = b
        end
    end

    devButtonsFrame:SetWidth((BUTTON_WIDTH + BUTTON_SPACING * 2) * columns)
    -- devButtonsFrame:SetHeight(#buttons * (BUTTON_HEIGHT + BUTTON_SPACING) + 20 + numEB * BUTTON_HEIGHT)
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
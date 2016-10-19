local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

XMSPELLBUTTON = LibStub("AceAddon-3.0"):NewAddon("XMSPELLBUTTON", "AceEvent-3.0", "AceConsole-3.0")

local XM.locale = LibStub("AceLocale-3.0"):GetLocale("XM")

----local variables
--
----tables for consumable items
--local itemtable = {}
--itemtable[1] = {
--    --items that share health stone cooldown (sort by hp)
--    --priority, itemID, texture, amount
--    [1] = {ID = 36894, TXT = "INV_Stone_04", AMT = 5136}, -- Fel Healthstone 5136
--    [2] = {ID = 36893, TXT = "INV_Stone_04", AMT = 4708}, -- Fel Healthstone 4708
--    [3] = {ID = 36892, TXT = "INV_Stone_04", AMT = 4280}, -- Fel Healthstone 4280
--    [4] = {ID = 22105, TXT = "INV_Stone_04", AMT = 2496},  --Healthstone 2496
--    [5] = {ID = 22104, TXT = "INV_Stone_04", AMT = 2288},  --Healthstone 2288
--    [6] = {ID = 22103, TXT = "INV_Stone_04", AMT = 2080},  --Healthstone 2080
--    [7] = {ID = 22797, TXT = "INV_Misc_Herb_Nightmareseed", AMT = 2000},  --Nightmare Seed
--}
--
----graphical frame arrays
--local ButtonType = #itemtable
--local ButtonCount = {}
--local ItemButton = {}
--
--local HealthButtonKey
--local ManaButtonKey
--local HSButtonKey
--local HPotButtonKey
--local MSButtonKey
--local MPotButtonKey
local SpellButtonKey = "0"

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMSPELLBUTTON:OnInitialize()
--called when addon loads

--    --initialize DB for new users
--    if (not XM.db["XMPOTION"]) then
--        XM.db["XMPOTION"] = {}
--        DEFAULT_CHAT_FRAME:AddMessage(XM.locale["addonName"].."Initializing Potion Frame: "..UnitName("player").." - "..GetRealmName():trim())
--
--        --write default values to the current profile (too bad they can't be sorted)
--        for key, value in pairs(XMPOTION.DEFAULTS) do
--            XM.db["XMPOTION"][key] = value
--        end
--    end

    --initialize spellbutton frame
    XMSPELLBUTTON:CreateSecurePotionFrame()

--    --register events
--    XMPOTION:RegisterEvent("PLAYER_REGEN_ENABLED")
--    XMPOTION:RegisterEvent("UNIT_INVENTORY_CHANGED")

end
--[[
--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMPOTION:OnUpdate(elapsed)
--update screen objects

    if (UnitIsGhost("player") == 1 or UnitIsDead("player") == 1) then
        XM.player.combatActive = false
    end

    if (XMPLAYER) then

    local h,i = 1,1
    local starttime,cooldown
    local itemcount = 0

    h = 1
    while (h <= ButtonType) do
        i = 1
        itemcount = 0

        while (i <= #ItemButton[h]) do
            if (i > ButtonCount[h] or XMPLAYER.VISIBLE == false) then
                ItemButton[h][i].texture:SetVertexColor(0,0,0,0)
                ItemButton[h][i].count:SetText("")
                ItemButton[h][i].cd:SetText("")
                ItemButton[h][i].key:SetText("")
            else
                itemcount = GetItemCount("item:"..itemtable[h][ItemButton[h][i].ID].ID)
                if (itemcount and itemcount > 0) then
                    ItemButton[h][i].count:SetText(itemcount)

                    starttime,cooldown,_ = GetItemCooldown("item:"..itemtable[h][ItemButton[h][i].ID].ID)
                    if (starttime > 0) then
                        ItemButton[h][i].texture:SetVertexColor(0.3,0.3,0.3,1)
                        ItemButton[h][i].cd:SetText(("%.0f"):format(cooldown - (GetTime() - starttime)))
                    elseif (h == 1 or h == 3) and (UnitHealthMax("player") - UnitHealth("player") >= itemtable[h][ItemButton[h][i].ID].AMT) then
                        ItemButton[h][i].texture:SetVertexColor(1,1,1,1)
                        ItemButton[h][i].cd:SetText("")
                    elseif (h == 2 or h == 4) and (UnitPowerType("player") < 1) and (UnitManaMax("player") - UnitMana("player") >= itemtable[h][ItemButton[h][i].ID].AMT) then
                        ItemButton[h][i].texture:SetVertexColor(1,1,1,1)
                        ItemButton[h][i].cd:SetText("")
                    else
                        ItemButton[h][i].texture:SetVertexColor(0.3,0.3,0.3,1)
                        ItemButton[h][i].cd:SetText("")
                    end

                    if (h == 1) and (ButtonCount[h] >= 1) and (HealthButtonKey and HealthButtonKey ~= "") then
                        ItemButton[h][1].key:SetText(HealthButtonKey)
                    elseif (h == 3) and (ButtonCount[h-2] < 1) and (ButtonCount[h] >= 1) and (HealthButtonKey and HealthButtonKey ~= "") then
                        ItemButton[h][1].key:SetText(HealthButtonKey)
                    elseif (h == 3) and (ButtonCount[h-2] >= 1) and (ButtonCount[h] >= 1) then
                        if (HSButtonKey and HSButtonKey ~= "") then
                            ItemButton[h-2][1].key:SetText(HSButtonKey)
                        end
                        if (HPotButtonKey and HPotButtonKey ~= "") then
                            ItemButton[h-2][1].key:SetText(HPotButtonKey)
                        end
                    elseif (h == 2) and (ButtonCount[h] >= 1) and (ManaButtonKey and ManaButtonKey ~= "") then
                        ItemButton[h][1].key:SetText(ManaButtonKey)
                    elseif (h == 4) and (ButtonCount[h-2] < 1) and (ButtonCount[h] >= 1) and (ManaButtonKey and ManaButtonKey ~= "") then
                        ItemButton[h][1].key:SetText(ManaButtonKey)
                    elseif (h == 4) and (ButtonCount[h-2] >= 1) and (ButtonCount[h] >= 1) then
                        if (MSButtonKey and MSButtonKey ~= "") then
                            ItemButton[h][1].key:SetText(MSButtonKey)
                        end
                        if (MPotButtonKey and MPotButtonKey ~= "") then
                            ItemButton[h][1].key:SetText(MPotButtonKey)
                        end
                    else
                        ItemButton[h][1].key:SetText("")
                    end

                else
                    ItemButton[h][i].texture:SetVertexColor(0.3,0.3,0.3,1)
                    ItemButton[h][i].count:SetText("")
                    ItemButton[h][i].cd:SetText("")
                    ItemButton[h][i].key:SetText("")
                end
            end
            i = i + 1
        end
        h = h + 1
    end

    end

end
]]

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMSPELLBUTTON:CreateSecurePotionFrame()

--    if (XMPLAYER) and (XM.player.combatActive == false) then

    --main spellbutton frame
    if (not XM_SPELLBUTTONFRAME) then
        XM_SPELLBUTTONFRAME = CreateFrame("Frame", "XM SpellButton Frame", UIParent)
        XM_SPELLBUTTONFRAME:SetAllPoints(UIParent)
    end
    XM_SPELLBUTTONFRAME:SetFrameStrata(XM.db["XMPLAYER"]["PLAYERSTRATA"])
--    XM_SPELLBUTTONFRAME:SetScript("OnUpdate", function() XMPOTION:OnUpdate(arg1) end)
--
--    local h,i,j
--    local calcx,calcy = 0,0
    local ButtonSquare = 25
--    local itemcount
--
--    h = 1
--    while (h <= ButtonType) do
--
--        i,j = 1,1
--        ButtonCount[h] = 0
--        itemcount = 0
--
--        while (i <= #itemtable[h] + 1) do
--            if (i == #itemtable[h] + 1) then
--                j = #ItemButton[h]
--                while (j > ButtonCount[h]) do
--                    if (ItemButton[h][j]) then
--                        ItemButton[h][j].texture:SetVertexColor(0,0,0,0)
--                    end
--                    j = j - 1
--                end
--                i = i + 1
--            else
--                itemcount = GetItemCount("item:"..itemtable[h][i].ID)
--                if (itemcount and itemcount > 0) then
--                    ButtonCount[h] = ButtonCount[h] + 1
--                    if (not ItemButton[h][ButtonCount[h]]) then
                        SpellButton1 = CreateFrame("Button", "SpellButton1", XM_SPELLBUTTONFRAME, "SecureActionButtonTemplate")
                        SpellButton1:SetFrameStrata(XM.db["XMPLAYER"]["PLAYERSTRATA"])

                        SpellButton1:SetHeight(ButtonSquare)
                        SpellButton1:SetWidth(ButtonSquare)

                        SpellButton1.texture = SpellButton1:CreateTexture()
                        SpellButton1.texture:SetAllPoints(SpellButton1)

--                        SpellButton1.text = CreateFrame("Frame", "ItemButton"..h.."-"..ButtonCount[h].."text", ItemButton[h][ButtonCount[h]])
--                        SpellButton1.text:SetFrameLevel((ItemButton[h][ButtonCount[h]]:GetFrameLevel())+1)
--                        SpellButton1.text:SetAllPoints(ItemButton[h][ButtonCount[h]])
--
--                        ItemButton[h][ButtonCount[h]].cd = ItemButton[h][ButtonCount[h]].text:CreateFontString("ItemButton"..h.."-"..ButtonCount[h].."cd", "OVERLAY", "GameFontNormal")
--                        ItemButton[h][ButtonCount[h]].cd:SetPoint("CENTER", ItemButton[h][ButtonCount[h]].text)
--                        ItemButton[h][ButtonCount[h]].cd:SetFont(XM.sharedMedia:Fetch("font","Emblem"), (ItemButton[h][ButtonCount[h]]:GetHeight()*0.4), "OUTLINE")
--                        ItemButton[h][ButtonCount[h]].cd:SetTextColor(1,1,1)
--                        ItemButton[h][ButtonCount[h]].cd:SetAlpha(1)
--
--                        ItemButton[h][ButtonCount[h]].key = ItemButton[h][ButtonCount[h]].text:CreateFontString("ItemButton"..h.."-"..ButtonCount[h].."key", "OVERLAY", "GameFontNormal")
--                        ItemButton[h][ButtonCount[h]].key:SetPoint("TOPRIGHT", ItemButton[h][ButtonCount[h]].text)
--                        ItemButton[h][ButtonCount[h]].key:SetFont(XM.sharedMedia:Fetch("font","Emblem"), (ItemButton[h][ButtonCount[h]]:GetHeight()*0.3), "OUTLINE")
--                        ItemButton[h][ButtonCount[h]].key:SetTextColor(1,1,1)
--                        ItemButton[h][ButtonCount[h]].key:SetAlpha(1)
--
--                        ItemButton[h][ButtonCount[h]].count = ItemButton[h][ButtonCount[h]].text:CreateFontString("ItemButton"..h.."-"..ButtonCount[h].."count", "OVERLAY", "GameFontNormal")
--                        ItemButton[h][ButtonCount[h]].count:SetPoint("BOTTOMRIGHT", ItemButton[h][ButtonCount[h]].text)
--                        ItemButton[h][ButtonCount[h]].count:SetFont(XM.sharedMedia:Fetch("font","Emblem"), (ItemButton[h][ButtonCount[h]]:GetHeight()*0.4), "OUTLINE")
--                        ItemButton[h][ButtonCount[h]].count:SetTextColor(1,1,1)
--                        ItemButton[h][ButtonCount[h]].count:SetAlpha(1)
--                    end
--                    ItemButton[h][ButtonCount[h]]:ClearAllPoints()
--                    if (h == 1) then
--                        calcx = -1 * (ButtonSquare + (ButtonSquare/3))
--                        if (XM.db["XMPLAYER"]["PLAYERSWAP"] == 1) then
--                            calcy = -1 * (XM.db["XMPLAYER"]["PLAYERHEIGHT"] + (ButtonSquare * (ButtonCount[h] - 1)))
--                            ItemButton[h][ButtonCount[h]]:SetPoint("TOPLEFT", XM_PLAYERFRAME, "TOPLEFT", calcx, calcy)
--                        else
--                            calcy = (XM.db["XMPLAYER"]["PLAYERHEIGHT"] + (ButtonSquare * (ButtonCount[h] - 1)))
--                            ItemButton[h][ButtonCount[h]]:SetPoint("BOTTOMLEFT", XM_PLAYERFRAME, "BOTTOMLEFT", calcx, calcy)
--                        end
--                    elseif (h == 2) then
--                        calcx = -1 * (ButtonSquare + (ButtonSquare/3))
--                        if (XM.db["XMPLAYER"]["PLAYERSWAP"] == 1) then
--                            calcy = (XM.db["XMPLAYER"]["PLAYERHEIGHT"] + (ButtonSquare * (ButtonCount[h] - 1)))
--                            ItemButton[h][ButtonCount[h]]:SetPoint("BOTTOMLEFT", XM_PLAYERFRAME, "BOTTOMLEFT", calcx, calcy)
--                        else
--                            calcy = -1 * (XM.db["XMPLAYER"]["PLAYERHEIGHT"] + (ButtonSquare * (ButtonCount[h] - 1)))
--                            ItemButton[h][ButtonCount[h]]:SetPoint("TOPLEFT", XM_PLAYERFRAME, "TOPLEFT", calcx, calcy)
--                        end
--                    elseif (h == 3) then
--                        calcx = -1 * (2*ButtonSquare + (ButtonSquare/3))
--                        if (XM.db["XMPLAYER"]["PLAYERSWAP"] == 1) then
--                            calcy = -1 * (XM.db["XMPLAYER"]["PLAYERHEIGHT"] + (ButtonSquare * (ButtonCount[h] - 1)))
--                            ItemButton[h][ButtonCount[h]]:SetPoint("TOPLEFT", XM_PLAYERFRAME, "TOPLEFT", calcx, calcy)
--                        else
--                            calcy = (XM.db["XMPLAYER"]["PLAYERHEIGHT"] + (ButtonSquare * (ButtonCount[h] - 1)))
--                            ItemButton[h][ButtonCount[h]]:SetPoint("BOTTOMLEFT", XM_PLAYERFRAME, "BOTTOMLEFT", calcx, calcy)
--                        end
--                    elseif (h == 4) then
--                        calcx = -1 * (2*ButtonSquare + (ButtonSquare/3))
--                        if (XM.db["XMPLAYER"]["PLAYERSWAP"] == 1) then
--                            calcy = (XM.db["XMPLAYER"]["PLAYERHEIGHT"] + (ButtonSquare * (ButtonCount[h] - 1)))
--                            ItemButton[h][ButtonCount[h]]:SetPoint("BOTTOMLEFT", XM_PLAYERFRAME, "BOTTOMLEFT", calcx, calcy)
--                        else
--                            calcy = -1 * (XM.db["XMPLAYER"]["PLAYERHEIGHT"] + (ButtonSquare * (ButtonCount[h] - 1)))
--                            ItemButton[h][ButtonCount[h]]:SetPoint("TOPLEFT", XM_PLAYERFRAME, "TOPLEFT", calcx, calcy)
--                        end
--                    end

SpellButton1:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT")


--                    ItemButton[h][ButtonCount[h]].ID = i

                    SpellButton1.texture:SetTexture("Interface\\Icons\\Ability_Ambush")
                    SpellButton1.texture:SetVertexColor(1,1,1,1)
                    SpellButton1:SetAttribute("type", "spell")
                    SpellButton1:SetAttribute("spell", "Battle Shout")
--
--                    if (h == 1) and (ButtonCount[h] >= 1) and (HealthButtonKey and HealthButtonKey ~= "") then
                        SetOverrideBindingClick(SpellButton1, false, SpellButtonKey, SpellButton1:GetName())
--                    elseif (h == 3) and (ButtonCount[h-2] < 1) and (ButtonCount[h] >= 1) and (HealthButtonKey and HealthButtonKey ~= "") then
--                        SetOverrideBindingClick(ItemButton[h][1], false, HealthButtonKey, ItemButton[h][1]:GetName())
--                    elseif (h == 3) and (ButtonCount[h-2] >= 1) and (ButtonCount[h] >= 1) then
--                        if (HSButtonKey and HSButtonKey ~= "") then
--                            SetOverrideBindingClick(ItemButton[h-2][1], false, HSButtonKey, ItemButton[h-2][1]:GetName())
--                        end
--                        if (HPotButtonKey and HPotButtonKey ~= "") then
--                            SetOverrideBindingClick(ItemButton[h][1], false, HPotButtonKey, ItemButton[h][1]:GetName())
--                        end
--                    elseif (h == 2) and (ButtonCount[h] >= 1) and (ManaButtonKey and ManaButtonKey ~= "") then
--                        SetOverrideBindingClick(ItemButton[h][1], false, ManaButtonKey, ItemButton[h][1]:GetName())
--                    elseif (h == 4) and (ButtonCount[h-2] < 1) and (ButtonCount[h] >= 1) and (ManaButtonKey and ManaButtonKey ~= "") then
--                        SetOverrideBindingClick(ItemButton[h][1], false, ManaButtonKey, ItemButton[h][1]:GetName())
--                    elseif (h == 4) and (ButtonCount[h-2] >= 1) and (ButtonCount[h] >= 1) then
--                        if (MSButtonKey and MSButtonKey ~= "") then
--                            SetOverrideBindingClick(ItemButton[h-2][1], false, MSButtonKey, ItemButton[h-2][1]:GetName())
--                        end
--                        if (MPotButtonKey and MPotButtonKey ~= "") then
--                            SetOverrideBindingClick(ItemButton[h][1], false, MPotButtonKey, ItemButton[h][1]:GetName())
--                        end
--                    else
--                        ClearOverrideBindings(ItemButton[h][1])
--                    end
--                    ShowUIPanel(ItemButton[h][ButtonCount[h]])
--                end
--            end
--            i = i + 1
--        end
--        if (ButtonCount[h] == 0 and #ItemButton[h] > 0) then
--            ClearOverrideBindings(ItemButton[h][1])
--        end
--        h = h + 1
--    end
--
--    end

end
--[[
--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMPOTION:PLAYER_REGEN_ENABLED()
--player leaving combat

    XMPOTION:CreateSecurePotionFrame()

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMPOTION:UNIT_INVENTORY_CHANGED(_,unit)

    if (XM.player.combatActive == false and unit == "player") then
        XMPOTION:CreateSecurePotionFrame()
    end

end
]]

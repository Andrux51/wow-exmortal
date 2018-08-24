local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

local petTable = {}
XM.extraSpellsCheckTable = {}
XM.reflectTable = {}

-- TODO: set up some options...
-- "all incoming events from my target"
-- "all outgoing events to my target"
-- "pvp mode - show all cc everywhere"
-- "my combat events" (incoming/outgoing)
-- "party combat events"

-- http://wow.gamepedia.com/COMBAT_LOG_EVENT
function XM:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
    local timestamp, event, hideCaster, sourceGuid, sourceName, sourceFlags,
        sourceRaidFlags, destGuid, destName, dstFlags, dstRaidFlags, spellId, spellName, spellSchool,
        suffixOne, suffixTwo, suffixThree, suffixsuffixOne, suffixFive, suffixSix, suffixSeven, suffixEight, suffixNine, suffixTen = CombatLogGetCurrentEventInfo()

    local environmentType = spellId -- ENVIRONMENT event uses same prefix arg as spellId

    local skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush, missType, power, extra

    local displayFrame = ''

    XM.player.pet.id = UnitGUID("pet")

    --local i = 1
    local petkey = 0

    local filter = false

    local incoming = false
    if destGuid == XM.player.id or (XM.player.pet.id and destGuid == XM.player.pet.id) then
        incoming = true
    end

    if sourceGuid == XM.player.id then
        -- print('src- '..event)
    elseif incoming then
        --print('dst- '..event)
    end

    --get player pets (that aren't "pet") ... (mostly for totems)
    --?? for better memory usage, should destroy old totems / remove old pets
    if strfind(event, "_SUMMON") then
        if (#petTable < 1) then
            petTable[1] = {ID = destGuid, NAME = destName, OWNERID = sourceGuid, OWNERNAME = sourceName}
        else
            for i, _ in ipairs(petTable) do
                if (petTable[i].ID == destGuid) then
                    break
                elseif (i == #petTable) then
                    --petTable[(#petTable + 1)] = {ID = destGuid, NAME = destName, OWNERID = sourceGuid, OWNERNAME = sourceName}
                    tinsert(petTable, {ID = destGuid, NAME = destName, OWNERID = sourceGuid, OWNERNAME = sourceName})
                end
            end
        end
    end

    if sourceGuid ~= XM.player.id and sourceGuid ~= XM.player.pet.id then
        --check pet table
        for i, _ in ipairs(petTable) do
            if (sourceGuid == petTable[i].ID) then
                petkey = i
                break
            end
        end
    end

    if strfind(event, 'SWING') then
        skill = nil
    elseif strfind(event, "ENVIRONMENTAL") then
        skill = spellId
    else
        skill = spellName
    end

    if strfind(event, '_CAST_START') then
        if sourceGuid == XM.player.id or destGuid == XM.player.id then
            XM:HandleCastStart(skill, incoming, sourceGuid, sourceName, destGuid, destName)
        end
    elseif strfind(event, "_DAMAGE") then
        XM:HandleDamageEvents(event, skill, incoming, sourceGuid, sourceName, destGuid, destName, spellId, spellName, spellSchool, suffixOne, suffixTwo, suffixThree, suffixsuffixOne, suffixFive, suffixSix, suffixSeven)
    elseif (strfind(event, "_MISSED")) then
        -- miss events [miss, dodge, block, deflect, immune, evade, parry, resist, absorb, reflect]
        if strfind(event, "SWING") then
            missType = spellId
        elseif strfind(event, "ENVIRONMENTAL") then
            missType = spellName
        else
            missType = suffixOne
        end
        if (destGuid == XM.player.id) then
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event(missType.."INC", missType, nil, nil, sourceName, destName, nil)
            else
                if (missType == "REFLECT") then
                    tinsert(XM.reflectTable, {TARGET = sourceGuid, SPELL = skill})
                end
                XM:Display_Event(missType.."INC", missType, nil, nil, sourceName, destName, skill)
            end
        elseif (sourceGuid == XM.player.id) then
            if (strfind(event, "SWING")) then
                XM:Display_Event(missType.."OUT", missType, nil, nil, sourceName, destName, nil)
            elseif (strfind(event, "RANGE")) then
                XM:Display_Event(missType.."OUT", missType, nil, nil, sourceName, destName, nil)
            else
                if (#XM.extraSpellsCheckTable > 0) then
                    for key, value in pairs(XM.extraSpellsCheckTable) do
                        if (value == skill) then
                            tremove(XM.extraSpellsCheckTable,key)
                        end
                    end
                end
                XM:Display_Event(missType.."OUT", missType, nil, nil, sourceName, destName, skill)
            end
        elseif (XM.player.pet.id and destGuid == XM.player.pet.id) then
            -- incoming pet miss events
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event("PET"..missType.."INC", missType.."("..PET..")", nil, nil, sourceName, destName, nil)
            else
                XM:Display_Event("PET"..missType.."INC", missType.."("..PET..")", nil, nil, sourceName, destName, skill)
            end
        elseif (XM.player.pet.id and sourceGuid == XM.player.pet.id) then
            -- outgoing pet miss events
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event("PETMISSOUT", PET.." "..missType, nil, nil, sourceName, destName, nil)
            else
                XM:Display_Event("PETMISSOUT", PET.." "..missType, nil, nil, sourceName, destName, skill)
            end
        elseif (#XM.reflectTable >= 1) then
            -- reflected events
            if (XM.reflectTable[1].TARGET == sourceGuid and XM.reflectTable[1].SPELL == skill) then
                XM:Display_Event(missType.."OUT", "("..XM.locale["REFLECT"]..") "..missType, nil, nil, sourceName, destName, skill)
                tremove(XM.reflectTable,1)
            end
        end
    elseif (strfind(event, "DAMAGE_")) then
        -- damage shields or split damage
        skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = spellName, suffixOne or 0, XM.elements[(suffixThree)], suffixsuffixOne, suffixFive, suffixSix, suffixSeven, eleven, twelve

        local text = XM:TruncateAmount(amount)
        if (isCrush) then
            text = XM.db["CRUSHCHAR"]..text..XM.db["CRUSHCHAR"]
        elseif (isGlance) then
            text = XM.db["GLANCECHAR"]..text..XM.db["GLANCECHAR"]
        elseif (isCrit) then
            text = XM.db["CRITCHAR"]..text..XM.db["CRITCHAR"]
        end
        if (amountAbsorb) and (XM.db["ABSORBINC"]) then
            text = text.." ("..XM.locale["ABSORB"].." "..XM:TruncateAmount(amountAbsorb)..")"
        end
        if (amountBlock) and (XM.db["BLOCKINC"]) then
            text = text.." ("..XM.locale["BLOCK"].." "..XM:TruncateAmount(amountBlock)..")"
        end
        if (amountResist) and (XM.db["RESISTINC"]) then
            text = text.." ("..XM.locale["RESIST"].." "..XM:TruncateAmount(amountResist)..")"
        end

        if destGuid == XM.player.id and amount > XM.db["DMGFILTERINC"] then
            XM:Display_Event("DMGSHIELDINC", "-"..text, isCrit, element, sourceName, destName, skill)
        elseif sourceGuid == XM.player.id and amount > XM.db["DMGFILTEROUT"] then
            XM:Display_Event("DMGSHIELDOUT", text, isCrit, element, sourceName, destName, skill)
        end
    elseif strfind(event, "_HEAL") then
        if strfind(event, "SWING") then
            amount, isCrit, extra = spellId, suffixOne, spellName
        elseif strfind(event, "ENVIRONMENTAL") then
            amount, isCrit, extra = spellName, suffixTwo, spellSchool
        else
            amount, isCrit, extra = suffixOne, suffixsuffixOne, suffixTwo
        end

        local healtext = XM:TruncateAmount(amount)
        local healamt = amount
        if extra and type(extra) == 'number' and extra > 0 then
            healamt = amount - extra
            healtext = XM:TruncateAmount(healamt).." {"..XM:TruncateAmount(extra).."}"
        end

        if (XM.db["SHOWHOTS"] or not strfind(event, "SPELL_PERIODIC")) then
            --heals over time
            if (isCrit) then
                healtext = XM.db["CRITCHAR"]..healtext.."+"..XM.db["CRITCHAR"]
            end

            if (destGuid == XM.player.id) then
                if healamt and XM.db["HEALFILTERINC"] and healamt > XM.db["HEALFILTERINC"] then
                    XM:Display_Event("HEALINC", "+"..healtext, isCrit, nil, sourceName, destName, skill)
                end
            elseif (sourceGuid == XM.player.id) then
                if (healamt > XM.db["HEALFILTEROUT"]) then
                    XM:Display_Event("HEALOUT", "+"..healtext, isCrit, nil, sourceName, destName, skill)
                end
            elseif (XM.player.pet.id and sourceGuid == XM.player.pet.id) or (petkey >= 1 and petTable[petkey].OWNERID == XM.player.id) then
                --outgoing pet heals
                if (petkey >= 1 and petTable[petkey].OWNERID == XM.player.id) then
                    sourceGuid = petTable[petkey].ID
                    source = petTable[petkey].NAME
                end

                if (healamt > XM.db["HEALFILTEROUT"]) then
                    XM:Display_Event("HEALOUT", "+"..healtext, isCrit, nil, source, destName, skill)
                end

            end
        end
    elseif (strfind(event, "_DIED") or strfind(event, "_DESTROYED")) and sourceGuid == XM.player.id then
        XM:Display_Event("KILLBLOW", XM.locale["KILLINGBLOW"], nil, nil, sourceName, destName, nil)
    elseif (strfind(event, "_INTERRUPT")) then
        local text = XM.locale["INTERRUPT"]

        if strfind(event, "SWING") then
            extra = spellName
        elseif strfind(event, "ENVIRONMENTAL") then
            extra = spellSchool
        else
            extra = suffixTwo
        end

        if extra then text = text.." "..extra end

        if destGuid == XM.player.id then
            XM:Display_Event("INTERRUPTINC", text, nil, nil, sourceName, destName, skill)
        elseif sourceGuid == XM.player.id then
            XM:Display_Event("INTERRUPTOUT", text, nil, nil, sourceName, destName, skill)
        end
    -- elseif destGuid == XM.player.id then
    --     -- buffs and debuffs
    --     if strfind(event, "SWING") then
    --         extra, amount = spellId, spellName
    --     elseif strfind(event, "ENVIRONMENTAL") then
    --         extra, amount = spellName, spellSchool
    --     else
    --         extra, amount = suffixOne, suffixTwo
    --     end
    --
    --     if (strfind(event, "AURA_APPLIED_DOSE")) then
    --         if (extra == "BUFF") then
    --             XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFGAIN"]).."]"..amount, nil, nil, sourceName, destName, nil)
    --         else
    --             XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFGAIN"]).."]"..amount, nil, nil, sourceName, destName, nil)
    --         end
    --     elseif (strfind(event, "AURA_REMOVED_DOSE")) then
    --         if (extra == "BUFF") then
    --             XM:Display_Event("BUFFFADE", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFFADE"]).."]"..amount, nil, nil, sourceName, destName, nil)
    --         else
    --             XM:Display_Event("DEBUFFFADE", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFFADE"]).."]"..amount, nil, nil, sourceName, destName, nil)
    --         end
    --     elseif (strfind(event, "AURA_APPLIED")) then
    --         if (extra == "BUFF") then
    --             XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFGAIN"]).."]", nil, nil, sourceName, destName, nil)
    --         else
    --             XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFGAIN"]).."]", nil, nil, sourceName, destName, nil)
    --         end
    --     end
    elseif strfind(event, "AURA_REFRESH") or strfind(event, "AURA_APPLIED") then
        XM:HandleAuraChange(event, skill, true, sourceGuid, sourceName, destGuid, destName, spellId, spellName, spellSchool, suffixOne, suffixTwo)
    elseif strfind(event, "AURA_REMOVED") or (strfind(event, 'AURA_BROKEN') and not strfind(event, 'AURA_BROKEN_SPELL')) then
        XM:HandleAuraChange(event, skill, false, sourceGuid, sourceName, destGuid, destName, spellId, spellName, spellSchool, suffixOne, suffixTwo)
    elseif sourceGuid == XM.player.id then
        displayFrame = 'SPELLOUT'

        if strfind(event, "_CAST_SUCCESS") then
            for _, v in pairs(XM.extraSpells) do
                if skill == v.name then
                    local exists = false
                    if (#XM.extraSpellsCheckTable > 0) then
                        for _, nextSpell in pairs(XM.extraSpellsCheckTable) do
                            if (v.debuffName == nextSpell.debuffName) then
                                exists = true
                            end
                        end
                    end

                    if not exists then
                        tinsert(XM.extraSpellsCheckTable, v)
                    end
                end
            end

            for k, v in pairs(XM.extraSpellsCheckTable) do
                if skill == v.debuffName and v.maxStacks > 1 then
                    local debuffCount = XM:GetDebuffCount(v.debuffName)

                    if debuffCount == v.maxStacks then
                        XM:Display_Event(displayFrame, "["..debuffCount.."]", nil, nil, sourceName, destName, skill)

                        tremove(XM.extraSpellsCheckTable, k)
                    end
                end
            end
        elseif destGuid == UnitGUID("target") and strfind(event, "AURA_APPLIED") then
            if #XM.extraSpellsCheckTable > 0 then
                for k, v in pairs(XM.extraSpellsCheckTable) do
                    if skill == v.debuffName then
                        if v.maxStacks > 1 then
                            XM:Display_Event(displayFrame, "["..XM:GetDebuffCount(v.debuffName).."]", nil, nil, sourceName, destName, skill)
                        else
                            XM:Display_Event(displayFrame, string.format('%s -> %s (%s)', skill, destName, sourceName), nil, nil, nil, nil, nil)
                        end

                        tremove(XM.extraSpellsCheckTable, k)
                    end
                end
            end
        end
    elseif destGuid == UnitGUID("target") and strfind(event, "AURA_APPLIED") then
        if (#XM.extraSpellsCheckTable > 0) then
            for k, v in pairs(XM.extraSpellsCheckTable) do
                if skill == v.debuffName then
                    if v.maxStacks > 1 then
                        XM:Display_Event("SPELLOUT", "["..XM:GetDebuffCount(v.debuffName).."]", nil, nil, sourceName, destName, skill)
                    else
                        XM:Display_Event("SPELLOUT", "", nil, nil, sourceName, destName, skill)
                    end

                    tremove(XM.extraSpellsCheckTable, k)
                end
            end
        end
    end
end

function XM:HandleAuraChange(event, skill, gain, sourceGuid, sourceName, destGuid, destName, spellId, spellName, spellSchool, suffixOne, suffixTwo)
    local auraType, amount, amountDisplay, modifier = suffixOne, suffixTwo, '', '+'

    if strfind(event, "SWING") then
        auraType, amount = spellId, spellName
    elseif strfind(event, "ENVIRONMENTAL") then
        auraType, amount = spellName, spellSchool
    end

    if amount then amountDisplay = ' '..amount end
    if not gain then modifier = '-' end

    -- TODO: set this up in options instead
    -- TODO: this functionality currently only exists for self...
    if sourceGuid == XM.player.id then
        if auraType == "BUFF" then
            displayFrame = 'BUFF'
        else
            displayFrame = 'DEBUFF'
        end

        if gain then
            displayFrame = displayFrame..'GAIN'
        else
            displayFrame = displayFrame..'FADE'
        end

        local msg = modifier..XM:ShortenString(skill, XM.db["SHOWSKILL"][displayFrame])..amountDisplay

        XM:Display_Event(displayFrame, msg, nil, nil, sourceName, destName, nil)
    end
end

function XM:HandleCastStart(skill, incoming, sourceGuid, sourceName, destGuid, destName)
    local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(sourceName)

    if incoming then
        displayFrame = 'SPELLINC'
    else
        displayFrame = 'SPELLOUT'
    end

    if endTime then
        local castTime = (endTime - startTime) / 1000
        if castTime % 1 == 0 then castTime = tostring(castTime)..'.0' end

        XM:Display_Event(displayFrame, 'Casting '..skill.. ' ('..castTime..'s)', nil, nil, sourceName, destName, nil)
    end
end

function XM:HandleDamageEvents(event, skill, incoming, sourceGuid, sourceName, destGuid, destName, spellId, spellName, spellSchool, suffixOne, suffixTwo, suffixThree, suffixsuffixOne, suffixFive, suffixSix, suffixSeven)
    local displayFrame = ''
    local amount, element, amountResist, amountBlock, amountAbsorb, crit, glance, crush

    -- incoming/outgoing damage events
    if strfind(event, "SWING") then
        amount, element, amountResist, amountBlock, amountAbsorb, crit, glance, crush, isOffHand = spellId, XM.elements[(spellSchool)], suffixOne, suffixTwo, suffixThree, suffixsuffixOne, suffixFive, suffixSix, suffixSeven
    elseif strfind(event, "ENVIRONMENTAL") then
        amount, element, amountResist, amountBlock, amountAbsorb, crit, glance, crush, isOffHand = spellName, XM.elements[(suffixOne)], suffixTwo, suffixThree, suffixsuffixOne, suffixFive, suffixSix, suffixSeven, eleven
    else
        amount, element, amountResist, amountBlock, amountAbsorb, crit, glance, crush, isOffHand = suffixOne, XM.elements[(spellSchool)], suffixsuffixOne, suffixFive, suffixSix, suffixSeven, eleven, twelve, thirteen
    end

    local text = XM:TruncateAmount(amount)
    if (crush) then
        text = XM.db["CRUSHCHAR"]..text..XM.db["CRUSHCHAR"]
    elseif (glance) then
        text = XM.db["GLANCECHAR"]..text..XM.db["GLANCECHAR"]
    elseif (crit) then
        text = XM.db["CRITCHAR"]..text..XM.db["CRITCHAR"]
    end
    if (amountAbsorb) and (XM.db["ABSORBINC"]) then
        text = text.." ("..XM.locale["ABSORB"].." "..XM:TruncateAmount(amountAbsorb)..")"
    end
    if (amountBlock) and (XM.db["BLOCKINC"]) then
        text = text.." ("..XM.locale["BLOCK"].." "..XM:TruncateAmount(amountBlock)..")"
    end
    if (amountResist) and (XM.db["RESISTINC"]) then
        text = text.." ("..XM.locale["RESIST"].." "..XM:TruncateAmount(amountResist)..")"
    end

    if incoming then
        if (XM.db["DMGFILTERINC"] > 0 and amount < XM.db["DMGFILTERINC"]) then filter = true end

        text = '-'..text

        displayFrame = 'HITINC'

        if strfind(event, "SPELL_PERIODIC") then
            displayFrame = 'DOTINC'
        elseif strfind(event, 'SPELL') then
            displayFrame = 'SPELLINC'
        end

        if strfind(event, 'SWING') or strfind(event, 'RANGE') then skill = nil end
    else
        if (XM.db["DMGFILTEROUT"] > 0 and amount < XM.db["DMGFILTEROUT"]) then filter = true end

        displayFrame = 'HITOUT'

        if strfind(event, "SPELL_PERIODIC") then
            displayFrame = 'DOTOUT'
        elseif strfind(event, 'SPELL') then
            displayFrame = 'SPELLOUT'
        end

        if strfind(event, 'SWING') then
            skill = 'Melee'
        elseif strfind(event, 'RANGE') then
            skill = 'Ranged'
        end
    end

    if not filter then
        if destGuid == XM.player.id then
            if strfind(event, "ENVIRONMENTAL") then
                local dmgPct = ''

                -- TODO: if show pct for environmental damage...
                if (strupper(skill) == "FALLING") then
                    dmgPct = ' (-'..("%.0f"):format((amount / UnitHealthMax("player"))*100)..'%)'
                    element = nil
                end

                XM:Display_Event(displayFrame, string.format("%s <%s>%s", text, skill, dmgPct), nil, element, sourceName, destName, nil)
            else
                XM:Display_Event(displayFrame, text, crit, element, sourceName, destName, skill)
            end
        elseif sourceGuid == XM.player.id then
            -- print(event..' ('..skill..') '..text)

            -- get skills out of array from class file main.lua
            for k, _ in pairs(XM.mergeCaptures) do
                if skill == k and not XM.mergeCaptures[k].merging then
                    -- print('Merging '..k)
                    XM.mergeCaptures[k] = {total = 0, merging = true}

                    -- callback after merge is complete (duration is 1 frame)
                    C_Timer.After(0, function() -- rife with race conditions
                        text = XM:TruncateAmount(XM.mergeCaptures[k].total)
                        -- print('Merged '..k..': '..text)

                        XM:Display_Event(displayFrame, text, crit, element, sourceName, destName, skill)

                        XM.mergeCaptures[k] = {total = 0, merging = false}
                    end)
                end
            end

            local skillMerging = false
            for k, _ in pairs(XM.mergeCaptures) do
                if XM.mergeCaptures[k].merging then
                    skillMerging = true
                    XM.mergeCaptures[k].total = XM.mergeCaptures[k].total + amount
                end
            end

            if not skillMerging then
                -- print('Displayed '..skill..': '..text)
                XM:Display_Event(displayFrame, text, crit, element, sourceName, destName, skill)
            end
        elseif XM.player.pet.id and destGuid == XM.player.pet.id then
            displayFrame = 'PET'..displayFrame

            if strfind(event, "ENVIRONMENTAL") then
                local dmgPct = ''

                if (strupper(skill) == "FALLING") then
                    dmgPct = ' '..("%.0f"):format((amount / UnitHealthMax("pet"))*100)..'%'
                    element = nil
                end

                XM:Display_Event(displayFrame, string.format("%s <%s> (%s)%s", text, skill, PET, dmgPct), nil, element, sourceName, destName, nil)
            else
                XM:Display_Event(displayFrame, string.format('%s (%s)', text, PET), crit, element, sourceName, destName, skill)
            end
        elseif XM.player.pet.id and sourceNameid == XM.player.pet.id then
            if strfind(event, 'DAMAGE_') then -- damage shield/split damage
                skill = nil
                displayFrame = 'SPELLOUT'
            end

            displayFrame = 'PET'..displayFrame

            XM:Display_Event(displayFrame, string.format('%s (%s)', text, PET), crit, element, sourceName, destName, skill)
        elseif #XM.reflectTable > 0 then
            --reflected events
            if (XM.reflectTable[1].TARGET == sourceGuid and XM.reflectTable[1].SPELL == skill) then
                XM:Display_Event("SPELLOUT", "("..XM.locale["REFLECT"]..") "..text, crit, element, sourceName, destName, skill)

                tremove(XM.reflectTable,1)
            end
        end
    end
end

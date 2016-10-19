local addonName = ...

local XM = LibStub("AceAddon-3.0"):NewAddon("XM", "AceEvent-3.0", "AceConsole-3.0")

XM.addonVersion = GetAddOnMetadata(addonName, "Version")

XM.player = {
    combatActive = false
}
XM.mergeCaptures = {}

--local variables
local PlayerLastHPPercent = 100
local PlayerLastMPPercent = 100
local PlayerLastHPFull = 100
local PlayerLastMPFull = 100
local ExtraAttack = {}	--table for extra attacks
local NextSpellCheck = {}
local ReflectTable = {}

local pettable = {}

-- addon is registered to the client
function XM:OnInitialize()
    XM.locale = LibStub("AceLocale-3.0"):GetLocale("XM")

    -- bark addon name into chat on load
    XM:DefaultChatMessage('%s v%s initialized', XM.locale.addonName, XM.addonVersion)

    XM:SetDefaultModuleState(false)

    local db = LibStub("AceDB-3.0"):New("eXMortalDB")
    XM.db = db.profile

    --initialize DB for new characters
    if not XM.db["VERSION"] then
        print('Performing eXMortal first time setup')

        XM:ResetDefaults()
    end

    -- class id's:
    -- 1-WARRIOR, 2-PALADIN, 3-HUNTER, 4-ROGUE, 5-PRIEST, 6-DEATHKNIGHT
    -- 7-SHAMAN, 8-MAGE, 9-WARLOCK, 10-MONK, 11-DRUID, 12-DEMONHUNTER
    XM.player.classNameLocalized, XM.player.className, XM.player.classID = UnitClass('player')
    XM.player.classColoredString = '|c'..RAID_CLASS_COLORS[XM.player.className].colorStr..XM.player.classNameLocalized..'|r'

    --DEFAULT_CHAT_FRAME:AddMessage(RAID_CLASS_COLORS[XM.player.className].colorStr)

    --register slash command
    XM:RegisterChatCommand("xm", function() XM.configDialog:Open("eXMortal", configFrame) end)

    --load shared media
    XM:RegisterMedia()

    --initialize animation frame
    XM:CreateAnimationFrame()

    --initialize option frame
    XM:InitOptionFrame()

    --register events
    XM:RegisterXMEvents()
end

-- addon is enabled, post-initialization (default path)
function XM:OnEnable()
end

-- addon is disabled (default action on logout, can be called manually)
function XM:OnDisable()
    XM:UnregisterAllEvents()
end

-- first event after initialize
function XM:PLAYER_LOGIN()
    XM.player.name = UnitName("player")
end

function XM:ResetDefaults()
    -- TODO: find a way to play nice with WowAceDB instead
    -- https://www.wowace.com/addons/ace3/pages/api/ace-db-3-0/
    for k, v in pairs(XM.configDefaults) do XM.db[k] = v end
end

-- unit health changes
function XM:UNIT_HEALTH(_, unit)
    if (unit == "player") then --player health change
        --low HP warning
        local warnlevel = XM.db["LOWHPVALUE"]
        if (warnlevel >= 1) then
            local hppercent = (UnitHealth("player") / UnitHealthMax("player")) * 100
            if (hppercent <= warnlevel and PlayerLastHPPercent > warnlevel and (not UnitIsFeignDeath("player"))) then
                PlaySoundFile("Sound\\Spells\\bind2_Impact_Base.wav")
                XM:Display_Event("LOWHP", XM.locale["LOWHP"].." ("..UnitHealth("player")..")", nil, nil, XM.player.name, XM.player.name, nil)
            end
            PlayerLastHPPercent = hppercent
        end
    elseif (unit == "target") then --target health change
        XM:CheckTargetHealth()
    end

end

-- check for target change to reveal need for execute, etc.
function XM:PLAYER_TARGET_CHANGED()
    XM:CheckTargetHealth()

    --extra attack fix
    ExtraAttack = {}

    --spellcasting fix
    NextSpellCheck = {}
end

function XM:CheckTargetHealth()
    local healthPct = (UnitHealth("target") / UnitHealthMax("target"))*100

    if (XM.player.className == "PALADIN") then
        --XM:PaladinCheckTargetHealth(healthPct)
    elseif (XM.player.className == "WARRIOR") then
        --XM:WarriorCheckTargetHealth(healthPct)
    end
end

--unit power changes (mana, rage, energy)
function XM:UnitPower(_, unit)
    --player mana change
    if (unit == "player" and UnitPowerType("player", 0) == 0) then
        local warnlevel = XM.db["LOWMANAVALUE"]
        if (warnlevel >= 1) then
            local mppercent = (UnitPower("player", 0) / UnitPowerMax("player", 0))*100
            if (mppercent < warnlevel and PlayerLastMPPercent >= warnlevel and (not UnitIsFeignDeath("player"))) then
                --PlaySoundFile("Sound\\Spells\\ShaysBell.wav")
                XM:Display_Event("LOWMANA", XM.locale["LOWMANA"].." ("..UnitPower("player", 0)..")", nil, nil, XM.player.name, XM.player.name, nil)
            end
            PlayerLastMPPercent = mppercent
        end
    end
end


--player entering combat
function XM:PLAYER_REGEN_DISABLED()
    XM.player.combatActive = true

    XM:Display_Event("COMBAT", XM.locale["COMBAT"], nil, nil, XM.player.name, XM.player.name, nil)
end


--player leaving combat
function XM:PLAYER_REGEN_ENABLED()
    XM.player.combatActive = false

    XM:Display_Event("COMBAT", XM.locale["NOCOMBAT"], nil, nil, XM.player.name, XM.player.name, nil)

    ReflectTable = {}
end


function XM:PLAYER_COMBO_POINTS()
    local cpCount = GetComboPoints()

    if (cpCount > 0) then
        local text = cpCount

        if (cpCount == 1) then
            text = cpCount.." "..XM.locale["COMBOPOINT"]
        elseif (cpCount == 5) then
            text = XM.locale["COMBOPOINTFULL"]
        else
            text = cpCount.." "..XM.locale["COMBOPOINTS"]
        end

        XM:Display_Event("COMBOPT", text, true, nil, XM.player.name, XM.player.name, nil)
    end

end

function XM:CHAT_MSG_LOOT(_, ...)
    message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter = ...
    --print(message) -- looks like 'You receive item: [itemName]x2.'

    if(target == XM.player.name) then
        -- itemLink style can be found in http://wowprogramming.com/docs/api_types
        local itemLink = message:match(".+(\124c.-\124h\124r)")
        if itemLink then
            local quantity = message:match("\124r.-(%d+)") or 1

            local qualityColor, itemName = itemLink:match("\124c(.-)\124H.-%[(.+)%]")

            --local itemName = itemLink:match("\124h%[(.+)%]\124h")
            local itemNameColored = XM:ColorizeString(itemName, qualityColor)

            -- include the amount in bank here
            local itemCount = GetItemCount(itemLink, true)

            XM:Display_Event("GETLOOT", string.format('+%s %s (%s)', quantity, itemNameColored, itemCount+quantity), nil, nil, XM.player.name, XM.player.name, nil)
        end
    end
end

function XM:CHAT_MSG_MONEY(_, ...)
    message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter = ...

    --print(message) -- like "You loot 1 Gold, 10 Silver, 50 Copper"

    local copperTotal = ''
    for num in message:gmatch("%d+") do
        copperTotal = copperTotal..XM:PadLeft(num, 2)
    end

    -- local gold, silver, copper = message:match(".+(%d+%s.-),%s(%d+%s.-),%s(%d+%s.+)")

    XM:Display_Event("GETLOOT", '+'..GetCoinTextureString(copperTotal), nil, nil, XM.player.name, XM.player.name, nil)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:CHAT_MSG_SKILL(_,arg1)
    --skill gains

    local firstword = strfind(arg1, " ") - 1
    local skillstart = 0
    local skillend = 0
    local skill = "Skill"
    local rankstart = 0
    local rankend = 0
    local rank = 0

    if (firstword == XM.locale["SKILLNONE"]) then
        skillstart = XM.locale["SKILLNONESTART"]
        skillend = strfind(arg1, " ", skillstart) - 1
        skill = string.sub(arg1, skillstart, skillend)
    elseif (firstword == XM.locale["SKILLSOME"]) then
        rankend = strlen(arg1) - 1
        local i = rankend
        while (i > 0) do
            if (strsub(arg1, i, i) == " ") then
                rankstart = i + 1
                i = 0
            else
                i = i - 1
            end
        end
        skillstart = XM.locale["SKILLSOMESTART"]
        skillend = rankstart - XM.locale["SKILLSOMERANK"] - 1
        skill = strsub(arg1, skillstart, skillend)

        rank = strsub(arg1, rankstart, rankend)
    end

    XM:Display_Event("SKILLGAIN", skill..": "..rank, nil, nil, XM.player.name, XM.player.name, nil)

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:CHAT_MSG_COMBAT_FACTION_CHANGE(_,arg1)
--reputation gains

    local repcheck = strfind(arg1, " ")
    if (strsub(arg1, 1, repcheck - 1) == "Reputation") then

        local rankstart = strfind(arg1, "by", -14) + 3
        local rank = strsub(arg1, rankstart, strlen(arg1) - 1)

        local incdecstart = strfind(arg1, " ", ((-1)*strlen(rank)) - 15) + 1

        local incdec = strsub(arg1, incdecstart, incdecstart)
        if (incdec == "d") then
            incdec = "-"
        else
            incdec = "+"
        end

        local factstart = strfind(arg1, "h") + 2
        local factend = incdecstart - 2
        local fact = strsub(arg1, factstart, factend)

        XM:Display_Event("REPGAIN", incdec..rank.." "..fact, nil, nil, XM.player.name, XM.player.name, nil)
    end

end

function XM:TruncateAmount(amount)
    result = tostring(amount)

    if(strlen(result) > 8) then -- 100m
        return strsub(result, 1, 3).."m"
    elseif(strlen(result) > 7) then -- 10.1m
        return strsub(result, 1, 2).."."..strsub(result,3,3).."m"
    elseif(strlen(result) > 6) then -- 1.2m
        return strsub(result, 1, 1).."."..strsub(result, 2, 2).."m"
    elseif(strlen(result) > 5) then -- 100k
        return strsub(result, 1, 3).."k"
    elseif(strlen(result) > 4) then -- 10.1k
        return strsub(result, 1, 2).."."..strsub(result,3,3).."k"
    elseif(strlen(result) > 3) then -- 1.2k
        return strsub(result, 1, 1).."."..strsub(result, 2, 2).."k"
    end

    return result
end


-- http://wow.gamepedia.com/COMBAT_LOG_EVENT
function XM:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
    local timestamp, event, hideCaster, srcGUID, srcName, srcFlags,
        srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, one, two, three,
        four, five, six, seven, eight, nine, ten, eleven, twelve = ...

    local source = srcName
    local victim = dstName
    local sourceid = srcGUID
    local victimid = dstGUID
    if (not source) then source = "" end
    if (not victim) then victim = "" end

    local playerid = UnitGUID("player")
    local playerpetid = UnitGUID("playerpet")

    local i = 1
    local petkey = 0
    local pettablecount = #pettable

    local skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush, missType, power, extra
    local filter = false

    --get player pets (that aren't "playerpet") ... (mostly for totems)
    --?? for better memory usage, should destroy old totems / remove old pets
    if (strfind(event, "_SUMMON")) then
        if (pettablecount < 1) then
            pettable[1] = {ID = victimid, NAME = victim, OWNERID = sourceid, OWNERNAME = source}
        else
            i = 1
            while (i <= pettablecount) do
                if (pettable[i].ID == victimid) then
                    i = pettablecount
                elseif (i == pettablecount) then
                    pettable[(pettablecount + 1)] = {ID = victimid, NAME = victim, OWNERID = sourceid, OWNERNAME = source}
                end
                i = i + 1
            end
        end
    end

    if (sourceid == playerid or sourceid == playerpetid) then
    else
        --check pet table
        i = 1
        while (i <= pettablecount) do
            if (sourceid == pettable[i].ID) then
                petkey = i
                i = pettablecount
            end
            i = i + 1
        end
    end

    --'damage' events
    if strfind(event, "_DAMAGE") then
        if strfind(event, "SWING") then
            skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = "Melee", one, XM.elements[(three)], four, five, six, seven, eight, nine
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = one, two, XM.elements[(four)], five, six, seven, eight, nine, ten
        else
            skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = two, four, XM.elements[(six)], seven, eight, nine, ten, eleven, twelve
        end

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

        if (victimid == playerid) then
            --incoming damage (melee, spell, etc..)
            if (XM.db["DMGFILTERINC"] >= 1 and amount < XM.db["DMGFILTERINC"]) then filter = true end

            if strfind(event, "ENVIRONMENTAL") then
                if (skill == "FALLING") then
                    if (not filter) then XM:Display_Event("HITINC", "-"..text.." <"..skill.."> "..("%.0f"):format((amount / UnitHealthMax("player"))*100).."%", nil, nil, source, victim, nil) end
                else
                    if (not filter) then XM:Display_Event("HITINC", "-"..text.." <"..skill..">", nil, element, source, victim, nil) end
                end
            elseif (strfind(event, "SWING") or strfind(event, "RANGE")) then
                if (element == "physical") then element = nil end
                if (not filter) then XM:Display_Event("HITINC", "-"..text, isCrit, element, source, victim, nil) end
            elseif (strfind(event, "SPELL_PERIODIC")) then
                if (not filter) then XM:Display_Event("DOTINC", "-"..text, isCrit, element, source, victim, skill) end
            else
                if (element == "physical") then element = nil end
                if (not filter) then XM:Display_Event("SPELLINC", "-"..text, isCrit, element, source, victim, skill) end
            end

        elseif (sourceid == playerid) then
            if (element == "physical") then element = nil end
            -- fish skills out of array from class file main.lua
            for k, v in pairs(XM.mergeCaptures) do
                if skill == k and not XM.mergeCaptures[k].merging then
                    -- print('Merging '..k)
                    XM.mergeCaptures[k] = {total = 0, merging = true}

                    -- callback after merge is complete (duration is 1 frame)
                    C_Timer.After(0, function()
                        text = XM:TruncateAmount(XM.mergeCaptures[k].total)
                        -- print('Merged '..k..': '..text)
                        if strfind(event, "SWING") then
                            XM:Display_Event("HITOUT", text, isCrit, element, source, victim, skill)
                        elseif strfind(event, "SPELL") then
                            XM:Display_Event("SPELLOUT", text, isCrit, element, source, victim, skill)
                        end
                        XM.mergeCaptures[k] = {total = 0, merging = false}
                    end)
                end
            end
            --outgoing damage
            if (XM.db["DMGFILTEROUT"] > 0 and amount < XM.db["DMGFILTEROUT"]) then filter = true end

            local d = date('*t')
            --melee attacks
            if (strfind(event, "SWING")) then
                -- print('['..d.hour..':'..d.min..'pm] '..event..' ('..skill..') '..text)

                local skillMerging = false
                for k, v in pairs(XM.mergeCaptures) do
                    if XM.mergeCaptures[k] and XM.mergeCaptures[k].merging then
                        skillMerging = true
                        XM.mergeCaptures[k].total = XM.mergeCaptures[k].total + amount
                    end
                end

                if not skillMerging then
                    if (#ExtraAttack > 0) then
                        --check unnamed damage for extra attacks
                        if not filter then XM:Display_Event("HITOUT", text, isCrit, element, source, victim, ExtraAttack[1]) end
                        skill = ExtraAttack[1]
                        tremove(ExtraAttack, 1)
                    elseif not filter then
                        XM:Display_Event("HITOUT", text, isCrit, element, source, victim, nil)
                    end
                end
            elseif (strfind(event, "RANGE")) then
                -- print(event..' ('..skill..')')
                if (not filter) then XM:Display_Event("HITOUT", text, isCrit, element, source, victim, nil) end
                if (XMSWING) then
                    XMSWING:SwingCheck("Range", 0)
                end
            elseif (strfind(event, "SPELL_PERIODIC")) then
                -- print(event..' ('..skill..')')
                if (not filter) then XM:Display_Event("DOTOUT", text, isCrit, element, source, victim, skill) end
            else
                -- print('['..d.hour..':'..d.min..'pm] '..event..' ('..skill..') '..text)

                if (#ExtraAttack > 0 and skill == ExtraAttack[1]) then
                    tremove(ExtraAttack, 1)
                end

                local skillMerging = false
                for k, v in pairs(XM.mergeCaptures) do
                    if XM.mergeCaptures[k] and XM.mergeCaptures[k].merging then
                        skillMerging = true
                        XM.mergeCaptures[k].total = XM.mergeCaptures[k].total + amount
                    end
                end

                if not filter and not skillMerging then
                    XM:Display_Event("SPELLOUT", text, isCrit, element, source, victim, skill)
                end
            end

        --incoming pet damage (melee, spell, etc..)
        elseif (playerpetid and victimid == playerpetid) then

            --damage filter
            if (XM.db["DMGFILTERINC"] >= 1 and amount < XM.db["DMGFILTERINC"]) then filter = true end

            --environmental damage
            if strfind(event, "ENVIRONMENTAL") then
                if (skill == "FALLING") then
                    if (not filter) then XM:Display_Event("PETHITINC", "-"..text.." <"..skill.."> ".."("..PET..")"..("%.0f"):format((amount / UnitHealthMax("player"))*100).."%", nil, nil, source, victim, nil) end
                else
                    if (not filter) then XM:Display_Event("PETHITINC", "-"..text.." <"..skill..">".."("..PET..")", nil, element, source, victim, nil) end
                end
            --melee or range attacks
            elseif (strfind(event, "SWING") or strfind(event, "RANGE")) then
                if (element == "physical") then element = nil end
                if (not filter) then XM:Display_Event("PETHITINC", "-"..text.."("..PET..")", isCrit, element, source, victim, nil) end
            --spell damage
            elseif (strfind(event, "SPELL_PERIODIC")) then
                if (not filter) then XM:Display_Event("PETDOTINC", "-"..text.."("..PET..")", isCrit, element, source, victim, skill) end
            else
                if (element == "physical") then element = nil end
                if (not filter) then XM:Display_Event("PETSPELLINC", "-"..text.."("..PET..")", isCrit, element, source, victim, skill) end
            end

        --outgoing pet damage
        elseif (playerpetid and sourceid == playerpetid) or (petkey >= 1) then
            local ownerid = playerid
            local ownername = XM.player.name

            if (petkey >= 1) then
                sourceid = pettable[petkey].ID
                source = pettable[petkey].NAME
                ownerid = pettable[petkey].OWNERID
                ownername = pettable[petkey].OWNERNAME
            end

            --damage filter
            if (XM.db["DMGFILTEROUT"] >= 1 and amount < XM.db["DMGFILTEROUT"]) then filter = true end

            --melee damage
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                if (element == "physical") then element = nil end
                if (not filter) and (ownerid == playerid) then XM:Display_Event("PETHITOUT", text.."("..PET..")", isCrit, element, source, victim, nil) end
            elseif (strfind(event, "DAMAGE_")) then
                if (not filter) and (ownerid == playerid) then XM:Display_Event("PETSPELLOUT", text.."("..PET..")", isCrit, element, source, victim, nil) end
            elseif (strfind(event, "SPELL_PERIODIC")) then
                if (not filter) and (ownerid == playerid) then XM:Display_Event("PETDOTOUT", text.."("..PET..")", isCrit, element, source, victim, skill) end
            else
                if (element == "physical") then element = nil end
                if (not filter) and (ownerid == playerid) then XM:Display_Event("PETSPELLOUT", text.."("..PET..")", isCrit, element, source, victim, skill) end
            end

        --reflected events
        elseif (#ReflectTable >= 1) then
            --damage filter
            if (XM.db["DMGFILTEROUT"] > 0 and amount < XM.db["DMGFILTEROUT"]) then filter = true end

            if (ReflectTable[1].TARGET == sourceid and ReflectTable[1].SPELL == skill) then
                if (element == "physical") then element = nil end
                if (not filter) then XM:Display_Event("SPELLOUT", "("..XM.locale["REFLECT"]..") "..text, isCrit, element, source, victim, skill) end
                tremove(ReflectTable,1)
            end
        end

    --damage shields or split damage
    elseif (strfind(event, "DAMAGE_")) then
        skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = two, four, XM.elements[(six)], seven, eight, nine, ten, eleven, twelve

        if (not strfind(event, "MISSED")) then
            if (not amount) then amount = 0 end
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

            if (victimid == UnitGUID("player")) and (XM.db["DMGFILTERINC"] < 1 or amount > XM.db["DMGFILTERINC"]) then
                XM:Display_Event("DMGSHIELDINC", "-"..text, isCrit, element, source, victim, skill)
            elseif (sourceid == UnitGUID("player")) and (XM.db["DMGFILTEROUT"] < 1 or amount > XM.db["DMGFILTEROUT"]) then
                XM:Display_Event("DMGSHIELDOUT", text, isCrit, element, source, victim, skill)
            end
        end

    --'heal' events
    elseif strfind(event, "_HEAL") then
        if strfind(event, "SWING") then
            skill, amount, isCrit, extra = "Melee", one, four, two
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, amount, isCrit, extra = one, two, five, three
        else
            skill, amount, isCrit, extra = two, four, seven, five
        end

        local healtext = XM:TruncateAmount(amount)
        local healamt = amount
        if (extra) then
            if (extra > 0) then
                healamt = amount - extra
                healtext = XM:TruncateAmount(healamt).." {"..XM:TruncateAmount(extra).."}"
            end
        end

        --heals over time
        if (XM.db["SHOWHOTS"] or not strfind(event, "SPELL_PERIODIC")) then
            if (isCrit) then
                healtext = XM.db["CRITCHAR"]..healtext.."+"..XM.db["CRITCHAR"]
            end
            --self heals
            if (sourceid == UnitGUID("player") and victimid == UnitGUID("player")) then
                --heal filter (after overhealing)
                if (healamt > XM.db["HEALFILTERINC"] and healamt > XM.db["HEALFILTEROUT"]) then
                    XM:Display_Event("HEALINC", "+"..healtext, isCrit, nil, source, victim, skill)
                end
            --incoming heals
            elseif (victimid == UnitGUID("player")) then
                --heal filter (after overhealing)
                if (healamt > XM.db["HEALFILTERINC"]) then
                    XM:Display_Event("HEALINC", "+"..healtext, isCrit, nil, source, victim, skill)
                end
            --outgoing heals
            elseif (sourceid == UnitGUID("player")) then
                --heal filter (after overhealing)
                if (healamt > XM.db["HEALFILTEROUT"]) then
                    XM:Display_Event("HEALOUT", "+"..healtext, isCrit, nil, source, victim, skill)
                end

            --outgoing pet heals
            elseif (playerpetid and sourceid == playerpetid) or (petkey >= 1 and pettable[petkey].OWNERID == UnitGUID("player")) then
                if (petkey >= 1 and pettable[petkey].OWNERID == UnitGUID("player")) then
                    sourceid = pettable[petkey].ID
                    source = pettable[petkey].NAME
                end
                --heal filter (after overhealing)
                if (healamt > XM.db["HEALFILTEROUT"]) then
                    XM:Display_Event("HEALOUT", "+"..healtext, isCrit, nil, source, victim, skill)
                end

            end
        end

    --'miss' events [miss, dodge, block, deflect, immune, evade, parry, resist, absorb, reflect]
    elseif (strfind(event, "_MISSED")) then
        if strfind(event, "SWING") then
            skill, missType = "Melee", one
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, missType = one, two
        else
            skill, missType = two, four
        end

        if (victimid == UnitGUID("player")) then
            -- incoming miss events
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event(missType.."INC", missType, nil, nil, source, victim, nil)
            else
                if (missType == "REFLECT") then
                    tinsert(ReflectTable, {TARGET = sourceid, SPELL = skill})
                end
                XM:Display_Event(missType.."INC", missType, nil, nil, source, victim, skill)
            end
            --pass events to swing timer
            if (XMSWING and missType == "PARRY") then
                XMSWING:ParryCheck()
            end
            if (XM.player.className == "WARRIOR") then
                XM:MISSINC_WARRIOR(event, source, victim, skill, missType)
            elseif (XM.player.className == "DEATHKNIGHT") then
                XM:MISSINC_DEATHKNIGHT(event, source, victim, skill, missType)
            end

        elseif (sourceid == UnitGUID("player")) then
            -- outgoing miss events
            if (strfind(event, "SWING")) then
                --check unnamed damage for extra attacks
                if (#ExtraAttack > 0) then
                    XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, ExtraAttack[1])
                    tremove(ExtraAttack, 1)
                else
                    if (XMSWING) and (XMSWING.HAND[2].STARTSPEED > 0) and (XMSWING.HAND[1].TIMELEFT <= XMSWING.HAND[2].TIMELEFT) then
                        XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, XM.db["MHCHAR"])
                    elseif (XMSWING) and (XMSWING.HAND[2].STARTSPEED > 0) then
                        XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, XM.db["OHCHAR"])
                    else
                        XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, nil)
                    end
                end
            elseif (strfind(event, "RANGE")) then
                XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, nil)
            else
                if (#NextSpellCheck > 0) then
                    for key, value in pairs(NextSpellCheck) do
                        if (value == skill) then
                            tremove(NextSpellCheck,key)
                        end
                    end
                end
                XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, skill)
            end
            if (XM.player.className == "WARRIOR") then
                XM:MISSOUT_WARRIOR(event, source, victim, skill, missType)
            elseif (XM.player.className == "DEATHKNIGHT") then
                XM:MISSOUT_DEATHKNIGHT(event, source, victim, skill, missType)
            end

        elseif (playerpetid and victimid == playerpetid) then
            -- incoming pet miss events
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event("PET"..missType.."INC", missType.."("..PET..")", nil, nil, source, victim, nil)
            else
                XM:Display_Event("PET"..missType.."INC", missType.."("..PET..")", nil, nil, source, victim, skill)
            end

        elseif (playerpetid and sourceid == playerpetid) then
            -- outgoing pet miss events
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event("PETMISSOUT", PET.." "..missType, nil, nil, source, victim, nil)
            else
                XM:Display_Event("PETMISSOUT", PET.." "..missType, nil, nil, source, victim, skill)
            end

        elseif (#ReflectTable >= 1) then
            -- reflected events
            if (ReflectTable[1].TARGET == sourceid and ReflectTable[1].SPELL == skill) then
                XM:Display_Event(missType.."OUT", "("..XM.locale["REFLECT"]..") "..missType, nil, nil, source, victim, skill)
                tremove(ReflectTable,1)
            end
        end


    elseif (strfind(event, "_DIED") or strfind(event, "_DESTROYED")) and (sourceid == playerid) then
        --your killing blows
        XM:Display_Event("KILLBLOW", XM.locale["KILLINGBLOW"], nil, nil, source, victim, nil)

    -- elseif (strfind(event, "_ENERGIZE")) then
        -- -- power gain events
        -- if strfind(event, "SWING") then
        --     skill, amount, power = "Melee", one, XM.powerNames[(two)]
        -- elseif strfind(event, "ENVIRONMENTAL") then
        --     skill, amount, power = one, two, XM.powerNames[(three)]
        -- else
        --     skill, amount, power = two, four, XM.powerNames[(five)]
        -- end
        --
        -- --incoming gains
        -- if (victimid == UnitGUID("player")) then
        --     --mana filter
        --     if (amount > XM.db["MANAFILTERINC"]) then
        --         --XM:Display_Event("POWERGAIN", "+"..amount.." "..power, nil, nil, source, victim, skill)
        --     end
        -- end

    -- elseif (strfind(event, "_DRAIN") or strfind(event, "_LEECH")) then
        -- power loss events
        -- if strfind(event, "SWING") then
        --     skill, amount, power, extra = "Melee", one, XM.powerNames[(two)], three
        -- elseif strfind(event, "ENVIRONMENTAL") then
        --     skill, amount, power, extra = one, two, XM.powerNames[(three)], four
        -- else
        --     skill, amount, power, extra = two, four, XM.powerNames[(five)], six
        -- end
        --
        -- --incoming drains
        -- if (victimid == UnitGUID("player")) then
        --     if (extra) then
        --         if (extra > 0) then
        --             XM:Display_Event("POWERGAIN", "-"..amount.." - "..extra.." "..power, nil, nil, source, victim, skill)
        --         else
        --             XM:Display_Event("POWERGAIN", "-"..amount.." "..power, nil, nil, source, victim, skill)
        --         end
        --     else
        --         XM:Display_Event("POWERGAIN", "-"..amount.." "..power, nil, nil, source, victim, skill)
        --     end
        -- end

    elseif (strfind(event, "_EXTRA_ATTACKS") and victimid == UnitGUID("player")) then
        if strfind(event, "SWING") then
            skill, amount = "Melee", one
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, amount = one, two
        else
            skill, amount = two, four
        end

        if (amount > 1) then
            XM:Display_Event("EXECUTE", amount, nil, nil, victim, victim, skill)
        else
            XM:Display_Event("EXECUTE", "", nil, nil, victim, victim, skill)
        end
        local i = 1
        while (i <= amount) do
            tinsert(ExtraAttack, skill)
            i = i + 1
        end
        --but can't show sword spec perfectly because it shows in combat log as 2 different forms

    elseif (strfind(event, "_INTERRUPT")) then

        if strfind(event, "SWING") then
            skill, extra = "Melee", two
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, extra = one, three
        else
            skill, extra = two, five
        end

        if (extra) then
            extra = XM.locale["INTERRUPT"].." "..extra
        else
            extra = XM.locale["INTERRUPT"]
        end

        --incoming interrupts
        if (victimid == UnitGUID("player")) then
            XM:Display_Event("INTERRUPTINC", extra, nil, nil, source, victim, skill)
        --outgoing interrupts
        elseif (sourceid == UnitGUID("player")) then
            XM:Display_Event("INTERRUPTOUT", extra, nil, nil, source, victim, skill)
        end

    elseif (victimid == UnitGUID("player")) then
        -- buffs and debuffs
        if strfind(event, "SWING") then
            skill, extra, amount = "Melee", two, three
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, extra, amount = one, two, three
        else
            skill, extra, amount = two, four, five
        end

        if (strfind(event, "AURA_APPLIED_DOSE")) then
            if (extra == "BUFF") then
                XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFGAIN"]).."]"..amount, nil, nil, source, victim, nil)
            else
                XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFGAIN"]).."]"..amount, nil, nil, source, victim, nil)
            end
            if (XMSWING) then XMSWING:SpeedCheck(false, 0) end

        elseif (strfind(event, "AURA_REMOVED_DOSE")) then
            if (extra == "BUFF") then
                XM:Display_Event("BUFFFADE", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFFADE"]).."]"..amount, nil, nil, source, victim, nil)
            else
                XM:Display_Event("DEBUFFFADE", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFFADE"]).."]"..amount, nil, nil, source, victim, nil)
            end
            if (XMSWING) then XMSWING:SpeedCheck(false, 0) end

        elseif (strfind(event, "AURA_APPLIED")) then
            if (extra == "BUFF") then
                XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFGAIN"]).."]", nil, nil, source, victim, nil)
            else
                XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFGAIN"]).."]", nil, nil, source, victim, nil)
            end
        end

    elseif (strfind(event, "AURA_REFRESH")) then
            if (strfind(event, "SWING")) then
                skill, extra = "Melee", two
            elseif (strfind(event, "ENVIRONMENTAL")) then
                skill, extra = one, two
            else
                skill, extra = two, four
            end

            if (extra == "BUFF") then
                XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFGAIN"]).."]", nil, nil, source, victim, nil)
            else
                XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFGAIN"]).."]", nil, nil, source, victim, nil)
            end

            if (XMSWING) then XMSWING:SpeedCheck(false, 0) end

    elseif (strfind(event, "AURA_REMOVED")) then
        if strfind(event, "SWING") then
            skill, extra = "Melee", two
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, extra = one, two
        else
            skill, extra = two, four
        end

        if (extra == "BUFF") then
            XM:Display_Event("BUFFFADE", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFFADE"]).."]", nil, nil, source, victim, nil)
        else
            XM:Display_Event("DEBUFFFADE", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFFADE"]).."]", nil, nil, source, victim, nil)
        end

    elseif (sourceid == UnitGUID("player")) then
        -- 'other' spellcasting
        if (strfind(event, "_CAST_SUCCESS")) then
            if strfind(event, "SWING") then
                skill = "Melee"
            elseif strfind(event, "ENVIRONMENTAL") then
                skill = one
            else
                skill = two
            end

            for key, value in pairs(XM.SPELLTABLE) do
                if (skill == value.SPELL) then
                    local foundspell = false
                    if (#NextSpellCheck > 0) then
                        for key2, value2 in pairs(NextSpellCheck) do
                            if (value.DEBUFF == value2.DEBUFF) then
                                foundspell = true
                            end
                        end
                    end
                    if (foundspell == false) then
                        tinsert(NextSpellCheck, value)
                    end
                end
            end

            for key,value in pairs(NextSpellCheck) do
                if (skill == value.DEBUFF and value.COUNT > 1 and XM:GetDebuffCount(value.DEBUFF) == value.COUNT) then
                    XM:Display_Event("SPELLOUT", "["..XM:GetDebuffCount(value.DEBUFF).."]", nil, nil, source, victim, skill)
                    tremove(NextSpellCheck,key)
                end
            end

            -- --create special skill table arrays here ...
            -- if (skill == "Shield Block" or skill == "Holy Shield") then
            --     XM:Display_Event("BLOCKINC", "+", nil, nil, source, victim, skill)
            --     XMSHIELD:ShieldStart()
            -- elseif (skill == "Bloodrage") then
            --     XM:Display_Event("SPELLINC", "-711 ", nil, nil, XM.player.name, XM.player.name, skill)
            -- end

        elseif (victimid == UnitGUID("target") and strfind(event, "AURA_APPLIED")) then
            if strfind(event, "SWING") then
                skill = "Melee"
            elseif strfind(event, "ENVIRONMENTAL") then
                skill = one
            else
                skill = two
            end

            if (#NextSpellCheck > 0) then
                for key, value in pairs(NextSpellCheck) do
                    if (skill == value.DEBUFF) then
                        if (value.COUNT > 1) then
                            XM:Display_Event("SPELLOUT", "["..XM:GetDebuffCount(value.DEBUFF).."]", nil, nil, source, victim, skill)
                        else
                            XM:Display_Event("SPELLOUT", "", nil, nil, source, victim, skill)
                        end
                        tremove(NextSpellCheck,key)
                    end
                end
            end

        --spells that don't fire the cast_success event
        elseif (strfind(event, "_CAST_START")) then
            if strfind(event, "SWING") then
                skill = "Melee"
            elseif strfind(event, "ENVIRONMENTAL") then
                skill = one
            else
                skill = two
            end
        end

    elseif (victimid == UnitGUID("target") and strfind(event, "AURA_APPLIED")) then
        if strfind(event, "SWING") then
            skill = "Melee"
        elseif strfind(event, "ENVIRONMENTAL") then
            skill = one
        else
            skill = two
        end
        if (#NextSpellCheck > 0) then
            for key, value in pairs(NextSpellCheck) do
                if (skill == value.DEBUFF) then
                    if (value.COUNT > 1) then
                        XM:Display_Event("SPELLOUT", "["..XM:GetDebuffCount(value.DEBUFF).."]", nil, nil, source, victim, skill)
                    else
                        XM:Display_Event("SPELLOUT", "", nil, nil, source, victim, skill)
                    end
                    tremove(NextSpellCheck,key)
                end
            end
        end
    end
end


function XM:GetDebuffLeft(inpskill)
    local i = 1
    local debuffName,debuffLeft
    --gather all target debuffs
    while (i <= 40) do
        debuffName,_,_,_,_,_,debuffLeft = UnitDebuff("target", i)
        if (debuffName) and (debuffName == inpskill) then
            i = 41
        elseif (debuffName) then
            i = i + 1
        else
            i = 41
        end
    end
    if (not debuffLeft) then debuffLeft = 0 end
    return debuffLeft
end


function XM:GetDebuffCount(inpskill)
    local i = 1
    local debuffName,debuffCount
    local maxDebuffsAllowed = 40
    -- TODO: don't use magic number here... get debuff count from API
    -- NOTE: if performance is a concern (it's not) then use a constant
    while (i <= maxDebuffsAllowed) do
        debuffName,_,_,debuffCount,_,_ = UnitDebuff("target", i)
        if (debuffName) and (debuffName == inpskill) then
            i = 41
        elseif (debuffName) then
            i = i + 1
        else
            i = 41
        end
    end
    if (not debuffCount) then debuffCount = 0 end
    return debuffCount
end


function XM:BlizzardCombatTextEvent(_,arg1, arg2, arg3)
    --handle blizzard special combat events

    --active skills (execute, overpower, revenge, victory rush)
    if (arg1 == "SPELL_ACTIVE") then
        --don't show blizzard execute or overpower
        if (arg2 == "Execute" or arg2 == "Overpower") then
        --revenge doesn't trigger by blizzard event
        --victory rush should be the only active spell remaining
        else
            XM:Display_Event("EXECUTE", arg2, true, nil, XM.player.name, XM.player.name, nil)
        end
    end
end


function XM:Display_Event(event, msg, crit, element, source, victim, skill)
    --display event to show messages

    --if event is enabled
    if (XM.db[event] and XM.db[event] > 0) then
        --get frame number
        local dispframe = XM.db[event]
        --get color
        local rgbcolor = {r = 1.0, g = 1.0, b = 1.0}
        if (XM.db["COLOR_TABLE"][event]) then
            rgbcolor = XM.db["COLOR_TABLE"][event]
        end

        --shorten skill name (-1 = no show, 0 = full name, 1 = truncate, 2 = abbreviate)
        if (skill) and (skill ~= "") then
            --check false first, then check number
            if (not XM.db["SHOWSKILL"][event]) then
            elseif (XM.db["SHOWSKILL"][event] > 0) then
                msg = msg.." ("..XM:ShortenString(skill, XM.db["SHOWSKILL"][event])..")"
            elseif (XM.db["SHOWSKILL"][event] == 0) then
                msg = msg.." ("..skill..")"
            end
        end

        --if elemental type (false = no color, 0 = full name, 1 = brackets, 2 = color only)
        if (element) then
            if (not XM.db["SHOWSKILL"]["ELEMENT"] or XM.db["SHOWSKILL"]["ELEMENT"] < 0) then
            else
                if (XM.db["COLOR_SPELL"][(strupper(element))]) then
                    rgbcolor = XM.db["COLOR_SPELL"][(strupper(element))]
                end
                if (XM.db["SHOWSKILL"]["ELEMENT"] == 0) then
                    msg = msg.." <"..element..">"
                elseif (XM.db["SHOWSKILL"]["ELEMENT"] == 1) then
                    msg = " <"..msg..">"
                end
            end
        end

        --shorten target name (-1 = no show, 0 = full name, 1 = truncate, 2 = abbreviate)
        local targetinterest
        if (strfind(event, "OUT")) then
            targetinterest = victim
        else
            targetinterest = source
        end

        if (targetinterest) and (targetinterest ~= "") and (targetinterest ~= XM.player.name) then
            --check false first, then check number
            if (not XM.db["SHOWTARGET"][event]) then
            elseif (XM.db["SHOWTARGET"][event] > 0) then
                msg = msg.." ("..XM:ShortenString(targetinterest, XM.db["SHOWTARGET"][event])..")"
            elseif (XM.db["SHOWTARGET"][event] == 0) then
                msg = msg.." ("..targetinterest..")"
            end
        end

        XM:DisplayText(dispframe, msg, rgbcolor, crit, victim, icon)
    end
end


function XM:ShortenString(strString, shorttype)
    local cTRUNCATE, cABBREVIATE = 1, 2

    if (strlen(strString) > XM.db["SHORTLENGTH"] and shorttype) then
        if (shorttype == cTRUNCATE) then
            return strsub(strString, 1, XM.db["SHORTLENGTH"])..XM.db["SHORTSTRING"]
        elseif (shorttype == cABBREVIATE) then
            return gsub(gsub(gsub(strString," of ","O"),"%s",""), "(%u)%l*", "%1")
        end
    end

    return strString
end


function XM:RegisterXMEvents()
    XM:RegisterEvent("UNIT_HEALTH")
    XM:RegisterEvent("UNIT_MANA", "UnitPower")
    XM:RegisterEvent("UNIT_ENERGY", "UnitPower")
    XM:RegisterEvent("UNIT_RAGE", "UnitPower")
    XM:RegisterEvent("PLAYER_REGEN_ENABLED")
    XM:RegisterEvent("PLAYER_REGEN_DISABLED")
    XM:RegisterEvent("COMBAT_TEXT_UPDATE", "BlizzardCombatTextEvent")
    XM:RegisterEvent("CHAT_MSG_LOOT")
    XM:RegisterEvent("CHAT_MSG_MONEY")

    --combo point gain
    if (XM.db["COMBOPT"] and XM.db["COMBOPT"] > 0) then
        XM:RegisterEvent("PLAYER_COMBO_POINTS")
    end

    XM:RegisterEvent("PLAYER_LOGIN")
    XM:RegisterEvent("CHAT_MSG_SKILL")
    XM:RegisterEvent("PLAYER_TARGET_CHANGED")
    XM:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    XM:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
end

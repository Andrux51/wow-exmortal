--MUST HAVE "xm_init.lua" LOADED FIRST

--embedded libs
local XM_Locale = LibStub("AceLocale-3.0"):GetLocale("XM")
local XM_Config = LibStub("AceConfigDialog-3.0")
--global XM_DB = LibStub("AceDB-3.0") ... reserved in xm_init.lua

--local variables
local PlayerLastHPPercent = 100
local PlayerLastMPPercent = 100
local PlayerLastHPFull = 100
local PlayerLastMPFull = 100
local ExtraAttack = {}	--table for extra attacks
local NextSpellCheck = {}
local ReflectTable = {}
local xm_init = false

local pettable = {}

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:OnInitialize()
--called when addon loads

    xm_PlayerName = UnitName("player")

    --announce addon
    DEFAULT_CHAT_FRAME:AddMessage(XM_Locale["IDSTRING"]..XM_Locale["STARTUP"])

    --connect saved variables
    XM_DB = LibStub("AceDB-3.0"):New("XM_CONFIG")
    XM_DB = XM_DB.profile

    --initialize DB for new users
    if (XM_DB["VERSION"] ~= XM.VERSION) then
        --reset saved variables
        XM_CONFIG = {}
        --connect saved variables
        XM_DB = LibStub("AceDB-3.0"):New("XM_CONFIG")
        XM_DB = XM_DB.profile

        DEFAULT_CHAT_FRAME:AddMessage(XM_Locale["IDSTRING"]..XM_Locale["INITIALIZE"]..xm_PlayerName.." - "..GetRealmName():trim())

        --write default values to the current profile (it doesn't seem to sort them)
        local key, value
        for key, value in pairs(XM.DEFAULTS) do
            XM_DB[key] = value
        end
    end

    --load shared media
    XM:RegisterMedia()

    --initialize animation frame
    XM:CreateAnimationFrame()

    --initialize option frame
    XM:InitOptionFrame()

    --register slash command
    XM:RegisterChatCommand("xm", function() XM_Config:Open("eXMortal", configFrame) end)
    XM:RegisterChatCommand("rl", function() ReloadUI() end)

    --register events
    XM:RegisterXMEvents()
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:OnEnable()
    --called when addon is enabled (called after OnInitialize)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:OnDisable()
    --called when addon is disabled (standby/logout)
    XM:UnregisterAllEvents()
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:PLAYER_LOGIN()
--set class vars on login (called after OnEnable)

    xm_PlayerClassText,xm_PlayerClassName,xm_PlayerClassId = UnitClass("player")

    -- class id's:
    -- 1-WARRIOR, 2-PALADIN, 3-HUNTER, 4-ROGUE, 5-PRIEST, 6-DEATHKNIGHT
    -- 7-SHAMAN, 8-MAGE, 9-WARLOCK, 10-MONK, 11-DRUID, 12-DEMONHUNTER

    -- check for files having been loaded
    if(xm_class_shaman_loaded and xm_PlayerClassId == 7) then
        XM:LOGIN_SHAMAN()
    end

    --class-specific login scripts
--    if (xm_PlayerClassName == "DEATHKNIGHT") then
--        XM:LOGIN_DEATHKNIGHT()
--    elseif (xm_PlayerClassName == "DRUID") then
--    elseif (xm_PlayerClassName == "HUNTER") then
--    elseif (xm_PlayerClassName == "MAGE") then
--    elseif (xm_PlayerClassName == "PALADIN") then
--        XM:LOGIN_PALADIN()
--    elseif (xm_PlayerClassName == "PRIEST") then
--    elseif (xm_PlayerClassName == "ROGUE") then
--        XM:LOGIN_ROGUE()
--    elseif (xm_PlayerClassName == "SHAMAN") then
--        XM:LOGIN_SHAMAN()
--    elseif (xm_PlayerClassName == "WARLOCK") then
--    elseif (xm_PlayerClassName == "WARRIOR") then
--        XM:LOGIN_WARRIOR()
--    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:UNIT_HEALTH(_,arg1)
--unit health changes

    --player health change
    if (arg1 == "player") then
        --low HP warning
        local warnlevel = XM_DB["LOWHPVALUE"]
        if (warnlevel >= 1) then
            local hppercent = (UnitHealth("player") / UnitHealthMax("player")) * 100
            if (hppercent <= warnlevel and PlayerLastHPPercent > warnlevel and (not UnitIsFeignDeath("player"))) then
                PlaySoundFile("Sound\\Spells\\bind2_Impact_Base.wav")
                XM:Display_Event("LOWHP", XM_Locale["LOWHP"].." ("..UnitHealth("player")..")", nil, nil, xm_PlayerName, xm_PlayerName, nil)
            end
            PlayerLastHPPercent = hppercent
        end

    --target health change
    elseif (arg1 == "target") then
        local hppercent = (UnitHealth("target") / UnitHealthMax("target"))*100
--        if (xm_PlayerClassName  == "PALADIN") then
--            XM:UNITHEALTH_PALADIN(arg1, hppercent)
--        elseif (xm_PlayerClassName  == "WARRIOR") then
--            XM:UNITHEALTH_WARRIOR(arg1, hppercent)
--        end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:PLAYER_TARGET_CHANGED()
--target change

    local hppercent = (UnitHealth("target") / UnitHealthMax("target"))*100
--    if (xm_PlayerClassName == "PALADIN") then
--        XM:TARGETCHANGE_PALADIN(arg1, hppercent)
--    elseif (xm_PlayerClassName == "WARRIOR") then
--        XM:TARGETCHANGE_WARRIOR(arg1, hppercent)
--    end

    --extra attack fix
    ExtraAttack = {}

    --spellcasting fix
    NextSpellCheck = {}

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:UnitPower(_,arg1)
--unit power changes (mana, rage, energy)

    --player mana change
    if (arg1 == "player" and UnitPowerType("player",0) == 0) then
        local warnlevel = XM_DB["LOWMANAVALUE"]
        if (warnlevel >= 1) then
            local mppercent = (UnitPower("player",0) / UnitPowerMax("player",0))*100
            if (mppercent < warnlevel and PlayerLastMPPercent >= warnlevel and (not UnitIsFeignDeath("player"))) then
                --PlaySoundFile("Sound\\Spells\\ShaysBell.wav")
                XM:Display_Event("LOWMANA", XM_Locale["LOWMANA"].." ("..UnitPower("player",0)..")", nil, nil, xm_PlayerName, xm_PlayerName, nil)
            end
            PlayerLastMPPercent = mppercent
        end
    end

    --show all power gains
    if (arg1 == "player" and XM_DB["SHOWALLPOWER"]) then
        local mpfull = UnitPower("player",0)
        if (mpfull > PlayerLastMPFull) then
            XM:Display_Event("POWERGAIN", "+"..(mpfull - PlayerLastMPFull).." "..xm_PowerTable[(UnitPowerType("player",0))], nil, nil, xm_PlayerName, xm_PlayerName, nil)
        end
        PlayerLastMPFull = mpfull
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:UNIT_DISPLAYPOWER()
--power type change

    PlayerLastMPFull = UnitPower("player",0)

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:PLAYER_REGEN_DISABLED()
--player entering combat

    xm_InCombat = true
    XM:Display_Event("COMBAT", XM_Locale["COMBAT"], nil, nil, xm_PlayerName, xm_PlayerName, nil)

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:PLAYER_REGEN_ENABLED()
--player leaving combat

    xm_InCombat = false
    XM:Display_Event("COMBAT", XM_Locale["NOCOMBAT"], nil, nil, xm_PlayerName, xm_PlayerName, nil)

    ReflectTable = {}

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:PLAYER_COMBO_POINTS()
--player combo point changes

    local cpnum = GetComboPoints()
    if (cpnum > 0) then
        local cptext = cpnum
        if (cpnum == 1) then
            cptext = cpnum.." "..XM_Locale["COMBOPOINT"]
        elseif (cpnum == 5) then
            cptext = XM_Locale["COMBOPOINTFULL"]
        else
            cptext = cpnum.." "..XM_Locale["COMBOPOINTS"]
        end
        XM:Display_Event("COMBOPT", cptext, true, nil, xm_PlayerName, xm_PlayerName, nil)
    end

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

    if (firstword == XM_Locale["SKILLNONE"]) then
        skillstart = XM_Locale["SKILLNONESTART"]
        skillend = strfind(arg1, " ", skillstart) - 1
        skill = string.sub(arg1, skillstart, skillend)
    elseif (firstword == XM_Locale["SKILLSOME"]) then
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
        skillstart = XM_Locale["SKILLSOMESTART"]
        skillend = rankstart - XM_Locale["SKILLSOMERANK"] - 1
        skill = strsub(arg1, skillstart, skillend)

        rank = strsub(arg1, rankstart, rankend)
    end

    XM:Display_Event("SKILLGAIN", skill..": "..rank, nil, nil, xm_PlayerName, xm_PlayerName, nil)

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

        XM:Display_Event("REPGAIN", incdec..rank.." "..fact, nil, nil, xm_PlayerName, xm_PlayerName, nil)
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

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:COMBAT_LOG_EVENT_UNFILTERED(_, timestamp, event, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve)
--displays parsed info based on combat log events

--    DEFAULT_CHAT_FRAME:AddMessage(event,hideCaster,srcGUID,srcName,srcFlags,dstGUID,dstName,dstFlags,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve)
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
            skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = "Melee", one, xm_ElementTable[(three)], four, five, six, seven, eight, nine
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = one, two, xm_ElementTable[(four)], five, six, seven, eight, nine, ten
        else
            skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = two, four, xm_ElementTable[(six)], seven, eight, nine, ten, eleven, twelve
        end

        local text = XM:TruncateAmount(amount)
        if (isCrush) then
            text = XM_DB["CRUSHCHAR"]..text..XM_DB["CRUSHCHAR"]
        elseif (isGlance) then
            text = XM_DB["GLANCECHAR"]..text..XM_DB["GLANCECHAR"]
        elseif (isCrit) then
            text = XM_DB["CRITCHAR"]..text..XM_DB["CRITCHAR"]
        end
        if (amountAbsorb) and (XM_DB["ABSORBINC"]) then
            text = text.." ("..XM_Locale["ABSORB"].." "..XM:TruncateAmount(amountAbsorb)..")"
        end
        if (amountBlock) and (XM_DB["BLOCKINC"]) then
            text = text.." ("..XM_Locale["BLOCK"].." "..XM:TruncateAmount(amountBlock)..")"
        end
        if (amountResist) and (XM_DB["RESISTINC"]) then
            text = text.." ("..XM_Locale["RESIST"].." "..XM:TruncateAmount(amountResist)..")"
        end

        --incoming damage (melee, spell, etc..)
        if (victimid == playerid) then

            --damage filter
            if (XM_DB["DMGFILTERINC"] >= 1 and amount < XM_DB["DMGFILTERINC"]) then filter = true end

            --environmental damage
            if strfind(event, "ENVIRONMENTAL") then
                if (skill == "FALLING") then
                    if (not filter) then XM:Display_Event("HITINC", "-"..text.." <"..skill.."> "..("%.0f"):format((amount / UnitHealthMax("player"))*100).."%", nil, nil, source, victim, nil) end
                else
                    if (not filter) then XM:Display_Event("HITINC", "-"..text.." <"..skill..">", nil, element, source, victim, nil) end
                end
            --melee or range attacks
            elseif (strfind(event, "SWING") or strfind(event, "RANGE")) then
                if (element == "physical") then element = nil end
                if (not filter) then XM:Display_Event("HITINC", "-"..text, isCrit, element, source, victim, nil) end
            --spell damage
            elseif (strfind(event, "SPELL_PERIODIC")) then
                if (not filter) then XM:Display_Event("DOTINC", "-"..text, isCrit, element, source, victim, skill) end
            else
                if (element == "physical") then element = nil end
                if (not filter) then XM:Display_Event("SPELLINC", "-"..text, isCrit, element, source, victim, skill) end
            end

        --outgoing damage
        elseif (sourceid == playerid) then

            --damage filter
            if (XM_DB["DMGFILTEROUT"] >= 1 and amount < XM_DB["DMGFILTEROUT"]) then filter = true end

            --melee attacks
            if (strfind(event, "SWING")) then
                if (element == "physical") then element = nil end
                --check unnamed damage for extra attacks
                if (#ExtraAttack > 0) then
                    if (not filter) then XM:Display_Event("HITOUT", text, isCrit, element, source, victim, ExtraAttack[1]) end
                    skill = ExtraAttack[1]
                    tremove(ExtraAttack, 1)
                else
                    if (XMSWING) and (XMSWING.HAND[2].STARTSPEED > 0) and (XMSWING.HAND[1].TIMELEFT <= XMSWING.HAND[2].TIMELEFT) then
                        if (not filter) then XM:Display_Event("HITOUT", text, isCrit, element, source, victim, XM_DB["MHCHAR"]) end
                    elseif (XMSWING) and (XMSWING.HAND[2].STARTSPEED > 0) then
                        if (not filter) then XM:Display_Event("HITOUT", text, isCrit, element, source, victim, XM_DB["OHCHAR"]) end
                    else
                        if (not filter) then XM:Display_Event("HITOUT", text, isCrit, element, source, victim, nil) end
                    end
                end
                if (XMSWING) then
                    XMSWING:SwingCheck(skill, 0)
                end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "HITOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end

            elseif (strfind(event, "RANGE")) then
                if (element == "physical") then element = nil end
                if (not filter) then XM:Display_Event("HITOUT", text, isCrit, element, source, victim, nil) end
                if (XMSWING) then
                    XMSWING:SwingCheck("Range", 0)
                end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "HITOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end

            elseif (strfind(event, "SPELL_PERIODIC")) then
                if (not filter) then XM:Display_Event("DOTOUT", text, isCrit, element, source, victim, skill) end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "DOTOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end

            else
                if (element == "physical") then element = nil end
                if (#ExtraAttack > 0 and skill == ExtraAttack[1]) then
                    tremove(ExtraAttack, 1)
                end
                if (not filter) then XM:Display_Event("SPELLOUT", text, isCrit, element, source, victim, skill) end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "SPELLOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end
            end

        --    if (xm_PlayerClassName == "DEATHKNIGHT") then
        --        XM:DAMAGEOUT_DEATHKNIGHT(event, source, victim, skill, --amount, element, amountResist, amountBlock, amountAbsorb, isCrit, --isGlance, isCrush)
        --    elseif (xm_PlayerClassName == "PALADIN") then
        --        XM:DAMAGEOUT_PALADIN(event, source, victim, skill, --amount, element, amountResist, amountBlock, amountAbsorb, isCrit, --isGlance, isCrush)
        --    elseif (xm_PlayerClassName == "SHAMAN") then
        --        XM:DAMAGEOUT_SHAMAN(event, source, victim, skill, --amount, element, amountResist, amountBlock, amountAbsorb, isCrit, --isGlance, isCrush)
        --    elseif (xm_PlayerClassName == "WARRIOR") then
        --        XM:DAMAGEOUT_WARRIOR(event, source, victim, skill, --amount, element, amountResist, amountBlock, amountAbsorb, isCrit, --isGlance, isCrush)
        --    end

        --incoming pet damage (melee, spell, etc..)
        elseif (playerpetid and victimid == playerpetid) then

            --damage filter
            if (XM_DB["DMGFILTERINC"] >= 1 and amount < XM_DB["DMGFILTERINC"]) then filter = true end

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
            local ownername = xm_PlayerName

            if (petkey >= 1) then
                sourceid = pettable[petkey].ID
                source = pettable[petkey].NAME
                ownerid = pettable[petkey].OWNERID
                ownername = pettable[petkey].OWNERNAME
            end

            if (XMDAMAGE) then
                XMDAMAGE:AddDamageSource(sourceid, source, ownerid, ownername)
            end

            --damage filter
            if (XM_DB["DMGFILTEROUT"] >= 1 and amount < XM_DB["DMGFILTEROUT"]) then filter = true end

            --melee damage
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                if (element == "physical") then element = nil end
                if (not filter) and (ownerid == playerid) then XM:Display_Event("PETHITOUT", text.."("..PET..")", isCrit, element, source, victim, nil) end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "HITOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end

            elseif (strfind(event, "DAMAGE_")) then
                if (not filter) and (ownerid == playerid) then XM:Display_Event("PETSPELLOUT", text.."("..PET..")", isCrit, element, source, victim, nil) end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "SPELLOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end

            elseif (strfind(event, "SPELL_PERIODIC")) then
                if (not filter) and (ownerid == playerid) then XM:Display_Event("PETDOTOUT", text.."("..PET..")", isCrit, element, source, victim, skill) end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "DOTOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end

            else
                if (element == "physical") then element = nil end
                if (not filter) and (ownerid == playerid) then XM:Display_Event("PETSPELLOUT", text.."("..PET..")", isCrit, element, source, victim, skill) end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "SPELLOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end

            end

        --reflected events
        elseif (#ReflectTable >= 1) then

            --damage filter
            if (XM_DB["DMGFILTEROUT"] >= 1 and amount < XM_DB["DMGFILTEROUT"]) then filter = true end

            if (ReflectTable[1].TARGET == sourceid and ReflectTable[1].SPELL == skill) then
                if (element == "physical") then element = nil end
                if (not filter) then XM:Display_Event("SPELLOUT", "("..XM_Locale["REFLECT"]..") "..text, isCrit, element, source, victim, skill) end
                tremove(ReflectTable,1)
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "SPELLOUT", playerid, xm_PlayerName, victimid, victim, skill, amount, element, isCrit)
                end
            end

        --all other outgoing damage, pass to damage meter
        elseif (sourceid and source ~= "") and (victimid and victim ~= "" ) then

            --melee attacks
            if (strfind(event, "SWING")) then
                if (element == "physical") then element = nil end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "HITOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end
            elseif (strfind(event, "RANGE")) then
                if (element == "physical") then element = nil end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "HITOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end
            elseif (strfind(event, "SPELL_PERIODIC")) then
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "DOTOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end
            else
                if (element == "physical") then element = nil end
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "SPELLOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end
            end

        end

    --damage shields or split damage
    elseif (strfind(event, "DAMAGE_")) then
        skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = two, four, xm_ElementTable[(six)], seven, eight, nine, ten, eleven, twelve

        if (strfind(event, "MISSED")) then
        else

            if (not amount) then amount = 0 end
            local text = amount
            if (isCrush) then
                text = XM_DB["CRUSHCHAR"]..text..XM_DB["CRUSHCHAR"]
            elseif (isGlance) then
                text = XM_DB["GLANCECHAR"]..text..XM_DB["GLANCECHAR"]
            elseif (isCrit) then
                text = XM_DB["CRITCHAR"]..text..XM_DB["CRITCHAR"]
            end
            if (amountAbsorb) and (XM_DB["ABSORBINC"]) then
                text = text.." ("..XM_Locale["ABSORB"].." "..XM:TruncateAmount(amountAbsorb)..")"
            end
            if (amountBlock) and (XM_DB["BLOCKINC"]) then
                text = text.." ("..XM_Locale["BLOCK"].." "..XM:TruncateAmount(amountBlock)..")"
            end
            if (amountResist) and (XM_DB["RESISTINC"]) then
                text = text.." ("..XM_Locale["RESIST"].." "..XM:TruncateAmount(amountResist)..")"
            end

            if (victimid == UnitGUID("player")) and (XM_DB["DMGFILTERINC"] < 1 or amount >= XM_DB["DMGFILTERINC"]) then
                XM:Display_Event("DMGSHIELDINC", "-"..text, isCrit, element, source, victim, skill)
            elseif (sourceid == UnitGUID("player")) and (XM_DB["DMGFILTEROUT"] < 1 or amount >= XM_DB["DMGFILTEROUT"]) then
                XM:Display_Event("DMGSHIELDOUT", text, isCrit, element, source, victim, skill)
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, "DMGSHIELDOUT", sourceid, source, victimid, victim, skill, amount, element, isCrit)
                end
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
        if (strfind(event, "SPELL_PERIODIC") and (not XM_DB["SHOWHOTS"])) then
        else
            if (isCrit) then
                healtext = XM_DB["CRITCHAR"]..healtext.."+"..XM_DB["CRITCHAR"]
            end
            --self heals
            if (sourceid == UnitGUID("player") and victimid == UnitGUID("player")) then
                --heal filter (after overhealing)
                if (healamt >= XM_DB["HEALFILTERINC"] and healamt >= XM_DB["HEALFILTEROUT"]) then
                    XM:Display_Event("HEALINC", "+"..healtext, isCrit, nil, source, victim, skill)
                end
            --incoming heals
            elseif (victimid == UnitGUID("player")) then
                --heal filter (after overhealing)
                if (healamt >= XM_DB["HEALFILTERINC"]) then
                    XM:Display_Event("HEALINC", "+"..healtext, isCrit, nil, source, victim, skill)
                end
            --outgoing heals
            elseif (sourceid == UnitGUID("player")) then
                --heal filter (after overhealing)
                if (healamt >= XM_DB["HEALFILTEROUT"]) then
                    XM:Display_Event("HEALOUT", "+"..healtext, isCrit, nil, source, victim, skill)
                end

            --outgoing pet heals
            elseif (playerpetid and sourceid == playerpetid) or (petkey >= 1 and pettable[petkey].OWNERID == UnitGUID("player")) then
                if (petkey >= 1 and pettable[petkey].OWNERID == UnitGUID("player")) then
                    sourceid = pettable[petkey].ID
                    source = pettable[petkey].NAME
                end
                --heal filter (after overhealing)
                if (healamt >= XM_DB["HEALFILTEROUT"]) then
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

        --incoming miss events
        if (victimid == UnitGUID("player")) then
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
            if (xm_PlayerClassName == "WARRIOR") then
                XM:MISSINC_WARRIOR(event, source, victim, skill, missType)
            elseif (xm_PlayerClassName == "DEATHKNIGHT") then
                XM:MISSINC_DEATHKNIGHT(event, source, victim, skill, missType)
            end

        --outgoing miss events
        elseif (sourceid == UnitGUID("player")) then
            if (strfind(event, "SWING")) then
                --check unnamed damage for extra attacks
                if (#ExtraAttack > 0) then
                    XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, ExtraAttack[1])
                    tremove(ExtraAttack, 1)
                else
                    if (XMSWING) and (XMSWING.HAND[2].STARTSPEED > 0) and (XMSWING.HAND[1].TIMELEFT <= XMSWING.HAND[2].TIMELEFT) then
                        XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, XM_DB["MHCHAR"])
                    elseif (XMSWING) and (XMSWING.HAND[2].STARTSPEED > 0) then
                        XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, XM_DB["OHCHAR"])
                    else
                        XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, nil)
                    end
                end
            elseif (strfind(event, "RANGE")) then
                XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, nil)
            else
                if (#NextSpellCheck > 0) then
                    local key, value
                    for key, value in pairs(NextSpellCheck) do
                        if (value == skill) then
                            tremove(NextSpellCheck,key)
                        end
                    end
                end
                XM:Display_Event(missType.."OUT", missType, nil, nil, source, victim, skill)
            end
            --pass events to swing timer
            if (XMSWING) then
                if (strfind(event, "SWING")) then
                    XMSWING:SwingCheck("Melee", 0)
                elseif (strfind(event, "RANGE")) then
                    XMSWING:SwingCheck("Range", 0)
                else
                    XMSWING:SwingCheck(skill, 0)
                end
            end
            if (XMDAMAGE) then
                XMDAMAGE:DamageOut(timestamp, missType.."OUT", sourceid, source, victimid, victim, skill, 0, nil, nil)
            end
            if (xm_PlayerClassName == "WARRIOR") then
                XM:MISSOUT_WARRIOR(event, source, victim, skill, missType)
            elseif (xm_PlayerClassName == "DEATHKNIGHT") then
                XM:MISSOUT_DEATHKNIGHT(event, source, victim, skill, missType)
            end

        --incoming pet miss events
        elseif (playerpetid and victimid == playerpetid) then
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event("PET"..missType.."INC", missType.."("..PET..")", nil, nil, source, victim, nil)
            else
                XM:Display_Event("PET"..missType.."INC", missType.."("..PET..")", nil, nil, source, victim, skill)
            end

        --outgoing pet miss events
        elseif (playerpetid and sourceid == playerpetid) then
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event("PETMISSOUT", PET.." "..missType, nil, nil, source, victim, nil)
            else
                XM:Display_Event("PETMISSOUT", PET.." "..missType, nil, nil, source, victim, skill)
            end
            if (XMDAMAGE) then
                XMDAMAGE:DamageOut(timestamp, "PETMISSOUT", UnitGUID("player"), UnitName("player"), victimid, victim, skill, 0, nil, nil)
                XMDAMAGE:DamageOut(timestamp, "MISSOUT", sourceid, source, victimid, victim, skill, 0, nil, nil)
            end

        --reflected events
        elseif (#ReflectTable >= 1) then
            if (ReflectTable[1].TARGET == sourceid and ReflectTable[1].SPELL == skill) then
                XM:Display_Event(missType.."OUT", "("..XM_Locale["REFLECT"]..") "..missType, nil, nil, source, victim, skill)
                tremove(ReflectTable,1)
                if (XMDAMAGE) then
                    XMDAMAGE:DamageOut(timestamp, missType.."OUT", sourceid, source, victimid, victim, skill, 0, nil, nil)
                end
            end
        end

    --your killing blows
    elseif (strfind(event, "_DIED") or strfind(event, "_DESTROYED")) and (sourceid == UnitGUID("player")) then
        XM:Display_Event("KILLBLOW", XM_Locale["KILLINGBLOW"], nil, nil, source, victim, nil)

    --'gain' events
    elseif (strfind(event, "_ENERGIZE")) then

        if strfind(event, "SWING") then
            skill, amount, power = "Melee", one, xm_PowerTable[(two)]
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, amount, power = one, two, xm_PowerTable[(three)]
        else
            skill, amount, power = two, four, xm_PowerTable[(five)]
        end

        --incoming gains
        if (victimid == UnitGUID("player")) then
            --mana filter
            if (amount >= XM_DB["MANAFILTERINC"]) then
                --XM:Display_Event("POWERGAIN", "+"..amount.." "..power, nil, nil, source, victim, skill)
            end
        end

    --'drain' or 'leech' events
    elseif (strfind(event, "_DRAIN") or strfind(event, "_LEECH")) then

        if strfind(event, "SWING") then
            skill, amount, power, extra = "Melee", one, xm_PowerTable[(two)], three
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, amount, power, extra = one, two, xm_PowerTable[(three)], four
        else
            skill, amount, power, extra = two, four, xm_PowerTable[(five)], six
        end

        --incoming drains
        if (victimid == UnitGUID("player")) then
            if (extra) then
                if (extra > 0) then
                    XM:Display_Event("POWERGAIN", "-"..amount.." - "..extra.." "..power, nil, nil, source, victim, skill)
                else
                    XM:Display_Event("POWERGAIN", "-"..amount.." "..power, nil, nil, source, victim, skill)
                end
            else
                XM:Display_Event("POWERGAIN", "-"..amount.." "..power, nil, nil, source, victim, skill)
            end
        end

    --'extra attacks'
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

    --'interrupt' events
    elseif (strfind(event, "_INTERRUPT")) then

        if strfind(event, "SWING") then
            skill, extra = "Melee", two
        elseif strfind(event, "ENVIRONMENTAL") then
            skill, extra = one, three
        else
            skill, extra = two, five
        end

        if (extra) then
            extra = XM_Locale["INTERRUPT"].." "..extra
        else
            extra = XM_Locale["INTERRUPT"]
        end

        --incoming interrupts
        if (victimid == UnitGUID("player")) then
            XM:Display_Event("INTERRUPTINC", extra, nil, nil, source, victim, skill)
        --outgoing interrupts
        elseif (sourceid == UnitGUID("player")) then
            XM:Display_Event("INTERRUPTOUT", extra, nil, nil, source, victim, skill)
        end

    --buffs and debuffs
    elseif (victimid == UnitGUID("player")) then
        if (strfind(event, "AURA_APPLIED_DOSE")) then
            if strfind(event, "SWING") then
                skill, extra, amount = "Melee", two, three
            elseif strfind(event, "ENVIRONMENTAL") then
                skill, extra, amount = one, two, three
            else
                skill, extra, amount = two, four, five
            end

            if (extra == "BUFF") then
                XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM_DB["SHOWSKILL"]["BUFFGAIN"]).."]"..amount, nil, nil, source, victim, nil)
            else
                XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM_DB["SHOWSKILL"]["DEBUFFGAIN"]).."]"..amount, nil, nil, source, victim, nil)
            end
            if (XMSWING) then XMSWING:SpeedCheck(false, 0) end

        elseif (strfind(event, "AURA_REMOVED_DOSE")) then

            if strfind(event, "SWING") then
                skill, extra, amount = "Melee", two, three
            elseif strfind(event, "ENVIRONMENTAL") then
                skill, extra, amount = one, two, three
            else
                skill, extra, amount = two, four, five
            end

            if (extra == "BUFF") then
                XM:Display_Event("BUFFFADE", "["..XM:ShortenString(skill, XM_DB["SHOWSKILL"]["BUFFFADE"]).."]"..amount, nil, nil, source, victim, nil)
            else
                XM:Display_Event("DEBUFFFADE", "["..XM:ShortenString(skill, XM_DB["SHOWSKILL"]["DEBUFFFADE"]).."]"..amount, nil, nil, source, victim, nil)
            end
            if (XMSWING) then XMSWING:SpeedCheck(false, 0) end

        elseif (strfind(event, "AURA_APPLIED")) then
             if strfind(event, "SWING") then
                skill, extra = "Melee", two
            elseif strfind(event, "ENVIRONMENTAL") then
                skill, extra = one, two
            else
                skill, extra = two, four
            end

            if (extra == "BUFF") then
                XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM_DB["SHOWSKILL"]["BUFFGAIN"]).."]", nil, nil, source, victim, nil)
            else
                XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM_DB["SHOWSKILL"]["DEBUFFGAIN"]).."]", nil, nil, source, victim, nil)
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
                XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM_DB["SHOWSKILL"]["BUFFGAIN"]).."]", nil, nil, source, victim, nil)
            else
                XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM_DB["SHOWSKILL"]["DEBUFFGAIN"]).."]", nil, nil, source, victim, nil)
            end

            if (XMSWING) then XMSWING:SpeedCheck(false, 0) end

--            if (xm_PlayerClassName == "SHAMAN") then
--                XM:BUFFGAIN_SHAMAN(event, source, victim, skill)
--            elseif (xm_PlayerClassName == "WARRIOR") then
--                XM:BUFFGAIN_WARRIOR(event, source, victim, skill)
--            elseif (xm_PlayerClassName == "DEATHKNIGHT") then
--                XM:BUFFGAIN_DEATHKNIGHT(event, source, victim, skill)
--            end

        elseif (strfind(event, "AURA_REMOVED")) then

            if strfind(event, "SWING") then
                skill, extra = "Melee", two
            elseif strfind(event, "ENVIRONMENTAL") then
                skill, extra = one, two
            else
                skill, extra = two, four
            end

            if (extra == "BUFF") then
                XM:Display_Event("BUFFFADE", "["..XM:ShortenString(skill, XM_DB["SHOWSKILL"]["BUFFFADE"]).."]", nil, nil, source, victim, nil)
            else
                XM:Display_Event("DEBUFFFADE", "["..XM:ShortenString(skill, XM_DB["SHOWSKILL"]["DEBUFFFADE"]).."]", nil, nil, source, victim, nil)
            end
            --pass events to swing timer
            if (XMSWING) then XMSWING:SpeedCheck(false, 0) end
--            if (xm_PlayerClassName == "PALADIN") then
--                XM:BUFFFADE_PALADIN(event, source, victim, skill)
--            elseif (xm_PlayerClassName == "SHAMAN") then
--                XM:BUFFFADE_SHAMAN(event, source, victim, skill)
--            elseif (xm_PlayerClassName == "WARRIOR") then
--                XM:BUFFFADE_WARRIOR(event, source, victim, skill)
--            elseif (xm_PlayerClassName == "DEATHKNIGHT") then
--                XM:BUFFFADE_DEATHKNIGHT(event, source, victim, skill)
--            end


        end

    --'other' spellcasting
    elseif (sourceid == UnitGUID("player")) then

        if (strfind(event, "_CAST_SUCCESS")) then
            if strfind(event, "SWING") then
                skill = "Melee"
            elseif strfind(event, "ENVIRONMENTAL") then
                skill = one
            else
                skill = two
            end

            local key,value
            for key, value in pairs(XM.SPELLTABLE) do
                if (skill == value.SPELL) then
                    local foundspell = false
                    if (#NextSpellCheck > 0) then
                        local key2,value2
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

            --create special skill table arrays here ...
            if (skill == "Shield Block" or skill == "Holy Shield") then
--              XM:Display_Event("BLOCKINC", "+", nil, nil, source, victim, skill)
                XMSHIELD:ShieldStart()
            --bloodrage (-711 health)
            elseif (skill == "Bloodrage") then
                XM:Display_Event("SPELLINC", "-711 ", nil, nil, xm_PlayerName, xm_PlayerName, skill)
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
                local key, value
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
            local key, value
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

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:GetDebuffLeft(inpskill)
--

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

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:GetDebuffCount(inpskill)
--

    local i = 1
    local debuffName,debuffCount
    --gather all target debuffs
    while (i <= 40) do
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


--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:OnUpdate(elapsed)
--update screen objects
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:BlizzardCombatTextEvent(_,arg1, arg2, arg3)
--handle blizzard special combat events

    --active skills (execute, overpower, revenge, victory rush)
    if (arg1 == "SPELL_ACTIVE") then
        --don't show blizzard execute or overpower
        if (arg2 == "Execute" or arg2 == "Overpower") then
        --revenge doesn't trigger by blizzard event
        --victory rush should be the only active spell remaining
        else
            XM:Display_Event("EXECUTE", arg2, true, nil, xm_PlayerName, xm_PlayerName, nil)
        end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:Display_Event(event, msg, crit, element, source, victim, skill)
--display event to show messages

    --if event is enabled
    if (XM_DB[event]) then
    if (XM_DB[event] > 0) then
        --get frame number
        local dispframe = XM_DB[event]
        --get color
        local rgbcolor = {r = 1.0, g = 1.0, b = 1.0}
        if (XM_DB["COLOR_TABLE"][event]) then
            rgbcolor = XM_DB["COLOR_TABLE"][event]
        end

        --shorten skill name (-1 = no show, 0 = full name, 1 = truncate, 2 = abbreviate)
        if (skill) and (skill ~= "") then
            --check false first, then check number
            if (not XM_DB["SHOWSKILL"][event]) then
            elseif (XM_DB["SHOWSKILL"][event] > 0) then
                msg = msg.." ("..XM:ShortenString(skill, XM_DB["SHOWSKILL"][event])..")"
            elseif (XM_DB["SHOWSKILL"][event] == 0) then
                msg = msg.." ("..skill..")"
            end
        end

        --if elemental type (false = no color, 0 = full name, 1 = brackets, 2 = color only)
        if (element) then
            if (not XM_DB["SHOWSKILL"]["ELEMENT"] or XM_DB["SHOWSKILL"]["ELEMENT"] < 0) then
            else
                if (XM_DB["COLOR_SPELL"][(strupper(element))]) then
                    rgbcolor = XM_DB["COLOR_SPELL"][(strupper(element))]
                end
                if (XM_DB["SHOWSKILL"]["ELEMENT"] == 0) then
                    msg = msg.." <"..element..">"
                elseif (XM_DB["SHOWSKILL"]["ELEMENT"] == 1) then
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

        if (targetinterest) and (targetinterest ~= "") and (targetinterest ~= xm_PlayerName) then
            --check false first, then check number
            if (not XM_DB["SHOWTARGET"][event]) then
            elseif (XM_DB["SHOWTARGET"][event] > 0) then
                msg = msg.." ("..XM:ShortenString(targetinterest, XM_DB["SHOWTARGET"][event])..")"
            elseif (XM_DB["SHOWTARGET"][event] == 0) then
                msg = msg.." ("..targetinterest..")"
            end
        end

        XM:DisplayText(dispframe, msg, rgbcolor, crit, victim, icon)

    end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:ShortenString(strString, shorttype)
--shorten a spell/buff name

    if (strlen(strString) > XM_DB["SHORTLENGTH"]) then
        if (shorttype) then
            --truncate
            if (shorttype == 1) then
                return strsub(strString, 1, XM_DB["SHORTLENGTH"])..XM_DB["SHORTSTRING"]
            --abbreviate
            elseif (shorttype == 2) then
                return gsub(gsub(gsub(strString," of ","O"),"%s",""), "(%u)%l*", "%1")
            --full string
            else
                return strString
            end
        else
            return strString
        end
    else
        return strString
    end
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:CHAT_MSG_ADDON(_, prefix, text, type, target)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:RegisterXMEvents()
--register XM with events

    --register main events
    XM:RegisterEvent("UNIT_HEALTH")
    XM:RegisterEvent("UNIT_MANA", "UnitPower")
    XM:RegisterEvent("UNIT_ENERGY", "UnitPower")
    XM:RegisterEvent("UNIT_RAGE", "UnitPower")
    XM:RegisterEvent("UNIT_DISPLAYPOWER")
    XM:RegisterEvent("PLAYER_REGEN_ENABLED")
    XM:RegisterEvent("PLAYER_REGEN_DISABLED")
    XM:RegisterEvent("COMBAT_TEXT_UPDATE", "BlizzardCombatTextEvent")

--++--
    XM:RegisterEvent("CHAT_MSG_ADDON")
--++--

    --combo point gain
    if (XM_DB["COMBOPT"]) then
        if (XM_DB["COMBOPT"] > 0) then
            XM:RegisterEvent("PLAYER_COMBO_POINTS")
        end
    end

    --player login
    XM:RegisterEvent("PLAYER_LOGIN")

    --skill gains
    XM:RegisterEvent("CHAT_MSG_SKILL")

    --player target change
    XM:RegisterEvent("PLAYER_TARGET_CHANGED")

    --combat log events to display
    XM:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    --non-combat events to display
    XM:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")

end

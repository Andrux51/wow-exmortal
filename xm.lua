local addonName = ...

local XM = LibStub("AceAddon-3.0"):NewAddon("XM", "AceEvent-3.0", "AceConsole-3.0")

XM.addonVersion = GetAddOnMetadata(addonName, "Version")

XM.player = {
    combatActive = false,
    pet = {}
}
XM.mergeCaptures = {}

--local variables
local PlayerLastHPPercent = 100
local PlayerLastMPPercent = 100
local PlayerLastHPFull = 100
local PlayerLastMPFull = 100
local NextSpellCheck = {}
local ReflectTable = {}


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

    --XM:DefaultChatMessage(RAID_CLASS_COLORS[XM.player.className].colorStr)

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
    XM.player.id = UnitGUID("player")

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
    end
end

-- check for target change to reveal need for execute, etc.
function XM:PLAYER_TARGET_CHANGED()
    --spellcasting fix
    NextSpellCheck = {}
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

    if cpCount > 0 then
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

    if target == XM.player.name then
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
    -- TODO: address "You loot 10 Gold"

    local copperTotal = ''
    for num in message:gmatch("%d+") do
        copperTotal = copperTotal..XM:PadLeft(num, 2)
    end

    XM:Display_Event("GETLOOT", '+'..GetCoinTextureString(copperTotal), nil, nil, XM.player.name, XM.player.name, nil)
end

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




local petTable = {}




-- http://wow.gamepedia.com/COMBAT_LOG_EVENT
function XM:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
    local timestamp, event, hideCaster, srcGUID, srcName, srcFlags,
        srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, one, two, three,
        four, five, six, seven, eight, nine, ten, eleven, twelve = ...

    local skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush, missType, power, extra

    local displayFrame = ''

    XM.player.pet.id = UnitGUID("playerpet")

    local i = 1
    local petkey = 0

    --local petTable = {}

    local filter = false

    --get player pets (that aren't "playerpet") ... (mostly for totems)
    --?? for better memory usage, should destroy old totems / remove old pets
    if (strfind(event, "_SUMMON")) then
        if (#petTable < 1) then
            petTable[1] = {ID = dstGUID, NAME = dstName, OWNERID = srcGUID, OWNERNAME = srcName}
        else
            for i, _ in ipairs(petTable) do
                if (petTable[i].ID == dstGUID) then
                    break
                elseif (i == #petTable) then
                    --petTable[(#petTable + 1)] = {ID = dstGUID, NAME = dstName, OWNERID = srcGUID, OWNERNAME = srcName}
                    tinsert(petTable, {ID = dstGUID, NAME = dstName, OWNERID = srcGUID, OWNERNAME = srcName})
                end
            end
        end
    end

    if srcGUID == XM.player.id or srcGUID == XM.player.pet.id then
    else
        --check pet table
        i = 1
        while (i <= #petTable) do
            if (srcGUID == petTable[i].ID) then
                petkey = i
                i = #petTable
            end
            i = i + 1
        end
    end

    if strfind(event, 'SWING') or strfind(event, 'RANGE') then
        skill = nil
    elseif strfind(event, "ENVIRONMENTAL") then
        skill = one
    else
        skill = two
    end

    if strfind(event, "_DAMAGE") then
        -- incoming/outgoing damage events
        if strfind(event, "SWING") then
            amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = one, XM.elements[(three)], four, five, six, seven, eight, nine
        elseif strfind(event, "ENVIRONMENTAL") then
            amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = two, XM.elements[(four)], five, six, seven, eight, nine, ten
        else
            amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = four, XM.elements[(six)], seven, eight, nine, ten, eleven, twelve
        end

        if element == 'physical' then element = nil end

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

        local incoming = false
        if dstGUID == XM.player.id or (XM.player.pet.id and dstGUID == XM.player.pet.id) then
            incoming = true
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
            if dstGUID == XM.player.id then
                if strfind(event, "ENVIRONMENTAL") then
                    local dmgPct = ''

                    if (skill == "FALLING") then
                        dmgPct = ' '..("%.0f"):format((amount / UnitHealthMax("player"))*100)..'%'
                        element = nil
                    end

                    XM:Display_Event(displayFrame, string.format("%s <%s>%s", text, skill, dmgPct), nil, element, srcName, dstName, nil)
                else
                    XM:Display_Event(displayFrame, text, isCrit, element, srcName, dstName, skill)
                end
            elseif srcGUID == XM.player.id then
                -- local d = date('*t')
                -- print('['..d.hour..':'..d.min..'pm] '..event..' ('..skill..') '..text)

                -- get skills out of array from class file main.lua
                for k, _ in pairs(XM.mergeCaptures) do
                    if skill == k and not XM.mergeCaptures[k].merging then
                        -- print('Merging '..k)
                        XM.mergeCaptures[k] = {total = 0, merging = true}

                        -- callback after merge is complete (duration is 1 frame)
                        C_Timer.After(0, function() -- rife with race conditions
                            text = XM:TruncateAmount(XM.mergeCaptures[k].total)
                            -- print('Merged '..k..': '..text)

                            XM:Display_Event(displayFrame, text, isCrit, element, srcName, dstName, skill)

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
                    XM:Display_Event(displayFrame, text, isCrit, element, srcName, dstName, skill)
                end
            elseif XM.player.pet.id and dstGUID == XM.player.pet.id then
                displayFrame = 'PET'..displayFrame

                if strfind(event, "ENVIRONMENTAL") then
                    local dmgPct = ''

                    if (skill == "FALLING") then
                        dmgPct = ' '..("%.0f"):format((amount / UnitHealthMax("playerpet"))*100)..'%'
                        element = nil
                    end

                    XM:Display_Event(displayFrame, string.format("%s <%s> (%s)%s", text, skill, PET, dmgPct), nil, element, srcName, dstName, nil)
                else
                    XM:Display_Event(displayFrame, string.format('%s (%s)', text, PET), isCrit, element, srcName, dstName, skill)
                end
            elseif XM.player.pet.id and srcNameid == XM.player.pet.id then
                if strfind(event, 'DAMAGE_') then -- damage shield/split damage
                    skill = nil
                    displayFrame = 'SPELLOUT'
                end

                displayFrame = 'PET'..displayFrame

                XM:Display_Event(displayFrame, string.format('%s (%s)', text, PET), isCrit, element, srcName, dstName, skill)
            elseif #ReflectTable > 0 then
                --reflected events
                if (ReflectTable[1].TARGET == srcGUID and ReflectTable[1].SPELL == skill) then
                    XM:Display_Event("SPELLOUT", "("..XM.locale["REFLECT"]..") "..text, isCrit, element, srcName, dstName, skill)

                    tremove(ReflectTable,1)
                end
            end
        end
    elseif (strfind(event, "_MISSED")) then
        -- miss events [miss, dodge, block, deflect, immune, evade, parry, resist, absorb, reflect]
        if strfind(event, "SWING") then
            missType = one
        elseif strfind(event, "ENVIRONMENTAL") then
            missType = two
        else
            missType = four
        end
        if (dstGUID == XM.player.id) then
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event(missType.."INC", missType, nil, nil, srcName, dstName, nil)
            else
                if (missType == "REFLECT") then
                    tinsert(ReflectTable, {TARGET = srcGUID, SPELL = skill})
                end
                XM:Display_Event(missType.."INC", missType, nil, nil, srcName, dstName, skill)
            end
            if (XM.player.className == "WARRIOR") then
                XM:MISSINC_WARRIOR(event, srcName, dstName, skill, missType)
            elseif (XM.player.className == "DEATHKNIGHT") then
                XM:MISSINC_DEATHKNIGHT(event, srcName, dstName, skill, missType)
            end
        elseif (srcGUID == XM.player.id) then
            if (strfind(event, "SWING")) then
                XM:Display_Event(missType.."OUT", missType, nil, nil, srcName, dstName, nil)
            elseif (strfind(event, "RANGE")) then
                XM:Display_Event(missType.."OUT", missType, nil, nil, srcName, dstName, nil)
            else
                if (#NextSpellCheck > 0) then
                    for key, value in pairs(NextSpellCheck) do
                        if (value == skill) then
                            tremove(NextSpellCheck,key)
                        end
                    end
                end
                XM:Display_Event(missType.."OUT", missType, nil, nil, srcName, dstName, skill)
            end
            if (XM.player.className == "WARRIOR") then
                XM:MISSOUT_WARRIOR(event, srcName, dstName, skill, missType)
            elseif (XM.player.className == "DEATHKNIGHT") then
                XM:MISSOUT_DEATHKNIGHT(event, srcName, dstName, skill, missType)
            end
        elseif (XM.player.pet.id and dstGUID == XM.player.pet.id) then
            -- incoming pet miss events
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event("PET"..missType.."INC", missType.."("..PET..")", nil, nil, srcName, dstName, nil)
            else
                XM:Display_Event("PET"..missType.."INC", missType.."("..PET..")", nil, nil, srcName, dstName, skill)
            end
        elseif (XM.player.pet.id and srcGUID == XM.player.pet.id) then
            -- outgoing pet miss events
            if (strfind(event, "SWING") or strfind(event, "RANGE")) then
                XM:Display_Event("PETMISSOUT", PET.." "..missType, nil, nil, srcName, dstName, nil)
            else
                XM:Display_Event("PETMISSOUT", PET.." "..missType, nil, nil, srcName, dstName, skill)
            end
        elseif (#ReflectTable >= 1) then
            -- reflected events
            if (ReflectTable[1].TARGET == srcGUID and ReflectTable[1].SPELL == skill) then
                XM:Display_Event(missType.."OUT", "("..XM.locale["REFLECT"]..") "..missType, nil, nil, srcName, dstName, skill)
                tremove(ReflectTable,1)
            end
        end
    elseif (strfind(event, "DAMAGE_")) then
        -- damage shields or split damage
        skill, amount, element, amountResist, amountBlock, amountAbsorb, isCrit, isGlance, isCrush = two, four or 0, XM.elements[(six)], seven, eight, nine, ten, eleven, twelve

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

        if dstGUID == XM.player.id and amount > XM.db["DMGFILTERINC"] then
            XM:Display_Event("DMGSHIELDINC", "-"..text, isCrit, element, srcName, dstName, skill)
        elseif srcGUID == XM.player.id and amount > XM.db["DMGFILTEROUT"] then
            XM:Display_Event("DMGSHIELDOUT", text, isCrit, element, srcName, dstName, skill)
        end
    elseif strfind(event, "_HEAL") then
        if strfind(event, "SWING") then
            amount, isCrit, extra = one, four, two
        elseif strfind(event, "ENVIRONMENTAL") then
            amount, isCrit, extra = two, five, three
        else
            amount, isCrit, extra = four, seven, five
        end

        local healtext = XM:TruncateAmount(amount)
        local healamt = amount
        if (extra) then
            if (extra > 0) then
                healamt = amount - extra
                healtext = XM:TruncateAmount(healamt).." {"..XM:TruncateAmount(extra).."}"
            end
        end

        if (XM.db["SHOWHOTS"] or not strfind(event, "SPELL_PERIODIC")) then
            --heals over time
            if (isCrit) then
                healtext = XM.db["CRITCHAR"]..healtext.."+"..XM.db["CRITCHAR"]
            end

            if (dstGUID == XM.player.id) then
                if (healamt > XM.db["HEALFILTERINC"]) then
                    XM:Display_Event("HEALINC", "+"..healtext, isCrit, nil, srcName, dstName, skill)
                end
            elseif (srcGUID == XM.player.id) then
                if (healamt > XM.db["HEALFILTEROUT"]) then
                    XM:Display_Event("HEALOUT", "+"..healtext, isCrit, nil, srcName, dstName, skill)
                end
            elseif (XM.player.pet.id and srcGUID == XM.player.pet.id) or (petkey >= 1 and petTable[petkey].OWNERID == XM.player.id) then
                --outgoing pet heals
                if (petkey >= 1 and petTable[petkey].OWNERID == XM.player.id) then
                    srcGUID = petTable[petkey].ID
                    source = petTable[petkey].NAME
                end

                if (healamt > XM.db["HEALFILTEROUT"]) then
                    XM:Display_Event("HEALOUT", "+"..healtext, isCrit, nil, source, dstName, skill)
                end

            end
        end
    elseif (strfind(event, "_DIED") or strfind(event, "_DESTROYED")) and srcGUID == XM.player.id then
        XM:Display_Event("KILLBLOW", XM.locale["KILLINGBLOW"], nil, nil, srcName, dstName, nil)
    elseif (strfind(event, "_INTERRUPT")) then
        if strfind(event, "SWING") then
            extra = two
        elseif strfind(event, "ENVIRONMENTAL") then
            extra = three
        else
            extra = five
        end

        if extra then
            extra = XM.locale["INTERRUPT"].." "..extra
        else
            extra = XM.locale["INTERRUPT"]
        end

        if dstGUID == XM.player.id then
            XM:Display_Event("INTERRUPTINC", extra, nil, nil, srcName, dstName, skill)
        elseif srcGUID == XM.player.id then
            XM:Display_Event("INTERRUPTOUT", extra, nil, nil, srcName, dstName, skill)
        end
    elseif dstGUID == XM.player.id then
        -- buffs and debuffs
        if strfind(event, "SWING") then
            extra, amount = two, three
        elseif strfind(event, "ENVIRONMENTAL") then
            extra, amount = two, three
        else
            extra, amount = four, five
        end

        if (strfind(event, "AURA_APPLIED_DOSE")) then
            if (extra == "BUFF") then
                XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFGAIN"]).."]"..amount, nil, nil, srcName, dstName, nil)
            else
                XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFGAIN"]).."]"..amount, nil, nil, srcName, dstName, nil)
            end
        elseif (strfind(event, "AURA_REMOVED_DOSE")) then
            if (extra == "BUFF") then
                XM:Display_Event("BUFFFADE", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFFADE"]).."]"..amount, nil, nil, srcName, dstName, nil)
            else
                XM:Display_Event("DEBUFFFADE", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFFADE"]).."]"..amount, nil, nil, srcName, dstName, nil)
            end
        elseif (strfind(event, "AURA_APPLIED")) then
            if (extra == "BUFF") then
                XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFGAIN"]).."]", nil, nil, srcName, dstName, nil)
            else
                XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFGAIN"]).."]", nil, nil, srcName, dstName, nil)
            end
        end
    elseif (strfind(event, "AURA_REFRESH")) then
            if (strfind(event, "SWING")) then
                extra = two
            elseif (strfind(event, "ENVIRONMENTAL")) then
                extra = two
            else
                extra = four
            end

            if (extra == "BUFF") then
                XM:Display_Event("BUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFGAIN"]).."]", nil, nil, srcName, dstName, nil)
            else
                XM:Display_Event("DEBUFFGAIN", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFGAIN"]).."]", nil, nil, srcName, dstName, nil)
            end
    elseif (strfind(event, "AURA_REMOVED")) then
        if strfind(event, "SWING") then
            extra = two
        elseif strfind(event, "ENVIRONMENTAL") then
            extra = two
        else
            extra = four
        end

        if (extra == "BUFF") then
            XM:Display_Event("BUFFFADE", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["BUFFFADE"]).."]", nil, nil, srcName, dstName, nil)
        else
            XM:Display_Event("DEBUFFFADE", "["..XM:ShortenString(skill, XM.db["SHOWSKILL"]["DEBUFFFADE"]).."]", nil, nil, srcName, dstName, nil)
        end
    elseif srcGUID == XM.player.id then
        displayFrame = 'SPELLOUT'

        if strfind(event, "_CAST_SUCCESS") then
            for _, v in pairs(XM.SPELLTABLE) do
                if skill == v.SPELL then
                    local exists = false
                    if (#NextSpellCheck > 0) then
                        for _, nextSpell in pairs(NextSpellCheck) do
                            if (v.DEBUFF == nextSpell.DEBUFF) then
                                exists = true
                            end
                        end
                    end

                    if not exists then
                        XM:DefaultChatMessage('insert NextSpellCheck: %s', skill)
                        tinsert(NextSpellCheck, v)
                    end
                end
            end

            for k, v in pairs(NextSpellCheck) do
                if skill == v.DEBUFF then
                    local debuffCount = XM:GetDebuffCount(v.DEBUFF)

                    if v.COUNT > 1 and debuffCount == v.COUNT then
                        XM:Display_Event(displayFrame, "["..debuffCount.."]", nil, nil, srcName, dstName, skill)

                        tremove(NextSpellCheck, k)
                    end
                end
            end
        elseif dstGUID == UnitGUID("target") and strfind(event, "AURA_APPLIED") then
            if #NextSpellCheck > 0 then
                for k, v in pairs(NextSpellCheck) do
                    if skill == v.DEBUFF then
                        if v.COUNT > 1 then
                            XM:Display_Event(displayFrame, "["..XM:GetDebuffCount(v.DEBUFF).."]", nil, nil, srcName, dstName, skill)
                        else
                            XM:Display_Event(displayFrame, "", nil, nil, srcName, dstName, skill)
                        end

                        tremove(NextSpellCheck, k)
                    end
                end
            end
        end
    elseif dstGUID == UnitGUID("target") and strfind(event, "AURA_APPLIED") then
        if (#NextSpellCheck > 0) then
            for k, v in pairs(NextSpellCheck) do
                if skill == v.DEBUFF then
                    if v.COUNT > 1 then
                        XM:Display_Event("SPELLOUT", "["..XM:GetDebuffCount(v.DEBUFF).."]", nil, nil, srcName, dstName, skill)
                    else
                        XM:Display_Event("SPELLOUT", "", nil, nil, srcName, dstName, skill)
                    end

                    tremove(NextSpellCheck, k)
                end
            end
        end
    end
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


function XM:Display_Event(event, msg, crit, element, srcName, dstName, skill)
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
            targetinterest = dstName
        else
            targetinterest = srcName
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

        XM:DisplayText(dispframe, msg, rgbcolor, crit, dstName, icon)
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
    XM:RegisterEvent("PLAYER_REGEN_ENABLED")
    XM:RegisterEvent("PLAYER_REGEN_DISABLED")
    XM:RegisterEvent("CHAT_MSG_LOOT")
    XM:RegisterEvent("CHAT_MSG_MONEY")

    if (XM.db["COMBOPT"] and XM.db["COMBOPT"] > 0) then
        XM:RegisterEvent("PLAYER_COMBO_POINTS")
    end

    XM:RegisterEvent("PLAYER_LOGIN")
    XM:RegisterEvent("CHAT_MSG_SKILL")
    XM:RegisterEvent("PLAYER_TARGET_CHANGED")
    XM:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    XM:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
end

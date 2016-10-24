local addonName = ...

local XM = LibStub("AceAddon-3.0"):NewAddon("XM", "AceEvent-3.0", "AceConsole-3.0")

XM.addonVersion = GetAddOnMetadata(addonName, "Version")

XM.player = {
    combatActive = false,
    pet = {}
}
XM.mergeCaptures = {}
XM.extraSpells = {}

--local variables
local PlayerLastHPPercent = 100
local PlayerLastMPPercent = 100
local PlayerLastHPFull = 100
local PlayerLastMPFull = 100


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
    XM.extraSpellsCheckTable = {}
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

    XM.reflectTable = {}
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

function XM:GetDebuffCount(skillName)
    for i = 1, 40 do
        local debuffName,_,_,debuffCount,_,_ = UnitDebuff("target", i)

        if debuffName == skillName then
            return debuffCount
        end
    end

    return 0
end

function XM:Display_Event(event, msg, crit, element, srcName, dstName, skill)
    -- TODO: srcName, dstName should merge together as targetName
    -- TODO: allow the user to choose which name is displayed

    if element and strupper(element) == 'PHYSICAL' then element = nil end

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
        if skill and skill ~= "" then
            --check false first, then check number
            if (not XM.db["SHOWSKILL"][event]) then
            elseif (XM.db["SHOWSKILL"][event] > 0) then
                msg = msg.." ("..XM:ShortenString(skill, XM.db["SHOWSKILL"][event])..")"
            elseif (XM.db["SHOWSKILL"][event] == 0) then
                msg = msg.." ("..skill..")"
            end
        end

        --if elemental type (false = no color, 0 = full name, 1 = brackets, 2 = color only)
        if element then
            if (not XM.db["SHOWSKILL"]["ELEMENT"] or XM.db["SHOWSKILL"]["ELEMENT"] < 0) then
            else
                if (XM.db["COLOR_SPELL"][strupper(element)]) then
                    rgbcolor = XM.db["COLOR_SPELL"][strupper(element)]
                end
                if (XM.db["SHOWSKILL"]["ELEMENT"] == 0) then
                    msg = msg.." <"..element..">"
                elseif (XM.db["SHOWSKILL"]["ELEMENT"] == 1) then
                    msg = " <"..msg..">"
                end
            end
        end

        --shorten target name (-1 = no show, 0 = full name, 1 = truncate, 2 = abbreviate)
        local targetinterest = nil
        if (strfind(event, "OUT")) then
            targetinterest = dstName
        else
            targetinterest = srcName
        end

        if targetinterest and targetinterest ~= "" and targetinterest ~= XM.player.name then
            if XM.db["SHOWTARGET"][event] then
                if (XM.db["SHOWTARGET"][event] > 0) then
                    msg = msg.." ("..XM:ShortenString(targetinterest, XM.db["SHOWTARGET"][event])..")"
                elseif (XM.db["SHOWTARGET"][event] == 0) then
                    msg = msg.." ("..targetinterest..")"
                end
            end
        end

        XM:DisplayText(dispframe, msg, rgbcolor, crit, dstName, icon)
    end
end


function XM:UNIT_PET(_, ...)
    -- test to see when players gain/lose a pet
    -- is it possible to tell gain vs. loss?
    local unitId = ...

    --print('pet gain/loss: '..unitId)
    --print(UnitExists('pet'))
end

function XM:RegisterXMEvents()
    XM:RegisterEvent("UNIT_HEALTH")
    XM:RegisterEvent("PLAYER_REGEN_ENABLED")
    XM:RegisterEvent("PLAYER_REGEN_DISABLED")
    XM:RegisterEvent("CHAT_MSG_LOOT")
    XM:RegisterEvent("CHAT_MSG_MONEY")
    --XM:RegisterEvent("UNIT_PET")

    if (XM.db["COMBOPT"] and XM.db["COMBOPT"] > 0) then
        XM:RegisterEvent("PLAYER_COMBO_POINTS")
    end

    XM:RegisterEvent("PLAYER_LOGIN")
    XM:RegisterEvent("CHAT_MSG_SKILL")
    XM:RegisterEvent("PLAYER_TARGET_CHANGED")
    XM:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    XM:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
end

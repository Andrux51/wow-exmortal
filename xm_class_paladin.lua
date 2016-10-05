--MUST HAVE "xm_init.lua" LOADED FIRST

--paladin local variables
local Execute = false
local SpellActive = false
local HasSpellActive = false
local LastTargetHPPercent = 100

local xm_ActiveSpells = {
    [1] = {TALENT="The Art of War", 	BUFF = "The Art of War"},
}

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:LOGIN_PALADIN()
--set class vars on login

    Execute = XM:SpellCheck("Hammer of Wrath")

    SpellActive = false
    local key,value
    for key,value in pairs(xm_ActiveSpells) do
        if (XM:TalentCheck(value.TALENT) and XM:TalentCheck(value.TALENT) >= 1) then
            SpellActive = value.BUFF
        end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:UNITHEALTH_PALADIN(arg1, hppercent)

    if (arg1 == "target") then
        --execute check (linked with target change) ... because blizzard's doesn't work
        if (Execute and (not UnitIsFriend("target", "player"))) then
            if (hppercent > 0 and hppercent < 20 and LastTargetHPPercent >= 20) then
                XM:Display_Event("EXECUTE", "Execute", true, nil, xm_PlayerName, xm_PlayerName, nil)
                LastTargetHPPercent = hppercent
            elseif (hppercent >= 20) then
                LastTargetHPPercent = hppercent
            else
                LastTargetHPPercent = 0
            end
        else
            LastTargetHPPercent = 100
        end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:TARGETCHANGE_PALADIN(arg1, hppercent)

    LastTargetHPPercent = 100
    XM:UNITHEALTH_PALADIN(arg1,hppercent)

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:DAMAGEOUT_PALADIN(event, source, victim, skill, amount, element, resist, block, absorb, crit, glance, crush)
--outgoing damage events

    --art of war for paladin, after a crit
    if (SpellActive == "The Art of War" and HasSpellActive == false) then
        if (crit) and (strfind(skill, "Judgement") or skill == "Crusader Strike" or skill == "Divine Storm") then
            XM:Display_Event("SPELLACTIVE", SpellActive, true, nil, source, source, nil)
            HasSpellActive = true
        end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:BUFFFADE_PALADIN(event, source, victim, skill)
--buff fade events

    if (skill == "Holy Shield") then
        XM:Display_Event("BLOCKINC", "-", nil, nil, source, victim, skill)
        if (XMSHIELD) then XMSHIELD:ShieldEnd() end
    elseif (SpellActive) and (skill == SpellActive) then
       XM:AniInitFrame(XM_DB["SPELLACTIVE"])
       HasSpellActive = false
    end

end
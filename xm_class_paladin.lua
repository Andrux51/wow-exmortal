local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

--paladin local variables
local SpellActive = false
local HasSpellActive = false

local xm_ActiveSpells = {
    [1] = {TALENT="The Art of War", 	BUFF = "The Art of War"},
}

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:LOGIN_PALADIN()
--set class vars on login

    Execute =

    SpellActive = false
    local key,value
    for key,value in pairs(xm_ActiveSpells) do
        if (XM:TalentCheck(value.TALENT) and XM:TalentCheck(value.TALENT) >= 1) then
            SpellActive = value.BUFF
        end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:PaladinCheckTargetHealth(healthPct)
    -- Hammer of Wrath was removed from the game...
    if (GetSpellInfo("Hammer of Wrath") and not UnitIsFriend("target", "player") and healthPct > 0 and healthPct < 20) then
        XM:Display_Event("EXECUTE", "Execute", true, nil, XM.player.name, XM.player.name, nil)
    end
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
       XM:AniInitFrame(XM.db["SPELLACTIVE"])
       HasSpellActive = false
    end

end

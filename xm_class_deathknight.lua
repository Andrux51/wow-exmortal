--MUST HAVE "xm_init.lua" LOADED FIRST

--deathknight local variables
local SpellActive = false
local HasSpellActive = false

local xm_ActiveSpells = {
    [1] = {TALENT="Rime", 	BUFF = "Freezing Fog"},
}

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:LOGIN_DEATHKNIGHT()
--set class vars on login

    SpellActive = false
    local key,value
    for key,value in pairs(xm_ActiveSpells) do
        if (XM:TalentCheck(value.TALENT) and XM:TalentCheck(value.TALENT) >= 1) then
            SpellActive = value.BUFF
        end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:UNITHEALTH_DEATHKNIGHT(arg1, hppercent)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:TARGETCHANGE_DEATHKNIGHT(arg1, hppercent)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:DAMAGEOUT_DEATHKNIGHT(event, source, victim, skill, amount, element, resist, block, absorb, crit, glance, crush)
--outgoing damage events
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:MISSINC_DEATHKNIGHT(event, source, victim, skill, misstype)
--incoming miss events
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:MISSOUT_DEATHKNIGHT(event, source, victim, skill, misstype)
--outgoing miss events

    --skills that can be instantly re-activated if they miss
    local skillarray = {
        [1] = "Plague Strike",
        [2] = "Scourge Strike",
        [3] = "Blood Strike",
        [4] = "Death Strike",
        [5] = "Obliterate",
        [6] = "Heart Strike",
    }

    local key, value    
    for key, value in pairs(skillarray) do
        if (value == skill) then
            XM:Display_Event("EXECUTE", skill, true, nil, source, source, nil)
        end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:BUFFGAIN_DEATHKNIGHT(event, source, victim, skill)

    --active spells
    if (SpellActive and skill == SpellActive and HasSpellActive == false) then
        XM:Display_Event("SPELLACTIVE", SpellActive, true, nil, source, source, nil)
        HasSpellActive = true
    end
    if (skill == "Pestilence") then XM:Display_Event("BUFFGAIN", skill, true, nil, source, source, nil)
    end
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:BUFFFADE_DEATHKNIGHT(event, source, victim, skill)
--buff fade events

    if SpellActive then
        if (skill == SpellActive) then
           XM:AniInitFrame(XM_DB["SPELLACTIVE"])
           HasSpellActive = false
        end
    end
end
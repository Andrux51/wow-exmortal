local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

--warrior variables
local Flurry = false
local SpellActive = false
local HasSpellActive = false
local LastTargetHPPercent = 100

local xm_ActiveSpells = {
--    [1] = {TALENT="Bloodsurge", 	BUFF = "Slam!"},
    [2] = {TALENT="Sword and Board",	BUFF = "Sword and Board"},
--    [3] = {TALENT="Taste for Blood",	BUFF = "Taste for Blood"},
--    [4] = {TALENT="Sudden Death",	BUFF = "Sudden Death"},
}

--warrior global variables
XM.CHECKFLURRY = false
XM.TALENTSLAM = false

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:LOGIN_WARRIOR()
--set class vars on login

    --warrior variables
    Flurry = XM:TalentCheck("Flurry")

    SpellActive = false
    local key,value
    for key,value in pairs(xm_ActiveSpells) do
        if (XM:TalentCheck(value.TALENT) and XM:TalentCheck(value.TALENT) >= 1) then
            SpellActive = value.BUFF
        end
    end
end

--execute check (linked with target change) ... because blizzard's doesn't work
function XM:WarriorCheckTargetHealth(healthPct)
    if (XM:GetSpellInfo("Execute") and (not UnitIsFriend("target", "player"))) then
        if (healthPct > 0 and healthPct < 20) then
            XM:Display_Event("EXECUTE", "Execute", true, nil, XM.player.name, XM.player.name, nil)
            LastTargetHPPercent = healthPct
        elseif (healthPct >= 20) then
            LastTargetHPPercent = healthPct
        else
            LastTargetHPPercent = 0
        end
    else
        LastTargetHPPercent = 100
    end
end


--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:MISSINC_WARRIOR(event, source, victim, skill, misstype)
--incoming miss events

    --check defensive stance and trigger revenge (blizzard doesn't trigger it)
    if (GetSpellInfo("Revenge") and GetShapeshiftForm(true) == 2 and (misstype == "DODGE" or misstype == "PARRY" or misstype == "BLOCK")) then
        --squelch revenge spam if the spell is on cooldown
        local start,duration,enabled = GetSpellCooldown("Revenge")
        if ((start + duration - GetTime()) <= 0) then
            XM:Display_Event("EXECUTE", "Revenge", true, nil, victim, victim, nil)
        end
    end
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:MISSOUT_WARRIOR(event, source, victim, skill, misstype)
--outgoing miss events

--    start,duration,enabled = GetSpellCooldown("Overpower")
--if (missType == "DODGE") then
--self:Print(start.." "..duration.." "..enabled)
--
--if enabled == 0 then
---- DEFAULT_CHAT_FRAME:AddMessage("Presence of Mind is currently active, use it and wait " .. duration .. " seconds for the next one.");
--elseif ( start > 0 and duration > 0) then
---- DEFAULT_CHAT_FRAME:AddMessage("Presence of Mind is cooling down, wait " .. (start + duration - GetTime()) .. " seconds for the next one.");
--else
--   XM:Display_Event("EXECUTE", "Overpower", true, nil, source, source, nil)
--end
--end


    --dodge triggers overpower
    if (GetSpellInfo("Overpower") and misstype == "DODGE") and (GetShapeshiftForm(true) == 1 or GetShapeshiftForm(true) == 3) then
        --squelch overpower spam if the spell is on cooldown
--DEFINITELY NOT WORKING (erratic behavior with getspellcooldown!)
--        local start,duration,enabled = GetSpellCooldown("Overpower")
--        if ((start + duration - GetTime()) <= 0) then
            XM:Display_Event("EXECUTE", "Overpower", true, nil, source, source, nil)
        end
--    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:BUFFGAIN_WARRIOR(event, source, victim, skill)

    if (XMSWING) and (Flurry) and (skill == "Flurry") then
        XM.CHECKFLURRY = true
        XMSWING:SpeedCheck(false, (5*Flurry/100))
    elseif (XMSWING) then
        XMSWING:SpeedCheck(false, 0)
    end

    --active spells
    if (SpellActive and skill == SpellActive and HasSpellActive == false) then
        XM:Display_Event("SPELLACTIVE", SpellActive, true, nil, source, source, nil)
        HasSpellActive = true
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:BUFFFADE_WARRIOR(event, source, victim, skill)
--buff fade events

    if (skill == "Shield Block") then
        XM:Display_Event("BLOCKINC", "-", nil, nil, source, victim, skill)
        if (XMSHIELD) then XMSHIELD:ShieldEnd() end
    elseif (skill == "Flurry") then
        XM.CHECKFLURRY = true
    elseif SpellActive then
        if (skill == SpellActive) then
           XM:AniInitFrame(XM.db["SPELLACTIVE"])
           HasSpellActive = false
        end
    end

end

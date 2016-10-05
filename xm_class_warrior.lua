--MUST HAVE "xm_init.lua" LOADED FIRST

--warrior variables
local Execute = false
local Overpower = false
local Flurry = false
local Revenge = false
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
    Execute = XM:SpellCheck("Execute")
    Overpower = XM:SpellCheck("Overpower")
    Flurry = XM:TalentCheck("Flurry")
    Revenge = XM:SpellCheck("Revenge")

    SpellActive = false
    local key,value
    for key,value in pairs(xm_ActiveSpells) do
        if (XM:TalentCheck(value.TALENT) and XM:TalentCheck(value.TALENT) >= 1) then
            SpellActive = value.BUFF
        end
    end

    XM.TALENTSLAM = XM:SpellTalentCheck("Slam", "Improved Slam", false)

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:UNITHEALTH_WARRIOR(arg1, hppercent)

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
function XM:TARGETCHANGE_WARRIOR(arg1, hppercent)

    LastTargetHPPercent = 100
    XM:UNITHEALTH_WARRIOR(arg1,hppercent)

end


--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:DAMAGEOUT_WARRIOR(event, source, victim, skill, amount, element, resist, block, absorb, crit, glance, crush)
--outgoing damage events

    --Flurry trigger for more accurate swing timer (blizz flurry buff lags)
    if (XMSWING) then
        if ((crit and Flurry) or XM.CHECKFLURRY == true) then
            XM.CHECKFLURRY = true
            XMSWING:SwingCheck(skill, (5*Flurry/100))
        else
            XMSWING:SwingCheck(skill, 0)
        end
    end


--!! inactivate this part in patch 3.0.8 because it will only be "chance on hit" !!--
    --Bloodsurge
    if (SpellActive == "Slam!" and XM:TalentCheck("Bloodsurge") == 3 and HasSpellActive == false) then
        if (crit and skill == "Bloodthirst") then
            XM:Display_Event("SPELLACTIVE", SpellActive, true, nil, source, source, nil)
           HasSpellActive = true
        end
    end
--!!

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:MISSINC_WARRIOR(event, source, victim, skill, misstype)
--incoming miss events

    --check defensive stance and trigger revenge (blizzard doesn't trigger it)
    if (Revenge and GetShapeshiftForm(true) == 2 and (misstype == "DODGE" or misstype == "PARRY" or misstype == "BLOCK")) then
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
    if (Overpower and misstype == "DODGE") and (GetShapeshiftForm(true) == 1 or GetShapeshiftForm(true) == 3) then
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
           XM:AniInitFrame(XM_DB["SPELLACTIVE"])
           HasSpellActive = false
        end
    end

end
--MUST HAVE "xm_init.lua" LOADED FIRST
xm_class_shaman_loaded = true

--shaman local variables
local Flurry = false
local SpellActive = false
local HasSpellActive = false

--shaman global variables
XM.CHECKFLURRY = false

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:LOGIN_SHAMAN()
--set class vars on login
    print("you are shaman")

    --shaman variables
    --Flurry = XM:TalentCheck("Flurry")
    --if (Flurry >= 1) then Flurry = Flurry + 1 end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:UNITHEALTH_SHAMAN(arg1, hppercent)
end


--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:TARGETCHANGE_SHAMAN(arg1, hppercent)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:DAMAGEOUT_SHAMAN(event, source, victim, skill, amount, element, resist, block, absorb, crit, glance, crush)
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

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:MISSINC_SHAMAN(event, source, victim, skill, misstype)
--incoming miss events
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:MISSOUT_SHAMAN(event, source, victim, skill, misstype)
--outgoing miss events
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:BUFFGAIN_SHAMAN(event, source, victim, skill)

    if (XMSWING) and (Flurry) and (skill == "Flurry") then
        XM.CHECKFLURRY = true
        XMSWING:SpeedCheck(false, (5*Flurry/100))
    elseif (XMSWING) then
        XMSWING:SpeedCheck(false, 0)
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:BUFFFADE_SHAMAN(event, source, victim, skill)
--buff fade events

    if (skill == "Flurry") then
        XM.CHECKFLURRY = true
    end

end

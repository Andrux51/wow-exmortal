--MUST HAVE "xm_init.lua" LOADED FIRST

--rogue local variables

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:LOGIN_ROGUE()
--set class vars on login
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:UNITHEALTH_ROGUE(arg1, hppercent)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:TARGETCHANGE_ROGUE(arg1, hppercent)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:DAMAGEOUT_ROGUE(event, source, victim, skill, amount, element, resist, block, absorb, crit, glance, crush)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:MISSINC_ROGUE(event, source, victim, skill, misstype)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:MISSOUT_ROGUE(event, source, victim, skill, misstype)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:BUFFGAIN_ROGUE(event, source, victim, skill)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:BUFFFADE_ROGUE(event, source, victim, skill)
end
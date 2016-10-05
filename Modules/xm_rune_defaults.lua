--XM object (REQUIRED)
if (not XMRUNE) then
    XMRUNE = LibStub("AceAddon-3.0"):NewAddon("XMRUNE", "AceEvent-3.0", "AceConsole-3.0")
end

XMRUNE.DEFAULTS = {
    ["RUNEFRAME"] = {
        ["STRATA"] = "MEDIUM",
        ["SCALE"] = 1,
        ["ALPHA"] = 1,
        ["POSX"] = 0,
        ["POSY"] = 0,
    },
    ["RUNEBACK"] = {
        ["TEXTURE"] = "Smooth",
        ["COLOR"] = {r = 0, g = 0, b = 0},
        ["ALPHA"] = 0.3,
    },
    ["RUNECD"] = {
        ["FONT"] = "Emblem",
        ["COLOR"] = {r = 1, g = 1, b = 1},
        ["ALPHA"] = 1,
    },
    ["ENABLED"] = true,
    ["RUNEGRIDX"] = 3,
    ["RUNEGRIDY"] = 2,
    ["RUNESQUARE"] = 25,
    ["RUNEBORDER"] = 2,

}
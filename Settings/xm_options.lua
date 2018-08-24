local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

XM.locale = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("XM", true)

--embedded libs
XM.configDialog = LibStub("AceConfigDialog-3.0")

--local variables
local ShowName = {[-1] = "No Name", [0] = "Full Name",[1] = "Truncate",[2] = "Abbreviate"}
local ShowElem = {[-1] = "No Name No Color", [0] = "Full Name & Color", [1] = "Brackets & Color", [2] = "Color Only"}
local FontOutline = {[1] = "NONE", [2] = "OUTLINE", [3] = "THICKOUTLINE"}
local TextAlign = {[1] = "LEFT", [2] = "CENTER", [3] = "RIGHT"}

function XM:InitOptionFrame()
    --register option frame
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("eXMortal", XM.OPTIONS)
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(LibStub("AceDB-3.0"):New("XM.configDialog")))

    --create option frame
    XM.configDialog:AddToBlizOptions("eXMortal", "eXMortal")
    XM.configDialog:AddToBlizOptions("Profiles", "Profiles", "eXMortal")
end

--NOTE: Range values must be integers!
XM.OPTIONS = {
    name = "eXMortal",
    desc = "eXMortal",
    type = "group",
    order = 0,
    args = {
        MAIN = {
            name = "Main Options",
            desc = "Main Options",
            type = "group",
            order = 100,
            args = {
                LOWHPVALUE = {
                    name = "Low HP Percent",
                    desc = "Show warning if HP drops below this percent (0=disabled)",
                    type = "range", min = 0, max = 100, step = 1,
                    order = 103,
                    get = function(info) return XM.db["LOWHPVALUE"] end,
                    set = function(info, v) XM.db["LOWHPVALUE"] = v end,
                },
                LOWMANAVALUE = {
                    name = "Low Mana Percent",
                    desc = "Show warning if mana drops below this percent (0=disabled)",
                    type = "range", min = 0, max = 100, step = 1,
                    order = 104,
                    get = function(info) return XM.db["LOWMANAVALUE"] end,
                    set = function(info, v) XM.db["LOWMANAVALUE"] = v end,
                },
                SHOWALLPOWER = {
                    name = "Show All Power Gains",
                    desc = "Show -ALL- power gains (i.e. mana regen)",
                    type = "toggle",
                    order = 105,
                    get = function(info) return XM.db["SHOWALLPOWER"] end,
                    set = function(info, v) XM.db["SHOWALLPOWER"] = v end,
                },
                DMGFILTERINC = {
                    name = "Damage Filter (Incoming)",
                    desc = "Silence incoming damage less than this number (0=disabled)",
                    type = "range", min = 0, max = 10000, step = 1,
                    order = 106,
                    get = function(info) return XM.db["DMGFILTERINC"] end,
                    set = function(info,v) XM.db["DMGFILTERINC"] = v end,
                },
                DMGFILTEROUT = {
                    name = "Damage Filter (Outgoing)",
                    desc = "Silence outgoing damage less than this number (0=disabled)",
                    type = "range", min = 0, max = 10000, step = 1,
                    order = 107,
                    get = function(info) return XM.db["DMGFILTEROUT"] end,
                    set = function(info, v) XM.db["DMGFILTEROUT"] = v end,
                },
                HEALFILTERINC = {
                    name = "Heal Filter (Incoming)",
                    desc = "Silence incoming heals less than this number (0=disabled)",
                    type = "range", min = 0, max = 10000, step = 1,
                    order = 108,
                    get = function(info) return XM.db["HEALFILTERINC"] end,
                    set = function(info, v) XM.db["HEALFILTERINC"] = v end,
                },
                HEALFILTEROUT = {
                    name = "Heal Filter (Outgoing)",
                    desc = "Silence outgoing heals less than this number (0=disabled)",
                    type = "range", min = 0, max = 10000, step = 1,
                    order = 109,
                    get = function(info) return XM.db["HEALFILTEROUT"] end,
                    set = function(info, v) XM.db["HEALFILTEROUT"] = v end,
                },
                SHOWHOTS = {
                    name = "Show HOTs",
                    desc = "Show heals over time (in and out)",
                    type = "toggle",
                    order = 110,
                    get = function(info) return XM.db["SHOWHOTS"] end,
                    set = function(info, v) XM.db["SHOWHOTS"] = v end,
                },
                MANAFILTERINC = {
                    name = "Mana Filter (Incoming)",
                    desc = "Silence incoming power (mana) gains less than this number (0=disabled)",
                    type = "range", min = 0, max = 10000, step = 1,
                    order = 111,
                    get = function(info) return XM.db["MANAFILTERINC"] end,
                    set = function(info, v) XM.db["MANAFILTERINC"] = v end,
                },
                SHORTLENGTH = {
                    name = "Text Length",
                    desc = "Limit phrases to this many characters",
                    type = "range", min = 1, max = 100, step = 1,
                    order = 112,
                    get = function(info) return XM.db["SHORTLENGTH"] end,
                    set = function(info, v) XM.db["SHORTLENGTH"] = v end,
                },
                CRITSIZE = {
                    name = "Crit Size",
                    desc = "Critical strike text size (percent)",
                    type = "range", min = 1, max = 400, step = 1,
                    order = 113,
                    get = function(info) return XM.db["CRITSIZE"] end,
                    set = function(info, v) XM.db["CRITSIZE"] = v end,
                },
                RESET = {
                    name = "Reset Defaults",
                    desc = "Resets ALL settings for current profile to default values",
                    type = "execute",
                    order = 120,
            		func = function() XM:ResetDefaults() end,
                    confirm = true,
            		confirmText = XM.locale["confirm_reset"]
                },
                COUNTBANKITEMS = {
                    name = 'Show Bank Count',
                    desc = 'Show banked quantity when looting',
                    type = 'toggle',
                    order = 121,
                    get = function(info) return XM.db["COUNTBANKITEMS"] end,
                    set = function(info, v) XM.db["COUNTBANKITEMS"] = v end,
                }
            }
        },
        FRAME = {
            name = "Event Frames",
            desc = "Event Frames",
            type = "group",
            order = 200,
            args = {}
        }
    }
}

XM.OPTIONS.args.FRAME.args.LOWHP = {
    name = "Low HP",
    desc = "Low HP Warning",
    type = "range", min = 0, max = 10, step = 1,
    order = 201,
    get = function(info) return XM.db["LOWHP"] end,
    set = function(info, v) XM.db["LOWHP"] = v end,
}

XM.OPTIONS.args.FRAME.args.LOWMANA = {
    name = "Low Mana",
    desc = "Low Mana Warning",
    type = "range", min = 0, max = 10, step = 1,
    order = 202,
    get = function(info) return XM.db["LOWMANA"] end,
    set = function(info, v) XM.db["LOWMANA"] = v end,
}

XM.OPTIONS.args.FRAME.args.COMBAT = {
    name = "Combat",
    desc = "Entering/Leaving Combat",
    type = "range", min = 0, max = 10, step = 1,
    order = 203,
    get = function(info) return XM.db["COMBAT"] end,
    set = function(info, v) XM.db["COMBAT"] = v end,
}

XM.OPTIONS.args.FRAME.args.SKILLGAIN = {
    name = "Skill Gain",
    desc = "Skill Gain Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 204,
    get = function(info) return XM.db["SKILLGAIN"] end,
    set = function(info, v) XM.db["SKILLGAIN"] = v end,
}

XM.OPTIONS.args.FRAME.args.EXECUTE = {
    name = "Execute",
    desc = "Popup Warnings (e.g. Execute)",
    type = "range", min = 0, max = 10, step = 1,
    order = 205,
    get = function(info) return XM.db["EXECUTE"] end,
    set = function(info, v) XM.db["EXECUTE"] = v end,
}

XM.OPTIONS.args.FRAME.args.KILLBLOW = {
    name = "Killing Blow",
    desc = "Killing Blow Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 206,
    get = function(info) return XM.db["KILLBLOW"] end,
    set = function(info, v) XM.db["KILLBLOW"] = v end,
}

XM.OPTIONS.args.FRAME.args.REPGAIN = {
    name = "Rep Gain",
    desc = "Reputation Gain Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 207,
    get = function(info) return XM.db["REPGAIN"] end,
    set = function(info, v) XM.db["REPGAIN"] = v end,
}

XM.OPTIONS.args.FRAME.args.XPGAIN = {
    name = "XP Gain",
    desc = "Experience Gain Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 207,
    get = function(info) return XM.db["XPGAIN"] end,
    set = function(info, v) XM.db["XPGAIN"] = v end,
}

XM.OPTIONS.args.FRAME.args.HONORGAIN = {
    name = "Honor Gain",
    desc = "Honor Gain Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 208,
    get = function(info) return XM.db["HONORGAIN"] end,
    set = function(info, v) XM.db["HONORGAIN"] = v end,
}

XM.OPTIONS.args.FRAME.args.POWERGAIN = {
    name = "Power Gain",
    desc = "Power Gain Messages (mana/rage/energy)",
    type = "range", min = 0, max = 10, step = 1,
    order = 209,
    get = function(info) return XM.db["POWERGAIN"] end,
    set = function(info, v) XM.db["POWERGAIN"] = v end,
}

XM.OPTIONS.args.FRAME.args.COMBOPT = {
    name = "Combo Point",
    desc = "Combo Point Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 210,
    get = function(info) return XM.db["COMBOPT"] end,
    set = function(info, v) XM.db["COMBOPT"] = v end,
}

XM.OPTIONS.args.FRAME.args.GETLOOT = {
    name = "Loot",
    desc = "Loot Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 210,
    get = function(info) return XM.db["GETLOOT"] end,
    set = function(info, v) XM.db["GETLOOT"] = v end,
}

XM.OPTIONS.args.FRAME.args.HITINC = {
    name = "Incoming Hits",
    desc = "Incoming Melee Damage",
    type = "range", min = 0, max = 10, step = 1,
    order = 211,
    get = function(info) return XM.db["HITINC"] end,
    set = function(info, v) XM.db["HITINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.HITOUT = {
    name = "Outgoing Hits",
    desc = "Outgoing Melee Damage",
    type = "range", min = 0, max = 10, step = 1,
    order = 212,
    get = function(info) return XM.db["HITOUT"] end,
    set = function(info, v) XM.db["HITOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.SPELLINC = {
    name = "Incoming Spells",
    desc = "Incoming Spell Damage",
    type = "range", min = 0, max = 10, step = 1,
    order = 213,
    get = function(info) return XM.db["SPELLINC"] end,
    set = function(info, v) XM.db["SPELLINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.SPELLOUT = {
    name = "Outgoing Spells",
    desc = "Outgoing Spell Damage",
    type = "range", min = 0, max = 10, step = 1,
    order = 214,
    get = function(info) return XM.db["SPELLOUT"] end,
    set = function(info, v) XM.db["SPELLOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.DOTINC = {
    name = "Incoming DoT",
    desc = "Incoming Damage over Time",
    type = "range", min = 0, max = 10, step = 1,
    order = 215,
    get = function(info) return XM.db["DOTINC"] end,
    set = function(info, v) XM.db["DOTINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.DOTOUT = {
    name = "Outgoing DoT",
    desc = "Outgoing Damage over Time",
    type = "range", min = 0, max = 10, step = 1,
    order = 216,
    get = function(info) return XM.db["DOTOUT"] end,
    set = function(info, v) XM.db["DOTOUT"] = v end,
}
XM.OPTIONS.args.FRAME.args.DMGSHIELDINC = {
    name = "Incoming Damage Shield",
    desc = "Incoming Damage Shield Damage",
    type = "range", min = 0, max = 10, step = 1,
    order = 217,
    get = function(info) return XM.db["DMGSHIELDINC"] end,
    set = function(info, v) XM.db["DMGSHIELDINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.DMGSHIELDOUT = {
    name = "Outgoing Damage Shield",
    desc = "Outgoing Damage Shield Damage",
    type = "range", min = 0, max = 10, step = 1,
    order = 218,
    get = function(info) return XM.db["DMGSHIELDOUT"] end,
    set = function(info, v) XM.db["DMGSHIELDOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.HEALINC = {
    name = "Incoming Heals",
    desc = "Incoming Heal Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 219,
    get = function(info) return XM.db["HEALINC"] end,
    set = function(info, v) XM.db["HEALINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.HEALOUT = {
    name = "Outgoing Heals",
    desc = "Outgoing Heal Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 220,
    get = function(info) return XM.db["HEALOUT"] end,
    set = function(info, v) XM.db["HEALOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.MISSINC = {
    name = "Incoming Miss",
    desc = "Incoming Miss Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 221,
    get = function(info) return XM.db["MISSINC"] end,
    set = function(info, v) XM.db["MISSINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.MISSOUT = {
    name = "Outgoing Miss",
    desc = "Outgoing Miss Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 222,
    get = function(info) return XM.db["MISSOUT"] end,
    set = function(info, v) XM.db["MISSOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.DODGEINC = {
    name = "Incoming Dodge",
    desc = "Incoming Dodge Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 223,
    get = function(info) return XM.db["DODGEINC"] end,
    set = function(info, v) XM.db["DODGEINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.DODGEOUT = {
    name = "Outgoing Dodge",
    desc = "Outgoing Dodge Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 224,
    get = function(info) return XM.db["DODGEOUT"] end,
    set = function(info, v) XM.db["DODGEOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.BLOCKINC = {
    name = "Incoming Block",
    desc = "Incoming Block Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 225,
    get = function(info) return XM.db["BLOCKINC"] end,
    set = function(info, v) XM.db["BLOCKINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.BLOCKOUT = {
    name = "Outgoing Block",
    desc = "Outgoing Block Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 226,
    get = function(info) return XM.db["BLOCKOUT"] end,
    set = function(info, v) XM.db["BLOCKOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.DEFLECTINC = {
    name = "Incoming Deflect",
    desc = "Incoming Deflect Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 227,
    get = function(info) return XM.db["DEFLECTINC"] end,
    set = function(info, v) XM.db["DEFLECTINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.DEFLECTOUT = {
    name = "Outgoing Deflect",
    desc = "Outgoing Deflect Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 228,
    get = function(info) return XM.db["DEFLECTOUT"] end,
    set = function(info, v) XM.db["DEFLECTOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.IMMUNEINC = {
    name = "Incoming Immune",
    desc = "Incoming Immune Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 229,
    get = function(info) return XM.db["IMMUNEINC"] end,
    set = function(info, v) XM.db["IMMUNEINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.IMMUNEOUT = {
    name = "Outgoing Immune",
    desc = "Outgoing Immune Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 230,
    get = function(info) return XM.db["IMMUNEOUT"] end,
    set = function(info, v) XM.db["IMMUNEOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.EVADEINC = {
    name = "Incoming Evade",
    desc = "Incoming Evade Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 231,
    get = function(info) return XM.db["EVADEINC"] end,
    set = function(info, v) XM.db["EVADEINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.EVADEOUT = {
    name = "Outgoing Evade",
    desc = "Outgoing Evade Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 232,
    get = function(info) return XM.db["EVADEOUT"] end,
    set = function(info, v) XM.db["EVADEOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.PARRYINC = {
    name = "Incoming Parry",
    desc = "Incoming Parry Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 233,
    get = function(info) return XM.db["PARRYINC"] end,
    set = function(info, v) XM.db["PARRYINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.PARRYOUT = {
    name = "Outgoing Parry",
    desc = "Outgoing Parry Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 234,
    get = function(info) return XM.db["PARRYOUT"] end,
    set = function(info, v) XM.db["PARRYOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.RESISTINC = {
    name = "Incoming Resist",
    desc = "Incoming Resist Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 235,
    get = function(info) return XM.db["RESISTINC"] end,
    set = function(info, v) XM.db["RESISTINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.RESISTOUT = {
    name = "Outgoing Resist",
    desc = "Outgoing Resist Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 236,
    get = function(info) return XM.db["RESISTOUT"] end,
    set = function(info, v) XM.db["RESISTOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.ABSORBINC = {
    name = "Incoming Absorb",
    desc = "Incoming Absorb Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 237,
    get = function(info) return XM.db["ABSORBINC"] end,
    set = function(info, v) XM.db["ABSORBINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.ABSORBOUT = {
    name = "Outgoing Absorb",
    desc = "Outgoing Absorb Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 238,
    get = function(info) return XM.db["ABSORBOUT"] end,
    set = function(info, v) XM.db["ABSORBOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.REFLECTINC = {
    name = "Incoming Reflect",
    desc = "Incoming Reflect Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 239,
    get = function(info) return XM.db["REFLECTINC"] end,
    set = function(info, v) XM.db["REFLECTINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.REFLECTOUT = {
    name = "Outgoing Reflect",
    desc = "Outgoing Reflect Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 240,
    get = function(info) return XM.db["REFLECTOUT"] end,
    set = function(info, v) XM.db["REFLECTOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.INTERRUPTINC = {
    name = "Incoming Interrrupts",
    desc = "Incoming Interrupt Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 241,
    get = function(info) return XM.db["INTERRUPTINC"] end,
    set = function(info, v) XM.db["INTERRUPTINC"] = v end,
}

XM.OPTIONS.args.FRAME.args.INTERRUPTOUT = {
    name = "Outgoing Interrupts",
    desc = "Outgoing Interrupt Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 242,
    get = function(info) return XM.db["INTERRUPTOUT"] end,
    set = function(info, v) XM.db["INTERRUPTOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.PETHITOUT = {
    name = "Outgoing Pet Hits",
    desc = "Outgoing Pet Melee Damage",
    type = "range", min = 0, max = 10, step = 1,
    order = 243,
    get = function(info) return XM.db["PETHITOUTOUT"] end,
    set = function(info, v) XM.db["PETHITOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.PETDOTOUT = {
    name = "Outgoing Pet DoT",
    desc = "Outgoing Pet Damage over Time",
    type = "range", min = 0, max = 10, step = 1,
    order = 244,
    get = function(info) return XM.db["PETDOTOUT"] end,
    set = function(info, v) XM.db["PETDOTOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.PETSPELLOUT = {
    name = "Outgoing Pet Spells",
    desc = "Outgoing Pet Spell Damage",
    type = "range", min = 0, max = 10, step = 1,
    order = 245,
    get = function(info) return XM.db["PETDOTOUT"] end,
    set = function(info, v) XM.db["PETDOTOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.PETMISSOUT = {
    name = "Outgoing Pet Miss",
    desc = "Outgoing Pet Miss Events",
    type = "range", min = 0, max = 10, step = 1,
    order = 246,
    get = function(info) return XM.db["PETMISSOUT"] end,
    set = function(info, v) XM.db["PETMISSOUT"] = v end,
}

XM.OPTIONS.args.FRAME.args.BUFFGAIN = {
    name = "Buff Gain",
    desc = "Buff Gain Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 247,
    get = function(info) return XM.db["BUFFGAIN"] end,
    set = function(info, v) XM.db["BUFFGAIN"] = v end,
}

XM.OPTIONS.args.FRAME.args.BUFFFADE = {
    name = "Buff Fade",
    desc = "Buff Fade Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 248,
    get = function(info) return XM.db["BUFFFADE"] end,
    set = function(info, v) XM.db["BUFFFADE"] = v end,
}

XM.OPTIONS.args.FRAME.args.DEBUFFGAIN = {
    name = "Debuff Gain",
    desc = "Debuff Gain Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 249,
    get = function(info) return XM.db["DEBUFFGAIN"] end,
    set = function(info, v) XM.db["DEBUFFGAIN"] = v end,
}

XM.OPTIONS.args.FRAME.args.DEBUFFFADE = {
    name = "Debuff Fade",
    desc = "Debuff Fade Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 250,
    get = function(info) return XM.db["DEBUFFFADE"] end,
    set = function(info, v) XM.db["DEBUFFFADE"] = v end,
}

XM.OPTIONS.args.FRAME.args.SPELLACTIVE = {
    name = "Spell Activation",
    desc = "Spell Activation Messages",
    type = "range", min = 0, max = 10, step = 1,
    order = 251,
    get = function(info) return XM.db["SPELLACTIVE"] end,
    set = function(info, v) XM.db["SPELLACTIVE"] = v end,
}

XM.OPTIONS.args.SHOWSKILL = {
    name = "Skill Names",
    desc = "Skill Names",
    type = "group",
    order = 300,
    args = {}
}

XM.OPTIONS.args.SHOWSKILL.args.SPELLINC = {
    name = "Incoming Spells",
    desc = "Incoming Spell Names",
    type = "select", values = ShowName,
    order = 301,
    get = function(info) return XM.db.SHOWSKILL["SPELLINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["SPELLINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.SPELLOUT = {
    name = "Outgoing Spells",
    desc = "Outgoing Spell Names",
    type = "select", values = ShowName,
    order = 302,
    get = function(info) return XM.db.SHOWSKILL["SPELLOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["SPELLOUT"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.DOTINC = {
    name = "Incoming DoT",
    desc = "Incoming DoT Names",
    type = "select", values = ShowName,
    order = 303,
    get = function(info) return XM.db.SHOWSKILL["DOTINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["DOTINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.DOTOUT = {
    name = "Outgoing DoT",
    desc = "Outgoing DoT Names",
    type = "select", values = ShowName,
    order = 304,
    get = function(info) return XM.db.SHOWSKILL["DOTOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["DOTOUT"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.DMGSHIELDINC = {
    name = "Incoming Damage Shield",
    desc = "Incoming Damage Shield Names",
    type = "select", values = ShowName,
    order = 305,
    get = function(info) return XM.db.SHOWSKILL["DMGSHIELDINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["DMGSHIELDINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.DMGSHIELDOUT = {
    name = "Outgoing Damage Shield",
    desc = "Outgoing Damage Shield Names",
    type = "select", values = ShowName,
    order = 306,
    get = function(info) return XM.db.SHOWSKILL["DMGSHIELDOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["DMGSHIELDOUT"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.HEALINC = {
    name = "Incoming Heals",
    desc = "Incoming Heal Names",
    type = "select", values = ShowName,
    order = 307,
    get = function(info) return XM.db.SHOWSKILL["HEALINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["HEALINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.HEALOUT = {
    name = "Outgoing Heals",
    desc = "Outgoing Heal Names",
    type = "select", values = ShowName,
    order = 308,
    get = function(info) return XM.db.SHOWSKILL["HEALOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["HEALOUT"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.MISSINC = {
    name = "Incoming Miss",
    desc = "Incoming Miss Names",
    type = "select", values = ShowName,
    order = 309,
    get = function(info) return XM.db.SHOWSKILL["MISSINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["MISSINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.MISSOUT = {
    name = "Outgoing Miss",
    desc = "Outgoing Miss Names",
    type = "select", values = ShowName,
    order = 310,
    get = function(info) return XM.db.SHOWSKILL["MISSOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["MISSOUT"] = v end,
}
XM.OPTIONS.args.SHOWSKILL.args.DODGEINC = {
    name = "Incoming Dodge",
    desc = "Incoming Dodge Names",
    type = "select", values = ShowName,
    order = 311,
    get = function(info) return XM.db.SHOWSKILL["DODGEINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["DODGEINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.DODGEOUT = {
    name = "Outgoing Dodge",
    desc = "Outgoing Dodge Names",
    type = "select", values = ShowName,
    order = 312,
    get = function(info) return XM.db.SHOWSKILL["DODGEOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["DODGEOUT"] = v end,
}
XM.OPTIONS.args.SHOWSKILL.args.BLOCKINC = {
    name = "Incoming Block",
    desc = "Incoming Block Names",
    type = "select", values = ShowName,
    order = 313,
    get = function(info) return XM.db.SHOWSKILL["BLOCKINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["BLOCKINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.BLOCKOUT = {
    name = "Outgoing Block",
    desc = "Outgoing Block Names",
    type = "select", values = ShowName,
    order = 314,
    get = function(info) return XM.db.SHOWSKILL["BLOCKOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["BLOCKOUT"] = v end,
}
XM.OPTIONS.args.SHOWSKILL.args.DEFLECTINC = {
    name = "Incoming Deflect",
    desc = "Incoming Deflect Names",
    type = "select", values = ShowName,
    order = 315,
    get = function(info) return XM.db.SHOWSKILL["DEFLECTINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["DEFLECTINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.DEFLECTOUT = {
    name = "Outgoing Deflect",
    desc = "Outgoing Deflect Names",
    type = "select", values = ShowName,
    order = 316,
    get = function(info) return XM.db.SHOWSKILL["DEFLECTOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["DEFLECTOUT"] = v end,
}
XM.OPTIONS.args.SHOWSKILL.args.IMMUNEINC = {
    name = "Incoming Immune",
    desc = "Incoming Immune Names",
    type = "select", values = ShowName,
    order = 317,
    get = function(info) return XM.db.SHOWSKILL["IMMUNEINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["IMMUNEINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.IMMUNEOUT = {
    name = "Outgoing Immune",
    desc = "Outgoing Immune Names",
    type = "select", values = ShowName,
    order = 318,
    get = function(info) return XM.db.SHOWSKILL["IMMUNEOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["IMMUNEOUT"] = v end,
}
XM.OPTIONS.args.SHOWSKILL.args.EVADEINC = {
    name = "Incoming Evade",
    desc = "Incoming Evade Names",
    type = "select", values = ShowName,
    order = 319,
    get = function(info) return XM.db.SHOWSKILL["EVADEINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["EVADEINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.EVADEOUT = {
    name = "Outgoing Evade",
    desc = "Outgoing Evade Names",
    type = "select", values = ShowName,
    order = 320,
    get = function(info) return XM.db.SHOWSKILL["EVADEOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["EVADEOUT"] = v end,
}
XM.OPTIONS.args.SHOWSKILL.args.PARRYINC = {
    name = "Incoming Parry",
    desc = "Incoming Parry Names",
    type = "select", values = ShowName,
    order = 321,
    get = function(info) return XM.db.SHOWSKILL["PARRYINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["PARRYINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.PARRYOUT = {
    name = "Outgoing Parry",
    desc = "Outgoing Parry Names",
    type = "select", values = ShowName,
    order = 322,
    get = function(info) return XM.db.SHOWSKILL["PARRYOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["PARRYOUT"] = v end,
}
XM.OPTIONS.args.SHOWSKILL.args.RESISTINC = {
    name = "Incoming Resist",
    desc = "Incoming Resist Names",
    type = "select", values = ShowName,
    order = 323,
    get = function(info) return XM.db.SHOWSKILL["RESISTINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["RESISTINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.RESISTOUT = {
    name = "Outgoing Resist",
    desc = "Outgoing Resist Names",
    type = "select", values = ShowName,
    order = 324,
    get = function(info) return XM.db.SHOWSKILL["RESISTOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["RESISTOUT"] = v end,
}
XM.OPTIONS.args.SHOWSKILL.args.ABSORBINC = {
    name = "Incoming Absorb",
    desc = "Incoming Absorb Names",
    type = "select", values = ShowName,
    order = 325,
    get = function(info) return XM.db.SHOWSKILL["ABSORBINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["ABSORBINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.ABSORBOUT = {
    name = "Outgoing Absorb",
    desc = "Outgoing Absorb Names",
    type = "select", values = ShowName,
    order = 326,
    get = function(info) return XM.db.SHOWSKILL["ABSORBOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["ABSORBOUT"] = v end,
}
XM.OPTIONS.args.SHOWSKILL.args.REFLECTINC = {
    name = "Incoming Reflect",
    desc = "Incoming Reflect Names",
    type = "select", values = ShowName,
    order = 327,
    get = function(info) return XM.db.SHOWSKILL["REFLECTINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["REFLECTINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.REFLECTOUT = {
    name = "Outgoing Reflect",
    desc = "Outgoing Reflect Names",
    type = "select", values = ShowName,
    order = 328,
    get = function(info) return XM.db.SHOWSKILL["REFLECTOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["REFLECTOUT"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.INTERRUPTINC = {
    name = "Incoming Interrupts",
    desc = "Incoming Interrupt Names",
    type = "select", values = ShowName,
    order = 329,
    get = function(info) return XM.db.SHOWSKILL["INTERRUPTINC"] end,
    set = function(info, v) XM.db.SHOWSKILL["INTERRUPTINC"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.INTERRUPTOUT = {
    name = "Outgoing Interrupts",
    desc = "Outgoing Interrupt Names",
    type = "select", values = ShowName,
    order = 330,
    get = function(info) return XM.db.SHOWSKILL["INTERRUPTOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["INTERRUPTOUT"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.PETSPELLOUT = {
    name = "Outgoing Pet Spell",
    desc = "Outgoing Pet Spell Names",
    type = "select", values = ShowName,
    order = 331,
    get = function(info) return XM.db.SHOWSKILL["PETSPELLOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["PETSPELLOUT"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.PETDOTOUT = {
    name = "Outgoing Pet DoT",
    desc = "Outgoing Pet DoT Names",
    type = "select", values = ShowName,
    order = 332,
    get = function(info) return XM.db.SHOWSKILL["PETDOTOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["PETDOTOUT"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.PETMISSOUT = {
    name = "Outgoing Pet Miss",
    desc = "Outgoing Pet Miss Names",
    type = "select", values = ShowName,
    order = 333,
    get = function(info) return XM.db.SHOWSKILL["PETMISSOUT"] end,
    set = function(info, v) XM.db.SHOWSKILL["PETMISSOUT"] = v end,
}

XM.OPTIONS.args.SHOWSKILL.args.SPELLACTIVE = {
    name = "Spell Activation",
    desc = "Spell Activation Names",
    type = "select", values = ShowName,
    order = 334,
    get = function(info) return XM.db.SHOWSKILL["SPELLACTIVE"] end,
    set = function(info, v) XM.db.SHOWSKILL["SPELLACTIVE"] = v end,
}

XM.OPTIONS.args.SHOWELEM = {
    name = "Elemental Flagging",
    desc = "Elemental Flagging",
    type = "group",
    order = 350,
    args = {}
}

XM.OPTIONS.args.SHOWELEM.args.ELEMENT = {
    name = "Element",
    desc = "Elemental Damage Flagging",
    type = "select", values = ShowElem,
    order = 351,
    get = function(info) return XM.db.SHOWSKILL["ELEMENT"] end,
    set = function(info, v) XM.db.SHOWSKILL["ELEMENT"] = v end,
}


XM.OPTIONS.args.SHOWTARG = {
    name = "Source / Target Names",
    desc = "Source / Target Names",
    type = "group",
    order = 400,
    args = {}
}

XM.OPTIONS.args.SHOWTARG.args.HITINC = {
    name = "Incoming Hits",
    desc = "Incoming Melee Names",
    type = "select", values = ShowName,
    order = 401,
    get = function(info) return XM.db.SHOWTARGET["HITINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["HITINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.HITOUT = {
    name = "Outgoing Hits",
    desc = "Outgoing Melee Names",
    type = "select", values = ShowName,
    order = 402,
    get = function(info) return XM.db.SHOWTARGET["HITOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["HITOUT"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.SPELLINC = {
    name = "Incoming Spells",
    desc = "Incoming Spell Names",
    type = "select", values = ShowName,
    order = 403,
    get = function(info) return XM.db.SHOWTARGET["SPELLINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["SPELLINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.SPELLOUT = {
    name = "Outgoing Spells",
    desc = "Outgoing Spell Names",
    type = "select", values = ShowName,
    order = 404,
    get = function(info) return XM.db.SHOWTARGET["SPELLOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["SPELLOUT"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.DOTINC = {
    name = "Incoming DoT",
    desc = "Incoming DoT Names",
    type = "select", values = ShowName,
    order = 405,
    get = function(info) return XM.db.SHOWTARGET["DOTINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["DOTINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.DOTOUT = {
    name = "Outgoing DoT",
    desc = "Outgoing DoT Names",
    type = "select", values = ShowName,
    order = 406,
    get = function(info) return XM.db.SHOWTARGET["DOTOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["DOTOUT"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.DMGSHIELDINC = {
    name = "Incoming Damage Shield",
    desc = "Incoming Damage Shield Names",
    type = "select", values = ShowName,
    order = 407,
    get = function(info) return XM.db.SHOWTARGET["DMGSHIELDINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["DMGSHIELDINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.DMGSHIELDOUT = {
    name = "Outgoing Damage Shield",
    desc = "Outgoing Damage Shield Names",
    type = "select", values = ShowName,
    order = 408,
    get = function(info) return XM.db.SHOWTARGET["DMGSHIELDOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["DMGSHIELDOUT"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.HEALINC = {
    name = "Incoming Heals",
    desc = "Incoming Heal Names",
    type = "select", values = ShowName,
    order = 409,
    get = function(info) return XM.db.SHOWTARGET["HEALINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["HEALINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.HEALOUT = {
    name = "Outgoing Heals",
    desc = "Outgoing Heal Names",
    type = "select", values = ShowName,
    order = 410,
    get = function(info) return XM.db.SHOWTARGET["HEALOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["HEALOUT"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.MISSINC = {
    name = "Incoming Miss",
    desc = "Incoming Miss Names",
    type = "select", values = ShowName,
    order = 411,
    get = function(info) return XM.db.SHOWTARGET["MISSINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["MISSINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.MISSOUT = {
    name = "Outgoing Miss",
    desc = "Outgoing Miss Names",
    type = "select", values = ShowName,
    order = 412,
    get = function(info) return XM.db.SHOWTARGET["MISSOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["MISSOUT"] = v end,
}
XM.OPTIONS.args.SHOWTARG.args.DODGEINC = {
    name = "Incoming Dodge",
    desc = "Incoming Dodge Names",
    type = "select", values = ShowName,
    order = 413,
    get = function(info) return XM.db.SHOWTARGET["DODGEINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["DODGEINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.DODGEOUT = {
    name = "Outgoing Dodge",
    desc = "Outgoing Dodge Names",
    type = "select", values = ShowName,
    order = 414,
    get = function(info) return XM.db.SHOWTARGET["DODGEOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["DODGEOUT"] = v end,
}
XM.OPTIONS.args.SHOWTARG.args.BLOCKINC = {
    name = "Incoming Block",
    desc = "Incoming Block Names",
    type = "select", values = ShowName,
    order = 415,
    get = function(info) return XM.db.SHOWTARGET["BLOCKINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["BLOCKINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.BLOCKOUT = {
    name = "Outgoing Block",
    desc = "Outgoing Block Names",
    type = "select", values = ShowName,
    order = 416,
    get = function(info) return XM.db.SHOWTARGET["BLOCKOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["BLOCKOUT"] = v end,
}
XM.OPTIONS.args.SHOWTARG.args.DEFLECTINC = {
    name = "Incoming Deflect",
    desc = "Incoming Deflect Names",
    type = "select", values = ShowName,
    order = 417,
    get = function(info) return XM.db.SHOWTARGET["DEFLECTINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["DEFLECTINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.DEFLECTOUT = {
    name = "Outgoing Deflect",
    desc = "Outgoing Deflect Names",
    type = "select", values = ShowName,
    order = 418,
    get = function(info) return XM.db.SHOWTARGET["DEFLECTOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["DEFLECTOUT"] = v end,
}
XM.OPTIONS.args.SHOWTARG.args.IMMUNEINC = {
    name = "Incoming Immune",
    desc = "Incoming Immune Names",
    type = "select", values = ShowName,
    order = 419,
    get = function(info) return XM.db.SHOWTARGET["IMMUNEINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["IMMUNEINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.IMMUNEOUT = {
    name = "Outgoing Immune",
    desc = "Outgoing Immune Names",
    type = "select", values = ShowName,
    order = 420,
    get = function(info) return XM.db.SHOWTARGET["IMMUNEOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["IMMUNEOUT"] = v end,
}
XM.OPTIONS.args.SHOWTARG.args.EVADEINC = {
    name = "Incoming Evade",
    desc = "Incoming Evade Names",
    type = "select", values = ShowName,
    order = 421,
    get = function(info) return XM.db.SHOWTARGET["EVADEINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["EVADEINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.EVADEOUT = {
    name = "Outgoing Evade",
    desc = "Outgoing Evade Names",
    type = "select", values = ShowName,
    order = 422,
    get = function(info) return XM.db.SHOWTARGET["EVADEOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["EVADEOUT"] = v end,
}
XM.OPTIONS.args.SHOWTARG.args.PARRYINC = {
    name = "Incoming Parry",
    desc = "Incoming Parry Names",
    type = "select", values = ShowName,
    order = 423,
    get = function(info) return XM.db.SHOWTARGET["PARRYINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["PARRYINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.PARRYOUT = {
    name = "Outgoing Parry",
    desc = "Outgoing Parry Names",
    type = "select", values = ShowName,
    order = 424,
    get = function(info) return XM.db.SHOWTARGET["PARRYOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["PARRYOUT"] = v end,
}
XM.OPTIONS.args.SHOWTARG.args.RESISTINC = {
    name = "Incoming Resist",
    desc = "Incoming Resist Names",
    type = "select", values = ShowName,
    order = 425,
    get = function(info) return XM.db.SHOWTARGET["RESISTINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["RESISTINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.RESISTOUT = {
    name = "Outgoing Resist",
    desc = "Outgoing Resist Names",
    type = "select", values = ShowName,
    order = 426,
    get = function(info) return XM.db.SHOWTARGET["RESISTOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["RESISTOUT"] = v end,
}
XM.OPTIONS.args.SHOWTARG.args.ABSORBINC = {
    name = "Incoming Absorb",
    desc = "Incoming Absorb Names",
    type = "select", values = ShowName,
    order = 427,
    get = function(info) return XM.db.SHOWTARGET["ABSORBINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["ABSORBINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.ABSORBOUT = {
    name = "Outgoing Absorb",
    desc = "Outgoing Absorb Names",
    type = "select", values = ShowName,
    order = 428,
    get = function(info) return XM.db.SHOWTARGET["ABSORBOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["ABSORBOUT"] = v end,
}
XM.OPTIONS.args.SHOWTARG.args.REFLECTINC = {
    name = "Incoming Reflect",
    desc = "Incoming Reflect Names",
    type = "select", values = ShowName,
    order = 429,
    get = function(info) return XM.db.SHOWTARGET["REFLECTINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["REFLECTINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.REFLECTOUT = {
    name = "Outgoing Reflect",
    desc = "Outgoing Reflect Names",
    type = "select", values = ShowName,
    order = 430,
    get = function(info) return XM.db.SHOWTARGET["REFLECTOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["REFLECTOUT"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.INTERRUPTINC = {
    name = "Incoming Interrupts",
    desc = "Incoming Interrupt Names",
    type = "select", values = ShowName,
    order = 431,
    get = function(info) return XM.db.SHOWTARGET["INTERRUPTINC"] end,
    set = function(info, v) XM.db.SHOWTARGET["INTERRUPTINC"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.INTERRUPTOUT = {
    name = "Outgoing Interrupts",
    desc = "Outgoing Interrupt Names",
    type = "select", values = ShowName,
    order = 432,
    get = function(info) return XM.db.SHOWTARGET["INTERRUPTOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["INTERRUPTOUT"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.PETHITOUT = {
    name = "Outgoing Pet Hit",
    desc = "Outgoing Pet Melee Names",
    type = "select", values = ShowName,
    order = 433,
    get = function(info) return XM.db.SHOWTARGET["PETHITOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["PETHITOUT"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.PETSPELLOUT = {
    name = "Outgoing Pet Spell",
    desc = "Outgoing Pet Spell Names",
    type = "select", values = ShowName,
    order = 434,
    get = function(info) return XM.db.SHOWTARGET["PETSPELLOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["PETSPELLOUT"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.PETDOTOUT = {
    name = "Outgoing Pet DoT",
    desc = "Outgoing Pet DoT Names",
    type = "select", values = ShowName,
    order = 435,
    get = function(info) return XM.db.SHOWTARGET["PETDOTOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["PETDOTOUT"] = v end,
}

XM.OPTIONS.args.SHOWTARG.args.PETMISSOUT = {
    name = "Outgoing Pet Miss",
    desc = "Outgoing Pet Miss Names",
    type = "select", values = ShowName,
    order = 436,
    get = function(info) return XM.db.SHOWTARGET["PETMISSOUT"] end,
    set = function(info, v) XM.db.SHOWTARGET["PETMISSOUT"] = v end,
}

XM.OPTIONS.args.COLORS = {
    name = "Event Colors",
    desc = "Event Colors",
    type = "group",
    order = 500,
    args = {}
}

XM.OPTIONS.args.COLORS.args.LOWHP = {
    name = "Low HP",
    desc = "Low HP Warning",
    type = "color",
    order = 501,
    get = function(info)
        local r = XM.db.COLOR_TABLE["LOWHP"].r
        local g = XM.db.COLOR_TABLE["LOWHP"].g
        local b = XM.db.COLOR_TABLE["LOWHP"].b
        local a = XM.db.COLOR_TABLE["LOWHP"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["LOWHP"].r = r
        XM.db.COLOR_TABLE["LOWHP"].g = g
        XM.db.COLOR_TABLE["LOWHP"].b = b
        XM.db.COLOR_TABLE["LOWHP"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.LOWMANA = {
    name = "Low Mana",
    desc = "Low Mana Warning",
    type = "color",
    order = 502,
    get = function(info)
        local r = XM.db.COLOR_TABLE["LOWMANA"].r
        local g = XM.db.COLOR_TABLE["LOWMANA"].g
        local b = XM.db.COLOR_TABLE["LOWMANA"].b
        local a = XM.db.COLOR_TABLE["LOWMANA"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["LOWMANA"].r = r
        XM.db.COLOR_TABLE["LOWMANA"].g = g
        XM.db.COLOR_TABLE["LOWMANA"].b = b
        XM.db.COLOR_TABLE["LOWMANA"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.COMBAT = {
    name = "Combat",
    desc = "Entering/Leaving Combat",
    type = "color",
    order = 503,
    get = function(info)
        local r = XM.db.COLOR_TABLE["COMBAT"].r
        local g = XM.db.COLOR_TABLE["COMBAT"].g
        local b = XM.db.COLOR_TABLE["COMBAT"].b
        local a = XM.db.COLOR_TABLE["COMBAT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["COMBAT"].r = r
        XM.db.COLOR_TABLE["COMBAT"].g = g
        XM.db.COLOR_TABLE["COMBAT"].b = b
        XM.db.COLOR_TABLE["COMBAT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.SKILLGAIN = {
    name = "Skill Gain",
    desc = "Skill Gain Messages",
    type = "color",
    order = 504,
    get = function(info)
        local r = XM.db.COLOR_TABLE["SKILLGAIN"].r
        local g = XM.db.COLOR_TABLE["SKILLGAIN"].g
        local b = XM.db.COLOR_TABLE["SKILLGAIN"].b
        local a = XM.db.COLOR_TABLE["SKILLGAIN"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["SKILLGAIN"].r = r
        XM.db.COLOR_TABLE["SKILLGAIN"].g = g
        XM.db.COLOR_TABLE["SKILLGAIN"].b = b
        XM.db.COLOR_TABLE["SKILLGAIN"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.EXECUTE = {
    name = "Execute",
    desc = "Popup Warnings (e.g. Execute)",
    type = "color",
    order = 505,
    get = function(info)
        local r = XM.db.COLOR_TABLE["EXECUTE"].r
        local g = XM.db.COLOR_TABLE["EXECUTE"].g
        local b = XM.db.COLOR_TABLE["EXECUTE"].b
        local a = XM.db.COLOR_TABLE["EXECUTE"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["EXECUTE"].r = r
        XM.db.COLOR_TABLE["EXECUTE"].g = g
        XM.db.COLOR_TABLE["EXECUTE"].b = b
        XM.db.COLOR_TABLE["EXECUTE"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.KILLBLOW = {
    name = "Killing Blow",
    desc = "Killing Blow Messages",
    type = "color",
    order = 506,
    get = function(info)
        local r = XM.db.COLOR_TABLE["KILLBLOW"].r
        local g = XM.db.COLOR_TABLE["KILLBLOW"].g
        local b = XM.db.COLOR_TABLE["KILLBLOW"].b
        local a = XM.db.COLOR_TABLE["KILLBLOW"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["KILLBLOW"].r = r
        XM.db.COLOR_TABLE["KILLBLOW"].g = g
        XM.db.COLOR_TABLE["KILLBLOW"].b = b
        XM.db.COLOR_TABLE["KILLBLOW"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.REPGAIN = {
    name = "Rep Gain",
    desc = "Reputation Gain Messages",
    type = "color",
    order = 507,
    get = function(info)
        local r = XM.db.COLOR_TABLE["REPGAIN"].r
        local g = XM.db.COLOR_TABLE["REPGAIN"].g
        local b = XM.db.COLOR_TABLE["REPGAIN"].b
        local a = XM.db.COLOR_TABLE["REPGAIN"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["REPGAIN"].r = r
        XM.db.COLOR_TABLE["REPGAIN"].g = g
        XM.db.COLOR_TABLE["REPGAIN"].b = b
        XM.db.COLOR_TABLE["REPGAIN"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.XPGAIN = {
    name = "XP Gain",
    desc = "Experience Gain Messages",
    type = "color",
    order = 507,
    get = function(info)
        local r = XM.db.COLOR_TABLE["XPGAIN"].r
        local g = XM.db.COLOR_TABLE["XPGAIN"].g
        local b = XM.db.COLOR_TABLE["XPGAIN"].b
        local a = XM.db.COLOR_TABLE["XPGAIN"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["XPGAIN"].r = r
        XM.db.COLOR_TABLE["XPGAIN"].g = g
        XM.db.COLOR_TABLE["XPGAIN"].b = b
        XM.db.COLOR_TABLE["XPGAIN"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.HONORGAIN = {
    name = "Honor Gain",
    desc = "Honor Gain Messages",
    type = "color",
    order = 508,
    get = function(info)
        local r = XM.db.COLOR_TABLE["HONORGAIN"].r
        local g = XM.db.COLOR_TABLE["HONORGAIN"].g
        local b = XM.db.COLOR_TABLE["HONORGAIN"].b
        local a = XM.db.COLOR_TABLE["HONORGAIN"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["HONORGAIN"].r = r
        XM.db.COLOR_TABLE["HONORGAIN"].g = g
        XM.db.COLOR_TABLE["HONORGAIN"].b = b
        XM.db.COLOR_TABLE["HONORGAIN"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.POWERGAIN = {
    name = "Power Gain",
    desc = "Power Gain Messages (mana/rage/energy)",
    type = "color",
    order = 509,
    get = function(info)
        local r = XM.db.COLOR_TABLE["POWERGAIN"].r
        local g = XM.db.COLOR_TABLE["POWERGAIN"].g
        local b = XM.db.COLOR_TABLE["POWERGAIN"].b
        local a = XM.db.COLOR_TABLE["POWERGAIN"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["POWERGAIN"].r = r
        XM.db.COLOR_TABLE["POWERGAIN"].g = g
        XM.db.COLOR_TABLE["POWERGAIN"].b = b
        XM.db.COLOR_TABLE["POWERGAIN"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.COMBOPT = {
    name = "Combo Point",
    desc = "Combo Point Messages",
    type = "color",
    order = 510,
    get = function(info)
        local r = XM.db.COLOR_TABLE["COMBOPT"].r
        local g = XM.db.COLOR_TABLE["COMBOPT"].g
        local b = XM.db.COLOR_TABLE["COMBOPT"].b
        local a = XM.db.COLOR_TABLE["COMBOPT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["COMBOPT"].r = r
        XM.db.COLOR_TABLE["COMBOPT"].g = g
        XM.db.COLOR_TABLE["COMBOPT"].b = b
        XM.db.COLOR_TABLE["COMBOPT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.GETLOOT = {
    name = "Loot",
    desc = "Loot Messages",
    type = "color",
    order = 510,
    get = function(info)
        local r = XM.db.COLOR_TABLE["GETLOOT"].r
        local g = XM.db.COLOR_TABLE["GETLOOT"].g
        local b = XM.db.COLOR_TABLE["GETLOOT"].b
        local a = XM.db.COLOR_TABLE["GETLOOT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["GETLOOT"].r = r
        XM.db.COLOR_TABLE["GETLOOT"].g = g
        XM.db.COLOR_TABLE["GETLOOT"].b = b
        XM.db.COLOR_TABLE["GETLOOT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.HITINC = {
    name = "Incoming Hits",
    desc = "Incoming Melee Damage",
    type = "color",
    order = 511,
    get = function(info)
        local r = XM.db.COLOR_TABLE["HITINC"].r
        local g = XM.db.COLOR_TABLE["HITINC"].g
        local b = XM.db.COLOR_TABLE["HITINC"].b
        local a = XM.db.COLOR_TABLE["HITINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["HITINC"].r = r
        XM.db.COLOR_TABLE["HITINC"].g = g
        XM.db.COLOR_TABLE["HITINC"].b = b
        XM.db.COLOR_TABLE["HITINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.HITOUT = {
    name = "Outgoing Hits",
    desc = "Outgoing Melee Damage",
    type = "color",
    order = 512,
    get = function(info)
        local r = XM.db.COLOR_TABLE["HITOUT"].r
        local g = XM.db.COLOR_TABLE["HITOUT"].g
        local b = XM.db.COLOR_TABLE["HITOUT"].b
        local a = XM.db.COLOR_TABLE["HITOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["HITOUT"].r = r
        XM.db.COLOR_TABLE["HITOUT"].g = g
        XM.db.COLOR_TABLE["HITOUT"].b = b
        XM.db.COLOR_TABLE["HITOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.SPELLINC = {
    name = "Incoming Spells",
    desc = "Incoming Spell Damage",
    type = "color",
    order = 513,
    get = function(info)
        local r = XM.db.COLOR_TABLE["SPELLINC"].r
        local g = XM.db.COLOR_TABLE["SPELLINC"].g
        local b = XM.db.COLOR_TABLE["SPELLINC"].b
        local a = XM.db.COLOR_TABLE["SPELLINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["SPELLINC"].r = r
        XM.db.COLOR_TABLE["SPELLINC"].g = g
        XM.db.COLOR_TABLE["SPELLINC"].b = b
        XM.db.COLOR_TABLE["SPELLINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.SPELLOUT = {
    name = "Outgoing Spells",
    desc = "Outgoing Spell Damage",
    type = "color",
    order = 514,
    get = function(info)
        local r = XM.db.COLOR_TABLE["SPELLOUT"].r
        local g = XM.db.COLOR_TABLE["SPELLOUT"].g
        local b = XM.db.COLOR_TABLE["SPELLOUT"].b
        local a = XM.db.COLOR_TABLE["SPELLOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["SPELLOUT"].r = r
        XM.db.COLOR_TABLE["SPELLOUT"].g = g
        XM.db.COLOR_TABLE["SPELLOUT"].b = b
        XM.db.COLOR_TABLE["SPELLOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.DOTINC = {
    name = "Incoming DoT",
    desc = "Incoming Damage over Time",
    type = "color",
    order = 515,
    get = function(info)
        local r = XM.db.COLOR_TABLE["DOTINC"].r
        local g = XM.db.COLOR_TABLE["DOTINC"].g
        local b = XM.db.COLOR_TABLE["DOTINC"].b
        local a = XM.db.COLOR_TABLE["DOTINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["DOTINC"].r = r
        XM.db.COLOR_TABLE["DOTINC"].g = g
        XM.db.COLOR_TABLE["DOTINC"].b = b
        XM.db.COLOR_TABLE["DOTINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.DOTOUT = {
    name = "Outgoing DoT",
    desc = "Outgoing Damage over Time",
    type = "color",
    order = 516,
    get = function(info)
        local r = XM.db.COLOR_TABLE["DOTOUT"].r
        local g = XM.db.COLOR_TABLE["DOTOUT"].g
        local b = XM.db.COLOR_TABLE["DOTOUT"].b
        local a = XM.db.COLOR_TABLE["DOTOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["DOTOUT"].r = r
        XM.db.COLOR_TABLE["DOTOUT"].g = g
        XM.db.COLOR_TABLE["DOTOUT"].b = b
        XM.db.COLOR_TABLE["DOTOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.DMGSHIELDINC = {
    name = "Incoming Damage Shield",
    desc = "Incoming Damage Shield Damage",
    type = "color",
    order = 517,
    get = function(info)
        local r = XM.db.COLOR_TABLE["DMGSHIELDINC"].r
        local g = XM.db.COLOR_TABLE["DMGSHIELDINC"].g
        local b = XM.db.COLOR_TABLE["DMGSHIELDINC"].b
        local a = XM.db.COLOR_TABLE["DMGSHIELDINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["DMGSHIELDINC"].r = r
        XM.db.COLOR_TABLE["DMGSHIELDINC"].g = g
        XM.db.COLOR_TABLE["DMGSHIELDINC"].b = b
        XM.db.COLOR_TABLE["DMGSHIELDINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.DMGSHIELDOUT = {
    name = "Outgoing Damage Shield",
    desc = "Outgoing Damage Shield Damage",
    type = "color",
    order = 518,
    get = function(info)
        local r = XM.db.COLOR_TABLE["DMGSHIELDOUT"].r
        local g = XM.db.COLOR_TABLE["DMGSHIELDOUT"].g
        local b = XM.db.COLOR_TABLE["DMGSHIELDOUT"].b
        local a = XM.db.COLOR_TABLE["DMGSHIELDOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["DMGSHIELDOUT"].r = r
        XM.db.COLOR_TABLE["DMGSHIELDOUT"].g = g
        XM.db.COLOR_TABLE["DMGSHIELDOUT"].b = b
        XM.db.COLOR_TABLE["DMGSHIELDOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.HEALINC = {
    name = "Incoming Heals",
    desc = "Incoming Heal Events",
    type = "color",
    order = 519,
    get = function(info)
        local r = XM.db.COLOR_TABLE["HEALINC"].r
        local g = XM.db.COLOR_TABLE["HEALINC"].g
        local b = XM.db.COLOR_TABLE["HEALINC"].b
        local a = XM.db.COLOR_TABLE["HEALINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["HEALINC"].r = r
        XM.db.COLOR_TABLE["HEALINC"].g = g
        XM.db.COLOR_TABLE["HEALINC"].b = b
        XM.db.COLOR_TABLE["HEALINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.HEALOUT = {
    name = "Outgoing Heals",
    desc = "Outgoing Heal Events",
    type = "color",
    order = 520,
    get = function(info)
        local r = XM.db.COLOR_TABLE["HEALOUT"].r
        local g = XM.db.COLOR_TABLE["HEALOUT"].g
        local b = XM.db.COLOR_TABLE["HEALOUT"].b
        local a = XM.db.COLOR_TABLE["HEALOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["HEALOUT"].r = r
        XM.db.COLOR_TABLE["HEALOUT"].g = g
        XM.db.COLOR_TABLE["HEALOUT"].b = b
        XM.db.COLOR_TABLE["HEALOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.MISSINC = {
    name = "Incoming Miss",
    desc = "Incoming Miss Events",
    type = "color",
    order = 521,
    get = function(info)
        local r = XM.db.COLOR_TABLE["MISSINC"].r
        local g = XM.db.COLOR_TABLE["MISSINC"].g
        local b = XM.db.COLOR_TABLE["MISSINC"].b
        local a = XM.db.COLOR_TABLE["MISSINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["MISSINC"].r = r
        XM.db.COLOR_TABLE["MISSINC"].g = g
        XM.db.COLOR_TABLE["MISSINC"].b = b
        XM.db.COLOR_TABLE["MISSINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.MISSOUT = {
    name = "Outgoing Miss",
    desc = "Outgoing Miss Events",
    type = "color",
    order = 522,
    get = function(info)
        local r = XM.db.COLOR_TABLE["MISSOUT"].r
        local g = XM.db.COLOR_TABLE["MISSOUT"].g
        local b = XM.db.COLOR_TABLE["MISSOUT"].b
        local a = XM.db.COLOR_TABLE["MISSOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["MISSOUT"].r = r
        XM.db.COLOR_TABLE["MISSOUT"].g = g
        XM.db.COLOR_TABLE["MISSOUT"].b = b
        XM.db.COLOR_TABLE["MISSOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.DODGEINC = {
    name = "Incoming Dodge",
    desc = "Incoming Dodge Events",
    type = "color",
    order = 523,
    get = function(info)
        local r = XM.db.COLOR_TABLE["DODGEINC"].r
        local g = XM.db.COLOR_TABLE["DODGEINC"].g
        local b = XM.db.COLOR_TABLE["DODGEINC"].b
        local a = XM.db.COLOR_TABLE["DODGEINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["DODGEINC"].r = r
        XM.db.COLOR_TABLE["DODGEINC"].g = g
        XM.db.COLOR_TABLE["DODGEINC"].b = b
        XM.db.COLOR_TABLE["DODGEINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.DODGEOUT = {
    name = "Outgoing Dodge",
    desc = "Outgoing Dodge Events",
    type = "color",
    order = 524,
    get = function(info)
        local r = XM.db.COLOR_TABLE["DODGEOUT"].r
        local g = XM.db.COLOR_TABLE["DODGEOUT"].g
        local b = XM.db.COLOR_TABLE["DODGEOUT"].b
        local a = XM.db.COLOR_TABLE["DODGEOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["DODGEOUT"].r = r
        XM.db.COLOR_TABLE["DODGEOUT"].g = g
        XM.db.COLOR_TABLE["DODGEOUT"].b = b
        XM.db.COLOR_TABLE["DODGEOUT"].a = a
    end,
}
XM.OPTIONS.args.COLORS.args.BLOCKINC = {
    name = "Incoming Block",
    desc = "Incoming Block Events",
    type = "color",
    order = 525,
    get = function(info)
        local r = XM.db.COLOR_TABLE["BLOCKINC"].r
        local g = XM.db.COLOR_TABLE["BLOCKINC"].g
        local b = XM.db.COLOR_TABLE["BLOCKINC"].b
        local a = XM.db.COLOR_TABLE["BLOCKINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["BLOCKINC"].r = r
        XM.db.COLOR_TABLE["BLOCKINC"].g = g
        XM.db.COLOR_TABLE["BLOCKINC"].b = b
        XM.db.COLOR_TABLE["BLOCKINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.BLOCKOUT = {
    name = "Outgoing Block",
    desc = "Outgoing Block Events",
    type = "color",
    order = 526,
    get = function(info)
        local r = XM.db.COLOR_TABLE["BLOCKOUT"].r
        local g = XM.db.COLOR_TABLE["BLOCKOUT"].g
        local b = XM.db.COLOR_TABLE["BLOCKOUT"].b
        local a = XM.db.COLOR_TABLE["BLOCKOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["BLOCKOUT"].r = r
        XM.db.COLOR_TABLE["BLOCKOUT"].g = g
        XM.db.COLOR_TABLE["BLOCKOUT"].b = b
        XM.db.COLOR_TABLE["BLOCKOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.DEFLECTINC = {
    name = "Incoming Deflect",
    desc = "Incoming Deflect Events",
    type = "color",
    order = 527,
    get = function(info)
        local r = XM.db.COLOR_TABLE["DEFLECTINC"].r
        local g = XM.db.COLOR_TABLE["DEFLECTINC"].g
        local b = XM.db.COLOR_TABLE["DEFLECTINC"].b
        local a = XM.db.COLOR_TABLE["DEFLECTINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["DEFLECTINC"].r = r
        XM.db.COLOR_TABLE["DEFLECTINC"].g = g
        XM.db.COLOR_TABLE["DEFLECTINC"].b = b
        XM.db.COLOR_TABLE["DEFLECTINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.DEFLECTOUT = {
    name = "Outgoing Deflect",
    desc = "Outgoing Deflect Events",
    type = "color",
    order = 528,
    get = function(info)
        local r = XM.db.COLOR_TABLE["DEFLECTOUT"].r
        local g = XM.db.COLOR_TABLE["DEFLECTOUT"].g
        local b = XM.db.COLOR_TABLE["DEFLECTOUT"].b
        local a = XM.db.COLOR_TABLE["DEFLECTOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["DEFLECTOUT"].r = r
        XM.db.COLOR_TABLE["DEFLECTOUT"].g = g
        XM.db.COLOR_TABLE["DEFLECTOUT"].b = b
        XM.db.COLOR_TABLE["DEFLECTOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.IMMUNEINC = {
    name = "Incoming Immune",
    desc = "Incoming Immune Events",
    type = "color",
    order = 529,
    get = function(info)
        local r = XM.db.COLOR_TABLE["IMMUNEINC"].r
        local g = XM.db.COLOR_TABLE["IMMUNEINC"].g
        local b = XM.db.COLOR_TABLE["IMMUNEINC"].b
        local a = XM.db.COLOR_TABLE["IMMUNEINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["IMMUNEINC"].r = r
        XM.db.COLOR_TABLE["IMMUNEINC"].g = g
        XM.db.COLOR_TABLE["IMMUNEINC"].b = b
        XM.db.COLOR_TABLE["IMMUNEINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.IMMUNEOUT = {
    name = "Outgoing Immune",
    desc = "Outgoing Immune Events",
    type = "color",
    order = 530,
    get = function(info)
        local r = XM.db.COLOR_TABLE["IMMUNEOUT"].r
        local g = XM.db.COLOR_TABLE["IMMUNEOUT"].g
        local b = XM.db.COLOR_TABLE["IMMUNEOUT"].b
        local a = XM.db.COLOR_TABLE["IMMUNEOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["IMMUNEOUT"].r = r
        XM.db.COLOR_TABLE["IMMUNEOUT"].g = g
        XM.db.COLOR_TABLE["IMMUNEOUT"].b = b
        XM.db.COLOR_TABLE["IMMUNEOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.EVADEINC = {
    name = "Incoming Evade",
    desc = "Incoming Evade Events",
    type = "color",
    order = 531,
    get = function(info)
        local r = XM.db.COLOR_TABLE["EVADEINC"].r
        local g = XM.db.COLOR_TABLE["EVADEINC"].g
        local b = XM.db.COLOR_TABLE["EVADEINC"].b
        local a = XM.db.COLOR_TABLE["EVADEINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["EVADEINC"].r = r
        XM.db.COLOR_TABLE["EVADEINC"].g = g
        XM.db.COLOR_TABLE["EVADEINC"].b = b
        XM.db.COLOR_TABLE["EVADEINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.EVADEOUT = {
    name = "Outgoing Evade",
    desc = "Outgoing Evade Events",
    type = "color",
    order = 532,
    get = function(info)
        local r = XM.db.COLOR_TABLE["EVADEOUT"].r
        local g = XM.db.COLOR_TABLE["EVADEOUT"].g
        local b = XM.db.COLOR_TABLE["EVADEOUT"].b
        local a = XM.db.COLOR_TABLE["EVADEOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["EVADEOUT"].r = r
        XM.db.COLOR_TABLE["EVADEOUT"].g = g
        XM.db.COLOR_TABLE["EVADEOUT"].b = b
        XM.db.COLOR_TABLE["EVADEOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.PARRYINC = {
    name = "Incoming Parry",
    desc = "Incoming Parry Events",
    type = "color",
    order = 533,
    get = function(info)
        local r = XM.db.COLOR_TABLE["PARRYINC"].r
        local g = XM.db.COLOR_TABLE["PARRYINC"].g
        local b = XM.db.COLOR_TABLE["PARRYINC"].b
        local a = XM.db.COLOR_TABLE["PARRYINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["PARRYINC"].r = r
        XM.db.COLOR_TABLE["PARRYINC"].g = g
        XM.db.COLOR_TABLE["PARRYINC"].b = b
        XM.db.COLOR_TABLE["PARRYINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.PARRYOUT = {
    name = "Outgoing Parry",
    desc = "Outgoing Parry Events",
    type = "color",
    order = 534,
    get = function(info)
        local r = XM.db.COLOR_TABLE["PARRYOUT"].r
        local g = XM.db.COLOR_TABLE["PARRYOUT"].g
        local b = XM.db.COLOR_TABLE["PARRYOUT"].b
        local a = XM.db.COLOR_TABLE["PARRYOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["PARRYOUT"].r = r
        XM.db.COLOR_TABLE["PARRYOUT"].g = g
        XM.db.COLOR_TABLE["PARRYOUT"].b = b
        XM.db.COLOR_TABLE["PARRYOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.RESISTINC = {
    name = "Incoming Resist",
    desc = "Incoming Resist Events",
    type = "color",
    order = 535,
    get = function(info)
        local r = XM.db.COLOR_TABLE["RESISTINC"].r
        local g = XM.db.COLOR_TABLE["RESISTINC"].g
        local b = XM.db.COLOR_TABLE["RESISTINC"].b
        local a = XM.db.COLOR_TABLE["RESISTINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["RESISTINC"].r = r
        XM.db.COLOR_TABLE["RESISTINC"].g = g
        XM.db.COLOR_TABLE["RESISTINC"].b = b
        XM.db.COLOR_TABLE["RESISTINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.RESISTOUT = {
    name = "Outgoing Resist",
    desc = "Outgoing Resist Events",
    type = "color",
    order = 536,
    get = function(info)
        local r = XM.db.COLOR_TABLE["RESISTOUT"].r
        local g = XM.db.COLOR_TABLE["RESISTOUT"].g
        local b = XM.db.COLOR_TABLE["RESISTOUT"].b
        local a = XM.db.COLOR_TABLE["RESISTOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["RESISTOUT"].r = r
        XM.db.COLOR_TABLE["RESISTOUT"].g = g
        XM.db.COLOR_TABLE["RESISTOUT"].b = b
        XM.db.COLOR_TABLE["RESISTOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.ABSORBINC = {
    name = "Incoming Absorb",
    desc = "Incoming Absorb Events",
    type = "color",
    order = 537,
    get = function(info)
        local r = XM.db.COLOR_TABLE["ABSORBINC"].r
        local g = XM.db.COLOR_TABLE["ABSORBINC"].g
        local b = XM.db.COLOR_TABLE["ABSORBINC"].b
        local a = XM.db.COLOR_TABLE["ABSORBINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["ABSORBINC"].r = r
        XM.db.COLOR_TABLE["ABSORBINC"].g = g
        XM.db.COLOR_TABLE["ABSORBINC"].b = b
        XM.db.COLOR_TABLE["ABSORBINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.ABSORBOUT = {
    name = "Outgoing Absorb",
    desc = "Outgoing Absorb Events",
    type = "color",
    order = 538,
    get = function(info)
        local r = XM.db.COLOR_TABLE["ABSORBOUT"].r
        local g = XM.db.COLOR_TABLE["ABSORBOUT"].g
        local b = XM.db.COLOR_TABLE["ABSORBOUT"].b
        local a = XM.db.COLOR_TABLE["ABSORBOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["ABSORBOUT"].r = r
        XM.db.COLOR_TABLE["ABSORBOUT"].g = g
        XM.db.COLOR_TABLE["ABSORBOUT"].b = b
        XM.db.COLOR_TABLE["ABSORBOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.REFLECTINC = {
    name = "Incoming Reflect",
    desc = "Incoming Reflect Events",
    type = "color",
    order = 539,
    get = function(info)
        local r = XM.db.COLOR_TABLE["REFLECTINC"].r
        local g = XM.db.COLOR_TABLE["REFLECTINC"].g
        local b = XM.db.COLOR_TABLE["REFLECTINC"].b
        local a = XM.db.COLOR_TABLE["REFLECTINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["REFLECTINC"].r = r
        XM.db.COLOR_TABLE["REFLECTINC"].g = g
        XM.db.COLOR_TABLE["REFLECTINC"].b = b
        XM.db.COLOR_TABLE["REFLECTINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.REFLECTOUT = {
    name = "Outgoing Reflect",
    desc = "Outgoing Reflect Events",
    type = "color",
    order = 540,
    get = function(info)
        local r = XM.db.COLOR_TABLE["REFLECTOUT"].r
        local g = XM.db.COLOR_TABLE["REFLECTOUT"].g
        local b = XM.db.COLOR_TABLE["REFLECTOUT"].b
        local a = XM.db.COLOR_TABLE["REFLECTOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["REFLECTOUT"].r = r
        XM.db.COLOR_TABLE["REFLECTOUT"].g = g
        XM.db.COLOR_TABLE["REFLECTOUT"].b = b
        XM.db.COLOR_TABLE["REFLECTOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.INTERRUPTINC = {
    name = "Incoming Interrupt",
    desc = "Incoming Interrupt Events",
    type = "color",
    order = 541,
    get = function(info)
        local r = XM.db.COLOR_TABLE["INTERRUPTINC"].r
        local g = XM.db.COLOR_TABLE["INTERRUPTINC"].g
        local b = XM.db.COLOR_TABLE["INTERRUPTINC"].b
        local a = XM.db.COLOR_TABLE["INTERRUPTINC"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["INTERRUPTINC"].r = r
        XM.db.COLOR_TABLE["INTERRUPTINC"].g = g
        XM.db.COLOR_TABLE["INTERRUPTINC"].b = b
        XM.db.COLOR_TABLE["INTERRUPTINC"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.INTERRUPTOUT = {
    name = "Outgoing Interrupt",
    desc = "Outgoing Interrupt Events",
    type = "color",
    order = 542,
    get = function(info)
        local r = XM.db.COLOR_TABLE["INTERRUPTOUT"].r
        local g = XM.db.COLOR_TABLE["INTERRUPTOUT"].g
        local b = XM.db.COLOR_TABLE["INTERRUPTOUT"].b
        local a = XM.db.COLOR_TABLE["INTERRUPTOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["INTERRUPTOUT"].r = r
        XM.db.COLOR_TABLE["INTERRUPTOUT"].g = g
        XM.db.COLOR_TABLE["INTERRUPTOUT"].b = b
        XM.db.COLOR_TABLE["INTERRUPTOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.PETHITOUT = {
    name = "Outgoing Pet Hits",
    desc = "Outgoing Pet Melee Damage",
    type = "color",
    order = 543,
    get = function(info)
        local r = XM.db.COLOR_TABLE["PETHITOUT"].r
        local g = XM.db.COLOR_TABLE["PETHITOUT"].g
        local b = XM.db.COLOR_TABLE["PETHITOUT"].b
        local a = XM.db.COLOR_TABLE["PETHITOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["PETHITOUT"].r = r
        XM.db.COLOR_TABLE["PETHITOUT"].g = g
        XM.db.COLOR_TABLE["PETHITOUT"].b = b
        XM.db.COLOR_TABLE["PETHITOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.PETDOTOUT = {
    name = "Outgoing Pet DoT",
    desc = "Outgoing Pet Damage over Time",
    type = "color",
    order = 544,
    get = function(info)
        local r = XM.db.COLOR_TABLE["PETDOTOUT"].r
        local g = XM.db.COLOR_TABLE["PETDOTOUT"].g
        local b = XM.db.COLOR_TABLE["PETDOTOUT"].b
        local a = XM.db.COLOR_TABLE["PETDOTOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["PETDOTOUT"].r = r
        XM.db.COLOR_TABLE["PETDOTOUT"].g = g
        XM.db.COLOR_TABLE["PETDOTOUT"].b = b
        XM.db.COLOR_TABLE["PETDOTOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.PETSPELLOUT = {
    name = "Outgoing Pet Spells",
    desc = "Outgoing Pet Spell Damage",
    type = "color",
    order = 545,
    get = function(info)
        local r = XM.db.COLOR_TABLE["PETSPELLOUT"].r
        local g = XM.db.COLOR_TABLE["PETSPELLOUT"].g
        local b = XM.db.COLOR_TABLE["PETSPELLOUT"].b
        local a = XM.db.COLOR_TABLE["PETSPELLOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["PETSPELLOUT"].r = r
        XM.db.COLOR_TABLE["PETSPELLOUT"].g = g
        XM.db.COLOR_TABLE["PETSPELLOUT"].b = b
        XM.db.COLOR_TABLE["PETSPELLOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.PETMISSOUT = {
    name = "Outgoing Pet Miss",
    desc = "Outgoing Pet Miss Events",
    type = "color",
    order = 546,
    get = function(info)
        local r = XM.db.COLOR_TABLE["PETMISSOUT"].r
        local g = XM.db.COLOR_TABLE["PETMISSOUT"].g
        local b = XM.db.COLOR_TABLE["PETMISSOUT"].b
        local a = XM.db.COLOR_TABLE["PETMISSOUT"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["PETMISSOUT"].r = r
        XM.db.COLOR_TABLE["PETMISSOUT"].g = g
        XM.db.COLOR_TABLE["PETMISSOUT"].b = b
        XM.db.COLOR_TABLE["PETMISSOUT"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.BUFFGAIN = {
    name = "Buff Gain",
    desc = "Buff Gain Events",
    type = "color",
    order = 547,
    get = function(info)
        local r = XM.db.COLOR_TABLE["BUFFGAIN"].r
        local g = XM.db.COLOR_TABLE["BUFFGAIN"].g
        local b = XM.db.COLOR_TABLE["BUFFGAIN"].b
        local a = XM.db.COLOR_TABLE["BUFFGAIN"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["BUFFGAIN"].r = r
        XM.db.COLOR_TABLE["BUFFGAIN"].g = g
        XM.db.COLOR_TABLE["BUFFGAIN"].b = b
        XM.db.COLOR_TABLE["BUFFGAIN"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.BUFFFADE = {
    name = "Buff Fade",
    desc = "Buff Fade Events",
    type = "color",
    order = 548,
    get = function(info)
        local r = XM.db.COLOR_TABLE["BUFFFADE"].r
        local g = XM.db.COLOR_TABLE["BUFFFADE"].g
        local b = XM.db.COLOR_TABLE["BUFFFADE"].b
        local a = XM.db.COLOR_TABLE["BUFFFADE"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["BUFFFADE"].r = r
        XM.db.COLOR_TABLE["BUFFFADE"].g = g
        XM.db.COLOR_TABLE["BUFFFADE"].b = b
        XM.db.COLOR_TABLE["BUFFFADE"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.DEBUFFGAIN = {
    name = "Debuff Gain",
    desc = "Debuff Gain Events",
    type = "color",
    order = 549,
    get = function(info)
        local r = XM.db.COLOR_TABLE["DEBUFFGAIN"].r
        local g = XM.db.COLOR_TABLE["DEBUFFGAIN"].g
        local b = XM.db.COLOR_TABLE["DEBUFFGAIN"].b
        local a = XM.db.COLOR_TABLE["DEBUFFGAIN"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["DEBUFFGAIN"].r = r
        XM.db.COLOR_TABLE["DEBUFFGAIN"].g = g
        XM.db.COLOR_TABLE["DEBUFFGAIN"].b = b
        XM.db.COLOR_TABLE["DEBUFFGAIN"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.DEBUFFFADE = {
    name = "Debuff Fade",
    desc = "Debuff Fade Events",
    type = "color",
    order = 550,
    get = function(info)
        local r = XM.db.COLOR_TABLE["DEBUFFFADE"].r
        local g = XM.db.COLOR_TABLE["DEBUFFFADE"].g
        local b = XM.db.COLOR_TABLE["DEBUFFFADE"].b
        local a = XM.db.COLOR_TABLE["DEBUFFFADE"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["DEBUFFFADE"].r = r
        XM.db.COLOR_TABLE["DEBUFFFADE"].g = g
        XM.db.COLOR_TABLE["DEBUFFFADE"].b = b
        XM.db.COLOR_TABLE["DEBUFFFADE"].a = a
    end,
}

XM.OPTIONS.args.COLORS.args.SPELLACTIVE = {
    name = "Spell Activation",
    desc = "Spell Activation Events",
    type = "color",
    order = 551,
    get = function(info)
        local r = XM.db.COLOR_TABLE["SPELLACTIVE"].r
        local g = XM.db.COLOR_TABLE["SPELLACTIVE"].g
        local b = XM.db.COLOR_TABLE["SPELLACTIVE"].b
        local a = XM.db.COLOR_TABLE["SPELLACTIVE"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_TABLE["SPELLACTIVE"].r = r
        XM.db.COLOR_TABLE["SPELLACTIVE"].g = g
        XM.db.COLOR_TABLE["SPELLACTIVE"].b = b
        XM.db.COLOR_TABLE["SPELLACTIVE"].a = a
    end,
}

XM.OPTIONS.args.COLORELEM = {
    name = "Elemental Colors",
    desc = "Elemental Colors",
    type = "group",
    order = 600,
    args = {}
}

XM.OPTIONS.args.COLORELEM.args.FIRE = {
    name = "FIRE",
    desc = "Fire Spell Color",
    type = "color",
    order = 601,
    get = function(info)
        local r = XM.db.COLOR_SPELL["FIRE"].r
        local g = XM.db.COLOR_SPELL["FIRE"].g
        local b = XM.db.COLOR_SPELL["FIRE"].b
        local a = XM.db.COLOR_SPELL["FIRE"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_SPELL["FIRE"].r = r
        XM.db.COLOR_SPELL["FIRE"].g = g
        XM.db.COLOR_SPELL["FIRE"].b = b
        XM.db.COLOR_SPELL["FIRE"].a = a
    end,
}

XM.OPTIONS.args.COLORELEM.args.NATURE = {
    name = "NATURE",
    desc = "Nature Spell Color",
    type = "color",
    order = 602,
    get = function(info)
        local r = XM.db.COLOR_SPELL["NATURE"].r
        local g = XM.db.COLOR_SPELL["NATURE"].g
        local b = XM.db.COLOR_SPELL["NATURE"].b
        local a = XM.db.COLOR_SPELL["NATURE"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_SPELL["NATURE"].r = r
        XM.db.COLOR_SPELL["NATURE"].g = g
        XM.db.COLOR_SPELL["NATURE"].b = b
        XM.db.COLOR_SPELL["NATURE"].a = a
    end,
}

XM.OPTIONS.args.COLORELEM.args.FROST = {
    name = "FROST",
    desc = "Frost Spell Color",
    type = "color",
    order = 603,
    get = function(info)
        local r = XM.db.COLOR_SPELL["FROST"].r
        local g = XM.db.COLOR_SPELL["FROST"].g
        local b = XM.db.COLOR_SPELL["FROST"].b
        local a = XM.db.COLOR_SPELL["FROST"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_SPELL["FROST"].r = r
        XM.db.COLOR_SPELL["FROST"].g = g
        XM.db.COLOR_SPELL["FROST"].b = b
        XM.db.COLOR_SPELL["FROST"].a = a
    end,
}

XM.OPTIONS.args.COLORELEM.args.SHADOW = {
    name = "SHADOW",
    desc = "Shadow Spell Color",
    type = "color",
    order = 604,
    get = function(info)
        local r = XM.db.COLOR_SPELL["SHADOW"].r
        local g = XM.db.COLOR_SPELL["SHADOW"].g
        local b = XM.db.COLOR_SPELL["SHADOW"].b
        local a = XM.db.COLOR_SPELL["SHADOW"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_SPELL["SHADOW"].r = r
        XM.db.COLOR_SPELL["SHADOW"].g = g
        XM.db.COLOR_SPELL["SHADOW"].b = b
        XM.db.COLOR_SPELL["SHADOW"].a = a
    end,
}

XM.OPTIONS.args.COLORELEM.args.ARCANE = {
    name = "ARCANE",
    desc = "Arcane Spell Color",
    type = "color",
    order = 605,
    get = function(info)
        local r = XM.db.COLOR_SPELL["ARCANE"].r
        local g = XM.db.COLOR_SPELL["ARCANE"].g
        local b = XM.db.COLOR_SPELL["ARCANE"].b
        local a = XM.db.COLOR_SPELL["ARCANE"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_SPELL["ARCANE"].r = r
        XM.db.COLOR_SPELL["ARCANE"].g = g
        XM.db.COLOR_SPELL["ARCANE"].b = b
        XM.db.COLOR_SPELL["ARCANE"].a = a
    end,
}

XM.OPTIONS.args.COLORELEM.args.HOLY = {
    name = "HOLY",
    desc = "Holy Spell Color",
    type = "color",
    order = 606,
    get = function(info)
        local r = XM.db.COLOR_SPELL["HOLY"].r
        local g = XM.db.COLOR_SPELL["HOLY"].g
        local b = XM.db.COLOR_SPELL["HOLY"].b
        local a = XM.db.COLOR_SPELL["HOLY"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_SPELL["HOLY"].r = r
        XM.db.COLOR_SPELL["HOLY"].g = g
        XM.db.COLOR_SPELL["HOLY"].b = b
        XM.db.COLOR_SPELL["HOLY"].a = a
    end,
}

XM.OPTIONS.args.COLORELEM.args.PHYSICAL = {
    name = "PHYSICAL",
    desc = "Physical Spell Color",
    type = "color",
    order = 607,
    get = function(info)
        local r = XM.db.COLOR_SPELL["PHYSICAL"].r
        local g = XM.db.COLOR_SPELL["PHYSICAL"].g
        local b = XM.db.COLOR_SPELL["PHYSICAL"].b
        local a = XM.db.COLOR_SPELL["PHYSICAL"].a
        return r,g,b,a
    end,
    set = function(info, r,g,b,a)
        XM.db.COLOR_SPELL["PHYSICAL"].r = r
        XM.db.COLOR_SPELL["PHYSICAL"].g = g
        XM.db.COLOR_SPELL["PHYSICAL"].b = b
        XM.db.COLOR_SPELL["PHYSICAL"].a = a
    end,
}


XM.OPTIONS.args.FRAME1 = {
    name = "Frame 1 Options",
    desc = "Frame 1 Options",
    type = "group",
    order = 1100,
    args = {}
}

XM.OPTIONS.args.FRAME1.args.FONT = {
    name = "Font",
    desc = "Frame 1 Font",
    type = "select", values = XM.sharedMedia:List("font"),
    order = 1101,
    get = function(info) return XM:GetMediaIndex("font", XM.db["FRAME1"]["FONT"]) end,
    set = function(info,v) XM.db["FRAME1"]["FONT"] = XM.sharedMedia:List("font")[v] end,
}

XM.OPTIONS.args.FRAME1.args.TEXTSIZE = {
    name = "Text Size",
    desc = "Frame 1 Text Size",
    type = "range", min = 1, max = 200, step = 1,
    order = 1102,
    get = function(info) return XM.db["FRAME1"]["TEXTSIZE"] end,
    set = function(info, v) XM.db["FRAME1"]["TEXTSIZE"] = v end,
}

XM.OPTIONS.args.FRAME1.args.FONTSHADOW = {
    name = "Font Shadow Type",
    desc = "Frame 1 Font Shadow Type",
    type = "select", values = FontOutline,
    order = 1103,
    get = function(info) return XM.db["FRAME1"]["FONTSHADOW"] end,
    set = function(info, v) XM.db["FRAME1"]["FONTSHADOW"] = v end,
}

XM.OPTIONS.args.FRAME1.args.ALPHA = {
    name = "Text Opacity (Percent)",
    desc = "Frame 1 Text Opacity (percent)",
    type = "range", min = 1, max = 100, step = 1,
    order = 1104,
    get = function(info) return XM.db["FRAME1"]["ALPHA"] end,
    set = function(info, v) XM.db["FRAME1"]["ALPHA"] = v end,
}

XM.OPTIONS.args.FRAME1.args.POSX = {
    name = "X offset",
    desc = "Frame 1 X offset",
    type = "range", min = -1000, max = 1000, step = 1,
    order = 1105,
    get = function(info) return XM.db["FRAME1"]["POSX"] end,
    set = function(info, v) XM.db["FRAME1"]["POSX"] = v end,
}

XM.OPTIONS.args.FRAME1.args.POSY = {
     name = "Y offset",
     desc = "Frame 1 Y offset",
     type = "range", min = -1000, max = 1000, step = 1,
     order = 1106,
     get = function(info) return XM.db["FRAME1"]["POSY"] end,
     set = function(info, v) XM.db["FRAME1"]["POSY"] = v end,
}

XM.OPTIONS.args.FRAME1.args.ALIGN = {
    name = "Text Alignment",
    desc = "Frame 1 Text Alignment",
    type = "select", values = TextAlign,
    order = 1107,
    get = function(info) return XM.db["FRAME1"]["ALIGN"] end,
    set = function(info, v) XM.db["FRAME1"]["ALIGN"] = v end,
}

XM.OPTIONS.args.FRAME1.args.ICONSIDE = {
    name = "Icon Side",
    desc = "Frame 1 Icon Alignment (1=left, 2=right)",
    type = "range", min = 1, max = 2, step = 1,
    order = 1108,
    get = function(info) return XM.db["FRAME1"]["ICONSIDE"] end,
    set = function(info, v) XM.db["FRAME1"]["ICONSIDE"] = v end,
}

XM.OPTIONS.args.FRAME1.args.ANITYPEX = {
    name = "Animation Type X",
    desc = "Frame 1 Animation Type X",
    type = "select", values = {[1] = "None"},
    order = 1109,
    get = function(info) return XM.db["FRAME1"]["ANITYPEX"] end,
    set = function(info, v) XM.db["FRAME1"]["ANITYPEX"] = v end,
}

XM.OPTIONS.args.FRAME1.args.ANITYPEY = {
    name = "Animation Type Y",
    desc = "Frame 1 Animation Type Y",
    type = "select", values = {[1] = "Vertical"},
    order = 1110,
    get = function(info) return XM.db["FRAME1"]["ANITYPEY"] end,
    set = function(info, v) XM.db["FRAME1"]["ANITYPEY"] = v end,
}

XM.OPTIONS.args.FRAME1.args.DIRECTIONX = {
    name = "Animation Direction X",
    desc = "Frame 1 Animation Direction X",
    type = "select", values = {[-1] = "LEFT", [1] = "RIGHT"},
    order = 1111,
    get = function(info) return XM.db["FRAME1"]["DIRECTIONX"] end,
    set = function(info, v) XM.db["FRAME1"]["DIRECTIONX"] = v end,
}

XM.OPTIONS.args.FRAME1.args.DIRECTIONY = {
    name = "Animation Direction Y",
    desc = "Frame 1 Animation Direction Y",
    type = "select", values = {[-1] = "DOWN", [1] = "UP"},
    order = 1112,
    get = function(info) return XM.db["FRAME1"]["DIRECTIONY"] end,
    set = function(info, v) XM.db["FRAME1"]["DIRECTIONY"] = v end,
}

XM.OPTIONS.args.FRAME1.args.ADDX = {
    name = "Animation Speed X",
    desc = "Frame 1 Animation Speed X",
    type = "range", min = 1, max = 100, step = 1,
    order = 1113,
    get = function(info) return XM.db["FRAME1"]["ADDX"] end,
    set = function(info, v) XM.db["FRAME1"]["ADDX"] = v end,
}

XM.OPTIONS.args.FRAME1.args.ADDY = {
    name = "Animation Speed Y",
    desc = "Frame 1 Animation Speed Y",
    type = "range", min = 1, max = 100, step = 1,
    order = 1114,
    get = function(info) return XM.db["FRAME1"]["ADDY"] end,
    set = function(info, v) XM.db["FRAME1"]["ADDY"] = v end,
}

XM.OPTIONS.args.FRAME1.args.FRAMESIZE = {
    name = "Frame Size",
    desc = "Frame 1 Frame Size",
    type = "range", min = 1, max = 1000, step = 1,
    order = 1115,
    get = function(info) return XM.db["FRAME1"]["FRAMESIZE"] end,
    set = function(info, v) XM.db["FRAME1"]["FRAMESIZE"] = v end,
}

XM.OPTIONS.args.FRAME2 = {
    name = "Frame 2 Options",
    desc = "Frame 2 Options",
    type = "group",
    order = 1200,
    args = {}
}

XM.OPTIONS.args.FRAME2.args.FONT = {
    name = "Font",
    desc = "Frame 2 Font",
    type = "select", values = XM.sharedMedia:List("font"),
    order = 1201,
    get = function(info) return XM:GetMediaIndex("font", XM.db["FRAME2"]["FONT"]) end,
    set = function(info,v) XM.db["FRAME2"]["FONT"] = XM.sharedMedia:List("font")[v] end,
}

XM.OPTIONS.args.FRAME2.args.TEXTSIZE = {
    name = "Text Size",
    desc = "Frame 2 Text Size",
    type = "range", min = 1, max = 200, step = 1,
    order = 1202,
    get = function(info) return XM.db["FRAME2"]["TEXTSIZE"] end,
    set = function(info, v) XM.db["FRAME2"]["TEXTSIZE"] = v end,
}

XM.OPTIONS.args.FRAME2.args.FONTSHADOW = {
    name = "Font Shadow Type",
    desc = "Frame 2 Font Shadow Type",
    type = "select", values = FontOutline,
    order = 1203,
    get = function(info) return XM.db["FRAME2"]["FONTSHADOW"] end,
    set = function(info, v) XM.db["FRAME2"]["FONTSHADOW"] = v end,
}

XM.OPTIONS.args.FRAME2.args.ALPHA = {
    name = "Text Opacity (Percent)",
    desc = "Frame 2 Text Opacity (percent)",
    type = "range", min = 1, max = 100, step = 1,
    order = 1204,
    get = function(info) return XM.db["FRAME2"]["ALPHA"] end,
    set = function(info, v) XM.db["FRAME2"]["ALPHA"] = v end,
}

XM.OPTIONS.args.FRAME2.args.POSX = {
    name = "X offset",
    desc = "Frame 2 X offset",
    type = "range", min = -1000, max = 1000, step = 1,
    order = 1205,
    get = function(info) return XM.db["FRAME2"]["POSX"] end,
    set = function(info, v) XM.db["FRAME2"]["POSX"] = v end,
}

XM.OPTIONS.args.FRAME2.args.POSY = {
     name = "Y offset",
     desc = "Frame 2 Y offset",
     type = "range", min = -1000, max = 1000, step = 1,
     order = 1206,
     get = function(info) return XM.db["FRAME2"]["POSY"] end,
     set = function(info, v) XM.db["FRAME2"]["POSY"] = v end,
}

XM.OPTIONS.args.FRAME2.args.ALIGN = {
    name = "Text Alignment",
    desc = "Frame 2 Text Alignment",
    type = "select", values = TextAlign,
    order = 1207,
    get = function(info) return XM.db["FRAME2"]["ALIGN"] end,
    set = function(info, v) XM.db["FRAME2"]["ALIGN"] = v end,
}

XM.OPTIONS.args.FRAME2.args.ICONSIDE = {
    name = "Icon Side",
    desc = "Frame 2 Icon Alignment (1=left, 2=right)",
    type = "range", min = 1, max = 2, step = 1,
    order = 1208,
    get = function(info) return XM.db["FRAME2"]["ICONSIDE"] end,
    set = function(info, v) XM.db["FRAME2"]["ICONSIDE"] = v end,
}

XM.OPTIONS.args.FRAME2.args.ANITYPEX = {
    name = "Animation Type X",
    desc = "Frame 2 Animation Type X",
    type = "select", values = {[1] = "None"},
    order = 1209,
    get = function(info) return XM.db["FRAME2"]["ANITYPEX"] end,
    set = function(info, v) XM.db["FRAME2"]["ANITYPEX"] = v end,
}

XM.OPTIONS.args.FRAME2.args.ANITYPEY = {
    name = "Animation Type Y",
    desc = "Frame 2 Animation Type Y",
    type = "select", values = {[1] = "Vertical"},
    order = 1210,
    get = function(info) return XM.db["FRAME2"]["ANITYPEY"] end,
    set = function(info, v) XM.db["FRAME2"]["ANITYPEY"] = v end,
}

XM.OPTIONS.args.FRAME2.args.DIRECTIONX = {
    name = "Animation Direction X",
    desc = "Frame 2 Animation Direction X",
    type = "select", values = {[-1] = "LEFT", [1] = "RIGHT"},
    order = 1211,
    get = function(info) return XM.db["FRAME2"]["DIRECTIONX"] end,
    set = function(info, v) XM.db["FRAME2"]["DIRECTIONX"] = v end,
}

XM.OPTIONS.args.FRAME2.args.DIRECTIONY = {
    name = "Animation Direction Y",
    desc = "Frame 2 Animation Direction Y",
    type = "select", values = {[-1] = "DOWN", [1] = "UP"},
    order = 1212,
    get = function(info) return XM.db["FRAME2"]["DIRECTIONY"] end,
    set = function(info, v) XM.db["FRAME2"]["DIRECTIONY"] = v end,
}

XM.OPTIONS.args.FRAME2.args.ADDX = {
    name = "Animation Speed X",
    desc = "Frame 2 Animation Speed X",
    type = "range", min = 1, max = 100, step = 1,
    order = 1213,
    get = function(info) return XM.db["FRAME2"]["ADDX"] end,
    set = function(info, v) XM.db["FRAME2"]["ADDX"] = v end,
}

XM.OPTIONS.args.FRAME2.args.ADDY = {
    name = "Animation Speed Y",
    desc = "Frame 2 Animation Speed Y",
    type = "range", min = 1, max = 100, step = 1,
    order = 1214,
    get = function(info) return XM.db["FRAME2"]["ADDY"] end,
    set = function(info, v) XM.db["FRAME2"]["ADDY"] = v end,
}

XM.OPTIONS.args.FRAME2.args.FRAMESIZE = {
    name = "Frame Size",
    desc = "Frame 2 Frame Size",
    type = "range", min = 1, max = 1000, step = 1,
    order = 1215,
    get = function(info) return XM.db["FRAME2"]["FRAMESIZE"] end,
    set = function(info, v) XM.db["FRAME2"]["FRAMESIZE"] = v end,
}

XM.OPTIONS.args.FRAME3 = {
    name = "Frame 3 Options",
    desc = "Frame 3 Options",
    type = "group",
    order = 1300,
    args = {}
}

XM.OPTIONS.args.FRAME3.args.FONT = {
    name = "Font",
    desc = "Frame 3 Font",
    type = "select", values = XM.sharedMedia:List("font"),
    order = 1301,
    get = function(info) return XM:GetMediaIndex("font", XM.db["FRAME3"]["FONT"]) end,
    set = function(info,v) XM.db["FRAME3"]["FONT"] = XM.sharedMedia:List("font")[v] end,
}

XM.OPTIONS.args.FRAME3.args.TEXTSIZE = {
    name = "Text Size",
    desc = "Frame 3 Text Size",
    type = "range", min = 1, max = 200, step = 1,
    order = 1302,
    get = function(info) return XM.db["FRAME3"]["TEXTSIZE"] end,
    set = function(info, v) XM.db["FRAME3"]["TEXTSIZE"] = v end,
}

XM.OPTIONS.args.FRAME3.args.FONTSHADOW = {
    name = "Font Shadow Type",
    desc = "Frame 3 Font Shadow Type",
    type = "select", values = FontOutline,
    order = 1303,
    get = function(info) return XM.db["FRAME3"]["FONTSHADOW"] end,
    set = function(info, v) XM.db["FRAME3"]["FONTSHADOW"] = v end,
}

XM.OPTIONS.args.FRAME3.args.ALPHA = {
    name = "Text Opacity (Percent)",
    desc = "Frame 3 Text Opacity (percent)",
    type = "range", min = 1, max = 100, step = 1,
    order = 1304,
    get = function(info) return XM.db["FRAME3"]["ALPHA"] end,
    set = function(info, v) XM.db["FRAME3"]["ALPHA"] = v end,
}

XM.OPTIONS.args.FRAME3.args.POSX = {
    name = "X offset",
    desc = "Frame 3 X offset",
    type = "range", min = -1000, max = 1000, step = 1,
    order = 1305,
    get = function(info) return XM.db["FRAME3"]["POSX"] end,
    set = function(info, v) XM.db["FRAME3"]["POSX"] = v end,
}

XM.OPTIONS.args.FRAME3.args.POSY = {
     name = "Y offset",
     desc = "Frame 3 Y offset",
     type = "range", min = -1000, max = 1000, step = 1,
     order = 1306,
     get = function(info) return XM.db["FRAME3"]["POSY"] end,
     set = function(info, v) XM.db["FRAME3"]["POSY"] = v end,
}

XM.OPTIONS.args.FRAME3.args.ALIGN = {
    name = "Text Alignment",
    desc = "Frame 3 Text Alignment",
    type = "select", values = TextAlign,
    order = 1307,
    get = function(info) return XM.db["FRAME3"]["ALIGN"] end,
    set = function(info, v) XM.db["FRAME3"]["ALIGN"] = v end,
}

XM.OPTIONS.args.FRAME3.args.ICONSIDE = {
    name = "Icon Side",
    desc = "Frame 3 Icon Alignment (1=left, 2=right)",
    type = "range", min = 1, max = 2, step = 1,
    order = 1308,
    get = function(info) return XM.db["FRAME3"]["ICONSIDE"] end,
    set = function(info, v) XM.db["FRAME3"]["ICONSIDE"] = v end,
}

XM.OPTIONS.args.FRAME3.args.ANITYPEX = {
    name = "Animation Type X",
    desc = "Frame 3 Animation Type X",
    type = "select", values = {[1] = "None"},
    order = 1309,
    get = function(info) return XM.db["FRAME3"]["ANITYPEX"] end,
    set = function(info, v) XM.db["FRAME3"]["ANITYPEX"] = v end,
}

XM.OPTIONS.args.FRAME3.args.ANITYPEY = {
    name = "Animation Type Y",
    desc = "Frame 3 Animation Type Y",
    type = "select", values = {[1] = "Vertical"},
    order = 1310,
    get = function(info) return XM.db["FRAME3"]["ANITYPEY"] end,
    set = function(info, v) XM.db["FRAME3"]["ANITYPEY"] = v end,
}

XM.OPTIONS.args.FRAME3.args.DIRECTIONX = {
    name = "Animation Direction X",
    desc = "Frame 3 Animation Direction X",
    type = "select", values = {[-1] = "LEFT", [1] = "RIGHT"},
    order = 1311,
    get = function(info) return XM.db["FRAME3"]["DIRECTIONX"] end,
    set = function(info, v) XM.db["FRAME3"]["DIRECTIONX"] = v end,
}

XM.OPTIONS.args.FRAME3.args.DIRECTIONY = {
    name = "Animation Direction Y",
    desc = "Frame 3 Animation Direction Y",
    type = "select", values = {[-1] = "DOWN", [1] = "UP"},
    order = 1312,
    get = function(info) return XM.db["FRAME3"]["DIRECTIONY"] end,
    set = function(info, v) XM.db["FRAME3"]["DIRECTIONY"] = v end,
}

XM.OPTIONS.args.FRAME3.args.ADDX = {
    name = "Animation Speed X",
    desc = "Frame 3 Animation Speed X",
    type = "range", min = 1, max = 100, step = 1,
    order = 1313,
    get = function(info) return XM.db["FRAME3"]["ADDX"] end,
    set = function(info, v) XM.db["FRAME3"]["ADDX"] = v end,
}

XM.OPTIONS.args.FRAME3.args.ADDY = {
    name = "Animation Speed Y",
    desc = "Frame 3 Animation Speed Y",
    type = "range", min = 1, max = 100, step = 1,
    order = 1314,
    get = function(info) return XM.db["FRAME3"]["ADDY"] end,
    set = function(info, v) XM.db["FRAME3"]["ADDY"] = v end,
}

XM.OPTIONS.args.FRAME3.args.FRAMESIZE = {
    name = "Frame Size",
    desc = "Frame 3 Frame Size",
    type = "range", min = 1, max = 1000, step = 1,
    order = 1315,
    get = function(info) return XM.db["FRAME3"]["FRAMESIZE"] end,
    set = function(info, v) XM.db["FRAME3"]["FRAMESIZE"] = v end,
}

XM.OPTIONS.args.FRAME4 = {
    name = "Frame 4 Options",
    desc = "Frame 4 Options",
    type = "group",
    order = 1400,
    args = {}
}

XM.OPTIONS.args.FRAME4.args.FONT = {
    name = "Font",
    desc = "Frame 4 Font",
    type = "select", values = XM.sharedMedia:List("font"),
    order = 1401,
    get = function(info) return XM:GetMediaIndex("font", XM.db["FRAME4"]["FONT"]) end,
    set = function(info,v) XM.db["FRAME4"]["FONT"] = XM.sharedMedia:List("font")[v] end,
}

XM.OPTIONS.args.FRAME4.args.TEXTSIZE = {
    name = "Text Size",
    desc = "Frame 4 Text Size",
    type = "range", min = 1, max = 200, step = 1,
    order = 1402,
    get = function(info) return XM.db["FRAME4"]["TEXTSIZE"] end,
    set = function(info, v) XM.db["FRAME4"]["TEXTSIZE"] = v end,
}

XM.OPTIONS.args.FRAME4.args.FONTSHADOW = {
    name = "Font Shadow Type",
    desc = "Frame 4 Font Shadow Type",
    type = "select", values = FontOutline,
    order = 1403,
    get = function(info) return XM.db["FRAME4"]["FONTSHADOW"] end,
    set = function(info, v) XM.db["FRAME4"]["FONTSHADOW"] = v end,
}

XM.OPTIONS.args.FRAME4.args.ALPHA = {
    name = "Text Opacity (Percent)",
    desc = "Frame 4 Text Opacity (percent)",
    type = "range", min = 1, max = 100, step = 1,
    order = 1404,
    get = function(info) return XM.db["FRAME4"]["ALPHA"] end,
    set = function(info, v) XM.db["FRAME4"]["ALPHA"] = v end,
}

XM.OPTIONS.args.FRAME4.args.POSX = {
    name = "X offset",
    desc = "Frame 4 X offset",
    type = "range", min = -1000, max = 1000, step = 1,
    order = 1405,
    get = function(info) return XM.db["FRAME4"]["POSX"] end,
    set = function(info, v) XM.db["FRAME4"]["POSX"] = v end,
}

XM.OPTIONS.args.FRAME4.args.POSY = {
     name = "Y offset",
     desc = "Frame 4 Y offset",
     type = "range", min = -1000, max = 1000, step = 1,
     order = 1406,
     get = function(info) return XM.db["FRAME4"]["POSY"] end,
     set = function(info, v) XM.db["FRAME4"]["POSY"] = v end,
}

XM.OPTIONS.args.FRAME4.args.ALIGN = {
    name = "Text Alignment",
    desc = "Frame 4 Text Alignment",
    type = "select", values = TextAlign,
    order = 1407,
    get = function(info) return XM.db["FRAME4"]["ALIGN"] end,
    set = function(info, v) XM.db["FRAME4"]["ALIGN"] = v end,
}

XM.OPTIONS.args.FRAME4.args.ICONSIDE = {
    name = "Icon Side",
    desc = "Frame 4 Icon Alignment (1=left, 2=right)",
    type = "range", min = 1, max = 2, step = 1,
    order = 1408,
    get = function(info) return XM.db["FRAME4"]["ICONSIDE"] end,
    set = function(info, v) XM.db["FRAME4"]["ICONSIDE"] = v end,
}

XM.OPTIONS.args.FRAME4.args.ANITYPEX = {
    name = "Animation Type X",
    desc = "Frame 4 Animation Type X",
    type = "select", values = {[1] = "None"},
    order = 1409,
    get = function(info) return XM.db["FRAME4"]["ANITYPEX"] end,
    set = function(info, v) XM.db["FRAME4"]["ANITYPEX"] = v end,
}

XM.OPTIONS.args.FRAME4.args.ANITYPEY = {
    name = "Animation Type Y",
    desc = "Frame 4 Animation Type Y",
    type = "select", values = {[1] = "Vertical"},
    order = 1410,
    get = function(info) return XM.db["FRAME4"]["ANITYPEY"] end,
    set = function(info, v) XM.db["FRAME4"]["ANITYPEY"] = v end,
}

XM.OPTIONS.args.FRAME4.args.DIRECTIONX = {
    name = "Animation Direction X",
    desc = "Frame 4 Animation Direction X",
    type = "select", values = {[-1] = "LEFT", [1] = "RIGHT"},
    order = 1411,
    get = function(info) return XM.db["FRAME4"]["DIRECTIONX"] end,
    set = function(info, v) XM.db["FRAME4"]["DIRECTIONX"] = v end,
}

XM.OPTIONS.args.FRAME4.args.DIRECTIONY = {
    name = "Animation Direction Y",
    desc = "Frame 4 Animation Direction Y",
    type = "select", values = {[-1] = "DOWN", [1] = "UP"},
    order = 1412,
    get = function(info) return XM.db["FRAME4"]["DIRECTIONY"] end,
    set = function(info, v) XM.db["FRAME4"]["DIRECTIONY"] = v end,
}

XM.OPTIONS.args.FRAME4.args.ADDX = {
    name = "Animation Speed X",
    desc = "Frame 4 Animation Speed X",
    type = "range", min = 1, max = 100, step = 1,
    order = 1413,
    get = function(info) return XM.db["FRAME4"]["ADDX"] end,
    set = function(info, v) XM.db["FRAME4"]["ADDX"] = v end,
}

XM.OPTIONS.args.FRAME4.args.ADDY = {
    name = "Animation Speed Y",
    desc = "Frame 4 Animation Speed Y",
    type = "range", min = 1, max = 100, step = 1,
    order = 1414,
    get = function(info) return XM.db["FRAME4"]["ADDY"] end,
    set = function(info, v) XM.db["FRAME4"]["ADDY"] = v end,
}

XM.OPTIONS.args.FRAME4.args.FRAMESIZE = {
    name = "Frame Size",
    desc = "Frame 4 Frame Size",
    type = "range", min = 1, max = 1000, step = 1,
    order = 1415,
    get = function(info) return XM.db["FRAME4"]["FRAMESIZE"] end,
    set = function(info, v) XM.db["FRAME4"]["FRAMESIZE"] = v end,
}

XM.OPTIONS.args.FRAME5 = {
    name = "Frame 5 Options",
    desc = "Frame 5 Options",
    type = "group",
    order = 1500,
    args = {}
}

XM.OPTIONS.args.FRAME5.args.FONT = {
    name = "Font",
    desc = "Frame 5 Font",
    type = "select", values = XM.sharedMedia:List("font"),
    order = 1501,
    get = function(info) return XM:GetMediaIndex("font", XM.db["FRAME5"]["FONT"]) end,
    set = function(info,v) XM.db["FRAME5"]["FONT"] = XM.sharedMedia:List("font")[v] end,
}

XM.OPTIONS.args.FRAME5.args.TEXTSIZE = {
    name = "Text Size",
    desc = "Frame 5 Text Size",
    type = "range", min = 1, max = 200, step = 1,
    order = 1502,
    get = function(info) return XM.db["FRAME5"]["TEXTSIZE"] end,
    set = function(info, v) XM.db["FRAME5"]["TEXTSIZE"] = v end,
}

XM.OPTIONS.args.FRAME5.args.FONTSHADOW = {
    name = "Font Shadow Type",
    desc = "Frame 5 Font Shadow Type",
    type = "select", values = FontOutline,
    order = 1503,
    get = function(info) return XM.db["FRAME5"]["FONTSHADOW"] end,
    set = function(info, v) XM.db["FRAME5"]["FONTSHADOW"] = v end,
}

XM.OPTIONS.args.FRAME5.args.ALPHA = {
    name = "Text Opacity (Percent)",
    desc = "Frame 5 Text Opacity (percent)",
    type = "range", min = 1, max = 100, step = 1,
    order = 1504,
    get = function(info) return XM.db["FRAME5"]["ALPHA"] end,
    set = function(info, v) XM.db["FRAME5"]["ALPHA"] = v end,
}

XM.OPTIONS.args.FRAME5.args.POSX = {
    name = "X offset",
    desc = "Frame 5 X offset",
    type = "range", min = -1000, max = 1000, step = 1,
    order = 1505,
    get = function(info) return XM.db["FRAME5"]["POSX"] end,
    set = function(info, v) XM.db["FRAME5"]["POSX"] = v end,
}

XM.OPTIONS.args.FRAME5.args.POSY = {
     name = "Y offset",
     desc = "Frame 5 Y offset",
     type = "range", min = -1000, max = 1000, step = 1,
     order = 1506,
     get = function(info) return XM.db["FRAME5"]["POSY"] end,
     set = function(info, v) XM.db["FRAME5"]["POSY"] = v end,
}

XM.OPTIONS.args.FRAME5.args.ALIGN = {
    name = "Text Alignment",
    desc = "Frame 5 Text Alignment",
    type = "select", values = TextAlign,
    order = 1507,
    get = function(info) return XM.db["FRAME5"]["ALIGN"] end,
    set = function(info, v) XM.db["FRAME5"]["ALIGN"] = v end,
}

XM.OPTIONS.args.FRAME5.args.ICONSIDE = {
    name = "Icon Side",
    desc = "Frame 5 Icon Alignment (1=left, 2=right)",
    type = "range", min = 1, max = 2, step = 1,
    order = 1508,
    get = function(info) return XM.db["FRAME5"]["ICONSIDE"] end,
    set = function(info, v) XM.db["FRAME5"]["ICONSIDE"] = v end,
}

XM.OPTIONS.args.FRAME5.args.ANITYPEX = {
    name = "Animation Type X",
    desc = "Frame 5 Animation Type X",
    type = "select", values = {[1] = "None"},
    order = 1509,
    get = function(info) return XM.db["FRAME5"]["ANITYPEX"] end,
    set = function(info, v) XM.db["FRAME5"]["ANITYPEX"] = v end,
}

XM.OPTIONS.args.FRAME5.args.ANITYPEY = {
    name = "Animation Type Y",
    desc = "Frame 5 Animation Type Y",
    type = "select", values = {[1] = "Vertical"},
    order = 1510,
    get = function(info) return XM.db["FRAME5"]["ANITYPEY"] end,
    set = function(info, v) XM.db["FRAME5"]["ANITYPEY"] = v end,
}

XM.OPTIONS.args.FRAME5.args.DIRECTIONX = {
    name = "Animation Direction X",
    desc = "Frame 5 Animation Direction X",
    type = "select", values = {[-1] = "LEFT", [1] = "RIGHT"},
    order = 1511,
    get = function(info) return XM.db["FRAME5"]["DIRECTIONX"] end,
    set = function(info, v) XM.db["FRAME5"]["DIRECTIONX"] = v end,
}

XM.OPTIONS.args.FRAME5.args.DIRECTIONY = {
    name = "Animation Direction Y",
    desc = "Frame 5 Animation Direction Y",
    type = "select", values = {[-1] = "DOWN", [1] = "UP"},
    order = 1512,
    get = function(info) return XM.db["FRAME5"]["DIRECTIONY"] end,
    set = function(info, v) XM.db["FRAME5"]["DIRECTIONY"] = v end,
}

XM.OPTIONS.args.FRAME5.args.ADDX = {
    name = "Animation Speed X",
    desc = "Frame 5 Animation Speed X",
    type = "range", min = 1, max = 100, step = 1,
    order = 1513,
    get = function(info) return XM.db["FRAME5"]["ADDX"] end,
    set = function(info, v) XM.db["FRAME5"]["ADDX"] = v end,
}

XM.OPTIONS.args.FRAME5.args.ADDY = {
    name = "Animation Speed Y",
    desc = "Frame 5 Animation Speed Y",
    type = "range", min = 1, max = 100, step = 1,
    order = 1514,
    get = function(info) return XM.db["FRAME5"]["ADDY"] end,
    set = function(info, v) XM.db["FRAME5"]["ADDY"] = v end,
}

XM.OPTIONS.args.FRAME5.args.FRAMESIZE = {
    name = "Frame Size",
    desc = "Frame 5 Frame Size",
    type = "range", min = 1, max = 1000, step = 1,
    order = 1515,
    get = function(info) return XM.db["FRAME5"]["FRAMESIZE"] end,
    set = function(info, v) XM.db["FRAME5"]["FRAMESIZE"] = v end,
}

XM.OPTIONS.args.FRAME6 = {
    name = "Frame 6 Options",
    desc = "Frame 6 Options",
    type = "group",
    order = 1600,
    args = {}
}

XM.OPTIONS.args.FRAME6.args.FONT = {
    name = "Font",
    desc = "Frame 6 Font",
    type = "select", values = XM.sharedMedia:List("font"),
    order = 1601,
    get = function(info) return XM:GetMediaIndex("font", XM.db["FRAME6"]["FONT"]) end,
    set = function(info,v) XM.db["FRAME6"]["FONT"] = XM.sharedMedia:List("font")[v] end,
}

XM.OPTIONS.args.FRAME6.args.TEXTSIZE = {
    name = "Text Size",
    desc = "Frame 6 Text Size",
    type = "range", min = 1, max = 200, step = 1,
    order = 1602,
    get = function(info) return XM.db["FRAME6"]["TEXTSIZE"] end,
    set = function(info, v) XM.db["FRAME6"]["TEXTSIZE"] = v end,
}

XM.OPTIONS.args.FRAME6.args.FONTSHADOW = {
    name = "Font Shadow Type",
    desc = "Frame 6 Font Shadow Type",
    type = "select", values = FontOutline,
    order = 1603,
    get = function(info) return XM.db["FRAME6"]["FONTSHADOW"] end,
    set = function(info, v) XM.db["FRAME6"]["FONTSHADOW"] = v end,
}

XM.OPTIONS.args.FRAME6.args.ALPHA = {
    name = "Text Opacity (Percent)",
    desc = "Frame 6 Text Opacity (percent)",
    type = "range", min = 1, max = 100, step = 1,
    order = 1604,
    get = function(info) return XM.db["FRAME6"]["ALPHA"] end,
    set = function(info, v) XM.db["FRAME6"]["ALPHA"] = v end,
}

XM.OPTIONS.args.FRAME6.args.POSX = {
    name = "X offset",
    desc = "Frame 6 X offset",
    type = "range", min = -1000, max = 1000, step = 1,
    order = 1605,
    get = function(info) return XM.db["FRAME6"]["POSX"] end,
    set = function(info, v) XM.db["FRAME6"]["POSX"] = v end,
}

XM.OPTIONS.args.FRAME6.args.POSY = {
     name = "Y offset",
     desc = "Frame 6 Y offset",
     type = "range", min = -1000, max = 1000, step = 1,
     order = 1606,
     get = function(info) return XM.db["FRAME6"]["POSY"] end,
     set = function(info, v) XM.db["FRAME6"]["POSY"] = v end,
}

XM.OPTIONS.args.FRAME6.args.ALIGN = {
    name = "Text Alignment",
    desc = "Frame 6 Text Alignment",
    type = "select", values = TextAlign,
    order = 1607,
    get = function(info) return XM.db["FRAME6"]["ALIGN"] end,
    set = function(info, v) XM.db["FRAME6"]["ALIGN"] = v end,
}

XM.OPTIONS.args.FRAME6.args.ICONSIDE = {
    name = "Icon Side",
    desc = "Frame 6 Icon Alignment (1=left, 2=right)",
    type = "range", min = 1, max = 2, step = 1,
    order = 1608,
    get = function(info) return XM.db["FRAME6"]["ICONSIDE"] end,
    set = function(info, v) XM.db["FRAME6"]["ICONSIDE"] = v end,
}

XM.OPTIONS.args.FRAME6.args.ANITYPEX = {
    name = "Animation Type X",
    desc = "Frame 6 Animation Type X",
    type = "select", values = {[1] = "None"},
    order = 1609,
    get = function(info) return XM.db["FRAME6"]["ANITYPEX"] end,
    set = function(info, v) XM.db["FRAME6"]["ANITYPEX"] = v end,
}

XM.OPTIONS.args.FRAME6.args.ANITYPEY = {
    name = "Animation Type Y",
    desc = "Frame 6 Animation Type Y",
    type = "select", values = {[1] = "Vertical"},
    order = 1610,
    get = function(info) return XM.db["FRAME6"]["ANITYPEY"] end,
    set = function(info, v) XM.db["FRAME6"]["ANITYPEY"] = v end,
}

XM.OPTIONS.args.FRAME6.args.DIRECTIONX = {
    name = "Animation Direction X",
    desc = "Frame 6 Animation Direction X",
    type = "select", values = {[-1] = "LEFT", [1] = "RIGHT"},
    order = 1611,
    get = function(info) return XM.db["FRAME6"]["DIRECTIONX"] end,
    set = function(info, v) XM.db["FRAME6"]["DIRECTIONX"] = v end,
}

XM.OPTIONS.args.FRAME6.args.DIRECTIONY = {
    name = "Animation Direction Y",
    desc = "Frame 6 Animation Direction Y",
    type = "select", values = {[-1] = "DOWN", [1] = "UP"},
    order = 1612,
    get = function(info) return XM.db["FRAME6"]["DIRECTIONY"] end,
    set = function(info, v) XM.db["FRAME6"]["DIRECTIONY"] = v end,
}

XM.OPTIONS.args.FRAME6.args.ADDX = {
    name = "Animation Speed X",
    desc = "Frame 6 Animation Speed X",
    type = "range", min = 1, max = 100, step = 1,
    order = 1613,
    get = function(info) return XM.db["FRAME6"]["ADDX"] end,
    set = function(info, v) XM.db["FRAME6"]["ADDX"] = v end,
}

XM.OPTIONS.args.FRAME6.args.ADDY = {
    name = "Animation Speed Y",
    desc = "Frame 6 Animation Speed Y",
    type = "range", min = 1, max = 100, step = 1,
    order = 1614,
    get = function(info) return XM.db["FRAME6"]["ADDY"] end,
    set = function(info, v) XM.db["FRAME6"]["ADDY"] = v end,
}

XM.OPTIONS.args.FRAME6.args.FRAMESIZE = {
    name = "Frame Size",
    desc = "Frame 6 Frame Size",
    type = "range", min = 1, max = 1000, step = 1,
    order = 1615,
    get = function(info) return XM.db["FRAME6"]["FRAMESIZE"] end,
    set = function(info, v) XM.db["FRAME6"]["FRAMESIZE"] = v end,
}

XM.OPTIONS.args.FRAME7 = {
    name = "Frame 7 Options",
    desc = "Frame 7 Options",
    type = "group",
    order = 1700,
    args = {}
}

XM.OPTIONS.args.FRAME7.args.FONT = {
    name = "Font",
    desc = "Frame 7 Font",
    type = "select", values = XM.sharedMedia:List("font"),
    order = 1701,
    get = function(info) return XM:GetMediaIndex("font", XM.db["FRAME7"]["FONT"]) end,
    set = function(info,v) XM.db["FRAME7"]["FONT"] = XM.sharedMedia:List("font")[v] end,
}

XM.OPTIONS.args.FRAME7.args.TEXTSIZE = {
    name = "Text Size",
    desc = "Frame 7 Text Size",
    type = "range", min = 1, max = 200, step = 1,
    order = 1702,
    get = function(info) return XM.db["FRAME7"]["TEXTSIZE"] end,
    set = function(info, v) XM.db["FRAME7"]["TEXTSIZE"] = v end,
}

XM.OPTIONS.args.FRAME7.args.FONTSHADOW = {
    name = "Font Shadow Type",
    desc = "Frame 7 Font Shadow Type",
    type = "select", values = FontOutline,
    order = 1703,
    get = function(info) return XM.db["FRAME7"]["FONTSHADOW"] end,
    set = function(info, v) XM.db["FRAME7"]["FONTSHADOW"] = v end,
}

XM.OPTIONS.args.FRAME7.args.ALPHA = {
    name = "Text Opacity (Percent)",
    desc = "Frame 7 Text Opacity (percent)",
    type = "range", min = 1, max = 100, step = 1,
    order = 1704,
    get = function(info) return XM.db["FRAME7"]["ALPHA"] end,
    set = function(info, v) XM.db["FRAME7"]["ALPHA"] = v end,
}

XM.OPTIONS.args.FRAME7.args.POSX = {
    name = "X offset",
    desc = "Frame 7 X offset",
    type = "range", min = -1000, max = 1000, step = 1,
    order = 1705,
    get = function(info) return XM.db["FRAME7"]["POSX"] end,
    set = function(info, v) XM.db["FRAME7"]["POSX"] = v end,
}

XM.OPTIONS.args.FRAME7.args.POSY = {
     name = "Y offset",
     desc = "Frame 7 Y offset",
     type = "range", min = -1000, max = 1000, step = 1,
     order = 1706,
     get = function(info) return XM.db["FRAME7"]["POSY"] end,
     set = function(info, v) XM.db["FRAME7"]["POSY"] = v end,
}

XM.OPTIONS.args.FRAME7.args.ALIGN = {
    name = "Text Alignment",
    desc = "Frame 7 Text Alignment",
    type = "select", values = TextAlign,
    order = 1707,
    get = function(info) return XM.db["FRAME7"]["ALIGN"] end,
    set = function(info, v) XM.db["FRAME7"]["ALIGN"] = v end,
}

XM.OPTIONS.args.FRAME7.args.ICONSIDE = {
    name = "Icon Side",
    desc = "Frame 7 Icon Alignment (1=left, 2=right)",
    type = "range", min = 1, max = 2, step = 1,
    order = 1708,
    get = function(info) return XM.db["FRAME7"]["ICONSIDE"] end,
    set = function(info, v) XM.db["FRAME7"]["ICONSIDE"] = v end,
}

XM.OPTIONS.args.FRAME7.args.ANITYPEX = {
    name = "Animation Type X",
    desc = "Frame 7 Animation Type X",
    type = "select", values = {[1] = "None"},
    order = 1709,
    get = function(info) return XM.db["FRAME7"]["ANITYPEX"] end,
    set = function(info, v) XM.db["FRAME7"]["ANITYPEX"] = v end,
}

XM.OPTIONS.args.FRAME7.args.ANITYPEY = {
    name = "Animation Type Y",
    desc = "Frame 7 Animation Type Y",
    type = "select", values = {[1] = "Vertical"},
    order = 1710,
    get = function(info) return XM.db["FRAME7"]["ANITYPEY"] end,
    set = function(info, v) XM.db["FRAME7"]["ANITYPEY"] = v end,
}

XM.OPTIONS.args.FRAME7.args.DIRECTIONX = {
    name = "Animation Direction X",
    desc = "Frame 7 Animation Direction X",
    type = "select", values = {[-1] = "LEFT", [1] = "RIGHT"},
    order = 1711,
    get = function(info) return XM.db["FRAME7"]["DIRECTIONX"] end,
    set = function(info, v) XM.db["FRAME7"]["DIRECTIONX"] = v end,
}

XM.OPTIONS.args.FRAME7.args.DIRECTIONY = {
    name = "Animation Direction Y",
    desc = "Frame 7 Animation Direction Y",
    type = "select", values = {[-1] = "DOWN", [1] = "UP"},
    order = 1712,
    get = function(info) return XM.db["FRAME7"]["DIRECTIONY"] end,
    set = function(info, v) XM.db["FRAME7"]["DIRECTIONY"] = v end,
}

XM.OPTIONS.args.FRAME7.args.ADDX = {
    name = "Animation Speed X",
    desc = "Frame 7 Animation Speed X",
    type = "range", min = 1, max = 100, step = 1,
    order = 1713,
    get = function(info) return XM.db["FRAME7"]["ADDX"] end,
    set = function(info, v) XM.db["FRAME7"]["ADDX"] = v end,
}

XM.OPTIONS.args.FRAME7.args.ADDY = {
    name = "Animation Speed Y",
    desc = "Frame 7 Animation Speed Y",
    type = "range", min = 1, max = 100, step = 1,
    order = 1714,
    get = function(info) return XM.db["FRAME7"]["ADDY"] end,
    set = function(info, v) XM.db["FRAME7"]["ADDY"] = v end,
}

XM.OPTIONS.args.FRAME7.args.FRAMESIZE = {
    name = "Frame Size",
    desc = "Frame 7 Frame Size",
    type = "range", min = 1, max = 1000, step = 1,
    order = 1715,
    get = function(info) return XM.db["FRAME7"]["FRAMESIZE"] end,
    set = function(info, v) XM.db["FRAME7"]["FRAMESIZE"] = v end,
}

XM.OPTIONS.args.FRAME8 = {
    name = "Frame 8 Options",
    desc = "Frame 8 Options",
    type = "group",
    order = 1800,
    args = {}
}

XM.OPTIONS.args.FRAME8.args.FONT = {
    name = "Font",
    desc = "Frame 8 Font",
    type = "select", values = XM.sharedMedia:List("font"),
    order = 1801,
    get = function(info) return XM:GetMediaIndex("font", XM.db["FRAME8"]["FONT"]) end,
    set = function(info,v) XM.db["FRAME8"]["FONT"] = XM.sharedMedia:List("font")[v] end,
}

XM.OPTIONS.args.FRAME8.args.TEXTSIZE = {
    name = "Text Size",
    desc = "Frame 8 Text Size",
    type = "range", min = 1, max = 200, step = 1,
    order = 1802,
    get = function(info) return XM.db["FRAME8"]["TEXTSIZE"] end,
    set = function(info, v) XM.db["FRAME8"]["TEXTSIZE"] = v end,
}

XM.OPTIONS.args.FRAME8.args.FONTSHADOW = {
    name = "Font Shadow Type",
    desc = "Frame 8 Font Shadow Type",
    type = "select", values = FontOutline,
    order = 1803,
    get = function(info) return XM.db["FRAME8"]["FONTSHADOW"] end,
    set = function(info, v) XM.db["FRAME8"]["FONTSHADOW"] = v end,
}

XM.OPTIONS.args.FRAME8.args.ALPHA = {
    name = "Text Opacity (Percent)",
    desc = "Frame 8 Text Opacity (percent)",
    type = "range", min = 1, max = 100, step = 1,
    order = 1804,
    get = function(info) return XM.db["FRAME8"]["ALPHA"] end,
    set = function(info, v) XM.db["FRAME8"]["ALPHA"] = v end,
}

XM.OPTIONS.args.FRAME8.args.POSX = {
    name = "X offset",
    desc = "Frame 8 X offset",
    type = "range", min = -1000, max = 1000, step = 1,
    order = 1805,
    get = function(info) return XM.db["FRAME8"]["POSX"] end,
    set = function(info, v) XM.db["FRAME8"]["POSX"] = v end,
}

XM.OPTIONS.args.FRAME8.args.POSY = {
     name = "Y offset",
     desc = "Frame 8 Y offset",
     type = "range", min = -1000, max = 1000, step = 1,
     order = 1806,
     get = function(info) return XM.db["FRAME8"]["POSY"] end,
     set = function(info, v) XM.db["FRAME8"]["POSY"] = v end,
}

XM.OPTIONS.args.FRAME8.args.ALIGN = {
    name = "Text Alignment",
    desc = "Frame 8 Text Alignment",
    type = "select", values = TextAlign,
    order = 1807,
    get = function(info) return XM.db["FRAME8"]["ALIGN"] end,
    set = function(info, v) XM.db["FRAME8"]["ALIGN"] = v end,
}

XM.OPTIONS.args.FRAME8.args.ICONSIDE = {
    name = "Icon Side",
    desc = "Frame 8 Icon Alignment (1=left, 2=right)",
    type = "range", min = 1, max = 2, step = 1,
    order = 1808,
    get = function(info) return XM.db["FRAME8"]["ICONSIDE"] end,
    set = function(info, v) XM.db["FRAME8"]["ICONSIDE"] = v end,
}

XM.OPTIONS.args.FRAME8.args.ANITYPEX = {
    name = "Animation Type X",
    desc = "Frame 8 Animation Type X",
    type = "select", values = {[1] = "None"},
    order = 1809,
    get = function(info) return XM.db["FRAME8"]["ANITYPEX"] end,
    set = function(info, v) XM.db["FRAME8"]["ANITYPEX"] = v end,
}

XM.OPTIONS.args.FRAME8.args.ANITYPEY = {
    name = "Animation Type Y",
    desc = "Frame 8 Animation Type Y",
    type = "select", values = {[1] = "Vertical"},
    order = 1810,
    get = function(info) return XM.db["FRAME8"]["ANITYPEY"] end,
    set = function(info, v) XM.db["FRAME8"]["ANITYPEY"] = v end,
}

XM.OPTIONS.args.FRAME8.args.DIRECTIONX = {
    name = "Animation Direction X",
    desc = "Frame 8 Animation Direction X",
    type = "select", values = {[-1] = "LEFT", [1] = "RIGHT"},
    order = 1811,
    get = function(info) return XM.db["FRAME8"]["DIRECTIONX"] end,
    set = function(info, v) XM.db["FRAME8"]["DIRECTIONX"] = v end,
}

XM.OPTIONS.args.FRAME8.args.DIRECTIONY = {
    name = "Animation Direction Y",
    desc = "Frame 8 Animation Direction Y",
    type = "select", values = {[-1] = "DOWN", [1] = "UP"},
    order = 1812,
    get = function(info) return XM.db["FRAME8"]["DIRECTIONY"] end,
    set = function(info, v) XM.db["FRAME8"]["DIRECTIONY"] = v end,
}

XM.OPTIONS.args.FRAME8.args.ADDX = {
    name = "Animation Speed X",
    desc = "Frame 8 Animation Speed X",
    type = "range", min = 1, max = 100, step = 1,
    order = 1813,
    get = function(info) return XM.db["FRAME8"]["ADDX"] end,
    set = function(info, v) XM.db["FRAME8"]["ADDX"] = v end,
}

XM.OPTIONS.args.FRAME8.args.ADDY = {
    name = "Animation Speed Y",
    desc = "Frame 8 Animation Speed Y",
    type = "range", min = 1, max = 100, step = 1,
    order = 1814,
    get = function(info) return XM.db["FRAME8"]["ADDY"] end,
    set = function(info, v) XM.db["FRAME8"]["ADDY"] = v end,
}

XM.OPTIONS.args.FRAME8.args.FRAMESIZE = {
    name = "Frame Size",
    desc = "Frame 8 Frame Size",
    type = "range", min = 1, max = 1000, step = 1,
    order = 1815,
    get = function(info) return XM.db["FRAME8"]["FRAMESIZE"] end,
    set = function(info, v) XM.db["FRAME8"]["FRAMESIZE"] = v end,
}

XM.OPTIONS.args.FRAME9 = {
    name = "Frame 9 Options",
    desc = "Frame 9 Options",
    type = "group",
    order = 1900,
    args = {}
}

XM.OPTIONS.args.FRAME9.args.FONT = {
    name = "Font",
    desc = "Frame 9 Font",
    type = "select", values = XM.sharedMedia:List("font"),
    order = 1901,
    get = function(info) return XM:GetMediaIndex("font", XM.db["FRAME9"]["FONT"]) end,
    set = function(info,v) XM.db["FRAME9"]["FONT"] = XM.sharedMedia:List("font")[v] end,
}

XM.OPTIONS.args.FRAME9.args.TEXTSIZE = {
    name = "Text Size",
    desc = "Frame 9 Text Size",
    type = "range", min = 1, max = 200, step = 1,
    order = 1902,
    get = function(info) return XM.db["FRAME9"]["TEXTSIZE"] end,
    set = function(info, v) XM.db["FRAME9"]["TEXTSIZE"] = v end,
}

XM.OPTIONS.args.FRAME9.args.FONTSHADOW = {
    name = "Font Shadow Type",
    desc = "Frame 9 Font Shadow Type",
    type = "select", values = FontOutline,
    order = 1903,
    get = function(info) return XM.db["FRAME9"]["FONTSHADOW"] end,
    set = function(info, v) XM.db["FRAME9"]["FONTSHADOW"] = v end,
}

XM.OPTIONS.args.FRAME9.args.ALPHA = {
    name = "Text Opacity (Percent)",
    desc = "Frame 9 Text Opacity (percent)",
    type = "range", min = 1, max = 100, step = 1,
    order = 1904,
    get = function(info) return XM.db["FRAME9"]["ALPHA"] end,
    set = function(info, v) XM.db["FRAME9"]["ALPHA"] = v end,
}

XM.OPTIONS.args.FRAME9.args.POSX = {
    name = "X offset",
    desc = "Frame 9 X offset",
    type = "range", min = -1000, max = 1000, step = 1,
    order = 1905,
    get = function(info) return XM.db["FRAME9"]["POSX"] end,
    set = function(info, v) XM.db["FRAME9"]["POSX"] = v end,
}

XM.OPTIONS.args.FRAME9.args.POSY = {
     name = "Y offset",
     desc = "Frame 9 Y offset",
     type = "range", min = -1000, max = 1000, step = 1,
     order = 1906,
     get = function(info) return XM.db["FRAME9"]["POSY"] end,
     set = function(info, v) XM.db["FRAME9"]["POSY"] = v end,
}

XM.OPTIONS.args.FRAME9.args.ALIGN = {
    name = "Text Alignment",
    desc = "Frame 9 Text Alignment",
    type = "select", values = TextAlign,
    order = 1907,
    get = function(info) return XM.db["FRAME9"]["ALIGN"] end,
    set = function(info, v) XM.db["FRAME9"]["ALIGN"] = v end,
}

XM.OPTIONS.args.FRAME9.args.ICONSIDE = {
    name = "Icon Side",
    desc = "Frame 9 Icon Alignment (1=left, 2=right)",
    type = "range", min = 1, max = 2, step = 1,
    order = 1908,
    get = function(info) return XM.db["FRAME9"]["ICONSIDE"] end,
    set = function(info, v) XM.db["FRAME9"]["ICONSIDE"] = v end,
}

XM.OPTIONS.args.FRAME9.args.ANITYPEX = {
    name = "Animation Type X",
    desc = "Frame 9 Animation Type X",
    type = "select", values = {[1] = "None"},
    order = 1909,
    get = function(info) return XM.db["FRAME9"]["ANITYPEX"] end,
    set = function(info, v) XM.db["FRAME9"]["ANITYPEX"] = v end,
}

XM.OPTIONS.args.FRAME9.args.ANITYPEY = {
    name = "Animation Type Y",
    desc = "Frame 9 Animation Type Y",
    type = "select", values = {[1] = "Vertical"},
    order = 1910,
    get = function(info) return XM.db["FRAME9"]["ANITYPEY"] end,
    set = function(info, v) XM.db["FRAME9"]["ANITYPEY"] = v end,
}

XM.OPTIONS.args.FRAME9.args.DIRECTIONX = {
    name = "Animation Direction X",
    desc = "Frame 9 Animation Direction X",
    type = "select", values = {[-1] = "LEFT", [1] = "RIGHT"},
    order = 1911,
    get = function(info) return XM.db["FRAME9"]["DIRECTIONX"] end,
    set = function(info, v) XM.db["FRAME9"]["DIRECTIONX"] = v end,
}

XM.OPTIONS.args.FRAME9.args.DIRECTIONY = {
    name = "Animation Direction Y",
    desc = "Frame 9 Animation Direction Y",
    type = "select", values = {[-1] = "DOWN", [1] = "UP"},
    order = 1912,
    get = function(info) return XM.db["FRAME9"]["DIRECTIONY"] end,
    set = function(info, v) XM.db["FRAME9"]["DIRECTIONY"] = v end,
}

XM.OPTIONS.args.FRAME9.args.ADDX = {
    name = "Animation Speed X",
    desc = "Frame 9 Animation Speed X",
    type = "range", min = 1, max = 100, step = 1,
    order = 1913,
    get = function(info) return XM.db["FRAME9"]["ADDX"] end,
    set = function(info, v) XM.db["FRAME9"]["ADDX"] = v end,
}

XM.OPTIONS.args.FRAME9.args.ADDY = {
    name = "Animation Speed Y",
    desc = "Frame 9 Animation Speed Y",
    type = "range", min = 1, max = 100, step = 1,
    order = 1914,
    get = function(info) return XM.db["FRAME9"]["ADDY"] end,
    set = function(info, v) XM.db["FRAME9"]["ADDY"] = v end,
}

XM.OPTIONS.args.FRAME9.args.FRAMESIZE = {
    name = "Frame Size",
    desc = "Frame 9 Frame Size",
    type = "range", min = 1, max = 1000, step = 1,
    order = 1915,
    get = function(info) return XM.db["FRAME9"]["FRAMESIZE"] end,
    set = function(info, v) XM.db["FRAME9"]["FRAMESIZE"] = v end,
}

XM.OPTIONS.args.FRAME10 = {
    name = "Frame 10 Options",
    desc = "Frame 10 Options",
    type = "group",
    order = 2000,
    args = {}
}

XM.OPTIONS.args.FRAME10.args.FONT = {
    name = "Font",
    desc = "Frame 10 Font",
    type = "select", values = XM.sharedMedia:List("font"),
    order = 2001,
    get = function(info) return XM:GetMediaIndex("font", XM.db["FRAME10"]["FONT"]) end,
    set = function(info,v) XM.db["FRAME10"]["FONT"] = XM.sharedMedia:List("font")[v] end,
}

XM.OPTIONS.args.FRAME10.args.TEXTSIZE = {
    name = "Text Size",
    desc = "Frame 10 Text Size",
    type = "range", min = 1, max = 200, step = 1,
    order = 2002,
    get = function(info) return XM.db["FRAME10"]["TEXTSIZE"] end,
    set = function(info, v) XM.db["FRAME10"]["TEXTSIZE"] = v end,
}

XM.OPTIONS.args.FRAME10.args.FONTSHADOW = {
    name = "Font Shadow Type",
    desc = "Frame 10 Font Shadow Type",
    type = "select", values = FontOutline,
    order = 2003,
    get = function(info) return XM.db["FRAME10"]["FONTSHADOW"] end,
    set = function(info, v) XM.db["FRAME10"]["FONTSHADOW"] = v end,
}

XM.OPTIONS.args.FRAME10.args.ALPHA = {
    name = "Text Opacity (Percent)",
    desc = "Frame 10 Text Opacity (percent)",
    type = "range", min = 1, max = 100, step = 1,
    order = 2004,
    get = function(info) return XM.db["FRAME10"]["ALPHA"] end,
    set = function(info, v) XM.db["FRAME10"]["ALPHA"] = v end,
}

XM.OPTIONS.args.FRAME10.args.POSX = {
    name = "X offset",
    desc = "Frame 10 X offset",
    type = "range", min = -1000, max = 1000, step = 1,
    order = 2005,
    get = function(info) return XM.db["FRAME10"]["POSX"] end,
    set = function(info, v) XM.db["FRAME10"]["POSX"] = v end,
}

XM.OPTIONS.args.FRAME10.args.POSY = {
     name = "Y offset",
     desc = "Frame 10 Y offset",
     type = "range", min = -1000, max = 1000, step = 1,
     order = 2006,
     get = function(info) return XM.db["FRAME10"]["POSY"] end,
     set = function(info, v) XM.db["FRAME10"]["POSY"] = v end,
}

XM.OPTIONS.args.FRAME10.args.ALIGN = {
    name = "Text Alignment",
    desc = "Frame 10 Text Alignment",
    type = "select", values = TextAlign,
    order = 2007,
    get = function(info) return XM.db["FRAME10"]["ALIGN"] end,
    set = function(info, v) XM.db["FRAME10"]["ALIGN"] = v end,
}

XM.OPTIONS.args.FRAME10.args.ICONSIDE = {
    name = "Icon Side",
    desc = "Frame 10 Icon Alignment (1=left, 2=right)",
    type = "range", min = 1, max = 2, step = 1,
    order = 2008,
    get = function(info) return XM.db["FRAME10"]["ICONSIDE"] end,
    set = function(info, v) XM.db["FRAME10"]["ICONSIDE"] = v end,
}

XM.OPTIONS.args.FRAME10.args.ANITYPEX = {
    name = "Animation Type X",
    desc = "Frame 10 Animation Type X",
    type = "select", values = {[1] = "None"},
    order = 2009,
    get = function(info) return XM.db["FRAME10"]["ANITYPEX"] end,
    set = function(info, v) XM.db["FRAME10"]["ANITYPEX"] = v end,
}

XM.OPTIONS.args.FRAME10.args.ANITYPEY = {
    name = "Animation Type Y",
    desc = "Frame 10 Animation Type Y",
    type = "select", values = {[1] = "Vertical"},
    order = 2010,
    get = function(info) return XM.db["FRAME10"]["ANITYPEY"] end,
    set = function(info, v) XM.db["FRAME10"]["ANITYPEY"] = v end,
}

XM.OPTIONS.args.FRAME10.args.DIRECTIONX = {
    name = "Animation Direction X",
    desc = "Frame 10 Animation Direction X",
    type = "select", values = {[-1] = "LEFT", [1] = "RIGHT"},
    order = 2011,
    get = function(info) return XM.db["FRAME10"]["DIRECTIONX"] end,
    set = function(info, v) XM.db["FRAME10"]["DIRECTIONX"] = v end,
}

XM.OPTIONS.args.FRAME10.args.DIRECTIONY = {
    name = "Animation Direction Y",
    desc = "Frame 10 Animation Direction Y",
    type = "select", values = {[-1] = "DOWN", [1] = "UP"},
    order = 2012,
    get = function(info) return XM.db["FRAME10"]["DIRECTIONY"] end,
    set = function(info, v) XM.db["FRAME10"]["DIRECTIONY"] = v end,
}

XM.OPTIONS.args.FRAME10.args.ADDX = {
    name = "Animation Speed X",
    desc = "Frame 10 Animation Speed X",
    type = "range", min = 1, max = 100, step = 1,
    order = 2013,
    get = function(info) return XM.db["FRAME10"]["ADDX"] end,
    set = function(info, v) XM.db["FRAME10"]["ADDX"] = v end,
}

XM.OPTIONS.args.FRAME10.args.ADDY = {
    name = "Animation Speed Y",
    desc = "Frame 10 Animation Speed Y",
    type = "range", min = 1, max = 100, step = 1,
    order = 2014,
    get = function(info) return XM.db["FRAME10"]["ADDY"] end,
    set = function(info, v) XM.db["FRAME10"]["ADDY"] = v end,
}

XM.OPTIONS.args.FRAME10.args.FRAMESIZE = {
    name = "Frame Size",
    desc = "Frame 10 Frame Size",
    type = "range", min = 1, max = 1000, step = 1,
    order = 2015,
    get = function(info) return XM.db["FRAME10"]["FRAMESIZE"] end,
    set = function(info, v) XM.db["FRAME10"]["FRAMESIZE"] = v end,
}

local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

XM.configDefaults = {
    ["VERSION"] = XM.addonVersion,
    ["CRUSHCHAR"] = "^",
    ["GLANCECHAR"] = "~",
    ["CRITCHAR"] = "+",
    ["MHCHAR"] = "m",
    ["OHCHAR"] = "o",
    ["SHORTSTRING"] = ".",

    ["LOWHPVALUE"] = 40,
    ["LOWMANAVALUE"] = 40,
    ["SHOWALLPOWER"] = false,
    ["DMGFILTERINC"] = 1,
    ["DMGFILTEROUT"] = 1,
    ["HEALFILTERINC"] = 1,
    ["HEALFILTEROUT"] = 1,
    ["SHOWHOTS"] = true,
    ["MANAFILTERINC"] = 1,
    ["SHORTLENGTH"] = 10,
    ["CRITSIZE"] = 120,

    --all events (and which frame to put them in)
    ["LOWHP"] = 2,
    ["EXECUTE"] = 2,
    ["LOWMANA"] = 2,
    ["POWERGAIN"] = 2,
    ["COMBAT"] = 2,
    ["GETLOOT"] = 10,
    ["COMBOPT"] = 0,
    ["SKILLGAIN"] = 10,
    ["KILLBLOW"] = 0,
    ["REPGAIN"] = 2,
    ["HONORGAIN"] = 2,
    ["SPELLACTIVE"] = 4,

    ["HITINC"] = 1,
    ["SPELLINC"] = 1,
    ["DOTINC"] = 1,
    ["DMGSHIELDINC"] = 1,
    ["HITOUT"] = 3,
    ["SPELLOUT"] = 3,
    ["DOTOUT"] = 3,
    ["DMGSHIELDOUT"] = 3,

    ["HEALINC"] = 2,
    ["HEALOUT"] = 3,

    ["MISSINC"] = 1,
    ["DODGEINC"] = 1,
    ["BLOCKINC"] = 1,
    ["DEFLECTINC"] = 1,
    ["IMMUNEINC"] = 1,
    ["EVADEINC"] = 1,
    ["PARRYINC"] = 1,
    ["RESISTINC"] = 1,
    ["ABSORBINC"] = 1,
    ["REFLECTINC"] = 1,

    ["MISSOUT"] = 3,
    ["DODGEOUT"] = 3,
    ["BLOCKOUT"] = 3,
    ["DEFLECTOUT"] = 3,
    ["IMMUNEOUT"] = 3,
    ["EVADEOUT"] = 3,
    ["PARRYOUT"] = 3,
    ["RESISTOUT"] = 3,
    ["ABSORBOUT"] = 3,
    ["REFLECTOUT"] = 3,

    ["INTERRUPTINC"] = 1,
    ["INTERRUPTOUT"] = 3,

    ["PETHITOUT"] = 3,
    ["PETDOTOUT"] = 3,
    ["PETSPELLOUT"] = 3,
    ["PETMISSOUT"] = 3,

    ["PETHITINC"] = 1,
    ["PETDOTINC"] = 1,
    ["PETSPELLINC"] = 1,
    ["PETMISSINC"] = 1,

    ["BUFFGAIN"] = 0,
    ["BUFFFADE"] = 0,
    ["DEBUFFGAIN"] = 0,
    ["DEBUFFFADE"] = 0,

    --show skill names for these events (-1 = no show, 0 = full name, 1 = truncate, 2 = abbreviate)
    ["SHOWSKILL"] = {
        ["LOWHP"] = -1,
        ["EXECUTE"] = 0,
        ["LOWMANA"] = -1,
        ["POWERGAIN"] = 1,
        ["COMBAT"] = -1,
        ["GETLOOT"] = -1,
        ["COMBOPT"] = -1,
        ["SKILLGAIN"] = -1,
        ["KILLBLOW"] = -1,
        ["REPGAIN"] = -1,
        ["HONORGAIN"] = -1,
        ["SPELLACTIVE"] = -1,

        ["HITINC"] = 1,
        ["HITOUT"] = 1,
        ["SPELLINC"] = 1,
        ["DOTINC"] = 1,
        ["DMGSHIELDINC"] = 1,
        ["SPELLOUT"] = 0,
        ["DOTOUT"] = 0,
        ["DMGSHIELDOUT"] = 1,

        ["HEALINC"] = 1,
        ["HEALOUT"] = 0,

        ["MISSINC"] = 1,
        ["DODGEINC"] = 1,
        ["BLOCKINC"] = 1,
        ["DEFLECTINC"] = 1,
        ["IMMUNEINC"] = 1,
        ["EVADEINC"] = 1,
        ["PARRYINC"] = 1,
        ["RESISTINC"] = 1,
        ["ABSORBINC"] = 1,
        ["REFLECTINC"] = 1,

        ["MISSOUT"] = 0,
        ["DODGEOUT"] = 0,
        ["BLOCKOUT"] = 0,
        ["DEFLECTOUT"] = 0,
        ["IMMUNEOUT"] = 0,
        ["EVADEOUT"] = 0,
        ["PARRYOUT"] = 0,
        ["RESISTOUT"] = 0,
        ["ABSORBOUT"] = 0,
        ["REFLECTOUT"] = 0,

        ["INTERRUPTINC"] = 1,
        ["INTERRUPTOUT"] = 0,

        ["PETDOTOUT"] = 0,
        ["PETSPELLOUT"] = 0,
        ["PETMISSOUT"] = 0,

        ["PETDOTINC"] = 0,
        ["PETSPELLINC"] = 0,
        ["PETMISSINC"] = 0,

        --element (-1 = no name or color, 0 = full name & color, 1 = brackets & color, 2 = color only)
        ["ELEMENT"] = 2,
    },

    --show target names for these events (-1 = no show, 0 = full name, 1 = truncate, 2 = abbreviate)
    ["SHOWTARGET"] = {
        ["LOWHP"] = -1,
        ["EXECUTE"] = -1,
        ["LOWMANA"] = -1,
        ["POWERGAIN"] = -1,
        ["COMBAT"] = -1,
        ["GETLOOT"] = -1,
        ["COMBOPT"] = -1,
        ["SKILLGAIN"] = -1,
        ["KILLBLOW"] = -1,
        ["REPGAIN"] = -1,
        ["HONORGAIN"] = -1,
        ["SPELLACTIVE"] = -1,

        ["HITINC"] = -1,
        ["SPELLINC"] = 1,
        ["DOTINC"] = 1,
        ["DMGSHIELDINC"] = -1,
        ["HITOUT"] = -1,
        ["SPELLOUT"] = -1,
        ["DOTOUT"] = -1,
        ["DMGSHIELDOUT"] = -1,

        ["HEALINC"] = 1,
        ["HEALOUT"] = 0,

        ["MISSINC"] = -1,
        ["DODGEINC"] = -1,
        ["BLOCKINC"] = -1,
        ["DEFLECTINC"] = -1,
        ["IMMUNEINC"] = -1,
        ["EVADEINC"] = -1,
        ["PARRYINC"] = -1,
        ["RESISTINC"] = -1,
        ["ABSORBINC"] = -1,
        ["REFLECTINC"] = -1,

        ["MISSOUT"] = -1,
        ["DODGEOUT"] = -1,
        ["BLOCKOUT"] = -1,
        ["DEFLECTOUT"] = -1,
        ["IMMUNEOUT"] = -1,
        ["EVADEOUT"] = -1,
        ["PARRYOUT"] = -1,
        ["RESISTOUT"] = -1,
        ["ABSORBOUT"] = -1,
        ["REFLECTOUT"] = -1,

        ["INTERRUPTINC"] = -1,
        ["INTERRUPTOUT"] = -1,

        ["PETHITOUT"] = -1,
        ["PETSPELLOUT"] = -1,
        ["PETDOTOUT"] = -1,
        ["PETMISSOUT"] = -1,

        ["PETHITINC"] = -1,
        ["PETSPELLINC"] = -1,
        ["PETDOTINC"] = -1,
        ["PETMISSINC"] = -1,
    },

    --event colors
    --white		1.0, 1.0, 1.0*
    --gray		0.5, 0.5, 0.5*
    --black		0.0, 0.0, 0.0*
    --red 		1.0, 0.0, 0.0*
    --orange	1.0, 0.5, 0.0*
    --yellow	1.0, 1.0, 0.0*
    --green		0.0, 1.0, 0.0*
    --blue		0.2, 0.2, 1.0*
    --purple	0.5, 0.0, 1.0*
    --light red	1.0, 0.5, 0.5*
    --light orange	1.0, 0.8, 0.0*
    --light yellow	1.0, 1.0, 0.5*
    --light green	0.5, 1.0, 0.5*
    --light blue	0.0, 0.5, 1.0*
    --light purple	0.8, 0.5, 1.0*
    --dark red	0.8, 0.0, 0.2*
    --dark orange	0.8, 0.5, 0.2*
    --dark yellow	0.8, 0.8, 0.0*
    --dark green	0.0, 0.5, 0.0*
    --dark blue	0.0, 0.0, 0.5*
    --dark purple	0.5, 0.2, 0,5*
    --blue green	0.0, 0.5, 0.2*

    ["COLOR_TABLE"] = {

        ["LOWHP"] = {r = 1.0, g = 0.0, b = 0.0, a = 1.0}, 		--*red
        ["EXECUTE"] = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, 	--*white
        ["LOWMANA"] = {r = 0.0, g = 0.5, b = 1.0, a = 1.0}, 	--*light blue
        ["POWERGAIN"] = {r = 0.0, g = 0.5, b = 1.0, a = 1.0}, 	--*light blue
        ["COMBAT"] = { r = 1.0, g = 0.5, b = 0.5, a = 1.0}, 	--*light red
        ["GETLOOT"] = { r = 0.0, g = 0.5, b = 0.0, a = 1.0}, 	--*dark green
        ["COMBOPT"] = { r = 1.0, g = 1.0, b = 0.0, a = 1.0}, 	--*yellow
        ["SKILLGAIN"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["KILLBLOW"] = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, 	--*white
        ["REPGAIN"] = {r = 0.8, g = 0.5, b = 1.0, a = 1.0}, 	--*light purple
        ["HONORGAIN"] = {r = 1.0, g = 0.5, b = 0.0, a = 1.0}, 	--*orange
        ["SPELLACTIVE"] = {r = 1.0, g = 0.5, b = 0.0, a = 1.0},     --*orange

        ["HITINC"] = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, 		--*white
        ["SPELLINC"] = {r = 1.0, g = 1.0, b = 0.0, a = 1.0}, 	--*yellow
        ["HITOUT"] = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, 		--*white
        ["SPELLOUT"] = {r = 1.0, g = 1.0, b = 0.0, a = 1.0}, 	--*yellow
        ["DOTOUT"] = {r = 1.0, g = 1.0, b = 0.0, a = 1.0}, 		--*yellow
        ["DMGSHIELDOUT"] = {r = 0.8, g = 0.8, b = 0.0, a = 1.0}, 	--*dark yellow
        ["DOTINC"] = {r = 1.0, g = 1.0, b = 0.0, a = 1.0}, 		--*yellow
        ["DMGSHIELDINC"] = {r = 0.8, g = 0.8, b = 0.0, a = 1.0}, 	--*dark yellow

        ["HEALINC"] = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}, 	--*green
        ["HEALOUT"] = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}, 	--*green

        ["MISSINC"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["DODGEINC"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["BLOCKINC"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["PARRYINC"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["DEFLECTINC"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["REFLECTINC"] = {r = 1.0, g = 1.0, b = 0.5, a = 1.0}, 	--*light yellow
        ["RESISTINC"] = {r = 1.0, g = 1.0, b = 0.5, a = 1.0}, 	--*light yellow
        ["ABSORBINC"] = {r = 1.0, g = 1.0, b = 0.5, a = 1.0}, 	--*light yellow
        ["IMMUNEINC"] = {r = 1.0, g = 1.0, b = 0.5, a = 1.0}, 	--*light yellow
        ["EVADEINC"] = {r = 1.0, g = 1.0, b = 0.5, a = 1.0}, 	--*light yellow

        ["MISSOUT"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["DODGEOUT"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["BLOCKOUT"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["PARRYOUT"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["DEFLECTOUT"] = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, 	--*blue
        ["REFLECTOUT"] = {r = 1.0, g = 1.0, b = 0, a = 1.0}, 	--*yellow
        ["RESISTOUT"] = {r = 1.0, g = 1.0, b = 0.5, a = 1.0}, 	--*light yellow
        ["ABSORBOUT"] = {r = 1.0, g = 1.0, b = 0.5, a = 1.0}, 	--*light yellow
        ["IMMUNEOUT"] = {r = 1.0, g = 1.0, b = 0.5, a = 1.0}, 	--*light yellow
        ["EVADEOUT"] = {r = 1.0, g = 1.0, b = 0.5, a = 1.0}, 	--*light yellow

        ["INTERRUPTINC"] = {r = 0.8, g = 0.5, b = 1.0, a = 1.0}, 	--*light purple
        ["INTERRUPTOUT"] = {r = 0.8, g = 0.5, b = 1.0, a = 1.0}, 	--*light purple

        ["PETHITOUT"] = {r = 0.5, g = 0.5, b = 0.5, a = 1.0}, 	--*gray
        ["PETDOTOUT"] = {r = 0.8, g = 0.8, b = 0.0, a = 1.0}, 	--*dark yellow
        ["PETSPELLOUT"] = {r = 0.8, g = 0.8, b = 0.0, a = 1.0}, 	--*dark yellow
        ["PETMISSOUT"] = {r = 0.0, g = 0.0, b = 0.5, a = 1.0}, 	--*dark blue

        ["PETHITINC"] = {r = 0.5, g = 0.5, b = 0.5, a = 1.0}, 	--*gray
        ["PETDOTINC"] = {r = 0.8, g = 0.8, b = 0.0, a = 1.0}, 	--*dark yellow
        ["PETSPELLINC"] = {r = 0.8, g = 0.8, b = 0.0, a = 1.0}, 	--*dark yellow
        ["PETMISSINC"] = {r = 0.0, g = 0.0, b = 0.5, a = 1.0}, 	--*dark blue

        ["BUFFGAIN"] = {r = 0.0, g = 0.5, b = 0.0, a = 1.0}, 	--*dark green
        ["BUFFFADE"] = {r = 0.5, g = 1.0, b = 0.5, a = 1.0}, 	--*light green
        ["DEBUFFGAIN"] = {r = 0.8, g = 0.0, b = 0.2, a = 1.0}, 	--*dark red
        ["DEBUFFFADE"] = {r = 1.0, g = 0.5, b = 0.5, a = 1.0}, 	--*light red
    },

    --elemental colors
    ["COLOR_SPELL"] = {
        ["PHYSICAL"] = {r = 1.0, g = 0.0, b = 0.0, a = 1.0}, 	--*red
        ["HOLY"] = {r = 0.8, g = 0.8, b = 0.0, a = 1.0}, 		--*dark yellow
        ["FIRE"] = {r = 1.0, g = 0.5, b = 0.0, a = 1.0}, 		--*orange
        ["NATURE"] = {r = 0.0, g = 0.5, b = 0.2, a = 1.0}, 		--*blue green
        ["FROST"] = {r = 0.0, g = 0.5, b = 1.0, a = 1.0}, 		--*light blue
        ["FROSTSTORM"] = {r = 0.0, g = 0.5, b = 1.0, a = 1.0}, 	--*light blue
        ["SHADOW"] = {r = 0.5, g = 0.5, b = 0.5, a = 1.0}, 		--*gray
        ["SHADOWSTORM"] = {r = 0.5, g = 0.5, b = 0.5, a = 1.0},		--*gray
        ["ARCANE"] = {r = 0.5, g = 0, b = 1.0, a = 1.0}, 		--*purple
    },

    --frame settings
    --direction: -1 = down, 1 = up
    --align: 1 = left, 2 = center, 3 = right

    ["FRAME1"] = {
        ["FONT"] = "Emblem",
        ["TEXTSIZE"] = 18,
        ["FONTSHADOW"] = 1,
        ["ALPHA"] = 80,
        ["POSX"] = -300,
        ["POSY"] = -100,
        ["ALIGN"] = 1,
        ["ICONSIDE"] = 2,
        ["ANITYPEX"] = 1,
        ["ANITYPEY"] = 1,
        ["DIRECTIONX"] = 1,
        ["DIRECTIONY"] = 1,
        ["ADDX"] = 1,
        ["ADDY"] = 30,
        ["FRAMESIZE"] = 400,
    },
    ["FRAME2"] = {
        ["FONT"] = "Emblem",
        ["TEXTSIZE"] = 18,
        ["FONTSHADOW"] = 1,
        ["ALPHA"] = 80,
        ["POSX"] = 0,
        ["POSY"] = 60,
        ["ALIGN"] = 2,
        ["ICONSIDE"] = 2,
        ["ANITYPEX"] = 1,
        ["ANITYPEY"] = 1,
        ["DIRECTIONX"] = 1,
        ["DIRECTIONY"] = 1,
        ["ADDX"] = 1,
        ["ADDY"] = 30,
        ["FRAMESIZE"] = 180,
    },
    ["FRAME3"] = {
        ["FONT"] = "Emblem",
        ["TEXTSIZE"] = 18,
        ["FONTSHADOW"] = 1,
        ["ALPHA"] = 80,
        ["POSX"] = 200,
        ["POSY"] = -100,
        ["ALIGN"] = 1,
        ["ICONSIDE"] = 2,
        ["ANITYPEX"] = 1,
        ["ANITYPEY"] = 1,
        ["DIRECTIONX"] = 1,
        ["DIRECTIONY"] = 1,
        ["ADDX"] = 1,
        ["ADDY"] = 30,
        ["FRAMESIZE"] = 400,
    },
    ["FRAME4"] = {
        ["FONT"] = "Emblem",
        ["TEXTSIZE"] = 24,
        ["FONTSHADOW"] = 1,
        ["ALPHA"] = 80,
        ["POSX"] = 60,
        ["POSY"] = 60,
        ["ALIGN"] = 1,
        ["ICONSIDE"] = 2,
        ["ANITYPEX"] = 1,
        ["ANITYPEY"] = 1,
        ["DIRECTIONX"] = 1,
        ["DIRECTIONY"] = 1,
        ["ADDX"] = 1,
        ["ADDY"] = 0,
        ["FRAMESIZE"] = 400,
    },
    ["FRAME5"] = {
        ["FONT"] = "Emblem",
        ["TEXTSIZE"] = 18,
        ["FONTSHADOW"] = 1,
        ["ALPHA"] = 80,
        ["POSX"] = -300,
        ["POSY"] = -100,
        ["ALIGN"] = 1,
        ["ICONSIDE"] = 2,
        ["ANITYPEX"] = 1,
        ["ANITYPEY"] = 1,
        ["DIRECTIONX"] = 1,
        ["DIRECTIONY"] = 1,
        ["ADDX"] = 1,
        ["ADDY"] = 30,
        ["FRAMESIZE"] = 400,
    },
    ["FRAME6"] = {
        ["FONT"] = "Emblem",
        ["TEXTSIZE"] = 18,
        ["FONTSHADOW"] = 1,
        ["ALPHA"] = 80,
        ["POSX"] = -300,
        ["POSY"] = -100,
        ["ALIGN"] = 1,
        ["ICONSIDE"] = 2,
        ["ANITYPEX"] = 1,
        ["ANITYPEY"] = 1,
        ["DIRECTIONX"] = 1,
        ["DIRECTIONY"] = 1,
        ["ADDX"] = 1,
        ["ADDY"] = 30,
        ["FRAMESIZE"] = 400,
    },
    ["FRAME7"] = {
        ["FONT"] = "Emblem",
        ["TEXTSIZE"] = 18,
        ["FONTSHADOW"] = 1,
        ["ALPHA"] = 80,
        ["POSX"] = -300,
        ["POSY"] = -100,
        ["ALIGN"] = 1,
        ["ICONSIDE"] = 2,
        ["ANITYPEX"] = 1,
        ["ANITYPEY"] = 1,
        ["DIRECTIONX"] = 1,
        ["DIRECTIONY"] = 1,
        ["ADDX"] = 1,
        ["ADDY"] = 30,
        ["FRAMESIZE"] = 400,
    },
    ["FRAME8"] = {
        ["FONT"] = "Emblem",
        ["TEXTSIZE"] = 18,
        ["FONTSHADOW"] = 1,
        ["ALPHA"] = 80,
        ["POSX"] = -300,
        ["POSY"] = -100,
        ["ALIGN"] = 1,
        ["ICONSIDE"] = 2,
        ["ANITYPEX"] = 1,
        ["ANITYPEY"] = 1,
        ["DIRECTIONX"] = 1,
        ["DIRECTIONY"] = 1,
        ["ADDX"] = 1,
        ["ADDY"] = 30,
        ["FRAMESIZE"] = 400,
    },
    ["FRAME9"] = {
        ["FONT"] = "Emblem",
        ["TEXTSIZE"] = 18,
        ["FONTSHADOW"] = 1,
        ["ALPHA"] = 80,
        ["POSX"] = -150,
        ["POSY"] = -150,
        ["ALIGN"] = 2,
        ["ICONSIDE"] = 2,
        ["ANITYPEX"] = 1,
        ["ANITYPEY"] = 1,
        ["DIRECTIONX"] = -1,
        ["DIRECTIONY"] = -1,
        ["ADDX"] = 1,
        ["ADDY"] = 15,
        ["FRAMESIZE"] = 150,
    },
    ["FRAME10"] = {
        ["FONT"] = "Emblem",
        ["TEXTSIZE"] = 18,
        ["FONTSHADOW"] = 1,
        ["ALPHA"] = 80,
        ["POSX"] = 0,
        ["POSY"] = -150,
        ["ALIGN"] = 2,
        ["ICONSIDE"] = 2,
        ["ANITYPEX"] = 1,
        ["ANITYPEY"] = 1,
        ["DIRECTIONX"] = -1,
        ["DIRECTIONY"] = -1,
        ["ADDX"] = 1,
        ["ADDY"] = 15,
        ["FRAMESIZE"] = 150,
    }
}

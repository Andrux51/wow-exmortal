--MUST HAVE "xm_init.lua" LOADED FIRST

--these spells do not appear in the combat log when you cast them
--they fire a SPELL_CAST_SUCCESS event
--and then either a SPELL_MISSED or a SPELL_AURA_START for your current target (not always listing you as the source)
--but if it's a "refreshable spell" like demo shout or sunder[x5], no events fire for the refresh!

--[unique number] = {"spellname", "debuffname", "debuffmaxcount"}
XM.SPELLTABLE = {
--druid (100)
--hunter(200)
--mage(300)
--paladin(400)
	[401] = {SPELL="Hammer of Justice", 	DEBUFF = "Hammer of Justice", 		COUNT = 1},
	[402] = {SPELL="Judgement of the Crusader",	DEBUFF = "Judgement of the Crusader",	COUNT = 1},
--priest(500)
--rogue(600)
--shaman(700)
	[701] = {SPELL="Hex",
DEBUFF = "Hex",				COUNT=1},
	[702] = {SPELL="Wind Shear",
DEBUFF = "Wind Shear",			COUNT=1},
--warlock(800)
--warrior(900)
	[901] = {SPELL="Taunt", 			DEBUFF = "Taunt", 			COUNT = 1},
	[902] = {SPELL="Demoralizing Shout", 	DEBUFF = "Demoralizing Shout",		COUNT = 1},
	[903] = {SPELL="Concussion Blow", 		DEBUFF = "Concussion Blow",		COUNT = 1},
	[904] = {SPELL="Sunder Armor", 		DEBUFF = "Sunder Armor",		COUNT = 5},
	[905] = {SPELL="Devastate", 		DEBUFF = "Sunder Armor", 		COUNT = 5},
	[906] = {SPELL="Intimidating Shout", 	DEBUFF = "Intimidating Shout",		COUNT = 1},
	[907] = {SPELL="Challenging Shout", 	DEBUFF = "Challenging Shout",		COUNT = 1},
	[908] = {SPELL="Disarm", 			DEBUFF = "Disarm", 			COUNT = 1},
	[909] = {SPELL="Hamstring", 		DEBUFF = "Hamstring", 			COUNT = 1},
	[910] = {SPELL="Rend", 			DEBUFF = "Rend", 			COUNT = 1},
--deathknight(1000)
	[1001] = {SPELL="Dark Command",
DEBUFF = "Dark Command",		COUNT = 1},
	[1002] = {SPELL="Death Grip",
DEBUFF = "Death Grip",			COUNT = 1},
	[1003] = {SPELL="Chains of Ice",
DEBUFF = "Chains of Ice",		COUNT = 1},
}

--link spellID to translations for easy coding??
XM.BABBLESPELL = {}

--talents named differently from spells ([spell] = "talent")
XM.TALENTTABLE = {
    ["Execute"] = "Improved Execute",
    ["Overpower"] = "Improved Overpower",
    ["Slam"] = "Improved Slam",
}

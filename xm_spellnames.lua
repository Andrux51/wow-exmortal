local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

--these spells do not appear in the combat log when you cast them
--they fire a SPELL_CAST_SUCCESS event
--and then either a SPELL_MISSED or a SPELL_AURA_START for your current target (not always listing you as the source)
--but if it's a "refreshable spell" like demo shout or sunder[x5], no events fire for the refresh!
-- [unique number] = {"spellname", "debuffname", "debuffmaxcount"}

XM.extraSpells = {
--druid (100)
--hunter(200)
--mage(300)
--paladin(400)
	[401] = {name = "Hammer of Justice", debuffName = "Hammer of Justice", maxStacks = 1},
	[402] = {name = "Judgement of the Crusader",	debuffName = "Judgement of the Crusader", maxStacks = 1},
--priest(500)
--rogue(600)
--warlock(800)
--warrior(900)
	[901] = {name = "Taunt", debuffName = "Taunt", maxStacks = 1},
	[902] = {name = "Demoralizing Shout", debuffName = "Demoralizing Shout", maxStacks = 1},
	[903] = {name = "Concussion Blow", debuffName = "Concussion Blow", maxStacks = 1},
	[904] = {name = "Sunder Armor", debuffName = "Sunder Armor", maxStacks = 5},
	[905] = {name = "Devastate", debuffName = "Sunder Armor", maxStacks = 5},
	[906] = {name = "Intimidating Shout", debuffName = "Intimidating Shout", maxStacks = 1},
	[907] = {name = "Challenging Shout", debuffName = "Challenging Shout", maxStacks = 1},
	[908] = {name = "Disarm", debuffName = "Disarm", maxStacks = 1},
	[909] = {name = "Hamstring", debuffName = "Hamstring", maxStacks = 1},
	[910] = {name = "Rend", debuffName = "Rend", maxStacks = 1},
--deathknight(1000)
	[1001] = {name = "Dark Command", debuffName = "Dark Command", maxStacks = 1},
	[1002] = {name = "Death Grip", debuffName = "Death Grip", maxStacks = 1},
	[1003] = {name = "Chains of Ice", debuffName = "Chains of Ice", maxStacks = 1},
}

--talents named differently from spells ([spell] = "talent")
-- XM.TALENTTABLE = {
--     ["Execute"] = "Improved Execute",
--     ["Overpower"] = "Improved Overpower",
--     ["Slam"] = "Improved Slam",
-- }

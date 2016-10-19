local addonName = ...
local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

XM.locale = LibStub:GetLibrary("AceLocale-3.0"):NewLocale("XM", "enUS", true)

--US ENGLISH

--addon name
local addonNameColor = 'AAFFAA'
XM.locale.addonName = XM:ColorizeString(addonName, addonNameColor)

--static messages
XM.locale["LOWHP"] = "Low Health"		-- Message to display when HP is low
XM.locale["LOWMANA"] = "Low Mana"		-- Message to display when Mana is low
XM.locale["COMBAT"] = "+Combat"			-- Message to display when entering combat
XM.locale["NOCOMBAT"] = "-Combat"		-- Message to display when leaving combat
XM.locale["KILLINGBLOW"] = "Killing Blow"	-- Message to display when you kill something
XM.locale["INTERRUPT"] = "Interrupt"		-- Message to display for interrupts
XM.locale["COMBOPOINT"] = "Combo Point"		-- Message to display when you have one combo point
XM.locale["COMBOPOINTS"] = "Combo Points"	-- Message to display when you have multiple combo points
XM.locale["COMBOPOINTFULL"] = "Finish It"	-- Message to display when you have full combo points

--miss events
XM.locale["ABSORB"] = "Absorb"
XM.locale["BLOCK"] = "Block"
XM.locale["RESIST"] = "Resist"
XM.locale["REFLECT"] = "Reflect"

--initialize settings
XM.locale["INITIALIZE"] = "Initializing Settings: "
XM.locale["SAVEDSETTINGS"] = "Using Saved Settings: "

--length of first word of skill gain message
--(eg. "[You] have gained the Blacksmithing skill.")
--(eg. "[Your] skill in Cooking has increased to 221.")
XM.locale["SKILLNONE"] = 3
XM.locale["SKILLSOME"] = 4

--position of skill (none) string character (eg. "You have gained the [B]lacksmithing skill.")
XM.locale["SKILLNONESTART"] = 21

--position of skill (some) string character (eg. "Your skill in [C]ooking has increased to 221.")
XM.locale["SKILLSOMESTART"] = 15

--number of characters between skill and rank (eg. "Your skill in Cooking[ has increased to ]221.")
XM.locale["SKILLSOMERANK"] = 18

XM.locale["confirm_reset"] = "This will irreversibly reset the current profile to default settings.\n\nAre you sure?"

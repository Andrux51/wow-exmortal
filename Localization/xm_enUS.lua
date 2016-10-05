--MUST HAVE "xm_init.lua" LOADED FIRST

--embedded libs
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local XM_Locale = AceLocale:NewLocale("XM", "enUS", true)

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--ENGLISH

--sample message
XM_Locale["EXAMPLE"] = "Sample Text Message"

--static messages
XM_Locale["LOWHP"] = "Low Health"		-- Message to display when HP is low
XM_Locale["LOWMANA"] = "Low Mana"		-- Message to display when Mana is low
XM_Locale["COMBAT"] = "+Combat"			-- Message to display when entering combat
XM_Locale["NOCOMBAT"] = "-Combat"		-- Message to display when leaving combat
XM_Locale["KILLINGBLOW"] = "Killing Blow"	-- Message to display when you kill something
XM_Locale["INTERRUPT"] = "Interrupt"		-- Message to display for interrupts
XM_Locale["COMBOPOINT"] = "Combo Point"		-- Message to display when you have one combo point
XM_Locale["COMBOPOINTS"] = "Combo Points"	-- Message to display when you have multiple combo points
XM_Locale["COMBOPOINTFULL"] = "Finish It"	-- Message to display when you have full combo points

--miss events
XM_Locale["ABSORB"] = "Absorb"
XM_Locale["BLOCK"] = "Block"
XM_Locale["RESIST"] = "Resist"
XM_Locale["REFLECT"] = "Reflect"

--addon idstring
XM_Locale["IDSTRING"] = "|cff007FFF eXMortal ("..XM.VERSION.."): |cffFFFFFF "

--initialize settings
XM_Locale["INITIALIZE"] = "Initializing Settings: "
XM_Locale["SAVEDSETTINGS"] = "Using Saved Settings: "

--startup message
XM_Locale["STARTUP"] = "Loaded. (|cff007AFF /xm |cffFFFFFF)"

--length of first word of skill gain message
--(eg. "[You] have gained the Blacksmithing skill.") 
--(eg. "[Your] skill in Cooking has increased to 221.") 
XM_Locale["SKILLNONE"] = 3
XM_Locale["SKILLSOME"] = 4

--position of skill (none) string character (eg. "You have gained the [B]lacksmithing skill.")
XM_Locale["SKILLNONESTART"] = 21

--position of skill (some) string character (eg. "Your skill in [C]ooking has increased to 221.")
XM_Locale["SKILLSOMESTART"] = 15

--number of characters between skill and rank (eg. "Your skill in Cooking[ has increased to ]221.")
XM_Locale["SKILLSOMERANK"] = 18
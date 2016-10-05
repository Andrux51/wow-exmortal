--eXMortal object (REQUIRED)
if (not XM) then
    XM = LibStub("AceAddon-3.0"):NewAddon("XM", "AceEvent-3.0", "AceConsole-3.0")
end

--eXMortal version number
XM.VERSION = "302.09"

--global embedded libs
XM_DB = nil --defined at xm.lua OnInitialize(requires char info)

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--GLOBAL FUNCTIONS (accessible to all xm scripts and modules)
--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:SpellCheck(inpspell)
--determines if a player spell exists (returns nil if no spell found, 0 if spell found)
--inpspell: [string] - name of spell as it appears in spellbook
--could add rank check if needed

    local spellname,spellSubName
    local i = 1
    while (i >= 1) do
        spellname, spellSubName = GetSpellName(i, BOOKTYPE_SPELL)
        if (not spellname) then
            i = 0
            return nil
        elseif (spellname == inpspell) then
            i = 0
            return 0
        else
            i = i + 1
        end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:TalentCheck(inptalent, inptarget)
--determines number of talent points (returns nil if no talent found, or number)
--inptalent: [string] - name of talent as it appears in the tab
--inptarget: [boolean] - false for "player", true for "inspect"

    if (not inptarget) then inptarget = false end
    local nametalent,iconpath,tier,column,currentrank,maxrank,isexceptional,meetsprereq
    local i,j = 1,1
    while (i + j >= 2) do
        nametalent, iconpath, tier, column, currentrank, maxrank, isexceptional, meetsprereq = GetTalentInfo(i, j, inptarget)
        if (not nametalent) then
            if (i == 1) and (j == 1) then
                i,j = 0,0
                return nil
            else
                i = i + 1
                j = 1
            end
        elseif (nametalent == inptalent) then
            i,j = 0,0
            return currentrank
        else
            j = j + 1
        end
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:SpellTalentCheck(inpspell, inptalent, inptarget)
--combined function to determine if a player spell exists, and number of talent points (returns nil if spell or talent doesnt exist, or number of talent points)

    if (inptarget == nil or inptarget == false) then inptarget = false end
    if (inptalent == nil or inptalent == false) then inptalent = false end
    --first check if spell exists
    if (XM:SpellCheck(inpspell) == nil) then
        return nil
    else
        if (not inptalent) then
            --make exceptions for talents named differently from spells
            local key, value
            for key, value in pairs(XM.TALENTTABLE) do
                if (key == inpspell) then
                    inptalent = value
                end
            end
        end
        if (inptalent == nil) then
            return nil
        else
            return XM:TalentCheck(inptalent, inptarget)
        end
    end    

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--GLOBAL VARIABLES (accessible to all xm scripts and modules)
--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
xm_PlayerName = ""
xm_PlayerClassText = ""
xm_PlayerClassName = ""
xm_InCombat = false

xm_PowerTable = {
    [-2] = "Health",
    [0] = "Mana",
    [1] = "Rage",
    [2] = "Focus",
    [3] = "Energy",
    --[4] = "Pet Happiness",
    [5] = "Runes",
    [6] = "Runic Power"
    --[7] = "Soul Shards"
    --[8] = "Eclipse"
    --[9] = "Holy Power"
}

xm_ElementTable ={
    [1] = "physical",
    [2] = "holy",
    [4] = "fire",
    [8] = "nature",
    [16] = "frost",
    [20] = "frostfire",
    [24] = "froststorm",
    [32] = "shadow",
    [40] = "shadowstorm",
    [64] = "arcane",
}

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:GroupMemberList(grouptype)
--grouptype = "raid" or "party"

    local partycount = 5
    local groupcount = 8
    local groupmaxcount = 0

    if (grouptype == "party") then
        groupmaxcount = partycount
    elseif (grouptype == "raid") then
        groupmaxcount = partycount*groupcount
    end

    local groupmemberlist = {}
    local groupplayerlist = {} --unitid, unitname
    local grouppetlist = {} --unitid, unitname, ownerid

    local i,j,k = 1,1,1
    local playername,petname
    while (i <= groupmaxcount) do
        playername,_ = UnitName(grouptype..i)
        if (playername) then
            j = #groupplayerlist + 1
            groupplayerlist[j] = {}
            groupplayerlist[j].ID = UnitGUID(grouptype..i)
            groupplayerlist[j].NAME = playername
            petname,_ = UnitName(grouptype.."pet"..i)
            if (petname) then
                k = #grouppetlist + 1
                grouppetlist[k] = {}
                grouppetlist[k].ID = UnitGUID(grouptype.."pet"..i)
                grouppetlist[k].NAME = petname
                grouppetlist[k].OWNERID = UnitGUID(grouptype..i)
                grouppetlist[k].OWNERNAME = UnitName(grouptype..i)
            end
        else
            i = groupmaxcount + 1
        end
        i = i + 1
    end

    groupmemberlist[1] = groupplayerlist
    groupmemberlist[2] = grouppetlist

    return groupmemberlist

end
local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

function XM:DefaultChatMessage(...)
    DEFAULT_CHAT_FRAME:AddMessage(string.format(...))
end

function XM:ColorizeString(msg, hex)
    -- I'm too lazy to write FF in front of every string I want to color
    if(strlen(hex) == 6) then hex = 'FF'..hex end

    return '|c'..hex..msg..'|r'
end

function XM:PadLeft(str, chars)
    local result = str

    if strlen(str) < chars then
        for i = strlen(str)+1, chars do
            result = '0'..result
        end
    end

    return result
end

--determines number of talent points (returns nil if no talent found, or number)
function XM:TalentCheck(inptalent, inptarget)
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

--combined function to determine if a player spell exists, and number of talent points (returns nil if spell or talent doesnt exist, or number of talent points)
function XM:SpellTalentCheck(spell, inptalent, inptarget)
    if not inptarget then inptarget = false end
    if not inptalent then inptalent = false end

    if GetSpellInfo(spell) then
        if (not inptalent) then
            --make exceptions for talents named differently from spells
            for k, v in pairs(XM.TALENTTABLE) do
                if (k == spell) then
                    inptalent = v
                end
            end
        end

        if (inptalent == nil) then
            return nil
        else
            return XM:TalentCheck(inptalent, inptarget)
        end
    end

    return nil
end

XM.powerNames = {
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

XM.elements ={
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

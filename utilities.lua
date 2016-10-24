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

function XM:ShortenString(strString, shorttype)
    local cTRUNCATE, cABBREVIATE = 1, 2

    if (strlen(strString) > XM.db["SHORTLENGTH"] and shorttype) then
        if (shorttype == cTRUNCATE) then
            return strsub(strString, 1, XM.db["SHORTLENGTH"])..XM.db["SHORTSTRING"]
        elseif (shorttype == cABBREVIATE) then
            return gsub(gsub(gsub(strString," of ","O"),"%s",""), "(%u)%l*", "%1")
        end
    end

    return strString
end

function XM:TruncateAmount(amount)
    result = tostring(amount)

    if(strlen(result) > 8) then -- 100m
        return strsub(result, 1, 3).."m"
    elseif(strlen(result) > 7) then -- 10.1m
        return strsub(result, 1, 2).."."..strsub(result,3,3).."m"
    elseif(strlen(result) > 6) then -- 1.2m
        return strsub(result, 1, 1).."."..strsub(result, 2, 2).."m"
    elseif(strlen(result) > 5) then -- 100k
        return strsub(result, 1, 3).."k"
    elseif(strlen(result) > 4) then -- 10.1k
        return strsub(result, 1, 2).."."..strsub(result,3,3).."k"
    elseif(strlen(result) > 3) then -- 1.2k
        return strsub(result, 1, 1).."."..strsub(result, 2, 2).."k"
    end

    return result
end

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

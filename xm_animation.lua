local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

local arrAlign = {[1] = "LEFT", [2] = "CENTER", [3] = "RIGHT"}
local arrFrameTexts = {}; --expandable array to hold each line of text
local arrAniData1 = {}; --arrays to contain texts for each frame
local arrAniData2 = {}
local arrAniData3 = {}
local arrAniData4 = {}
local arrAniData5 = {}
local arrAniData6 = {}
local arrAniData7 = {}
local arrAniData8 = {}
local arrAniData9 = {}
local arrAniData10 = {}
local ArrayAniData = {arrAniData1, arrAniData2, arrAniData3, arrAniData4, arrAniData5, arrAniData6, arrAniData7, arrAniData8, arrAniData9, arrAniData10}

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:DisplayText(dispframe, msg, rgbcolor, crit, parent, icon)
    --display text

    --set up text animation placement
    local adat = XM:GetNextAniObj(dispframe)
    adat.parent = UIParent

    --increase size for crits
    if (crit) then
        adat.textsize = adat.textsize * XM.db["CRITSIZE"] / 100
    end

    --Vertical Animation

    --make room for new text
    local moveoffset = 0
    for key, value in pairs(ArrayAniData[adat.frame]) do
        if (adat.directionY > 0 and (adat.bottompoint + adat.textsize - value.posY) > moveoffset) then
            moveoffset = adat.bottompoint + adat.textsize - value.posY
        elseif (adat.directionY < 0 and value.posY - (adat.bottompoint - adat.textsize) > moveoffset) then
            moveoffset = value.posY - (adat.bottompoint - adat.textsize)
        end
    end

    --move offset
    if (moveoffset > 0) then
        for key, value in pairs(ArrayAniData[adat.frame]) do
            value.posY = value.posY + (moveoffset)*(adat.directionY)
        end
        if (XMSHIELD and adat.frame == 1) then XMSHIELD:ShieldAnimate(moveoffset) end
    end

    --set text start position
    adat.posY = adat.bottompoint
    adat.text = msg

    --set default color if none
    if (not rgbcolor) then
        rgbcolor = {r = 1.0, g = 1.0, b = 1.0}
    end

    --set up text
    XM:SetFontSize(adat, adat.font, adat.textsize, adat.fontshadow)
    adat:SetTextColor(rgbcolor.r, rgbcolor.g, rgbcolor.b)
    adat:SetAlpha(adat.alpha)
    adat:SetPoint(arrAlign[adat.align], adat.parent, "CENTER", adat.posX, adat.posY)
    adat:SetText(msg)
    adat:Show()

    --insert text into animation table
    tinsert(ArrayAniData[adat.frame], adat)

    --show animation frame
    if (not XM_ANIMATIONFRAME:IsVisible()) then
        XM_ANIMATIONFRAME:Show()
    end

end

function XM:ONUPDATE_ANIMATION(elapsed)
    --upate animations that are being used

	local framerate = GetFramerate()
	timerino = 1.6/framerate
    --check for any text slots
    for i, _ in ipairs(ArrayAniData) do
        for k, value in pairs(ArrayAniData[i]) do
            XM:DoAnimation(value, timerino)
            if value == false then tremove(ArrayAniData[i][k]) end
        end
    end

end

function XM:DoAnimation(aniData, elapsed)
    --move text to perform animation

    --calculate animation
    XM:VerticalAnimation(aniData, elapsed)

    --new text position
    aniData:SetAlpha(aniData.alpha)
    aniData:SetPoint(arrAlign[aniData.align], aniData.parent, "CENTER", aniData.posX, aniData.posY)

     --reset when alpha drops below one percent (zero isn't working because of floating point?)
    if (aniData.alpha <= 0.01) then
        XM:AniReset(aniData)

        for i, v in ipairs(arrFrameTexts) do
            if(arrFrameTexts[i] and arrFrameTexts[i]:IsVisible() ~= 1) then
                arrFrameTexts[i] = false
                break
            end
        end
    end

end

function XM:VerticalAnimation(aniData, elapsed)
--vertical animation

    --adjust vertical position (up or down)
    aniData.posY = aniData.posY + (elapsed)*(aniData.addY)*(aniData.directionY)

    --start fading when text has moved half way
    local fadedist = (aniData.framesize)*(0.5)
    local fadepos = aniData.bottompoint + (fadedist)*(aniData.directionY)

    --fade 2 percent per position (of the original alpha) for the last 50 positions
    if (aniData.directionY > 0 and aniData.posY >= fadepos) or (aniData.directionY < 0 and aniData.posY <= fadepos) then
        aniData.alpha = (aniData.alpha)*(1 - (aniData.directionY)*((aniData.posY - fadepos)/(fadedist))*0.02)
    end

end

function XM:GetNextAvailableID()
    local random = math.random

    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:GetNextAniObj(inpframe)
    --gets the next available animation object

    local adat = false
    local i = 1

    --first fill all empty text slots
    while (i <= #arrFrameTexts) do
        adat = arrFrameTexts[i]
        if adat and adat:IsVisible() == nil then
            i = #arrFrameTexts + 1
        else
            adat = false
            i = i + 1
        end
    end

    --if all slots are shown, create a new text slot
    if (not adat) then
        i = #arrFrameTexts + 1
        arrFrameTexts[i] = XM_ANIMATIONFRAME:CreateFontString("XManiData"..i,"OVERLAY", "GameFontNormal")
        adat = arrFrameTexts[i]
    end

    XM:AniReset(adat)

    --set defaults based on frame

    adat.frame = inpframe
    adat.font = XM.db[("FRAME"..inpframe)]["FONT"]
    adat.textsize = XM.db[("FRAME"..inpframe)]["TEXTSIZE"]
    adat.fontshadow = XM.db[("FRAME"..inpframe)]["FONTSHADOW"]
    adat.alpha = XM.db[("FRAME"..inpframe)]["ALPHA"]/100
    adat.posX = XM.db[("FRAME"..inpframe)]["POSX"]
    adat.posY = XM.db[("FRAME"..inpframe)]["POSY"]
    adat.align = XM.db[("FRAME"..inpframe)]["ALIGN"]
    adat.iconside = XM.db[("FRAME"..inpframe)]["ICONSIDE"]

    adat.anitypeX = XM.db[("FRAME"..inpframe)]["ANITYPEX"]
    adat.anitypeY = XM.db[("FRAME"..inpframe)]["ANITYPEY"]
    adat.directionX = XM.db[("FRAME"..inpframe)]["DIRECTIONX"]
    adat.directionY = XM.db[("FRAME"..inpframe)]["DIRECTIONY"]
    adat.addX = XM.db[("FRAME"..inpframe)]["ADDX"]
    adat.addY = XM.db[("FRAME"..inpframe)]["ADDY"]
    adat.framesize = XM.db[("FRAME"..inpframe)]["FRAMESIZE"]

    --calculated vars
    adat.bottompoint = adat.posY

    return adat
end

function XM:AniReset(adat)
    --remove this data from the display table
    for i, _ in ipairs(ArrayAniData) do
        for k, value in pairs(ArrayAniData[i]) do
            if (not value or value.id == adat.id) then
                tremove(ArrayAniData[i], k)
                break
            end
        end
    end

    for i, _ in ipairs(arrFrameTexts) do
        if not arrFrameTexts[i] then tremove(arrFrameTexts, i) end
    end

    --reset all settings
    adat.id = XM:GetNextAvailableID()
    adat.frame = 0
    adat.textsize = 0
    adat.fontshadow = 1
    adat.alpha = 0
    adat.posX = 0
    adat.posY = 0
    adat.align = 2
    adat.iconside = 2

    adat.anitypeX = 1
    adat.anitypeY = 1
    adat.directionX = 1
    adat.directionY = 1
    adat.addX = 0
    adat.addY = 0
    adat.framesize = 0

    adat:SetAlpha(adat.alpha)
    adat:Hide()
    adat:ClearAllPoints()
    if adat.icon then
        adat.icon:ClearAllPoints()
        adat.icon:SetTexture(nil)
    end

end

function XM:AniInit()
    --initialize animations

    local i = 1
    while (i <= #arrFrameTexts) do
        XM:AniReset(arrFrameTexts[i])
        i = i + 1
    end
    arrFrameTexts = {}
    XM_ANIMATIONFRAME:Hide()

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:AniInitFrame(inpframe)

    local i = 1
    local adat
    while (i <= #arrFrameTexts) do
        adat = arrFrameTexts[i]
        if (adat.frame == inpframe) then
            XM:AniReset(arrFrameTexts[i])
        end
        i = i + 1
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:CreateAnimationFrame()
--create animation frame

    if (not XM_ANIMATIONFRAME) then
        XM_ANIMATIONFRAME = CreateFrame("Frame", "XM Animation Frame", UIParent)
    end
    XM_ANIMATIONFRAME:SetFrameStrata("HIGH")
    XM_ANIMATIONFRAME:EnableMouse("false")
    XM_ANIMATIONFRAME:SetPoint("CENTER")
    XM_ANIMATIONFRAME:SetScript("OnUpdate", function() XM:ONUPDATE_ANIMATION(arg1) end)
    XM:AniInit()
end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:SetFontSize(object, font, textsize, fontshadow)
--set the font of an object

    --array for font outline
    local arrShadowOutline = {[1] = "", [2] = "OUTLINE", [3] = "THICKOUTLINE"}
    object:SetFont(XM.sharedMedia:Fetch("font",font), textsize, arrShadowOutline[fontshadow])

end

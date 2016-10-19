local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

--local variables
local framemove = false
local RuneTable = {
    --type, texture
    [1] = {ID = "Blood", TXT = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood"},
    [2] = {ID = "Unholy", TXT = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy"},
    [3] = {ID = "Frost", TXT = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost"},
    [4] = {ID = "Death", TXT = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death"},
}

local movex = 0
local movey = 0

--graphic object table
local RuneButton = {}

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMRUNE:OnInitialize()
--called when addon loads

    --register events
    XMRUNE:RegisterEvent("PLAYER_LOGIN")

    XMRUNE:PLAYER_LOGIN()

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMRUNE:PLAYER_LOGIN()
--enable addon at player login

    local classtext,classname = UnitClass("player")

    if (classname == "DEATHKNIGHT") then
        --initialize DB for new users
        if (not XM.db["XMRUNE"]) then
            XM.db["XMRUNE"] = {}
            DEFAULT_CHAT_FRAME:AddMessage(XM.locale["addonName"].."Initializing Rune Frame: "..UnitName("player").." - "..GetRealmName():trim())

            --write default values to the current profile (too bad they can't be sorted)
            for key, value in pairs(XMRUNE.DEFAULTS) do
                XM.db["XMRUNE"][key] = value
            end
        end

        XMRUNE:CreateRuneFrame()
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMRUNE:OnUpdate(elapsed)
--update screen objects

    if (UnitIsGhost("player") == 1 or UnitIsDead("player") == 1) then
        XM.player.combatActive = false
    end

    local i = 1
    local starttime,cooldown,_
    local runetype
    while (i <= #RuneButton) do
        runetype = GetRuneType(i)
        RuneButton[i].texture:SetTexture(RuneTable[runetype].TXT)

        starttime,cooldown,_ = GetRuneCooldown(i)
        if (starttime > 0) then
            RuneButton[i].texture:SetVertexColor(0.3,0.3,0.3,1)
            RuneButton[i].cd:SetText(("%.0f"):format(cooldown - (GetTime() - starttime)))
        else
            RuneButton[i].texture:SetVertexColor(1,1,1,1)
            RuneButton[i].cd:SetText("")
        end
        i = i + 1
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMRUNE:CreateRuneFrame()

    local settings = XM.db["XMRUNE"]
    local runegridx = settings["RUNEGRIDX"]
    local runegridy = settings["RUNEGRIDY"]
    local runesquare = settings["RUNESQUARE"]
    local runeborder = settings["RUNEBORDER"]

    --main rune frame
    if (not XM_RUNEFRAME) then
        XM_RUNEFRAME = CreateFrame("Frame", "XM Rune Frame", UIParent)
        XM_RUNEFRAME:SetPoint("CENTER", UIParent, "CENTER", settings["RUNEFRAME"]["POSX"], settings["RUNEFRAME"]["POSY"])
    end
    XM_RUNEFRAME:SetFrameStrata(settings["RUNEFRAME"]["STRATA"])
    XM_RUNEFRAME:SetWidth(runegridx*runesquare + 2*runeborder)
    XM_RUNEFRAME:SetHeight(runegridy*runesquare + 2*runeborder)
    XM_RUNEFRAME:SetScale(settings["RUNEFRAME"]["SCALE"])
    XM_RUNEFRAME:SetScript("OnUpdate", function() XMRUNE:OnUpdate(arg1) end)

    --movable rune frame
    XM_RUNEFRAME:SetMovable(true)
    XM_RUNEFRAME:SetClampedToScreen(true)
    XM_RUNEFRAME:EnableMouse(true)
    XM_RUNEFRAME:SetScript("OnMouseDown", function() XMRUNE:OnClick(arg1) end)
    XM_RUNEFRAME:SetScript("OnMouseUp", function() XMRUNE:OnDragStop(arg1) end)

    if (not XM_RUNEFRAME.texture) then
        XM_RUNEFRAME.texture = XM_RUNEFRAME:CreateTexture()
        XM_RUNEFRAME.texture:SetAllPoints(XM_RUNEFRAME)
    end
    XM_RUNEFRAME.texture:SetTexture(XM.sharedMedia:Fetch("statusbar", settings["RUNEBACK"]["TEXTURE"]))
    XM_RUNEFRAME.texture:SetVertexColor(settings["RUNEBACK"]["COLOR"].r,settings["RUNEBACK"]["COLOR"].g,settings["RUNEBACK"]["COLOR"].b,settings["RUNEBACK"]["ALPHA"])

    --rune buttons
    local i = 1
    local calcx,calcy = 0,0
    while (i <= runegridx*runegridy) do
        if (not RuneButton[i]) then
            RuneButton[i] = CreateFrame("Frame", "RuneButton"..i, XM_RUNEFRAME)

            --grid position calculations
            calcx = (floor((i-1)/runegridy)) * runesquare + runeborder
            if (i/runegridy)*1000 - floor(i/runegridy)*1000 < 0.01 then
                calcy = ((-1) * runesquare) - runeborder
            else
                calcy = (0 * runesquare) - runeborder
            end
            RuneButton[i]:SetPoint("TOPLEFT", XM_RUNEFRAME, calcx, calcy)
        end
        RuneButton[i]:SetFrameLevel(XM_RUNEFRAME:GetFrameLevel() + 1)
        RuneButton[i]:SetHeight(runesquare)
        RuneButton[i]:SetWidth(runesquare)

        if (not RuneButton[i].texture) then
            RuneButton[i].texture = RuneButton[i]:CreateTexture()
            RuneButton[i].texture:SetAllPoints(RuneButton[i])
        end

        if (not RuneButton[i].text) then
            RuneButton[i].text = CreateFrame("Frame", "RuneButton"..i.."text", RuneButton[i])
            RuneButton[i].text:SetAllPoints(RuneButton[i])
        end
        RuneButton[i].text:SetFrameLevel((RuneButton[i]:GetFrameLevel())+1)

        if (not RuneButton[i].cd) then
            RuneButton[i].cd = RuneButton[i].text:CreateFontString("RuneButton"..i.."cd", "OVERLAY", "GameFontNormal")
            RuneButton[i].cd:SetPoint("CENTER", RuneButton[i].text)
        end
        RuneButton[i].cd:SetFont(XM.sharedMedia:Fetch("font",settings["RUNECD"]["FONT"]), (RuneButton[i]:GetHeight()*0.4), "OUTLINE")
        RuneButton[i].cd:SetTextColor(settings["RUNECD"]["COLOR"].r,settings["RUNECD"]["COLOR"].g,settings["RUNECD"]["COLOR"].b,settings["RUNECD"]["ALPHA"])

        i = i + 1
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMRUNE:OnClick(inpbutton)

    if (IsControlKeyDown()) then
		framemove = true
        movex, movey = GetCursorPosition()
        XM_RUNEFRAME:Show()
        XM_RUNEFRAME:StartMoving()
    elseif (IsShiftKeyDown()) then
        framemove = true
        movex, movey = GetCursorPosition()
        XM_RUNEFRAME:Show()
        XM_RUNEFRAME:StartMoving()
    end

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMRUNE:OnDragStop()
--save position

    XMRUNE:SavePosition()
    XM_RUNEFRAME:StopMovingOrSizing()
    framemove = false

end

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XMRUNE:SavePosition()
--save position

    local cursorx, cursory = GetCursorPosition()
    movex = cursorx - movex
    movey = cursory - movey

    XM.db["XMRUNE"]["RUNEFRAME"]["POSX"] = XM.db["XMRUNE"]["RUNEFRAME"]["POSX"] + movex
    XM.db["XMRUNE"]["RUNEFRAME"]["POSY"] = XM.db["XMRUNE"]["RUNEFRAME"]["POSY"] + movey

end

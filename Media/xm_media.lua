--MUST HAVE "xm_init.lua" LOADED FIRST

--embedded libs
local XM_SMedia = LibStub("LibSharedMedia-3.0")

--local variables
local Fonts = { 
    [1] = {name="Emblem", path="Interface\\Addons\\eXMortal\\Media\\Fonts\\Emblem.ttf"},
    [2] = {name="TwCent", path="Interface\\Addons\\eXMortal\\Media\\Fonts\\Tw_Cen_MT_Bold.TTF"},
    [3] = {name="Adventure", path="Interface\\Addons\\eXMortal\\Media\\Fonts\\Adventure.ttf"},
    [4] = {name="Enigma", path="Interface\\Addons\\eXMortal\\Media\\Fonts\\Enigma__2.TTF"},
    [5] = {name="Diablo", path="Interface\\Addons\\eXMortal\\Media\\Fonts\\Avqest.ttf"},
}
local Textures = { 
    [1] = {name="Banto", path="Interface\\Addons\\eXMortal\\Media\\Textures\\BantoBar"},
    [2] = {name="Bar", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Bars"},
    [3] = {name="Button", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Button"},
    [4] = {name="Charcoal", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Charcoal"},
    [5] = {name="Cloud", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Cloud"},
    [6] = {name="Dabs", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Dabs"},
    [7] = {name="DarkBottom", path="Interface\\Addons\\eXMortal\\Media\\Textures\\DarkBottom"},
    [8] = {name="Fifths", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Fifths"},
    [9] = {name="Fourths", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Fourths"},
    [10] = {name="Gloss", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Gloss"},
    [11] = {name="Grid", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Grid"},
    [12] = {name="LiteStep", path="Interface\\Addons\\eXMortal\\Media\\Textures\\LiteStep"},
    [13] = {name="Smooth", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Smooth"},
    [14] = {name="Steel", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Steel"},
    [15] = {name="Water", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Water"},
    [16] = {name="Wisps", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Wisps"},
    [17] = {name="Plain", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Plain"},
}

--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
function XM:RegisterMedia()
--register fonts, textures, sounds

    local key,value
    for key, value in pairs(Fonts) do
        XM_SMedia:Register("font", value.name, value.path)
    end

    for key, value in pairs(Textures) do
        XM_SMedia:Register("statusbar", value.name, value.path)
    end

end
local XM = LibStub("AceAddon-3.0"):GetAddon("XM")

if XM.media == nil then XM.media = {} end

XM.sharedMedia = LibStub("LibSharedMedia-3.0")

XM.media.fonts = {
    {name="Emblem", path="Interface\\Addons\\eXMortal\\Media\\Fonts\\Emblem.ttf"},
    {name="TwCent", path="Interface\\Addons\\eXMortal\\Media\\Fonts\\Tw_Cen_MT_Bold.TTF"},
    {name="Adventure", path="Interface\\Addons\\eXMortal\\Media\\Fonts\\Adventure.ttf"},
    {name="Enigma", path="Interface\\Addons\\eXMortal\\Media\\Fonts\\Enigma__2.TTF"},
    {name="Diablo", path="Interface\\Addons\\eXMortal\\Media\\Fonts\\Avqest.ttf"},
}

XM.media.textures = {
    {name="Banto", path="Interface\\Addons\\eXMortal\\Media\\Textures\\BantoBar"},
    {name="Bar", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Bars"},
    {name="Button", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Button"},
    {name="Charcoal", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Charcoal"},
    {name="Cloud", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Cloud"},
    {name="Dabs", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Dabs"},
    {name="DarkBottom", path="Interface\\Addons\\eXMortal\\Media\\Textures\\DarkBottom"},
    {name="Fifths", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Fifths"},
    {name="Fourths", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Fourths"},
    {name="Gloss", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Gloss"},
    {name="Grid", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Grid"},
    {name="LiteStep", path="Interface\\Addons\\eXMortal\\Media\\Textures\\LiteStep"},
    {name="Smooth", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Smooth"},
    {name="Steel", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Steel"},
    {name="Water", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Water"},
    {name="Wisps", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Wisps"},
    {name="Plain", path="Interface\\Addons\\eXMortal\\Media\\Textures\\Plain"},
}

local libSharedMedia = LibStub("LibSharedMedia-3.0")

function XM:RegisterMedia()
    for _, v in pairs(XM.media.fonts) do
        libSharedMedia:Register("font", v.name, v.path)
    end

    for _, v in pairs(XM.media.textures) do
        libSharedMedia:Register("statusbar", v.name, v.path)
    end
end

function XM:GetMediaIndex(t, value)
    for k,v in pairs(XM.sharedMedia:List(t)) do
        if v == value then
            return k
        end
    end
    return nil
end

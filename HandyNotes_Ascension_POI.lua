---------------------------------------------------------
-- Addon declaration
HandyNotes_AscensionPOI = LibStub("AceAddon-3.0"):NewAddon("HandyNotes_AscensionPOI", "AceEvent-3.0")
local APOI = HandyNotes_AscensionPOI

---------------------------------------------------------
-- Our db upvalue and db defaults
local db
local defaults = {
    profile = {
        icon_scale = 1.0,
        icon_alpha = 1.0,
        show_coords = true,
    }
}

---------------------------------------------------------
-- Localize some globals
local next = next
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip

---------------------------------------------------------
-- Constants
local iconTexture = "Interface\\Icons\\INV_Misc_QuestionMark"

---------------------------------------------------------
-- Plugin Handlers to HandyNotes

local APOIHandler = {}

do
    local emptyTbl = {}
    
    -- This is a custom iterator we use to iterate over every node in a given zone
    local function iter(t, prestate)
        if not t then return end
        local state, value = next(t, prestate)
        if state then -- Have we reached the end of this zone?
            -- Return the coordinate, mapFile, icon, scale, alpha
            return state, nil, iconTexture, db.icon_scale, db.icon_alpha
        end
    end

    function APOIHandler:GetNodes(mapFile, minimap)
        return iter, AscensionPOI_Data[mapFile], nil
    end
end

function APOIHandler:OnEnter(mapFile, coord)
    local tooltip = GameTooltip
    
    if self:GetParent() == WorldMapButton then
        tooltip = WorldMapTooltip
        tooltip:SetOwner(self, "ANCHOR_NONE")
        tooltip:SetPoint("BOTTOMRIGHT", WorldMapButton)
    else
        tooltip = GameTooltip
        tooltip:SetOwner(self, self:GetCenter() > UIParent:GetCenter() and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
    end
    
    -- Get POI data for this coordinate
    local poiData = AscensionPOI_Data[mapFile] and AscensionPOI_Data[mapFile][coord]
    if poiData then
        tooltip:SetText(poiData)
        
        if db.show_coords then
            local x, y = HandyNotes:getXY(coord)
            tooltip:AddLine("Coordinates: " .. string.format("%.1f, %.1f", x*100, y*100), 1, 1, 1)
        end
    end
    
    tooltip:Show()
end

function APOIHandler:OnLeave(mapFile, coord)
    if self:GetParent() == WorldMapButton then
        WorldMapTooltip:Hide()
    else
        GameTooltip:Hide()
    end
end

---------------------------------------------------------
-- Options table
local options = {
    type = "group",
    name = "Ascension POI",
    desc = "Points of Interest for Ascension WoW",
    get = function(info) return db[info.arg] end,
    set = function(info, v)
        db[info.arg] = v
        APOI:SendMessage("HandyNotes_NotifyUpdate", "AscensionPOI")
    end,
    args = {
        desc = {
            name = "These settings control the look and feel of the Ascension POI icons.",
            type = "description",
            order = 0,
        },
        poi_icons = {
            type = "group",
            name = "POI Icons",
            desc = "POI Icons",
            order = 20,
            inline = true,
            args = {
                icon_scale = {
                    type = "range",
                    name = "Icon Scale",
                    desc = "The scale of the icons",
                    min = 0.25, max = 2, step = 0.01,
                    arg = "icon_scale",
                    order = 10,
                },
                icon_alpha = {
                    type = "range",
                    name = "Icon Alpha",
                    desc = "The alpha transparency of the icons",
                    min = 0, max = 1, step = 0.01,
                    arg = "icon_alpha",
                    order = 20,
                },
                show_coords = {
                    type = "toggle",
                    name = "Show Coordinates",
                    desc = "Show coordinates in the tooltip",
                    arg = "show_coords",
                    order = 30,
                },
            },
        },
    },
}

---------------------------------------------------------
-- Addon initialization, enabling and disabling

function APOI:OnInitialize()
    -- Set up our database
    self.db = LibStub("AceDB-3.0"):New("HandyNotesAscensionPOIDB", defaults)
    db = self.db.profile

    -- Initialize our database with HandyNotes
    HandyNotes:RegisterPluginDB("AscensionPOI", APOIHandler, options)
end

function APOI:OnEnable()
end

function APOI:OnDisable()
end

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
        show_on_minimap = true,
    }
}

---------------------------------------------------------
-- Localize some globals
local next = next
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip

---------------------------------------------------------
-- Constants
local defaultIconTexture = "Interface\\Icons\\INV_Box_01"

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
            -- Get the POI data to determine the icon
            local poiEntry = t[state]
            local iconTexture = defaultIconTexture
            
            -- If we have a valid itemId, try to get the item icon
            if poiEntry and poiEntry.itemId and poiEntry.itemId ~= 0 then
                local itemIcon = GetItemIcon(poiEntry.itemId)
                if itemIcon then
                    iconTexture = itemIcon
                end
            end
            
            -- Return the coordinate, mapFile, icon, scale, alpha
            return state, nil, iconTexture, db.icon_scale, db.icon_alpha
        end
    end

    function APOIHandler:GetNodes(mapFile, minimap)
        if minimap then 
            -- Return only the requested zone's data for the minimap
            if not db.show_on_minimap then 
                return next, emptyTbl, nil 
            end
            return iter, AscensionPOI_Data[mapFile] or emptyTbl, nil
        else
            -- For world map, return the zone data if it exists
            return iter, AscensionPOI_Data[mapFile] or emptyTbl, nil
        end
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
    
    -- Get POI data for this coordinate and show it first
    local poiEntry = AscensionPOI_Data[mapFile] and AscensionPOI_Data[mapFile][coord]
    if poiEntry then
        local poiName = poiEntry.name or poiEntry -- Handle both old string format and new object format
        local itemId = poiEntry.itemId or 1484 -- Default to 1484 if not specified
        
        -- Add POI information with coordinates on same line
        if db.show_coords then
            local x, y = HandyNotes:getXY(coord)
            local coordText = string.format(" (%.1f, %.1f)", x*100, y*100)
            tooltip:SetText(poiName .. coordText, 0.6, 0.8, 1.0) -- POI name with coordinates
        else
            tooltip:SetText(poiName, 0.6, 0.8, 1.0) -- Just POI name
        end
        
        -- Only show item tooltip if itemId is not 0
        if itemId and itemId ~= 0 then
            -- Add separator line before item info
            tooltip:AddLine(" ")
            
            -- Use the itemId from the data entry
            local tempTooltip = CreateFrame("GameTooltip", "TempItemTooltip", UIParent, "GameTooltipTemplate")
            tempTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            tempTooltip:SetHyperlink("item:" .. itemId)
            
            -- Copy the item tooltip lines to our main tooltip
            for i = 1, tempTooltip:NumLines() do
                local line = _G["TempItemTooltipTextLeft" .. i]
                if line and line:GetText() then
                    local r, g, b, a = line:GetTextColor()
                    tooltip:AddLine(line:GetText(), r, g, b)
                end
            end
            
            tempTooltip:Hide()
        end
    else
        -- Fallback if no POI data
        tooltip:SetText("Ascension POI", 0.6, 0.8, 1.0)
        tooltip:AddLine("Unknown location", 0.8, 0.8, 0.8)
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
                show_on_minimap = {
                    type = "toggle",
                    name = "Show on Minimap",
                    desc = "Show POI icons on the minimap",
                    arg = "show_on_minimap",
                    order = 40,
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

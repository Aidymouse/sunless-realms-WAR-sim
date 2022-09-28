local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local phase_movement = require ("phases.movement")


local Unit = {}

Unit.unit_attributes = {
    levies = { max_moves = 1, attack_range=1},
    infantry = { max_moves = 1, attack_range=1},
    archers = { max_moves = 1, attack_range=2 },
    cavalry = { max_moves = 2, attack_range=1 },
    flying = { max_moves = 2, attack_range=2 },
    warmachine = { max_moves = 1, attack_range=4 },
}


---@param player player The player who controls this unit
---@param type unit_types Which type of unit
---@param axialCoord coords_axial The coordinates of the hex this unit inhabits
---@param size integer The size of the unit
---@return unit Unit 
function Unit:New(player, type, axialCoord, size)
    assert(player ~= nil, "A unit needs a player!")

    ---@type unit
    local u = {
        type = type or UNIT_TYPES.INFANTRY,
        occupiedTileCoords = axialCoord,
        size = size or 5,
        attack_range = Unit.unit_attributes[type].attack_range,

        attack_value = size or 5,

        controller = player,

        flyingTimer = 0,

        movement = {
            max_moves = Unit.unit_attributes[type or UNIT_TYPES.INFANTRY].max_moves,
            moves_made = 0
        },

        tactics = {
            chosen_tactic = tactics.NONE,
            target = nil,
        },

        action = {
            has_fought = false
        }

    }
    setmetatable(u, self)
    self.__index = self
    return u
end

---@param dt number The time that has passed since last frame
function Unit:update(dt)
    self.flyingTimer = self.flyingTimer + dt
end


---@param unit_type unit_types Type of the unit
---@param bottom_center_XY coords_XY The X and Y of the point at which the unit touches the "ground"
---@return number[] path The shape path for the unit
local function get_unit_shape_polygon(unit_type, bottom_center_XY)

    if unit_type == UNIT_TYPES.LEVIES then
        local size = 35
        local corner = 7
        return {
            bottom_center_XY.x - (size/2 - corner), bottom_center_XY.y,
            bottom_center_XY.x - size/2, bottom_center_XY.y - corner,
            bottom_center_XY.x - size/2, bottom_center_XY.y - (size - corner),
            bottom_center_XY.x - (size/2 - corner), bottom_center_XY.y - size,
            bottom_center_XY.x + (size/2 - corner), bottom_center_XY.y - size,
            bottom_center_XY.x + size/2, bottom_center_XY.y - (size - corner),
            bottom_center_XY.x + size/2, bottom_center_XY.y - corner,
            bottom_center_XY.x + (size/2 - corner), bottom_center_XY.y,
        }

    elseif unit_type == UNIT_TYPES.INFANTRY then
        return {
            bottom_center_XY.x - 25, bottom_center_XY.y,
            bottom_center_XY.x - 25, bottom_center_XY.y-50,
            bottom_center_XY.x + 25, bottom_center_XY.y-50,
            bottom_center_XY.x + 25, bottom_center_XY.y,
        }
    
    elseif unit_type == UNIT_TYPES.ARCHERS then
        return {
            bottom_center_XY.x-25, bottom_center_XY.y,
            bottom_center_XY.x, bottom_center_XY.y-50,
            bottom_center_XY.x+25, bottom_center_XY.y
        }
    
    elseif unit_type == UNIT_TYPES.CAVALRY then
        
        local size = 30
        local spike_length = 20

        return {
            bottom_center_XY.x - size / 2, bottom_center_XY.y,
            bottom_center_XY.x - size / 2-spike_length, bottom_center_XY.y-size/2,
            bottom_center_XY.x - size / 2, bottom_center_XY.y - size,
            bottom_center_XY.x, bottom_center_XY.y - size - spike_length,
            bottom_center_XY.x + size / 2, bottom_center_XY.y - size,
            bottom_center_XY.x+size/2+spike_length, bottom_center_XY.y - size/2,
            bottom_center_XY.x + size / 2, bottom_center_XY.y,
        }

    elseif unit_type == UNIT_TYPES.FLYING then
        return {
            bottom_center_XY.x, bottom_center_XY.y,
            bottom_center_XY.x-25, bottom_center_XY.y-25,
            bottom_center_XY.x, bottom_center_XY.y-50,
            bottom_center_XY.x+25, bottom_center_XY.y-25,
        }
    
    elseif unit_type == UNIT_TYPES.WARMACHINE then
        return {
            bottom_center_XY.x, bottom_center_XY.y,
            bottom_center_XY.x - 25, bottom_center_XY.y - 47,
            bottom_center_XY.x-22, bottom_center_XY.y - 50,
            bottom_center_XY.x + 25, bottom_center_XY.y - 41,
            bottom_center_XY.x + 25, bottom_center_XY.y - 25,
            bottom_center_XY.x + 25, bottom_center_XY.y - 12,
        }


    end

    return {
        bottom_center_XY.x - 25, bottom_center_XY.y,
        bottom_center_XY.x - 25, bottom_center_XY.y-50,
        bottom_center_XY.x + 25, bottom_center_XY.y-50,
        bottom_center_XY.x + 25, bottom_center_XY.y,
    }

end

local function offsetPath(path, offsetX, offsetY)
    local new_path = {}

    for i=1, #path, 2 do
        table.insert(new_path, path[i]+offsetX)
        table.insert(new_path, path[i+1]+offsetY)
    end

    return new_path
end

---@param mapAttr map_attributes
function Unit:draw(mapAttr)

    mapAttr = mapAttr or MAPATTRIBUTES

    local bottomcenterXY = HL_convert.axialToWorld( self.occupiedTileCoords, mapAttr )

    local flyingOffsetY = 0
    if self.type == UNIT_TYPES.FLYING then
        flyingOffsetY = 20 + math.sin(self.flyingTimer*2) * 5
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.circle("fill", bottomcenterXY.x, bottomcenterXY.y, 50-flyingOffsetY)
    end

    love.graphics.setColor(self.controller.color)
    
    local unit_path = get_unit_shape_polygon(self.type, bottomcenterXY)
    if self.type == UNIT_TYPES.FLYING then unit_path = offsetPath(unit_path, 0, -flyingOffsetY) end

    love.graphics.polygon("fill", unit_path )

    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.size, bottomcenterXY.x-3, bottomcenterXY.y-25-6-flyingOffsetY)


    if STATE.currentPhase == game_phases.MOVEMENT then
        if phase_movement.state.actingPlayer == self.controller then
            if self.movement.moves_made < self.movement.max_moves then
                love.graphics.setColor(1, 0, 0)
                love.graphics.circle("line", bottomcenterXY.x, bottomcenterXY.y, 30)
            end
        end
    end

end

---@returns string
function Unit:__tostring()
    return "UNIT ("..self.type..", "..self.size.." in "..tostring(self.occupiedTileCoords)..")"
end


function Unit:movement_refresh()
    self.movement.destinationCoords = self.occupiedTileCoords
    self.movement.moves_made = 0
end

function Unit:tactics_refresh()
    self.tactics.chosen_tactic = tactics.NONE
    self.tactics.target = nil
end

function Unit:action_refresh()
    self.action.has_fought = false
end

return Unit
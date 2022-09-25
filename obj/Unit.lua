local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local phase_movement = require ("phases.movement")


local Unit = {}

Unit.unit_attributes = {
    levies = { max_moves = 1},
    infantry = { max_moves = 1},
    archers = { max_moves = 1 },
    cavalry = { max_moves = 2 },
    flying = { max_moves = 2 },
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

        controller = player,

        flyingTimer = 0,

        movement = {
            max_moves = Unit.unit_attributes[type or UNIT_TYPES.INFANTRY].max_moves,
            moves_made = 0
        },

        tactics = {
            chosen_tactic = tactics.NONE,
            target = nil,
        }

    }
    setmetatable(u, self)
    self.__index = self
    return u
end

function Unit:update(dt)
    self.flyingTimer = self.flyingTimer + dt
end

function Unit:draw(mapAttr)

    mapAttr = mapAttr or MAPATTRIBUTES

    local bottomcenterXY = HL_convert.axialToWorld( self.occupiedTileCoords, mapAttr )

    local flyingOffsetY = 0
    if self.type == UNIT_TYPES.FLYING then
        flyingOffsetY = 20 + math.sin(self.flyingTimer*2) * 5
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.circle("fill", bottomcenterXY.x, bottomcenterXY.y, flyingOffsetY)
    end

    love.graphics.setColor(self.controller.color)
    love.graphics.rectangle("fill", bottomcenterXY.x - 25, bottomcenterXY.y-50-flyingOffsetY, 50, 50)
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

return Unit
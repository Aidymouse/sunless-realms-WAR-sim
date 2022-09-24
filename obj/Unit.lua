local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local phase_movement = require ("phases.movement")

---@enum unit_type
---| "levies"
---| "infantry"
---| "archers"
---| "cavalry"
---| "flying"
---| "war machine"

---@class unit
---@field type unit_type The type of the unit
---@field siex integer The size of the unit
---@field occupiedTileCoords coords_axial
---@field controller player
---@field flyingTimer number

---@type unit
local Unit = {}

Unit.unit_types = {
    LEVIES = "levies",
    INFANTRY = "infantry",
    ARCHERS = "archers",
    CAVALRY = "cavalry",
    FLYING = "flying"
}
local unit_types = Unit.unit_types

Unit.unit_attributes = {
    levies = { max_moves = 1},
    infantry = { max_moves = 1},
    archers = { max_moves = 1 },
    cavalry = { max_moves = 2 },
    flying = { max_moves = 2 },
}



---@param player player The player who controls this unit
---@param type unit_type Which type of unit
---@param axialCoord coords_axial The coordinates of the hex this unit inhabits
---@param size integer The size of the unit
---@return unit Unit 
function Unit:New(player, type, axialCoord, size)
    assert(player ~= nil, "A unit needs a player!")

    ---@type unit
    local u = {
        type = type or unit_types.INFANTRY,
        occupiedTileCoords = axialCoord,
        size = size or 5,

        controller = player,

        flyingTimer = 0,

        movement = {
            maxMoves = Unit.unit_attributes[type or unit_types.INFANTRY].max_moves,
            movesMade = 0
        },

        tactics = {
            chosenTactic = tactics.NONE,
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

    local mapAttr = mapAttr or MAPATTRIBUTES


    local bottomcenterXY = HL_convert.axialToWorld( self.occupiedTileCoords, mapAttr )

    local flyingOffsetY = 0
    if self.type == unit_types.FLYING then
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
            if self.movement.movesMade < self.movement.maxMoves then
                love.graphics.setColor(1, 0, 0)
                love.graphics.circle("line", bottomcenterXY.x, bottomcenterXY.y, 30)
            end
        end
    end

end

function Unit:__tostring()
    return "UNIT ("..self.type..", "..self.size.." in "..tostring(self.occupiedTileCoords)..")"
end


function Unit:movement_refreshMovement()
    self.movement.destinationCoords = self.occupiedTileCoords
    self.movement.movesMade = 0
end

function Unit:tactics_refresh()
    self.tactics.chosenTactic = tactics.NONE
    self.tactics.target = nil
end

return Unit
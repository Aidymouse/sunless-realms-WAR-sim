local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local Unit = {}

Unit.unit_types = {
    LEVIES = "levies",
    INFANTRY = "infantry",
    ARCHERS = "archers",
    CAVALRY = "cavalry",
    FLYING = "flying"
}
local unit_types = Unit.unit_types

function Unit:New(player, type, axialCoord, size)
    assert(player ~= nil, "A unit needs a player!")

    u = {
        type = type or Unit.unit_types.INFANTRY,
        occupiedTileCoords = axialCoord,
        size = size or 5,

        controller = player,

        flyingTimer = 0,

        movement = {
            maxMoves = 2,
            destinationCoords = nil,
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

    if self.movement.destinationCoords ~= nil then
        bottomcenterXY = HL_convert.axialToWorld(self.movement.destinationCoords, mapAttr)
    end

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
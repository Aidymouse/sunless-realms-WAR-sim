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

function Unit:New(player, type, axialCoord, color, size)
    assert(player ~= nil, "A unit needs a player!")

    u = {
        type = type or Unit.unit_types.INFANTRY,
        occupiedTileCoords = axialCoord,
        size = size or 5,

        controller = player,

        movement = {
            movesLeft = 1
        },

        tactics = {
            chosenTactic = tactics.NONE,
            target = nil
        }

    }
    setmetatable(u, self)
    self.__index = self
    return u
end

function Unit:draw(mapAttr)

    local mapAttr = mapAttr or MAPATTRIBUTES

    local bottomcenterXY = HL_convert.axialToWorld( self.occupiedTileCoords, mapAttr )

    love.graphics.setColor(self.controller.color)
    love.graphics.rectangle("fill", bottomcenterXY.x - 25, bottomcenterXY.y-50, 50, 50)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.size, bottomcenterXY.x-3, bottomcenterXY.y-25-6)

end

function Unit:__tostring()
    return "UNIT ("..self.type..", "..self.size.." in "..tostring(self.occupiedTileCoords)..")"
end


function Unit:movement_refreshMovement()
    if self.type == unit_types.CAVALRY or self.type == unit_types.FLYING then
        self.movement.movesLeft = 2
    else
        self.movement.movesLeft = 1
    end
end

function Unit:tactics_refresh()
    self.tactics.chosenTactic = tactics.NONE
    self.tactics.target = nil
end

return Unit
Hexlib = require("lib.hexlib")
hl_convert = Hexlib.coordConversions

Unit = {}

Unit.unit_types = {
    LEVIES = "levies",
    INFANTRY = "infantry",
    ARCHERS = "archers",
    CAVALRY = "cavalry",
    FLYING = "flying"
}

function Unit:New(type, axialCoord, color, size)
    u = {
        type = type or Unit.unit_types.INFANTRY,
        occupiedTileId = axialCoord,
        color = color or {0, 0, 1},
        size = size or 5
    }
    setmetatable(u, self)
    self.__index = self
    return u
end

function Unit:draw(mapAttr)

    local mapAttr = mapAttr or MAPATTRIBUTES

    local hW = mapAttr.hexWidth
    local hH = mapAttr.hexHeight
    local hO = mapAttr.orientation

    local bottomcenterXY = hl_convert.axialToWorld( self.occupiedTileId )

    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", bottomcenterXY.x - 25, bottomcenterXY.y-50, 50, 50)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.size, bottomcenterXY.x-3, bottomcenterXY.y-25-6)

end

return Unit
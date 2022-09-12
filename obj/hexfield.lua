-- Responsible for rendering the hex field

hexlib = require("lib.hexlib")



local hl_convert = hexlib.coordConversions
local axialCoords = hexlib.coords.axial

terrain = {
    PLAINS = "plains",
    SWAMP = "swamp",
    WATER = "water"
}

terrainAttributes = {}

terrainAttributes[""] = {color={1, 1, 1} }
terrainAttributes[terrain.PLAINS] = {color={0, 1, 0}}
terrainAttributes[terrain.SWAMP] = {color={0, 0.4, 0}}
terrainAttributes[terrain.WATER] = {color={0.6, 0.6, 1}}



Hexfield = {
    tiles = {
    }
}

function tileExists(id)
   return Hexfield.tiles[id] ~= nil 
end

function Hexfield.update(dt)

    if love.mouse.isDown(1) then

        local cellCoords = hl_convert.worldToAxial(love.mouse.custom_getXYWithOffset())

        local tileId = tostring(cellCoords)
        if tileExists(tileId) then Hexfield.tiles[ tileId ].terrain = terrain.WATER end

    end

end

function Hexfield.draw()
    
    for id, tile in pairs(Hexfield.tiles) do

        love.graphics.setColor( terrainAttributes[ tile.terrain ].color )

        local curPath = hexlib.getHexPath(hl_convert.axialToWorld(tile.coords))

        love.graphics.polygon("fill", curPath)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.polygon("line", curPath)
        
        

    end
end


function populate()

    for q=0, 4, 1 do
        for r=0, 4, 1 do

            if love.math.random(1, 3) == 1 then 
                Hexfield.tiles[ tostring(axialCoords:New(q, r)) ] = { coords = axialCoords:New(q, r), terrain=terrain.PLAINS }
            else
                Hexfield.tiles[ tostring(axialCoords:New(q, r)) ] = { coords=axialCoords:New(q, r), terrain=terrain.SWAMP }
            end
        end
    end

end

populate()

return Hexfield
-- Responsible for rendering the hex field

local hexlib = require("lib.hexlib")

local HL_convert = hexlib.coordConversions
local HL_coords = hexlib.coords

terrain = {
    PLAINS = "plains",
    SWAMP = "swamp",
    WATER = "water"
}

terrainAttributes = {}

terrainAttributes[""] = {color={1, 1, 1} }
terrainAttributes[terrain.PLAINS] = { color = { 201/255, 1, 115/255 } }
terrainAttributes[terrain.SWAMP] = {color={0, 0.4, 0}}
terrainAttributes[terrain.WATER] = {color={0.6, 0.6, 1}}

Hexfield = {
    tiles = {
    }
}

Hexfield.hexDirVectors = {
    { q = 1, r = 0 },
    { q = 1, r = -1 },
    { q = 0, r = -1 },
    { q = -1, r = 0 },
    { q = -1, r = 1 },
    { q = 0, r = 1 }
}


function Hexfield.tileExists(id)
   return Hexfield.tiles[id] ~= nil
end
local tileExists = Hexfield.tileExists

function Hexfield.getTileFromWorldCoords(XY)

    local cellCoords = HL_convert.worldToAxial(XY)

    if tileExists( tostring(cellCoords) ) then
        return Hexfield.tiles[tostring(cellCoords)]
    end

end

---Find all tiles that exist that are neighbours of supplied ID
---@param tileID string
---@return table<tile> Tiles Table containing existing neighbouring tiles
function Hexfield.getNeighbouringTiles(axialCoords)

    local neighboursThatExist = {}

    for _, dir in ipairs(Hexfield.hexDirVectors) do
        
        local neighbourCoords = HL_coords.axial:New( axialCoords.q + dir.q, axialCoords.r + dir.r )

        if tileExists(tostring(neighbourCoords)) then
        
            table.insert(neighboursThatExist, Hexfield.tiles[tostring(neighbourCoords)])

        end

    end

    return neighboursThatExist
end

function Hexfield.update(dt)

    if love.mouse.isDown(1) then

        local cellCoords = HL_convert.worldToAxial(love.mouse.custom_getXYWithOffset())

        local tileId = tostring(cellCoords)

        if not tileExists(tileId) then return end

    end

end

function Hexfield.draw()
    
    for id, tile in pairs(Hexfield.tiles) do

        love.graphics.setColor( terrainAttributes[ tile.terrain ].color )

        local curPath = hexlib.getHexPath(HL_convert.axialToWorld(tile.coords))

        love.graphics.polygon("fill", curPath)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.polygon("line", curPath)

    end


end

function Hexfield.movement_refresh()

    for id, tile in pairs(Hexfield.tiles) do
        tile.movement.effectiveOccupant = tile.occupant
    end

end

local function populate()

    for q=0, 4, 1 do
        for r=0, 4, 1 do

            local newCoords = HL_coords.axial:New(q, r)

            local newTile = {
                coords = newCoords,
                terrain=terrain.PLAINS,
                occupant=nil,

                movement = {
                    effectiveOccupant = nil,
                }
            }
            
            Hexfield.tiles[ tostring(newCoords) ] = newTile

            if love.math.random(1, 3) == 1 then
                newTile.terrain = terrain.SWAMP
            end
        end
    end

end

populate()

return Hexfield
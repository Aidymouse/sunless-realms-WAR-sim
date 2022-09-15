local Hexfield = require("obj.hexfield")

local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local phase_movement = {}

local moveQueue = {
    -- { unit, destinationCoords }
}

function phase_movement.update(dt)

    if STATE.MOVEMENT.currentlySelectedUnit == nil then

    elseif STATE.MOVEMENT.currentlySelectedUnit then

    end

end

local function deselectUnit()
    STATE.MOVEMENT.currentlySelectedUnit = nil
    STATE.MOVEMENT.validMoveTiles = {}
end

function phase_movement.mousepressed(x, y, button)

    local selectedUnit = STATE.MOVEMENT.currentlySelectedUnit

    if selectedUnit == nil then

        local clickedTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())

        if clickedTile == nil then return end
        if clickedTile.occupant == nil then return end

        local actingPlayer = PLAYERS[STATE.MOVEMENT.actingPlayerIndex]

        if clickedTile.occupant.controller ~= actingPlayer then return end
        if clickedTile.occupant.movement.hasMoved then return end

        STATE.MOVEMENT.currentlySelectedUnit = clickedTile.occupant

        local neighbours = Hexfield.getNeighbouringTiles(clickedTile.coords)
        local validNeigbours = {}
        for _, tile in ipairs(neighbours) do
            if tile.movement.effectiveOccupant == nil then
                table.insert(validNeigbours, tile)
            end
        end

        STATE.MOVEMENT.validMoveTiles = validNeigbours

    else

        local clickedTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())
        if clickedTile == nil then
            deselectUnit()
            return
        end

        if tostring(clickedTile.coords) == tostring(selectedUnit.occupiedTileCoords) then
            return
        end

        for _, tile in ipairs(STATE.MOVEMENT.validMoveTiles) do
            if tostring(clickedTile.coords) == tostring(tile.coords) then -- We have clicked on a valid tile

                selectedUnit.movement.destinationCoords = tile.coords
                selectedUnit.movement.hasMoved = true
                Hexfield.tiles[tostring(tile.coords)].movement.effectiveOccupant = selectedUnit
                Hexfield.tiles[tostring(selectedUnit.occupiedTileCoords)].movement.effectiveOccupant = nil

                deselectUnit()
                break

            end
        end

        deselectUnit()





    end
    

end


function phase_movement.draw()

    local curPlayer = PLAYERS[STATE.MOVEMENT.actingPlayerIndex]

    -- Valid Tile Dots
    if STATE.MOVEMENT.currentlySelectedUnit then
        
        local centerCoords = HL_convert.axialToWorld( STATE.MOVEMENT.currentlySelectedUnit.occupiedTileCoords )

        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("line", centerCoords.x, centerCoords.y, MAPATTRIBUTES.hexHeight/2)

        love.graphics.setColor(0.5, 1, 0, 1)
        for _, tile in ipairs(STATE.MOVEMENT.validMoveTiles) do
            local centerCoords = HL_convert.axialToWorld(tile.coords)

            love.graphics.circle("fill", centerCoords.x, centerCoords.y, MAPATTRIBUTES.hexHeight/3)
        end

    end

    -- Movement Plans

    --[[
    for _, unit in ipairs(curPlayer.units) do
        
        if unit.movement.destinationCoords ~= nil then
            
            local startXY = HL_convert.axialToWorld(unit.occupiedTileCoords)
            local endXY = HL_convert.axialToWorld(unit.movement.destinationCoords)

            love.graphics.setColor(1, 1, 0)
            love.graphics.line(startXY.x, startXY.y, endXY.x, endXY.y)

        end

    end
    ]]

    love.graphics.translate(-CAMERA.offsetX, -CAMERA.offsetY)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Acting: "..PLAYERS[STATE.MOVEMENT.actingPlayerIndex].name, 0, 16)
    love.graphics.translate(CAMERA.offsetX, CAMERA.offsetY)

end

--[[
function phase_movement.validateMovement()

    -- Returns false if an unit tries to move into a unit that isnt moving
    local curPlayer = PLAYERS[STATE.MOVEMENT.actingPlayerIndex]

    for _, unit in ipairs(curPlayer.units) do
        if unit.movement.destinationCoords ~= nil then

            local destinationOccupant = Hexfield.tiles[tostring(unit.movement.destinationCoords)].occupant
            if destinationOccupant == nil then goto continue end

            if destinationOccupant.movement.destinationCoords == nil then return false end
        end

        ::continue::
    end

    return true


end
]]


function phase_movement.commitMovement()

    
    local curPlayer = PLAYERS[STATE.MOVEMENT.actingPlayerIndex]
    
    -- TODO: Bug if you switch places where the second one.
    for _, unit in ipairs(curPlayer.units) do
        if unit.movement.destinationCoords ~= nil then
            
            -- Deregister occupant
            

            Hexfield.tiles[tostring(unit.occupiedTileCoords)].occupant = nil

            unit.occupiedTileCoords = unit.movement.destinationCoords

            local destinationTile = Hexfield.tiles[tostring(unit.movement.destinationCoords)]
            destinationTile.occupant = destinationTile.effectiveOccupant
            
            
        end
    end

end

return phase_movement
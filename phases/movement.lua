local Hexfield = require("obj.hexfield")

local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local phase_movement = {}

local moveQueue = {
    -- { movementType, unit, destinationCoords }
}
local movetypes = {
    NORMAL = "normal",
    SWITCH = "switch"
}

function phase_movement.update(dt)

    if STATE.MOVEMENT.currentlySelectedUnit == nil then

    elseif STATE.MOVEMENT.currentlySelectedUnit then

    end

end

local function tileIsValidMoveSpot(tile)

    if tile.movement.effectiveOccupant == nil then return true end
    if tile.movement.effectiveOccupant.controller == PLAYERS[STATE.MOVEMENT.actingPlayerIndex] then return true end
    return false
end


local function deselectUnit()
    STATE.MOVEMENT.currentlySelectedUnit = nil
    STATE.MOVEMENT.validMoveTiles = {}
end

local function switchUnits(unit1, unit2)

    local unit1Tile = Hexfield.tiles[tostring(unit1.movement.destinationCoords)]
    local unit2Tile = Hexfield.tiles[tostring(unit2.movement.destinationCoords)]

    local tempCoords = unit1.movement.destinationCoords
    unit1.movement.destinationCoords = unit2.movement.destinationCoords
    unit2.movement.destinationCoords = tempCoords

    unit1Tile.movement.effectiveOccupant = unit2
    unit2Tile.movement.effectiveOccupant = unit1

    unit1.movement.movesMade = unit1.movement.movesMade + 1
    unit2.movement.movesMade = unit2.movement.movesMade + 1


end

local function findValidMoveTiles(clickedTile)
    local neighbours = Hexfield.getNeighbouringTiles(clickedTile.coords)
    local validNeigbours = {}

    for _, tile in ipairs(neighbours) do

        if tileIsValidMoveSpot(tile) then
            table.insert(validNeigbours, tile)
        end

    end

    return validNeigbours

end

function phase_movement.mousepressed(x, y, button)

    local selectedUnit = STATE.MOVEMENT.currentlySelectedUnit

    if selectedUnit == nil then

        local clickedTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())

        if clickedTile == nil then return end
        if clickedTile.occupant == nil then return end

        local actingPlayer = PLAYERS[STATE.MOVEMENT.actingPlayerIndex]

        if clickedTile.movement.effectiveOccupant.controller ~= actingPlayer then return end
        if clickedTile.movement.effectiveOccupant.movement.movesMade >= clickedTile.occupant.movement.maxMoves then return end

        STATE.MOVEMENT.currentlySelectedUnit = clickedTile.occupant

        STATE.MOVEMENT.validMoveTiles = findValidMoveTiles(clickedTile)

    else

        local clickedTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())
        if clickedTile == nil then
            deselectUnit()
            return
        end

        -- What if we click on ourselves
        if tostring(clickedTile.coords) == tostring(selectedUnit.movement.destinationCoords) then
            deselectUnit()
            return
        end

        for _, tile in ipairs(STATE.MOVEMENT.validMoveTiles) do
            if tostring(clickedTile.coords) == tostring(tile.coords) then -- We have clicked on a valid tile

                -- Does the valid tile contain an allied unit?
                if tile.movement.effectiveOccupant ~= nil then
                    
                    local switchUnit = tile.movement.effectiveOccupant
                    -- Can unit move? If not, cancel all moves
                    if switchUnit.movement.movesMade >= switchUnit.movement.maxMoves then return end

                    table.insert(moveQueue, {type=movetypes.SWITCH, units={selectedUnit, switchUnit}, coords={selectedUnit.movement.destinationCoords, switchUnit.movement.destinationCoords} })

                    switchUnits(selectedUnit, switchUnit)


                -- Otherwise just move there
                else

                    table.insert(moveQueue, { type=movetypes.NORMAL, unit=selectedUnit, leftFromId=tostring(selectedUnit.movement.destinationCoords) } )

                    Hexfield.tiles[tostring(selectedUnit.movement.destinationCoords)].movement.effectiveOccupant = nil
                    Hexfield.tiles[tostring(tile.coords)].movement.effectiveOccupant = selectedUnit
                    
                    selectedUnit.movement.destinationCoords = tile.coords
                    selectedUnit.movement.movesMade = selectedUnit.movement.movesMade + 1
                    
                end

                break


            end
        end

        if selectedUnit.movement.movesMade >= selectedUnit.movement.maxMoves then 
            deselectUnit()
        else

            STATE.MOVEMENT.validMoveTiles = findValidMoveTiles( Hexfield.tiles[ tostring(selectedUnit.movement.destinationCoords) ] )

        end


    end


end



function phase_movement.undoMovement()

    if #moveQueue < 1 then return end

    local poppedMove = table.remove(moveQueue)

    if poppedMove.type == movetypes.NORMAL then
        local fromTile = Hexfield.tiles[ poppedMove.leftFromId ]

        local curTile = Hexfield.tiles[tostring(poppedMove.unit.movement.destinationCoords)]
        curTile.movement.effectiveOccupant = nil

        poppedMove.unit.movement.destinationCoords = fromTile.coords
        poppedMove.unit.movement.movesMade = poppedMove.unit.movement.movesMade - 1
    end


end


function phase_movement.draw()

    local curPlayer = PLAYERS[STATE.MOVEMENT.actingPlayerIndex]

    -- Valid Tile Dots
    if STATE.MOVEMENT.currentlySelectedUnit then
        
        local unitCenterCoords = HL_convert.axialToWorld( STATE.MOVEMENT.currentlySelectedUnit.movement.destinationCoords )

        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("line", unitCenterCoords.x, unitCenterCoords.y, MAPATTRIBUTES.hexHeight / 2)

        
        for _, tile in ipairs(STATE.MOVEMENT.validMoveTiles) do
            love.graphics.setColor(0.5, 1, 0, 1)
            if tile.movement.effectiveOccupant ~= nil then
                if tile.movement.effectiveOccupant.movement.movesMade < tile.movement.effectiveOccupant.movement.maxMoves then
                    love.graphics.setColor(0.5, 1, 1, 1)
                else
                    love.graphics.setColor(1,0.5, 0, 1)
                end
            end
            local centerCoords = HL_convert.axialToWorld(tile.coords)

            love.graphics.circle("fill", centerCoords.x, centerCoords.y, MAPATTRIBUTES.hexHeight/3)
        end

    end

    -- Who hasnt moved yet
    for _, unit in ipairs(curPlayer.units) do
        if unit.movement.movesMade < unit.movement.maxMoves then
            local unitCenterCoords = HL_convert.axialToWorld(unit.movement.destinationCoords)

            love.graphics.setColor(1, 0.5, 0.5, 1)
            love.graphics.circle("line", unitCenterCoords.x, unitCenterCoords.y-25, 15)
        end
    end

    -- Movement Plans
    love.graphics.translate(-CAMERA.offsetX, -CAMERA.offsetY)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Acting: "..PLAYERS[STATE.MOVEMENT.actingPlayerIndex].name, 0, 16)
    
    love.graphics.translate(CAMERA.offsetX, CAMERA.offsetY)

end

function phase_movement.commitMovement()


    local curPlayer = PLAYERS[STATE.MOVEMENT.actingPlayerIndex]

    for _, unit in ipairs(curPlayer.units) do
        if unit.movement.destinationCoords ~= nil then

            -- Deregister occupant
            if Hexfield.tiles[tostring(unit.occupiedTileCoords)].occupant == unit then 
                Hexfield.tiles[tostring(unit.occupiedTileCoords)].occupant = nil
            end

            -- Update units occupied tile
            unit.occupiedTileCoords = unit.movement.destinationCoords

            -- Update occupant of destination tile 
            local destinationTile = Hexfield.tiles[tostring(unit.movement.destinationCoords)]
            destinationTile.occupant = destinationTile.movement.effectiveOccupant
            
            
        end
    end

end

return phase_movement
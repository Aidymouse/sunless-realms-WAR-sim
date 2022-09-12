local Hexfield = require("obj.hexfield")

local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local phase_movement = {}

function phase_movement.update(dt)

    if STATE.MOVEMENT.currentlySelectedUnit == nil then

    elseif STATE.MOVEMENT.currentlySelectedUnit then

    end

end

function phase_movement.mousepressed(x, y, button)

    if STATE.MOVEMENT.currentlySelectedUnit == nil then

        local clickedTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())

        if clickedTile == nil then return end
        if clickedTile.occupant == nil then return end

        print(STATE.MOVEMENT.actingPlayer)

        if clickedTile.occupant.controller ~= STATE.MOVEMENT.actingPlayer then return end
        if clickedTile.occupant.movement.movesLeft <= 0 then return end

        -- TODO: Check if we're allowed to control this unit

        STATE.MOVEMENT.currentlySelectedUnit = clickedTile.occupant

        local neighbours = Hexfield.getNeighbouringTiles(clickedTile.coords)
        local validNeigbours = {}
        for _, tile in ipairs(neighbours) do
            if tile.occupant == nil then
                table.insert(validNeigbours, tile)
            end
        end
        
        STATE.MOVEMENT.validMoveTiles = validNeigbours


    elseif STATE.MOVEMENT.currentlySelectedUnit then

        local clickedTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())
        if clickedTile == nil then return end

        for _, tile in ipairs(STATE.MOVEMENT.validMoveTiles) do
            if tostring(clickedTile.coords) == tostring(tile.coords) then -- We have clicked on a valid tile

                -- De-register occupant of current unit tile
                Hexfield.tiles[tostring( STATE.MOVEMENT.currentlySelectedUnit.occupiedTileCoords )].occupant = nil
                
                -- Change unit tile
                STATE.MOVEMENT.currentlySelectedUnit.occupiedTileCoords = clickedTile.coords
                STATE.MOVEMENT.currentlySelectedUnit.movement.movesLeft = STATE.MOVEMENT.currentlySelectedUnit.movement.movesLeft - 1

                -- Register occupant of unit tile
                Hexfield.tiles[tostring( clickedTile.coords )].occupant = STATE.MOVEMENT.currentlySelectedUnit
                
                -- Reset state
                STATE.MOVEMENT.currentlySelectedUnit = nil
                STATE.MOVEMENT.validMoveTiles = {}

                break
            end
        end



    end
    

end


function phase_movement.draw()

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


end

return phase_movement
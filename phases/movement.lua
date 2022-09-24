local Hexfield = require("obj.hexfield")

local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions
local HL_coords = Hexlib.coords

local phase_movement = {}

local hoveredTile
local latestMovePlanTile

function phase_movement.refresh()

end

local function updateUnitPositon(unit, newTileCoords) 

    Hexfield.tiles[tostring(unit.occupiedTileCoords)].occupant = nil
    Hexfield.tiles[tostring(newTileCoords)].occupant = unit

    unit.occupiedTileCoords = newTileCoords

end

local function verifyMovePlan(moveplan)

    -- Check, does move plan end on another occupant?
    local lastTile = moveplan[#moveplan]
    if lastTile.occupant ~= nil then
        return false
    end

    return true

end

function phase_movement.update(dt)

    hoveredTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())

    if STATE.MOVEMENT.selectedUnit ~= nil then

        if hoveredTile ~= latestMovePlanTile then
            print("Hovered new tile")
            table.insert(STATE.MOVEMENT.selectedMovePlan, hoveredTile)
            latestMovePlanTile = hoveredTile
        end

        if not love.mouse.isDown(1) and STATE.MOVEMENT.selectedUnit ~= nil then
            -- Mouse has been let go
            print("Dropped")

            
            if verifyMovePlan(STATE.MOVEMENT.selectedMovePlan) then
                updateUnitPositon(STATE.MOVEMENT.selectedUnit,
                    STATE.MOVEMENT.selectedMovePlan[#STATE.MOVEMENT.selectedMovePlan].coords)

            end
            
            STATE.MOVEMENT.selectedUnit = nil
            STATE.MOVEMENT.selectedMovePlan = {}
            latestMovePlanTile = nil
        end
    
    end

end

function phase_movement.mousepressed(x, y, button)
    
    if button ~= 1 then return end

    local clicked_tile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())
    if clicked_tile == nil then return end
    if clicked_tile.occupant == nil then return end
    if clicked_tile.occupant.controller ~= STATE.MOVEMENT.actingPlayer then return end

    print("Picked up "..tostring(clicked_tile.occupant))
    STATE.MOVEMENT.selectedUnit = clicked_tile.occupant

    table.insert(STATE.MOVEMENT.selectedMovePlan, clicked_tile)

    latestMovePlanTile = clicked_tile

end

function phase_movement.draw()

    -- Draw Move Plan

    if STATE.MOVEMENT.selectedMovePlan ~= nil then
        
        local moveplan = STATE.MOVEMENT.selectedMovePlan

        for tileIndex=1, #moveplan-1 do
            local fromTile = moveplan[tileIndex]
            local toTile = moveplan[tileIndex+1]

            local fromXY = HL_convert.axialToWorld(fromTile.coords)
            local toXY = HL_convert.axialToWorld(toTile.coords)

            love.graphics.line(fromXY.x, fromXY.y, toXY.x, toXY.y)
        end

    end


    love.graphics.translate(-CAMERA.offsetX, -CAMERA.offsetY)



    love.graphics.translate(CAMERA.offsetX, CAMERA.offsetY)

end

local function tileIsValidMoveSpot(tile)

    if tile.occupant == nil then return true end
    if tile.occupant.controller == PLAYERS[STATE.MOVEMENT.actingPlayerIndex] then return true end
    return false

end



return phase_movement
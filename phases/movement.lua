local Hexfield = require("obj.hexfield")

local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions
local HL_coords = Hexlib.coords

local phase_movement = {
    state = {

        selectedUnit = nil,
        selectedMovePlan = {},

        playersWhoHaveMoved = {},
        actingPlayerIndex = 1,
        actingPlayer = PLAYERS[1]

    }

}



local State = phase_movement.state

local hoveredTile
local latestMovePlanTile

function phase_movement.refresh()
    State.playersWhoHaveMoved = {}
    State.validMoveTiles = {}
    State.actingPlayer = PLAYERS[1]

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

local function validateNewTile(tile)

    if tile == nil then return false end

    local from_tile = State.selectedMovePlan[#State.selectedMovePlan]

    -- If tile is out of range then nope! Don't allow
    if Hexlib.axial_distance(tile.coords, from_tile.coords) > 1 then return false end

    -- Don't disobey max moves!
    -- Move plan also include first tile, so subtract by 1 to correct
    if #State.selectedMovePlan-1 == (State.selectedUnit.movement.maxMoves - State.selectedUnit.movement.movesMade) then return false end


    if tile.occupant ~= nil then
        if tile.occupant.controller ~= State.selectedUnit.controller then return false end
    end

    return true
end

function phase_movement.update(dt)

    hoveredTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())

    if State.selectedUnit ~= nil then

        if hoveredTile ~= latestMovePlanTile then
            print("Hovered new tile")

            if #State.selectedMovePlan > 1 and hoveredTile == State.selectedMovePlan[#State.selectedMovePlan - 1] then
                table.remove(State.selectedMovePlan)
            elseif validateNewTile(hoveredTile) then
                table.insert(State.selectedMovePlan, hoveredTile)
                
            end
            


            -- If we mouse over the second latest move tile, roll back to that tile
            --print(tostring(State.selectedMovePlan[#State.selectedMovePlan - 1].coords))

            
            latestMovePlanTile = hoveredTile
            
        end

        if not love.mouse.isDown(1) and State.selectedUnit ~= nil then
            -- Mouse has been let go
            print("Dropped")

            
            --if verifyMovePlan(State.selectedMovePlan) then
            --end
            State.selectedUnit.movement.movesMade = State.selectedUnit.movement.movesMade + #State.selectedMovePlan-1
            updateUnitPositon(State.selectedUnit,
                State.selectedMovePlan[#State.selectedMovePlan].coords)
            
            State.selectedUnit = nil
            State.selectedMovePlan = {}
            latestMovePlanTile = nil
        end
    
    end

end

function phase_movement.mousepressed(x, y, button)
    
    if button ~= 1 then return end

    local clicked_tile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())
    if clicked_tile == nil then return end
    if clicked_tile.occupant == nil then return end
    if clicked_tile.occupant.controller ~= State.actingPlayer then return end

    print("Picked up "..tostring(clicked_tile.occupant))
    State.selectedUnit = clicked_tile.occupant

    table.insert(State.selectedMovePlan, clicked_tile)

    latestMovePlanTile = clicked_tile

end

function phase_movement.draw()

    -- Draw Move Plan

    if State.selectedMovePlan ~= nil then
        
        local moveplan = State.selectedMovePlan

        for tileIndex=1, #moveplan-1 do
            local fromTile = moveplan[tileIndex]
            local toTile = moveplan[tileIndex+1]

            local fromXY = HL_convert.axialToWorld(fromTile.coords)
            local toXY = HL_convert.axialToWorld(toTile.coords)

            love.graphics.line(fromXY.x, fromXY.y, toXY.x, toXY.y)
        end

    end


    love.graphics.translate(-CAMERA.offsetX, -CAMERA.offsetY)

    for i, tile in ipairs(State.selectedMovePlan) do
        love.graphics.print(tostring(tile.coords), 500, i*16)
    end

    love.graphics.translate(CAMERA.offsetX, CAMERA.offsetY)

end

local function tileIsValidMoveSpot(tile)

    if tile.occupant == nil then return true end
    if tile.occupant.controller == PLAYERS[State.actingPlayerIndex] then return true end
    return false

end



return phase_movement
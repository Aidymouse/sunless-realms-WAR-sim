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
    State.actingPlayerIndex = 1 -- TODO: Find this based on tactical advantage
    State.actingPlayer = PLAYERS[State.actingPlayerIndex]

end


local function updateUnitPositon(unit, newTileCoords) 

    Hexfield.tiles[tostring(unit.occupiedTileCoords)].occupant = nil
    Hexfield.tiles[tostring(newTileCoords)].occupant = unit

    unit.occupiedTileCoords = newTileCoords

end

local function validateNewTile(tile)

    
    if tile == nil then return false end
    -- Prevent duplicate tiles 
    if tile == State.selectedMovePlan[#State.selectedMovePlan] then return false end

    local from_tile = State.selectedMovePlan[#State.selectedMovePlan]

    -- If tile is out of range then nope! Don't allow
    if Hexlib.axial_distance(tile.coords, from_tile.coords) > 1 then return false end

    -- Don't disobey max moves!
    -- Move plan also include first tile, so subtract by 1 to correct
    if #State.selectedMovePlan-1 == (State.selectedUnit.movement.max_moves - State.selectedUnit.movement.moves_made) then return false end

    -- If the tile has an ally unit in it
    -- And the tile the unit is moving from is free
    -- And the unit we're moving in to has movement left

    if tile.occupant ~= nil then
        if tile.occupant.controller ~= State.selectedUnit.controller then return false end
    end

    return true
end

local function validateMovePlan()
    
    if #State.selectedMovePlan == 1 then return true end

    local last_tile = State.selectedMovePlan[#State.selectedMovePlan]
    if last_tile == nil then return false end

    if last_tile.occupant ~= nil then
        if last_tile.occupant.controller == State.actingPlayer then
            
            local switch_unit = last_tile.occupant
            local second_last_tile = State.selectedMovePlan[#State.selectedMovePlan-1]
            if switch_unit.movement.moves_made == switch_unit.movement.max_moves then return false end
            if second_last_tile.occupant ~= nil and second_last_tile.occupant ~= State.selectedUnit then return false end
            
            -- Switch units! Well, kinda
            --[[ Selected unit's position is going to be updated, but as part of that, it will
                    overwrite the position it's currently sitting on before moving
                    to its destination. By setting it's destination to where it wants to
                    go, we won't set something to null that we shouldnt. Then we can
                    update the switch units positon normally ]]
            Hexfield.tiles[tostring(State.selectedUnit.occupiedTileCoords)].occupant = nil
            State.selectedUnit.occupiedTileCoords = last_tile.coords
            
            updateUnitPositon(switch_unit, second_last_tile.coords)

            switch_unit.movement.moves_made = switch_unit.movement.moves_made + 1


        end
    end

    return true
end

function phase_movement.update(dt)

    hoveredTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())

    if State.selectedUnit ~= nil then

        if hoveredTile ~= latestMovePlanTile then
            --print("Hovered new tile")


            -- Reset move plan if hover over self tile
            
            if hoveredTile ~= nil and hoveredTile.occupant ~= nil and hoveredTile.occupant == State.selectedUnit then
                State.selectedMovePlan = {hoveredTile}

            -- Rewind move plan by one if we go back
            elseif hoveredTile == State.selectedMovePlan[#State.selectedMovePlan - 1] then
                table.remove(State.selectedMovePlan)
            
            -- Try to add tile to move plan, if we can
            elseif validateNewTile(hoveredTile) then
                table.insert(State.selectedMovePlan, hoveredTile)
                
            end
            
            
            latestMovePlanTile = hoveredTile
            
        end

        if not love.mouse.isDown(1) and State.selectedUnit ~= nil then
            -- Mouse has been let go
            --print("Dropped")

            
            if validateMovePlan() then
                State.selectedUnit.movement.moves_made = State.selectedUnit.movement.moves_made + #State.selectedMovePlan-1
            
                updateUnitPositon(
                    State.selectedUnit,
                    State.selectedMovePlan[#State.selectedMovePlan].coords
                )
            end
            
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



return phase_movement
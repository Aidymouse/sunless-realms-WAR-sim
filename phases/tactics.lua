
local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local Hexfield = require("obj.hexfield")

local Camera = require("lib.camera")

local phase_tactics = {
    state = {
        ---@type unit?
        selected_unit = nil, -- Type: unit
        
        ---@type tactics?
        currentlyDeciding = nil, -- Type: tactics
        
        ---@type integer
        actingPlayerIndex = 1,

        

    }
}

local State = phase_tactics.state


function phase_tactics.refresh()
    State.selected_unit = nil -- Type: unit
    State.currentlyDeciding = nil -- Type: tactics
    State.actingPlayerIndex = 1
end

function phase_tactics.update(dt)
end

function phase_tactics.mousepressed(x, y, button)

    local clickedTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())
    if clickedTile == nil then return end
    if clickedTile.occupant == nil then return end


    if State.selected_unit == nil then

        if clickedTile.occupant.controller == PLAYERS[State.actingPlayerIndex] then
            phase_tactics.state.selected_unit = clickedTile.occupant

        end
    
    elseif State.selected_unit ~= nil then

        if State.currentlyDeciding == nil then return end
        if clickedTile.occupant == State.selected_unit then return end

        -- Validate chosen tactic 

        ---@type tactics
        local cur_tactic = State.currentlyDeciding

        ---@type unit
        local selected_unit = State.selected_unit

        local tdist = Hexlib.axial_distance(clickedTile.coords, selected_unit.occupiedTileCoords)

        if tdist > State.selected_unit.attack_range then return end
        
        -- Must be within attack range
        -- Archers cannot help

        -- Update Unit Tactics State
        State.selected_unit.tactics.chosen_tactic = State.currentlyDeciding
        State.selected_unit.tactics.target = clickedTile.occupant

        -- Update State
        State.selected_unit = nil
        State.currentlyDeciding = nil

    end

end

function phase_tactics.draw()

    local selected_unit = State.selected_unit

    if selected_unit ~= nil then
    
        local selected_unitXY = HL_convert.axialToWorld(selected_unit.occupiedTileCoords)
        love.graphics.circle("line", selected_unitXY.x, selected_unitXY.y, MAPATTRIBUTES.hexHeight/2)

    end

    -- Draw Unit Tactics
    local curPlayer = PLAYERS[State.actingPlayerIndex]

    for _, unit in ipairs(curPlayer.units) do
        
        if State.selected_unit == unit and State.currentlyDeciding ~= nil then
            goto continue
        end

        if unit.tactics.target ~= nil and unit.tactics.chosen_tactic ~= tactics.NONE then
            local startXY = HL_convert.axialToWorld(unit.occupiedTileCoords)
            local endXY = HL_convert.axialToWorld(unit.tactics.target.occupiedTileCoords)
            
            if unit.tactics.chosen_tactic == TACTICS.FIGHT then love.graphics.setColor(1, 0, 0) end
            if unit.tactics.chosen_tactic == TACTICS.HELP then love.graphics.setColor(0, 1, 0) end
            if unit.tactics.chosen_tactic == TACTICS.HINDER then love.graphics.setColor(0, 0, 1) end
            
            love.graphics.line(startXY.x, startXY.y-25, endXY.x, endXY.y-25)

        end

        ::continue::
    end

    if State.selected_unit ~= nil and State.currentlyDeciding ~= nil then
        local startXY = HL_convert.axialToWorld(State.selected_unit.occupiedTileCoords)
        local endXY = love.mouse.custom_getXYWithOffset()

        if State.currentlyDeciding == tactics.FIGHT then love.graphics.setColor(1, 0, 0) end
        if State.currentlyDeciding == tactics.HELP then love.graphics.setColor(0, 1, 0) end
        if State.currentlyDeciding == tactics.HINDER then love.graphics.setColor(0, 0, 1) end

        love.graphics.line(startXY.x, startXY.y - 25, endXY.x, endXY.y)



    end


    Camera.to_screen_space()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Acting: " .. PLAYERS[State.actingPlayerIndex].name, 0, 16)
        local tactic = "None"
        if State.currentlyDeciding ~= nil then tactic = State.currentlyDeciding end
        love.graphics.print("Deciding: " .. tactic, 0, 48)
        
        local unit = "None"
        if State.selected_unit ~= nil then unit = tostring(State.selected_unit) end
        love.graphics.print("Deciding for unit: " .. tostring(unit), 0, 64)
        
        
    Camera.to_world_space()


end

return phase_tactics
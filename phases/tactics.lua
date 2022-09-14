
local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local Hexfield = require("obj.hexfield")

local gui_tactics_unit = require("ui.ui_tactics_unit")
local gui_tactics = require("ui.ui_tactics")

local phase_tactics = {}

function phase_tactics.update(dt)
end

function phase_tactics.mousepressed(x, y, button)

    local selectedUnit = STATE.TACTICS.currentlySelectedUnit

    local clickedTile = Hexfield.getTileFromWorldCoords(love.mouse.custom_getXYWithOffset())
    if clickedTile == nil then return end
    if clickedTile.occupant == nil then return end

    if selectedUnit == nil then

        if clickedTile.occupant.controller == PLAYERS[STATE.TACTICS.actingPlayerIndex] then
            STATE.TACTICS.currentlySelectedUnit = clickedTile.occupant

            gui_tactics_unit.updateButtonCoords(clickedTile.occupant)
            table.insert(STATE.activeGuis, gui_tactics_unit)
        end
    
    elseif selectedUnit ~= nil then

        if clickedTile.occupant == selectedUnit then return end

        -- Update Unit Tactics State
        selectedUnit.tactics.chosenTactic = STATE.TACTICS.currentlyDeciding
        selectedUnit.tactics.target = clickedTile.occupant

        -- Update State
        STATE.TACTICS.currentlySelectedUnit = nil
        STATE.TACTICS.currentlyDeciding = nil
        STATE.activeGuis = {gui_tactics}

    
    end

end

function phase_tactics.draw()

    local selectedUnit = STATE.TACTICS.currentlySelectedUnit

    if selectedUnit ~= nil then
    
        local selectedUnitXY = HL_convert.axialToWorld(selectedUnit.occupiedTileCoords)
        love.graphics.circle("line", selectedUnitXY.x, selectedUnitXY.y, MAPATTRIBUTES.hexHeight/2)

    end

    -- Draw Unit Tactics
    local curPlayer = PLAYERS[STATE.TACTICS.actingPlayerIndex]

    for _, unit in ipairs(curPlayer.units) do
        
        if STATE.TACTICS.currentlySelectedUnit == unit and STATE.TACTICS.currentlyDeciding ~= nil then
            goto continue
        end

        if unit.tactics.target and unit.tactics.chosenTactic ~= tactics.NONE then
            local startXY = HL_convert.axialToWorld(unit.occupiedTileCoords)
            local endXY = HL_convert.axialToWorld(unit.tactics.target.occupiedTileCoords)
            
            if unit.tactics.chosenTactic == tactics.FIGHT then love.graphics.setColor(1, 0, 0) end
            if unit.tactics.chosenTactic == tactics.HELP then love.graphics.setColor(0, 1, 0) end
            if unit.tactics.chosenTactic == tactics.HINDER then love.graphics.setColor(0, 0, 1) end
            
            love.graphics.line(startXY.x, startXY.y-25, endXY.x, endXY.y-25)

        end

        ::continue::
    end

    if STATE.TACTICS.currentlyDeciding and STATE.TACTICS.currentlySelectedUnit ~= nil then
        local startXY = HL_convert.axialToWorld(STATE.TACTICS.currentlySelectedUnit.occupiedTileCoords)
        local endXY = love.mouse.custom_getXYWithOffset()

        if STATE.TACTICS.currentlyDeciding == tactics.FIGHT then love.graphics.setColor(1, 0, 0) end
        if STATE.TACTICS.currentlyDeciding == tactics.HELP then love.graphics.setColor(0, 1, 0) end
        if STATE.TACTICS.currentlyDeciding == tactics.HINDER then love.graphics.setColor(0, 0, 1) end

        love.graphics.line(startXY.x, startXY.y - 25, endXY.x, endXY.y)



    end


    love.graphics.translate(-CAMERA.offsetX, -CAMERA.offsetY)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Acting: " .. PLAYERS[STATE.TACTICS.actingPlayerIndex].name, 0, 16)
    local tactic = "None"
    if STATE.TACTICS.currentlyDeciding ~= nil then tactic = STATE.TACTICS.currentlyDeciding end
    love.graphics.print("Deciding: " .. tactic, 0, 48)
    
    local unit = "None"
    if STATE.TACTICS.currentlySelectedUnit ~= nil then unit = STATE.TACTICS.currentlySelectedUnit end
    love.graphics.print("Deciding: " .. tostring(unit), 0, 64)


    love.graphics.translate(CAMERA.offsetX, CAMERA.offsetY)


end

return phase_tactics
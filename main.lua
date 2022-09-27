-- Include Types
-- These are purely useless, but let you know what types are around if you're using the lua language server
require("definitions.coords")
-- These ones are not useless, they have global enum defintions
require("definitions.hexfield")
require("definitions.unit")




local Hexlib = require("lib.hexlib")
local HL_coords = Hexlib.coords
local HL_convert = Hexlib.coordConversions

-- Global State Stuff, probs a bad idea
---@alias map_attributes {hexWidth: number, hexHeight: number, orientation: hex_orientation}
MAPATTRIBUTES = {
    hexWidth = 100,
    hexHeight = 60,
    orientation = "flattop"
}

CAMERA = {
    offsetX = 100,
    offsetY = 100,

    oldX = -1,
    oldY = -1
}


-- ENUMS
game_phases = {
    MOVEMENT = "movement",
    TACTICS = "tactics",
    ACTION = "action"
}

tactics = {
    NONE = "none",
    FIGHT = "fight",
    HELP = "help",
    HINDER = "hinder"
}






-- State
STATE = {
    currentPhase = game_phases.MOVEMENT,

    armies = {},

    -- Phases
    --MOVEMENT = PHASES[game_phases.MOVEMENT].state,

    ACTION = {

    }
}



---@class player
---@field name string
---@field units unit[]
---@field color number[]

---@type player[]
PLAYERS = {
    {
        name="Player",
        units={},
        color={0, 0, 1}
    },
    {
        name="Enemy", -- OH THE MISERY
        units={},
        color={0, 0, 0}
    }
}

PHASES = {}
PHASES[game_phases.MOVEMENT] = require("phases.movement")
PHASES[game_phases.TACTICS] = require("phases.tactics")

Gui_manager = require("lib.guimanager")

Gui_manager.register_gui("movement", require("ui.ui_movement") )
Gui_manager.register_gui("tactics", require("ui.ui_tactics") )


love.mouse.custom_getXYWithOffset = function()
    return {x=love.mouse.getX() - CAMERA.offsetX, y=love.mouse.getY() - CAMERA.offsetY}
end



-- Objects
local Hexfield = require("obj.hexfield")
local Units = require("obj.Unit")


function changePhase(newPhase)

    if newPhase == game_phases.MOVEMENT then
        
        -- Refresh all units
        for _, player in ipairs(PLAYERS) do

            for _, unit in ipairs(player.units) do
                unit:movement_refresh()
            end

        end

        Hexfield.movement_refresh()

        PHASES[game_phases.MOVEMENT].refresh()

        Gui_manager.set_gui("movement")
        STATE.currentPhase = game_phases.MOVEMENT

    elseif newPhase == game_phases.TACTICS then
        for _, player in ipairs(PLAYERS) do

            for _, unit in ipairs(player.units) do
                unit:tactics_refresh()
            end

        end

        
        PHASES[game_phases.TACTICS].refresh()
        
        Gui_manager.set_gui("tactics")
        STATE.currentPhase = game_phases.TACTICS

    elseif newPhase == game_phases.ACTION then


        changePhase(game_phases.MOVEMENT)

    end

end

local function populateRandomUnits()

    for _, player in ipairs(PLAYERS) do
        local unitCounter = 1

        for _ = 0, love.math.random(1, 6), 1 do
            local randomCoords = HL_coords.axial:New(love.math.random(4), love.math.random(4))

            if Hexfield.tiles[tostring(randomCoords)].occupant == nil then
                local newUnit = Units:New(player, UNIT_TYPES.INFANTRY, randomCoords, unitCounter)
                table.insert(player.units, newUnit)
                Hexfield.tiles[tostring(randomCoords)].occupant = newUnit
                unitCounter = unitCounter+1
            end
        end

    end

end


-- Main Love Functions
function love.load()

    -- Populate random units
    populateRandomUnits()

    changePhase(game_phases.MOVEMENT)

end

function love.update(dt)


    Hexfield.update(dt)
    PHASES[STATE.currentPhase].update(dt)

    -- UNITS
    for _, player in ipairs(PLAYERS) do
        for _, unit in ipairs(player.units) do
            unit:update(dt)
        end
    end

    -- STATE
    Gui_manager.update(dt)

    -- CAMERA
    if CAMERA.oldX ~= -1 then
        local newX = love.mouse.getX()
        local newY = love.mouse.getY()

        local deltaX = newX - CAMERA.oldX
        local deltaY = newY - CAMERA.oldY

        CAMERA.offsetX = CAMERA.offsetX + deltaX
        CAMERA.offsetY = CAMERA.offsetY + deltaY

        CAMERA.oldX = newX
        CAMERA.oldY = newY
    end


end

function love.draw()
    -- Transition to world space
    love.graphics.translate(CAMERA.offsetX, CAMERA.offsetY)

    Hexfield.draw()


    -- Draw highlighter ring if mouse is in hex
    local cellCoords = HL_convert.worldToAxial(love.mouse.custom_getXYWithOffset())
    local mousePath = Hexlib.getHexPath(HL_convert.axialToWorld(cellCoords))
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.polygon("line", mousePath)

    for _, player in ipairs(PLAYERS) do

        for _, unit in ipairs(player.units) do
            unit:draw()
        end

    end

    


    PHASES[STATE.currentPhase].draw()

    -- Exit to screen space
    love.graphics.translate(-CAMERA.offsetX, -CAMERA.offsetY)

    -- Draw Gui
    Gui_manager.draw()
    

    -- Display Mouse Info
    --[[
        local mxy = love.mouse.custom_getXYWithOffset()
        love.graphics.print("Mouse Position (world space): "..mxy.x..", "..mxy.y, 0, 50)
        ]]
    love.graphics.print("Hovered Cell: "..cellCoords.q..", "..cellCoords.r, 0, love.graphics.getHeight()-32)


    -- Display current tiles occupant
    if Hexfield.tileExists(tostring(cellCoords)) then
        local mouseTile = Hexfield.tiles[tostring(cellCoords)]
        if mouseTile.occupant ~= nil then

            love.graphics.print("Current Occupant: "..tostring(Hexfield.tiles[tostring(cellCoords)].occupant), 0, love.graphics.getHeight()-16)

        else
            love.graphics.print("Current Occupant: No One", 0, love.graphics.getHeight()-16)
        end

    else

        love.graphics.print("Current Occupant: —", 0, love.graphics.getHeight()-16)

    end


    -- Debug
    love.graphics.print(STATE.currentPhase, 0, 0)
    

end


love.keypressed = function(key, code, isrepeat)

    Gui_manager.keypressed(key)

    

end
love.textinput = function(key)
    Gui_manager.textinput(key)

    
end
love.mousepressed = function(x, y, button)
    PHASES[STATE.currentPhase].mousepressed(x, y, button)
    Gui_manager.mousepressed(x, y, button)
    
    if (button == 2) then
        CAMERA.oldX = x
        CAMERA.oldY = y
    end


end
love.mousereleased = function(x, y, button)
    Gui_manager.mousereleased(x, y, button)

    if (button == 2) then
        CAMERA.oldX = -1
        CAMERA.oldY = -1
    end
    
end
love.wheelmoved = function(x, y)
    Gui_manager.wheelmoved(x, y)

    
end

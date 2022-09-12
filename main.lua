

local gui = require('lib.gspot')

local gui_movement = require("ui.movement")
local gui_tactics = require("ui.tactics")

local Hexlib = require("lib.hexlib")
local HL_coords = Hexlib.coords
local HL_convert = Hexlib.coordConversions

-- Global State Stuff, probs a bad idea
MAPATTRIBUTES = {
    hexWidth = 100,
    hexHeight = 60,
    orientation = Hexlib.hex_orientation.FLATTOP
}

CAMERA = {
    offsetX = 100,
    offsetY = 100
}

game_phases = {
    MOVEMENT = "movement",
    TACTICS = "tactics",
    ACTION = "action"
}

STATE = {
    currentPhase = game_phases.MOVEMENT,
    activeGui = gui_movement,

    armies = {},

    -- Phases
    MOVEMENT = {},

    TACTICS = {

    },

    ACTION = {

    }
}

love.mouse.custom_getXYWithOffset = function()
    return {x=love.mouse.getX() - CAMERA.offsetX, y=love.mouse.getY() - CAMERA.offsetY}
end

-- Objects
local Hexfield = require("obj.hexfield")
local Units = require("obj.Unit")


-- Main Love Functions
function love.load()

    units = {}
    enemyUnits = {}

    -- Populate random units
    for _=0, love.math.random(1, 6), 1 do
        local randomCoords = HL_coords.axial:New( love.math.random(4), love.math.random(4) )
        local newUnit = Units:New(Units.unit_types.INFANTRY, randomCoords)
        table.insert(units, newUnit)
        Hexfield.tiles[ tostring(randomCoords) ].occupant = newUnit
    end

    for _=0, love.math.random(1, 6), 1 do
        local randomCoords = HL_coords.axial:New( love.math.random(4), love.math.random(4) )
        local newUnit = Units:New(Units.unit_types.INFANTRY, randomCoords, {1, 0, 0})
        table.insert(enemyUnits, newUnit)
        Hexfield.tiles[ tostring(randomCoords) ].occupant = newUnit
    end

end

function love.update(dt)

    Hexfield.update(dt)


    -- STATE
    STATE.activeGui:update(dt)

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

    for _, unit in ipairs(units) do

        unit:draw(MAPATTRIBUTES)

    end

    for k, unit in ipairs(enemyUnits) do
        
        unit:draw(MAPATTRIBUTES)

    end

    -- Exit to world space
    love.graphics.translate(-100, -100)

    STATE.activeGui:draw()

    -- Debug
    love.graphics.print(STATE.currentPhase, 0, 0)
    

end


love.keypressed = function(key, code, isrepeat)
  STATE.activeGui:keypress(key)
end
love.textinput = function(key)
  STATE.activeGui:textinput(key)
end
love.mousepressed = function(x, y, button)
  STATE.activeGui:mousepress(x, y, button)
end
love.mousereleased = function(x, y, button)
  STATE.activeGui:mouserelease(x, y, button)
end
love.wheelmoved = function(x, y)
  STATE.activeGui:mousewheel(x, y)
end
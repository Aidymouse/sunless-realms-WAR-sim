

local gui = require('lib.gspot')

local gui_movement = require("ui.ui_movement")
local gui_tactics = require("ui.ui_tactics")

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

tactics = {
    NONE = "none",
    FIGHT = "fight",
    HELP = "help",
    HINDER = "hinder"
}

STATE = {
    currentPhase = game_phases.MOVEMENT,
    activeGuis = {gui_movement},

    armies = {},

    -- Phases
    MOVEMENT = {

        currentlySelectedUnit = nil,
        validMoveTiles = {},
        playersWhoHaveMoved = {},
        actingPlayerIndex = 2

    },

    TACTICS = {

        currentlySelectedUnit = nil, -- Type: unit
        currentlyDeciding = nil, -- Type: tactics
        actingPlayerIndex = 1

    },

    ACTION = {

    }
}

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
                unit:movement_refreshMovement()
            end

        end

        Hexfield.movement_refresh()


        STATE.MOVEMENT.playersWhoHaveMoved = {}
        STATE.MOVEMENT.validMoveTiles = {}
        STATE.MOVEMENT.actingPlayer = PLAYERS[1] -- TODO: Base first player on tactical advantage

        STATE.activeGuis = {gui_movement}
        STATE.currentPhase = game_phases.MOVEMENT

    elseif newPhase == game_phases.TACTICS then
        for _, player in ipairs(PLAYERS) do

            for _, unit in ipairs(player.units) do
                unit:tactics_refresh()
            end

        end

        STATE.TACTICS.currentlyDeciding = nil
        STATE.TACTICS.currentlySelectedUnit = nil
        STATE.TACTICS.actingPlayerIndex = 1

        STATE.activeGuis = {gui_tactics}
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
                local newUnit = Units:New(player, Units.unit_types.INFANTRY, randomCoords, unitCounter)
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
    for _, gui in ipairs(STATE.activeGuis) do
        gui:update(dt)
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

    if Hexfield.tileExists(tostring(cellCoords)) then
        if Hexfield.tiles[tostring(cellCoords)].occupant ~= nil then

            love.graphics.print(tostring(Hexfield.tiles[tostring(cellCoords)].occupant), 300, 0)
            
        else
            love.graphics.print("No occupant", 300, 0)
        end
    end


    PHASES[STATE.currentPhase].draw()

    -- Exit to world space
    love.graphics.translate(-100, -100)

    for _, gui in ipairs(STATE.activeGuis) do
        gui:draw()
    end

    -- Debug
    love.graphics.print(STATE.currentPhase, 0, 0)
    

end


love.keypressed = function(key, code, isrepeat)

    for _, gui in ipairs(STATE.activeGuis) do
        gui:keypress(key)
    end

end
love.textinput = function(key)
    for _, gui in ipairs(STATE.activeGuis) do
        gui:textinput(key)
    end
end
love.mousepressed = function(x, y, button)
    PHASES[STATE.currentPhase].mousepressed(x, y, button)
    
    for _, gui in ipairs(STATE.activeGuis) do
        gui:mousepress(x, y, button)
    end



end
love.mousereleased = function(x, y, button)
    for _, gui in ipairs(STATE.activeGuis) do
        gui:mouserelease(x, y, button)
    end
end
love.wheelmoved = function(x, y)
    for _, gui in ipairs(STATE.activeGuis) do
        gui:mousewheel(x, y)
    end
end

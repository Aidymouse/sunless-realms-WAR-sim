

gui = require('lib.gspot')

activeGui = require("ui.movement")

Hexlib = require("lib.hexlib")
hl_coords = Hexlib.coords

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
    currentPhase = game_phases.MOVEMENT
}

love.mouse.custom_getXYWithOffset = function()
    return {x=love.mouse.getX() - CAMERA.offsetX, y=love.mouse.getY() - CAMERA.offsetY}
end

Hexfield = require("obj.hexfield")
Units = require("obj.Unit")

function love.load()

    units = {}
    enemyUnits = {}

    -- Populate random units
    for i=0, love.math.random(1, 6), 1 do
        randomCoords = hl_coords.axial:New( love.math.random(4), love.math.random(4) )
        newUnit = Units:New(Units.unit_types.INFANTRY, randomCoords)
        table.insert(units, newUnit)
        Hexfield.tiles[ tostring(randomCoords) ].occupant = newUnit
    end

    for i=0, love.math.random(1, 6), 1 do
        randomCoords = hl_coords.axial:New( love.math.random(4), love.math.random(4) )
        newUnit = Units:New(Units.unit_types.INFANTRY, randomCoords, {1, 0, 0})
        table.insert(enemyUnits, newUnit)
        Hexfield.tiles[ tostring(randomCoords) ].occupant = newUnit
    end

end

function love.update(dt)

    Hexfield.update(dt)


    -- STATE

    if STATE.currentPhase == game_phases.MOVEMENT then
        
        

    end

    activeGui:update(dt)

end

function love.draw()
    -- Transition to world space
    love.graphics.translate(CAMERA.offsetX, CAMERA.offsetY)
    
    Hexfield.draw() 
    

    -- Draw highlighter ring if mouse is in hex
    local cellCoords = hl_convert.worldToAxial(love.mouse.custom_getXYWithOffset())
    local mousePath = Hexlib.getHexPath(hl_convert.axialToWorld(cellCoords))
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.polygon("line", mousePath)

    for k, unit in ipairs(units) do
        
        unit:draw(MAPATTRIBUTES)

    end

    for k, unit in ipairs(enemyUnits) do
        
        unit:draw(MAPATTRIBUTES)

    end

    -- Exit to world space
    love.graphics.translate(-100, -100)

    activeGui:draw()

    -- Debug
    love.graphics.print(STATE.currentPhase, 0, 0)
    

end


love.keypressed = function(key, code, isrepeat)
  activeGui:keypress(key)
end
love.textinput = function(key)
  activeGui:textinput(key)
end
love.mousepressed = function(x, y, button)
  activeGui:mousepress(x, y, button)
end
love.mousereleased = function(x, y, button)
  activeGui:mouserelease(x, y, button)
end
love.wheelmoved = function(x, y)
  activeGui:mousewheel(x, y)
end
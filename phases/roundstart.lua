local Camera = require("lib.camera")

local phase_roundstart = {
    state = {
        winning_player = nil
    }
}
local State = phase_roundstart.state
local big_font = love.graphics.setNewFont(48)
local small_font = love.graphics.setNewFont(12)

function phase_roundstart.update(dt)
    if Camera.zoom_scale > 0.5 then
        Camera.zoom_scale = Camera.zoom_scale - dt
    end
end

function phase_roundstart.mousepressed(x, y, button)
end

function phase_roundstart.draw()

    Camera.to_screen_space()
    
    love.graphics.setFont(big_font)
    
    love.graphics.print("WINNER: "..State.winning_player.name, 100, 100)
    
    love.graphics.setFont(small_font)
    
    Camera.to_world_space()
end

return phase_roundstart
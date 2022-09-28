local phase_roundstart = {
    state = {
        winning_player = nil
    }
}
local State = phase_roundstart.state
local big_font = love.graphics.setNewFont(48)
local small_font = love.graphics.setNewFont(12)

function phase_roundstart.update(dt)
    CAMERA.zoomScale = CAMERA.zoomScale * 0.99
end

function phase_roundstart.mousepressed(x, y, button)
end

function phase_roundstart.draw()

    love.graphics.translate(-CAMERA.offsetX, -CAMERA.offsetY)
    
    love.graphics.setFont(big_font)
    
    love.graphics.print("WINNER: "..State.winning_player.name, 100, 100)
    
    love.graphics.setFont(small_font)
    
    love.graphics.translate(CAMERA.offsetX, CAMERA.offsetY)
end

return phase_roundstart
local Camera = {
    offsetX = 0,
    offsetY = 0,

    zoom_scale = 1,

    oldX = -1,
    oldY = -1

}

function Camera.to_world_space()
    love.graphics.push()
    love.graphics.translate(Camera.offsetX, Camera.offsetY)
    love.graphics.scale(Camera.zoom_scale, Camera.zoom_scale)
end

function Camera.to_screen_space()
    love.graphics.pop()
end


return Camera
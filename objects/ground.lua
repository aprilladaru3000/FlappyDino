ground = {}

function initGround()
    ground.y = height - 50
    ground.height = 50
    ground.color = {0.6, 0.5, 0.2}
end

function drawGround()
    love.graphics.setColor(ground.color)
    love.graphics.rectangle("fill", 0, ground.y, width, ground.height)
end
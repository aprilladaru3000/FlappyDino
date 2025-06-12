clouds = {}

function initClouds()
    for i = 1, 5 do
        table.insert(clouds, {
            x = math.random(0, width),
            y = math.random(50, height/2),
            width = math.random(60, 120),
            speed = math.random(30, 70)
        })
    end
end

function updateClouds(dt)
    for i, cloud in ipairs(clouds) do
        cloud.x = cloud.x - cloud.speed * dt
        if cloud.x + cloud.width < 0 then
            cloud.x = width
            cloud.y = math.random(50, height/2)
        end
    end
end

function drawClouds()
    love.graphics.setColor(1, 1, 1, 0.8)
    for i, cloud in ipairs(clouds) do
        love.graphics.rectangle("fill", cloud.x, cloud.y, cloud.width, 30, 15)
        love.graphics.rectangle("fill", cloud.x + 20, cloud.y - 20, cloud.width - 40, 30, 15)
    end
end
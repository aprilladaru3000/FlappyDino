function love.load()
    love.window.setTitle("Flappy Dino")
    width, height = love.graphics.getDimensions()
    gameFont = love.graphics.newFont(20)

    -- Game state
    gameState = "menu"
    score = 0
    highscore = 0

    -- Dino player
    dino = {
        x = 100,
        y = height / 2,
        width = 40,
        height = 30,
        velocity = 0,
        gravity = 800,
        jumpForce = -300,
        color = {0.2, 0.7, 0.2}
    }

    -- Ground setup
    ground = {
        y = height - 50,
        height = 50,
        color = {0.6, 0.5, 0.2}
    }

    -- Load obstacle system
    Obstacle = require('objects.obstacle')
    Obstacle.init()

    -- Load sounds
    sounds = {
        jump = love.audio.newSource("audio/jump.wav", "static"),
        score = love.audio.newSource("audio/score.mp3", "static"),
        hit = love.audio.newSource("audio/hit.wav", "static"),
        music = love.audio.newSource("audio/music.mp3", "stream")
    }
    sounds.music:setLooping(true)
    sounds.music:play()
    love.audio.setVolume(0.7)

    -- Background clouds
    clouds = {}
    for i = 1, 5 do
        table.insert(clouds, {
            x = math.random(0, width),
            y = math.random(50, height / 2),
            width = math.random(60, 120),
            speed = math.random(30, 70)
        })
    end
end

function love.update(dt)
    if gameState == "playing" then
        -- Dino physics
        dino.velocity = dino.velocity + dino.gravity * dt
        dino.y = dino.y + dino.velocity * dt

        if dino.y + dino.height > ground.y then
            dino.y = ground.y - dino.height
            dino.velocity = 0
            sounds.hit:play()
            gameState = "gameover"
        end

        if dino.y < 0 then
            dino.y = 0
            dino.velocity = 0
        end

        -- Update obstacles
        if Obstacle.update(dt) then
            score = score + 1
            sounds.score:play()
            highscore = math.max(score, highscore)
        end

        -- Check collision
        for _, obs in ipairs(Obstacle.list) do
            if Obstacle.checkCollision(dino, obs) then
                sounds.hit:play()
                gameState = "gameover"
                break
            end
        end

        -- Update background clouds
        for _, cloud in ipairs(clouds) do
            cloud.x = cloud.x - cloud.speed * dt
            if cloud.x + cloud.width < 0 then
                cloud.x = width
                cloud.y = math.random(50, height / 2)
            end
        end
    end
end

function love.draw()
    -- Background
    love.graphics.setBackgroundColor(0.7, 0.9, 1)

    -- Clouds
    love.graphics.setColor(1, 1, 1, 0.8)
    for _, cloud in ipairs(clouds) do
        love.graphics.rectangle("fill", cloud.x, cloud.y, cloud.width, 30, 15)
        love.graphics.rectangle("fill", cloud.x + 20, cloud.y - 20, cloud.width - 40, 30, 15)
    end

    -- Ground
    love.graphics.setColor(ground.color)
    love.graphics.rectangle("fill", 0, ground.y, width, ground.height)

    -- Dino
    love.graphics.setColor(dino.color)
    love.graphics.rectangle("fill", dino.x, dino.y, dino.width, dino.height, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", dino.x + 30, dino.y + 10, 5)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", dino.x + 30, dino.y + 10, 2)

    -- Obstacles
    Obstacle.draw()

    -- Score display
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(gameFont)
    love.graphics.print("Score: " .. score, 20, 20)
    love.graphics.print("Highscore: " .. highscore, 20, 50)

    -- Game state info
    if gameState == "menu" then
        love.graphics.printf("Press SPACE to Start", 0, height / 2 - 50, width, "center")
    elseif gameState == "gameover" then
        love.graphics.printf("Game Over! Press SPACE to Restart", 0, height / 2 - 50, width, "center")
    end

    -- Tampilkan nama developer di pojok kanan bawah
    local developerText = "Developed by: Daru, Nana, Rizki, Fauzi, Zahra"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(developerText)
    local textHeight = font:getHeight()

    love.graphics.setColor(1, 1, 1, 0.5) -- putih transparan
    love.graphics.print(developerText, width - textWidth - 10, height - textHeight - 5)

    love.graphics.setColor(1, 1, 1, 1) -- reset warna
end

function love.keypressed(key)
    if key == "space" then
        if gameState == "menu" or gameState == "gameover" then
            Obstacle.init()
            score = 0
            dino.y = height / 2
            dino.velocity = 0
            gameState = "playing"
        elseif gameState == "playing" then
            dino.velocity = dino.jumpForce
            sounds.jump:play()
        end
    end
end

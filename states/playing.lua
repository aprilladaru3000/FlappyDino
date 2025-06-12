function updatePlaying(dt)
    updateDino(dt)
    updateObstacles(dt)
    updateClouds(dt)
end

function keyPressedPlaying(key)
    if key == "space" or key == "up" then
        dinoJump()
    end
end

function startGame()
    gameState = "playing"
    score = 0
    dino.y = height/2
    dino.velocity = 0
    obstacles = {}
    obstacleTimer = 0
    obstacleInterval = 2
end
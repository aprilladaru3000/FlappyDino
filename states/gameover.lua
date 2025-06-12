function drawGameOver()
    love.graphics.printf("Game Over", 0, height/2 - 50, width, "center")
    love.graphics.printf("Press SPACE to restart", 0, height/2, width, "center")
end

function keyPressedGameOver(key)
    if key == "space" or key == "up" then
        startGame()
    end
end
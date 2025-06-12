function drawMenu()
    love.graphics.printf("Flappy Dino", 0, height/2 - 50, width, "center")
    love.graphics.printf("Press SPACE to start", 0, height/2, width, "center")
end

function keyPressedMenu(key)
    if key == "space" or key == "up" then
        startGame()
    end
end
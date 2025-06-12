local Dino = {}

function initDino()
    Dino.x = 100
    Dino.y = height/2
    Dino.width = 40
    Dino.height = 30
    Dino.velocity = 0
    Dino.gravity = 800
    Dino.jumpForce = -300
    Dino.color = {0.2, 0.7, 0.2}
    Dino.invincible = false
    Dino.invincibleTimer = 0
end

function Dino.update(dt)
    Dino.velocity = Dino.velocity + Dino.gravity * dt
    Dino.y = Dino.y + Dino.velocity * dt
    
    -- Handle invincibility
    if Dino.invincible then
        Dino.invincibleTimer = Dino.invincibleTimer - dt
        if Dino.invincibleTimer <= 0 then
            Dino.invincible = false
        end
    end
    
    -- Ground collision
    if Dino.y + Dino.height > ground.y then
        Dino.y = ground.y - Dino.height
        Dino.velocity = 0
        if not Dino.invincible then
            gameState = "gameover"
        end
    end
    
    -- Ceiling collision
    if Dino.y < 0 then
        Dino.y = 0
        Dino.velocity = 0
    end
end

function Dino.draw()
    -- Flash when invincible
    if not Dino.invincible or math.floor(love.timer.getTime() * 10) % 2 == 0 then
        love.graphics.setColor(Dino.color)
        love.graphics.rectangle("fill", Dino.x, Dino.y, Dino.width, Dino.height, 5)
        -- Eyes
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", Dino.x + 30, Dino.y + 10, 5)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", Dino.x + 30, Dino.y + 10, 2)
    end
end

function Dino.jump()
    Dino.velocity = Dino.jumpForce
    sounds.jump:play()
end

function Dino.makeInvincible(duration)
    Dino.invincible = true
    Dino.invincibleTimer = duration
end

return Dino
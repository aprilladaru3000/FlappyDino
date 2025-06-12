local Obstacle = {}

-- Enhanced obstacle types with more variety
Obstacle.TYPES = {
    CACTUS_SMALL = {
        width = 40,
        minHeight = 150,
        maxHeight = 250,
        color = {0.2, 0.5, 0.2},
        speedVariation = 1.0,
        draw = function(self, x, y, height)
            love.graphics.setColor(self.color)
            love.graphics.rectangle("fill", x, y - height, self.width, height)
            love.graphics.rectangle("fill", x - 8, y - height + 30, 16, 10)
            love.graphics.rectangle("fill", x + self.width - 8, y - height + 50, 16, 10)
        end
    },
    CACTUS_LARGE = {
        width = 60,
        minHeight = 200,
        maxHeight = 350,
        color = {0.15, 0.45, 0.15},
        speedVariation = 1.1,
        draw = function(self, x, y, height)
            love.graphics.setColor(self.color)
            love.graphics.rectangle("fill", x, y - height, self.width, height)
            love.graphics.rectangle("fill", x - 10, y - height + 40, 20, 15)
            love.graphics.rectangle("fill", x + self.width - 10, y - height + 70, 20, 15)
            love.graphics.rectangle("fill", x - 5, y - height + 100, 10, 10)
        end
    },
    BIRD = {
        width = 50,
        height = 30,
        minY = 100,
        maxY = 300,
        color = {0.8, 0.2, 0.2},
        speedVariation = 1.3,
        draw = function(self, x, y)
            love.graphics.setColor(self.color)
            love.graphics.rectangle("fill", x, y, self.width, self.height, 10)
            love.graphics.circle("fill", x + self.width, y + 10, 15)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", x + self.width + 5, y + 5, 3)
            love.graphics.setColor(1, 0.8, 0.2)
            love.graphics.polygon("fill", 
                x + self.width + 15, y + 10,
                x + self.width + 25, y + 15,
                x + self.width + 15, y + 20
            )
        end
    },
    CACTUS_CLUSTER = {
        width = 90,
        minHeight = 200,
        maxHeight = 300,
        color = {0.1, 0.4, 0.1},
        speedVariation = 1.2,
        draw = function(self, x, y, height)
            love.graphics.setColor(self.color)
            -- Three cacti close together
            love.graphics.rectangle("fill", x, y - height, 30, height)
            love.graphics.rectangle("fill", x + 30, y - height + 20, 30, height - 20)
            love.graphics.rectangle("fill", x + 60, y - height, 30, height)
        end
    }
}

Obstacle.list = {}
Obstacle.timer = 0
Obstacle.interval = 2
Obstacle.baseSpeed = 200
Obstacle.difficultyTimer = 0
Obstacle.difficultyInterval = 10  -- Increase difficulty every 10 seconds

function Obstacle.init()
    Obstacle.list = {}
    Obstacle.timer = 0
    Obstacle.interval = 2
    Obstacle.baseSpeed = 200
    Obstacle.difficultyTimer = 0
end

function Obstacle.add()
    local typeWeights = {
        CACTUS_SMALL = 0.35,
        CACTUS_LARGE = 0.3,
        BIRD = 0.25,
        CACTUS_CLUSTER = 0.1
    }
    
    -- Weighted random selection
    local r = love.math.random()
    local typeKey
    local cumulativeWeight = 0
    
    for k, weight in pairs(typeWeights) do
        cumulativeWeight = cumulativeWeight + weight
        if r <= cumulativeWeight then
            typeKey = k
            break
        end
    end
    
    local type = Obstacle.TYPES[typeKey]
    local obstacle = {
        type = type,
        x = width,
        passed = false,
        speed = Obstacle.baseSpeed * (type.speedVariation or 1),
        scored = false
    }
    
    if typeKey == "BIRD" then
        -- Birds can move up/down
        obstacle.y = love.math.random(type.minY, type.maxY)
        obstacle.yVelocity = love.math.random() > 0.5 and 20 or -20
    else
        obstacle.height = love.math.random(type.minHeight, type.maxHeight)
    end
    
    table.insert(Obstacle.list, obstacle)
end

function Obstacle.update(dt)
    -- Increase difficulty over time
    Obstacle.difficultyTimer = Obstacle.difficultyTimer + dt
    if Obstacle.difficultyTimer > Obstacle.difficultyInterval then
        Obstacle.difficultyTimer = 0
        Obstacle.baseSpeed = Obstacle.baseSpeed * 1.05
        Obstacle.interval = math.max(0.6, Obstacle.interval * 0.95)
    end
    
    -- Add new obstacles
    Obstacle.timer = Obstacle.timer + dt
    if Obstacle.timer > Obstacle.interval then
        Obstacle.add()
        Obstacle.timer = 0
    end
    
    -- Update existing obstacles
    for i, obstacle in ipairs(Obstacle.list) do
        -- Horizontal movement
        obstacle.x = obstacle.x - obstacle.speed * dt
        
        -- Vertical movement for birds
        if obstacle.type == Obstacle.TYPES.BIRD then
            obstacle.y = obstacle.y + obstacle.yVelocity * dt
            if obstacle.y < obstacle.type.minY or obstacle.y > obstacle.type.maxY then
                obstacle.yVelocity = -obstacle.yVelocity
            end
        end
        
        -- Score handling (moved to main game loop)
        if not obstacle.passed and dino.x > obstacle.x + obstacle.type.width then
            obstacle.passed = true
            return true  -- Signal to main.lua that player scored
        end
    end
    
    -- Remove off-screen obstacles
    for i = #Obstacle.list, 1, -1 do
        if Obstacle.list[i].x + Obstacle.list[i].type.width < 0 then
            table.remove(Obstacle.list, i)
        end
    end
    
    return false  -- No score this frame
end

function Obstacle.draw()
    for i, obstacle in ipairs(Obstacle.list) do
        if obstacle.type == Obstacle.TYPES.BIRD then
            obstacle.type:draw(obstacle.x, obstacle.y)
        else
            obstacle.type:draw(obstacle.x, ground.y, obstacle.height)
        end
    end
end

function Obstacle.checkCollision(player, obstacle)
    local collision = false
    
    if obstacle.type == Obstacle.TYPES.BIRD then
        collision = player.x < obstacle.x + obstacle.type.width and
                   player.x + player.width > obstacle.x and
                   player.y < obstacle.y + obstacle.type.height and
                   player.y + player.height > obstacle.y
    else
        collision = player.x < obstacle.x + obstacle.type.width and
                   player.x + player.width > obstacle.x and
                   player.y < ground.y and
                   player.y + player.height > ground.y - obstacle.height
    end
    
    return collision
end

return Obstacle
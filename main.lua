frame_length = 0.1
timers = {}

function love.load()
    love.window.setMode(800, 600)
    love.window.setTitle( "Damm I LÖVE vampires" )
    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    player = {}
    player.x = 100
    player.y = 75
    player.speed = 1
    player.looking_right = true
    player.spriteSheet = love.graphics.newImage('sprites/player.png')
    player.grid = anim8.newGrid( 32, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {}
    player.animations.attack = anim8.newAnimation( player.grid('1-4', 1) , frame_length )
    player.animations.idle = anim8.newAnimation( player.grid('1-4', 2), frame_length )

    -- player.animations.down = anim8.newAnimation( player.grid('1-4', 1), 0.2 )
    -- player.animations.left = anim8.newAnimation( player.grid('1-4', 2), 0.2 )
    -- player.animations.right = anim8.newAnimation( player.grid('1-4', 3), 0.2 )
    -- player.animations.up = anim8.newAnimation( player.grid('1-4', 4), 0.2 )
    
    player.anim = player.animations.idle
    background = love.graphics.newImage('sprites/background.png')
end

function love.update(dt)

    TickTimers(dt)

    if len(timers) > 0 then
        player.anim:update(dt)
        return
    end

    x=0
    y=0

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        x = x + 1
    end

    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        x = x - 1
    end

    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        y = y + 1
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        y = y - 1
    end

    if player.anim == player.animations.attack and player.anim.position == 4 then
        player.anim = player.animations.idle
    end

    if love.keyboard.isDown("space") then
        player.anim = player.animations.attack
        createTimer("atk", frame_length * 4 - 0.01)
    end

    player.x = player.x + x * player.speed
    player.y = player.y + y * player.speed

    if x < 0 then
        player.looking_right = true
    elseif x > 0 then
        player.looking_right = false
    end

    player.anim.flippedH = player.looking_right

    player.anim:update(dt)
end


-- DRAW STUFF -----------------
function love.draw()
    love.graphics.draw(background, 0, 0, 0, 4, 4)
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 4, 4)
end

function createTimer(name, seconds)
    timers[name] = seconds + .0
end

function TickTimers(dt)
    for k, v in pairs(timers) do
        timers[k] = timers[k] - dt
        if timers[k] <= 0 then
            table.removekey(timers, k)
        end
    end
end

function len(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

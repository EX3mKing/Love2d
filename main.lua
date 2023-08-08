_FL = 0.1 -- frame lenght
_DS = 4   -- display scale factor
timers = {}

function love.load()
    love.window.setMode(800, 600)
    love.window.setTitle( "Damm I LÖVE vampires" )
    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    spriteSheet = love.graphics.newImage('sprites/sheet.png')
    grid = anim8.newGrid( 32, 32, spriteSheet:getWidth(), spriteSheet:getHeight())

    player = {}
    player.x = 100
    player.y = 75
    player.speed = 1
    player.looking_right = true
    player.animations = {}
    player.animations.attack = anim8.newAnimation( grid('1-4', 1) , _FL )
    player.animations.idle = anim8.newAnimation( grid('1-4', 2), _FL )
    player.anim = player.animations.idle

    enemy = {}
    enemy.x = 100
    enemy.y = 75
    enemy.speed = 1
    enemy.looking_right = true
    enemy.animations = {}
    enemy.animations.attack = anim8.newAnimation( grid('1-4', 4) , _FL )
    enemy.animations.idle = anim8.newAnimation( grid('1-4', 3), _FL )
    enemy.anim = enemy.animations.idle


    background = {}
    background.sky = love.graphics.newImage('sprites/sky.png')
    background.planet = love.graphics.newImage('sprites/planet.png')
    background.arena = love.graphics.newImage('sprites/arena.png')

    actors = {}
    actors.foreground = {}
    actors.background = {}

    -- table.insert(actors.foreground, enemy)

    --player.spriteSheet = love.graphics.newImage('sprites/player.png')
    --player.grid = anim8.newGrid( 32, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    --player.animations.attack = anim8.newAnimation( player.grid('1-4', 1) , _FL )
    --player.animations.idle = anim8.newAnimation( player.grid('1-4', 2), _FL )
end

function love.update(dt)

    TickTimers(dt)
    -- enemy.anim:update(dt)

    UpdateAnimations(actors.foreground, dt)

    if len(timers) > 0 then
        player.anim:update(dt)
        return
    end

    x = 0
    y = 0

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
        table.insert(actors.foreground, deepcopy(enemy))
        CreateTimer("atk", _FL * 4 - 0.01)
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

    -- background
    love.graphics.draw(background.sky, 0, 0, 0, _DS, _DS)
    love.graphics.draw(background.planet, 0, 0, 0, _DS, _DS)

    -- behind enemies


    -- arena
    love.graphics.draw(background.arena, 0, 0, 0, _DS, _DS)

    -- foreground
    DrawEntities(actors.foreground)
    DrawEntities({player})
end


-- MY FUNCTIONS

function CreateTimer(name, seconds)
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

function EntityInsertionSort(entities)
    local j
    for j = 2, len(entities) do
        local key = entities[j]
        local i = j - 1
        while i > 0 and entities[i].y > key.y do
            entities[i + 1] = entities[i]
            i = i - 1
        end
        entities[i + 1] = key
    end
    return entities
end

function DrawEntities(entities)
    EntityInsertionSort(entities)
    for i = 1, len(entities) do
        entities[i].anim:draw(spriteSheet, entities[i].x, entities[i].y, nil, _DS, _DS)
    end
end

function UpdateAnimations(entities, dt)
    for e in pairs(entities) do
        entities[e].anim:update(dt)
    end
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
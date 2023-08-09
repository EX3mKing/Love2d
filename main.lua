_FL = 0.1       -- frame lenght
_DS = 4         -- display scale factor
timers = {}     -- timers table
last_id = 0     -- id of last enemy

function love.load()
    love.window.setMode(200 * _DS, 150 * _DS)
    love.window.setTitle( "Damm I LÖVE vampires" )
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    anim8 = require 'libraries/anim8'

    math.randomseed(os.time())

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

    enmy = {}

    enemy = {}
    enemy.id = 0
    enemy.x = 100
    enemy.y = 75
    enemy.speed = 0.25
    enemy.looking_right = true
    enemy.attack_distance = 16
    enemy.animations = {}
    enemy.animations.attack = anim8.newAnimation( grid('1-4', 4) , _FL )
    enemy.animations.idle = anim8.newAnimation( grid('1-4', 3), _FL )
    enemy.animations.spawn_circle = anim8.newAnimation( grid('1-4', 5), _FL)
    enemy.animations.spawn = anim8.newAnimation( grid('1-4', 6), _FL)
    enemy.anim = enemy.animations.idle


    background = {}
    background.sky = love.graphics.newImage('sprites/sky.png')
    background.planet = love.graphics.newImage('sprites/planet.png')
    background.arena = love.graphics.newImage('sprites/arena.png')
    
end

function love.update(dt)
    TickTimers(dt)
    UpdateAnimations({player, unpack(enmy)}, dt)
    
    EnemyUpdate()
    PlayerUpdate()
end


-- DRAW STUFF -----------------
function love.draw()

    -- background
    love.graphics.draw(background.sky, 0, 0, 0, _DS, _DS)
    love.graphics.draw(background.planet, 0, 0, 0, _DS, _DS)

    -- behind enemies
    -- DrawEntities({})

    -- arena
    love.graphics.draw(background.arena, 0, 0, 0, _DS, _DS)

    -- foreground
    DrawEntities({player, unpack(enmy)})
end


-- MY FUNCTIONS

function CreateTimer(name, seconds)
    timers[name] = seconds + .0
end

function TickTimers(dt)
    for k, v in pairs(timers) do
        timers[k] = timers[k] - dt
        if timers[k] <= 0 then
            --print(k)
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
        entities[i].anim.flippedH = not entities[i].looking_right
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
    else
        copy = orig
    end
    return copy
end

function SpawnEnemy()
    e = deepcopy(enemy)
    e.x = math.random(100, 550)
    e.y = math.random(170, 280)

    last_id = last_id + 1
    e.id = last_id 
    CreateTimer("e" .. tostring(e.id), _FL * 4 - 0.01)

    e.anim = e.animations.spawn

    if e.x > player.x then
        e.looking_right = false
    end
    
    table.insert(enmy, e)
end

function EnemyUpdate()
    for i = 1, len(enmy)do
        e = enmy[i]

        if timers["e" .. e.id] ~= nil then goto continue end

        if math.abs(e.x - player.x) <= e.attack_distance * _DS and math.abs(e.y - player.y) <= e.attack_distance * _DS / 2 then
            e.anim = e.animations.attack
            CreateTimer("e" .. e.id, 4 * _FL -0.01)
            goto continue
        end
        
        if e.x < player.x then
            e.looking_right = true
            e.x = e.x + e.speed
        else
            e.looking_right = false
            e.x = e.x - e.speed
        end

        if e.y < player.y then
            e.y = e.y + e.speed
        else
            e.y = e.y - e.speed
        end

        e.anim = e.animations.idle

        ::continue::
    end
end

function PlayerUpdate()
    if timers["atk"] ~= nil then
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

    player.anim = player.animations.idle

    if love.keyboard.isDown("space") then
        player.anim = player.animations.attack
        SpawnEnemy()
        CreateTimer("atk", _FL * 4 - 0.01)
    end

    player.x = player.x + x * player.speed
    player.y = player.y + y * player.speed

    if x > 0 then
        player.looking_right = true
    elseif x < 0 then
        player.looking_right = false
    end
end
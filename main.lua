_FL = 0.1       -- frame lenght
_DS =  4        -- display scale factor -- let it stay on 4
timers = {}     -- timers table
last_id = 0     -- id of last enemy
st = 3.0        -- time between spawns
et = st         -- enemy timer
score = 0       -- number of enemies killed

died = false

function love.load()
    -- window setup
    -- love.window.setMode(200 * _DS, 150 * _DS)
    -- love.window.setTitle( "Damm I LÖVE games" )
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- get libraries
    anim8 = require 'libraries/anim8'

    math.randomseed(os.time())

    spriteSheet = love.graphics.newImage('sprites/sheet.png')
    grid = anim8.newGrid( 32, 32, spriteSheet:getWidth(), spriteSheet:getHeight())

    -- player info
    player = {}
    player.x = 100 * _DS - 16 * _DS
    player.y = 75 * _DS - 16 * _DS
    player.speed = 40 * _DS
    player.looking_right = true
    player.reach = 27 * _DS
    player.animations = {}
    player.animations.attack = anim8.newAnimation( grid('1-4', 1) , _FL )
    player.animations.idle = anim8.newAnimation( grid('1-4', 2), _FL )
    player.anim = player.animations.idle

    -- table for copied enemies
    enmy = {}

    -- original instance of an enemy (enemy info)
    enemy = {}
    enemy.id = 0
    enemy.x = 100
    enemy.y = 75
    enemy.speed = 15 * _DS
    enemy.looking_right = true
    enemy.attack_distance = 19 * _DS
    enemy.attack_time = _FL * 6
    enemy.spawn_time = _FL * 4
    enemy.animations = {}
    enemy.animations.attack = anim8.newAnimation( grid('1-4', 4) , enemy.attack_time / 4 )
    enemy.animations.idle = anim8.newAnimation( grid('1-4', 3), _FL )
    enemy.animations.spawn_circle = anim8.newAnimation( grid('1-4', 5), _FL)
    enemy.animations.spawn = anim8.newAnimation( grid('1-4', 6), _FL)
    enemy.anim = enemy.animations.idle

    arena = {}
    arena.x0 = 25 * _DS
    arena.x1 = 137.5 * _DS
    arena.y0 = 42.5 * _DS
    arena.y1 = 70 * _DS

    background = {}
    background.sky = love.graphics.newImage('sprites/sky.png')
    background.planet = love.graphics.newImage('sprites/planet.png')
    background.arena = love.graphics.newImage('sprites/arena.png')

    sounds = {}
    sounds.death = love.audio.newSource( "audio/death.wav", "static" )
    sounds.eswing = love.audio.newSource( "audio/eswing.wav", "static" )
    sounds.pswing = love.audio.newSource( "audio/pswing.wav", "static" )
    sounds.hit = love.audio.newSource( "audio/hit.wav", "static" )
    sounds.select = love.audio.newSource( "audio/select.wav", "static" )

end

function love.update(dt)
    -- stop game after lose state
    if died then return end

    -- update everything
    TickTimers(dt)
    UpdateAnimations({player, unpack(enmy)}, dt)
    EnemyUpdate(dt)
    PlayerUpdate(dt)
    Spawner(dt)
end

function love.draw()

    -- draw score on defeat
    if died then
        love.graphics.print( "Lost", 85 * _DS, 20 * _DS, nil, _DS, _DS)
        love.graphics.print( "SCORE: " .. score, 70 * _DS, 60 * _DS, nil, _DS, _DS)
        return
    end

    -- background
    love.graphics.draw(background.sky, 0, 0, 0, _DS, _DS)
    love.graphics.draw(background.planet, 0, 0, 0, _DS, _DS)

    -- arena
    love.graphics.draw(background.arena, 0, 0, 0, _DS, _DS)

    -- foreground (player and enemies)
    DrawEntities(EntityInsertionSort({player, unpack(enmy)}))

    -- score top right
    love.graphics.print( "SCORE: " .. score, 0, 0, nil, _DS, _DS)
end

-- create timer with called x that lasts for x secounds
-- id is neaded for calling a function on enemy hit
-- it is not a required value
function CreateTimer(name, seconds, id)
    timers[name] = {}
    timers[name].t = seconds + .0
    timers[name].id = id
end

-- tick timers and remove ones that tick down past 0
function TickTimers(dt)
    for k, v in pairs(timers) do
        timers[k].t = timers[k].t - dt
        if timers[k].t <= 0 then
            -- check if it has component id
            -- timer will only have id if checking for hit on enemy
            if timers[k].id ~= nil then
                EnemyHitCheck(timers[k].id)
            end
            table.removekey(timers, k)          
        end
    end
end

-- remove key and item from table
function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

-- get lenght of the table
function len(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- sort enemies by y position
-- used for layered drawing
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

-- draw enemies and player
function DrawEntities(entities)
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

-- make a complete copy of a table
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

-- spawn enemy at random position
function SpawnEnemy()
    e = deepcopy(enemy)
    e.x = math.random(arena.x0, arena.x1)
    e.y = math.random(arena.y0, arena.y1)

    last_id = last_id + 1
    e.id = last_id 
    CreateTimer("e" .. tostring(e.id), e.spawn_time - 0.01)

    e.anim = e.animations.spawn

    if e.x > player.x then
        e.looking_right = false
    end
    
    table.insert(enmy, e)
end

-- spawn enemy every few sec
function Spawner(dt)
    et = et - dt
    if et < 0 then
        et = st
        SpawnEnemy()
    end
end

-- enemy logic
function EnemyUpdate(dt)
    for i = 1, len(enmy)do
        e = enmy[i]

        if timers["e" .. e.id] ~= nil then
            goto continue 
        end

        ex = e.x
        ey = e.y
        px = player.x
        py = player.y

        e.looking_right = ex < px

        if math.abs(ex - px) <= e.attack_distance - 3 * _DS and math.abs( ey - py) 
        <= e.attack_distance / 2 - 3 * _DS then
            e.anim = e.animations.attack
            CreateTimer("e" .. e.id, e.attack_time -0.01, e.id)
            goto continue
        end

        x = 0
        y = 0
        
        if ex < px then
            x = x + 1
        else
            x = x - 1
        end

        if ey < py then
            y = y + 1
        else
            y = y - 1
        end

        e.x = e.x + x * e.speed * dt
        e.y = e.y + y * e.speed * dt
        e.anim = e.animations.idle
        ::continue::
    end
end

-- check if enemy landed a hit
function EnemyHitCheck(id)
    -- see if there is an enemy with specified id
    -- it won't be there if enemy died to the player
    i = nil
    for l = 0, len(enmy) do
        if enmy[l] ~= nil then 
            if enmy[l].id == id then
                i = l
                break
            end
        end
    end

    if i == nil then return end

    sounds.eswing:play()

    -- actual checker (dependant on enemy orientation)

    --

    if enmy[i].looking_right then
        if player.x - enmy[i].x <= enmy[i].attack_distance and player.x - enmy[i].x > 0  
        and math.abs( enmy[i].y - player.y) <= enmy[i].attack_distance / 2 - 3 * _DS then
            print("hit p")
            died = true
            sounds.death:play()
        end
    else
        if enmy[i].x - player.x <= enmy[i].attack_distance and player.x - enmy[i].x < 0 
        and math.abs( enmy[i].y - player.y) <= enmy[i].attack_distance / 2 - 3 * _DS then
            print("hit p")
            died = true
            sounds.death:play()
        end
    end
    
end

-- player logic
function PlayerUpdate(dt)
    -- timer used to lock player during attack
    if timers["atk"] ~= nil then
        return
    end

    x = 0
    y = 0

    -- get player input
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then x = x + 1 end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then x = x - 1 end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then y = y + 1 end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then y = y - 1 end

    player.anim = player.animations.idle


    -- player attack
    if love.keyboard.isDown("space") then
        player.anim = player.animations.attack
        CreateTimer("atk", _FL * 4 - 0.01)

        sounds.pswing:play()

        for k, v in pairs(enmy) do
            e = enmy[k]

            -- check hit on enemy (dependant on enemy orientation)
            if player.looking_right then
                if e.x - player.x <= player.reach and e.x - player.x > 0 then
                    print("hit r")
                    score = score + 1
                    table.remove(enmy, k)
                    st = st - st * 0.05
                    print(st)
                    sounds.hit:play()
                end
            else
                if player.x - e.x <= player.reach and e.x - player.x < 0 then 
                    print("hit l")
                    score = score + 1
                    table.remove(enmy, k)
                    st = st - st * 0.05
                    print(st)
                    sounds.hit:play()
                end
            end
        end
    end

    -- move player
    player.x = player.x + x * player.speed * dt
    player.y = player.y + y * player.speed * dt

    -- limit the player to the arena borders
    if player.y > arena.y1 then player.y = arena.y1 end
    if player.y < arena.y0 then player.y = arena.y0 end
    if player.x > arena.x1 then player.x = arena.x1 end
    if player.x < arena.x0 then player.x = arena.x0 end

    if x > 0 then
        player.looking_right = true
    elseif x < 0 then
        player.looking_right = false
    end
end

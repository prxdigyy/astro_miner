-- main.lua
local Player = require("src.player")
local Crystal = require("src.crystal")
local Level = require("src.level")

local currentLevelIndex = 1
local levelConfig = Level.get(currentLevelIndex)
local player
local crystals = {}
local background
local score = 0
local crystalsCollected = 0
local font

local lavaY = nil
local lavaSpeed = 0

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    font = love.graphics.newFont(18)

    loadLevel(currentLevelIndex)
end

function loadLevel(index)
    levelConfig = Level.get(index)
    background = love.graphics.newImage(levelConfig.bg)
    player = Player.new(80, levelConfig.groundY - 128)
    player:setLevelGravity(levelConfig.gravity)

    -- crystals
    crystals = {}
    for _, pos in ipairs(levelConfig.crystalPositions) do
        table.insert(crystals, Crystal.new(pos[1], pos[2], "assets/crystals/crystal_5_32x32_12f_20d_no_border.png"))
    end

    -- HUD / score reset per design (keep total score but reset per-level collected if desired)
    crystalsCollected = 0

    -- lava setup
    if levelConfig.lava and levelConfig.lava.enabled then
        lavaY = love.graphics.getHeight()  -- start bottom
        lavaSpeed = levelConfig.lava.speed * 10 -- tune multiplier
    else
        lavaY = nil
    end
end

function love.update(dt)
    -- player: update with groundY so player resolves grounding before choosing animation
    player:update(dt, levelConfig.groundY)

    -- crystals
    for _, c in ipairs(crystals) do
        c:update(dt)
        if c:checkCollect(player:getRect()) then
            score = score + c.points
            crystalsCollected = crystalsCollected + 1
        end
    end

    -- remove collected crystals (optional)
    for i = #crystals, 1, -1 do
        if crystals[i].collected then table.remove(crystals, i) end
    end

    -- lava update (Level 3)
    if lavaY then
        lavaY = lavaY - lavaSpeed * dt
        -- if lava hits player
        local pr = player:getRect()
        if pr.y + pr.h >= lavaY then
            -- damage player
            player.hearts = player.hearts - 1
            -- respawn on ground (simple)
            player.x = 80
            player.y = levelConfig.groundY - 128
            player.vx = 0
            player.vy = 0
            if player.hearts <= 0 then
                -- restart level
                loadLevel(1)
                score = 0
            end
        end
    end

    -- check level completion (collected enough crystals AND reach right side portal)
    if crystalsCollected >= levelConfig.crystalsRequired then
        -- simple portal region near right edge
        local pr = player:getRect()
        if pr.x > (love.graphics.getWidth() - 140) then
            -- next level or finish
            currentLevelIndex = currentLevelIndex + 1
            if currentLevelIndex > #Level.data then
                -- game complete — show score and restart at level 1
                print("Game Complete! Final score:", score)
                currentLevelIndex = 1
                score = 0
            end
            loadLevel(currentLevelIndex)
        end
    end
end

function drawHUD()
    love.graphics.setFont(font)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Crystals: " .. crystalsCollected .. " / " .. levelConfig.crystalsRequired, 10, 32)
    love.graphics.print("Hearts: " .. player.hearts, 10, 54)
    love.graphics.print("Level: " .. levelConfig.name, 10, 76)
end

function love.draw()
    -- background
    love.graphics.draw(background, 0, 0, 0, 900 / background:getWidth(), 600 / background:getHeight())

    -- ground strip
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, levelConfig.groundY, love.graphics.getWidth(), love.graphics.getHeight() - levelConfig.groundY)

    -- crystals
    for _, c in ipairs(crystals) do
        c:draw()
    end

    -- draw player
    player:draw()

    -- lava
    if lavaY then
        love.graphics.setColor(1, 0.25, 0.05)
        love.graphics.rectangle("fill", 0, lavaY, love.graphics.getWidth(), love.graphics.getHeight() - lavaY)
        love.graphics.setColor(1,1,1)
    end

    -- HUD
    drawHUD()
end
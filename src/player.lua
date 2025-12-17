-- src/player.lua
local Animation = require("src.animation")

-- Toggle to draw a solid rectangle for debugging (helps isolate sprite vs logic flicker)
local DEBUG_PLAYER_RECT = false

local Player = {}
Player.__index = Player

local SPRITE_W, SPRITE_H = 64, 64
local SCALE = 2        -- 2x scale -> 128x128 on-screen
local DRAW_W = SPRITE_W * SCALE
local DRAW_H = SPRITE_H * SCALE

-- Configure default physics; levels override gravity
Player.default = {
    speed = 200,         -- px per second
    jumpForce = 420,     -- initial jump velocity
    gravity = 1000,      -- px/s^2
}

-- filenames and frame counts
local anims = {
    idle = {file = "assets/player/idle_breath(64,64).png", frames = 12, speed = 0.08},
    walk = {file = "assets/player/idle_walk(64,64).png", frames = 16, speed = 0.05},
    jump = {file = "assets/player/idle_jump(64,64).png", frames = 8,  speed = 0.10},
    hurt = {file = "assets/player/idle_hurt(64,64).png", frames = 6, speed = 0.12},
    dead = {file = "assets/player/idle_dead(64,64).png", frames = 11, speed = 0.12},
}

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0
    self.onGround = false
    self.dead = false
    self.hearts = 3

    -- load animations
    self.anim = {}
    for name, v in pairs(anims) do
        local img = love.graphics.newImage(v.file)
        self.anim[name] = Animation.new(img, SPRITE_W, SPRITE_H, v.frames, v.speed)
    end
    self.state = "idle"
    self.facingRight = true
    self.scale = SCALE
    -- draw offset (positive moves sprite down relative to collision box)
    self.drawOffset = 0
    -- timing to debounce rapid state changes (prevents animation flicker)
    self._stateTimer = 0
    self._stateDebounce = 0.06 -- seconds required before committing a new state

    -- physics settings (can be changed per level)
    self.speed = Player.default.speed
    self.jumpForce = -Player.default.jumpForce
    self.gravity = Player.default.gravity

    -- collision box
    self.w = DRAW_W * 0.6
    self.h = DRAW_H * 0.8

    return self
end

function Player:setLevelGravity(g)
    self.gravity = g
end

function Player:setDrawOffset(offset)
    self.drawOffset = offset or 0
end

function Player:update(dt, groundY)
    -- input
    local left = love.keyboard.isDown("left") or love.keyboard.isDown("a")
    local right = love.keyboard.isDown("right") or love.keyboard.isDown("d")
    local jumpKey = love.keyboard.isDown("space") or love.keyboard.isDown("w") or love.keyboard.isDown("up")

    self.vx = 0
    if left then
        self.vx = -self.speed
        self.facingRight = false
    elseif right then
        self.vx = self.speed
        self.facingRight = true
    end

    -- jump (only if on ground)
    if jumpKey and self.onGround then
        self.vy = self.jumpForce
        self.onGround = false
    end

    -- apply gravity
    self.vy = self.vy + self.gravity * dt

    -- integrate
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Modify the ground collision logic to account for the hitbox
    if groundY then
         if self.y + self.h >= groundY then
            self.y = groundY - self.h  -- Snap the *smaller* hitbox to the ground
            self.vy = 0
            self.onGround = true
        else
            self.onGround = false
        end
    end

    -- determine desired state (do not commit immediately)
    local desired
    if self.dead then
        desired = "dead"
    elseif not self.onGround then
        desired = "jump"
    elseif math.abs(self.vx) > 1 then
        desired = "walk"
    else
        desired = "idle"
    end

    -- debounce quick state flips to avoid animation popping
    if desired ~= self.state then
        self._stateTimer = self._stateTimer + dt
        if self._stateTimer >= self._stateDebounce then
            self.state = desired
            self._stateTimer = 0
        end
    else
        self._stateTimer = 0
    end

    -- update only the active animation so other animations pause where left off
    local active = self.anim[self.state]
    if active then
        active:update(dt)
    end
end

function Player:draw()
    local a = self.anim[self.state]
    -- ensure color is reset and draw at integer coords to avoid sub-pixel flicker
    love.graphics.setColor(1, 1, 1, 1)
    local dx = math.floor(self.x + 0.5)
    local dy = math.floor(self.y + 0.5)
    if DEBUG_PLAYER_RECT then
        love.graphics.setColor(1,0,0,1)
        love.graphics.rectangle("fill", dx, dy, self.w, self.h)
        love.graphics.setColor(1,1,1,1)
    else
        if self.facingRight then
            a:draw(dx, dy, self.scale, self.scale, false)
        else
            a:draw(dx, dy, self.scale, self.scale, true)
        end
    end
end

function Player:getRect()
    return { x = self.x, y = self.y, w = self.w, h = self.h }
end

return Player

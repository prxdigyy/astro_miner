-- src/crystal.lua
local Animation = require("src.animation")

local Crystal = {}
Crystal.__index = Crystal

local FRAME_W, FRAME_H = 32, 32
local SCALE = 2  -- display at 64x64

function Crystal.new(x, y, imagepath)
    local self = setmetatable({}, Crystal)
    self.x = x
    self.y = y
    self.collected = false
    self.points = 1

    local img = love.graphics.newImage(imagepath)
    self.anim = Animation.new(img, FRAME_W, FRAME_H, 12, 0.08)
    self.w = FRAME_W * SCALE
    self.h = FRAME_H * SCALE
    return self
end

function Crystal:update(dt)
    if not self.collected then
        self.anim:update(dt)
    end
end

function Crystal:draw()
    if not self.collected then
        self.anim:draw(self.x, self.y, SCALE, SCALE, false)
    end
end

function Crystal:checkCollect(playerRect)
    if self.collected then return false end
    local pr = playerRect
    if pr.x < self.x + self.w and self.x < pr.x + pr.w and pr.y < self.y + self.h and self.y < pr.y + pr.h then
        self.collected = true
        return true
    end
    return false
end

return Crystal
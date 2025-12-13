-- src/animation.lua
local Animation = {}
Animation.__index = Animation

-- image: love.graphics.Image
-- frameW, frameH: frame size in px
-- framesCount: number of frames horizontally
-- speed: seconds per frame
function Animation.new(image, frameW, frameH, framesCount, speed)
    local self = setmetatable({}, Animation)
    self.image = image
    self.frameW = frameW
    self.frameH = frameH
    self.frames = {}
    self.speed = speed or 0.1
    self.timer = 0
    self.current = 1

    local imgW, imgH = image:getDimensions()
    local framesPerRow = math.floor(imgW / frameW)
    for i = 0, framesCount - 1 do
        local fx = (i % framesPerRow) * frameW
        local fy = math.floor(i / framesPerRow) * frameH
        local quad = love.graphics.newQuad(fx, fy, frameW, frameH, imgW, imgH)
        table.insert(self.frames, quad)
    end

    return self
end

function Animation:update(dt)
    self.timer = self.timer + dt
    if self.timer >= self.speed then
        self.timer = self.timer - self.speed
        self.current = self.current + 1
        if self.current > #self.frames then
            self.current = 1
        end
    end
end

function Animation:draw(x, y, scaleX, scaleY, flip)
    local quad = self.frames[self.current]
    local sx = scaleX or 1
    local sy = scaleY or sx
    local ox = 0
    local oy = 0
    if flip then
        -- draw flipped by scaling -1 and offsetting
        love.graphics.draw(self.image, quad, x + (self.frameW * sx), y, 0, -sx, sy)
    else
        love.graphics.draw(self.image, quad, x, y, 0, sx, sy)
    end
end

return Animation
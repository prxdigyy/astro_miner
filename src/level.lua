-- src/level.lua
local Level = {}
Level.__index = Level

-- level config list
Level.data = {
    {
        id = 1,
        name = "Rocky Planet",
        bg = "assets/backgrounds/level1.png",
        gravity = 1000,
        groundY = 464,
        crystalsRequired = 5,
        crystalPositions = { {200, 380}, {300, 360}, {420, 380}, {540, 360}, {660, 380} }
    },
    {
        id = 2,
        name = "Ice Planet",
        bg = "assets/backgrounds/level2.png",
        gravity = 800,  -- floaty
        groundY = 464,
        crystalsRequired = 5,
        crystalPositions = { {160, 340}, {260, 300}, {360, 320}, {500, 280}, {700, 320}, {780, 300} }
    },
    {
        id = 3,
        name = "Lava Planet",
        bg = "assets/backgrounds/level3.png",
        gravity = 1100,
        groundY = 380,
        crystalsRequired = 8,
        crystalPositions = { {180, 300}, {320, 280}, {440, 300}, {560, 260}, {700, 300} },
        lava = { enabled = true, speed = 1.5 } -- rising px/sec (scaled to pixels through dt)
    }
}

function Level.get(id)
    return Level.data[id]
end

return Level
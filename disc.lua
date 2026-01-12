local disc = {}

disc.tile = love.graphics.newImage("ski_assets/Tiles/tile_disc.png") 

-- List of discs flying around to draw
disc.discs = {}
local word_bucket = {
    "slalom", "miscellaneous",
}
local active_words = {}

function disc.spawn()
    local new_disc = {
        -- TODO: Use the same check in typing to avoid dupes
        word = word_bucket[math.random(#word_bucket)],
        start_side = "left", -- calc above and randomize
        pos = {
            -- Randomize at the start based on side, remember to start off screen somewhere.
            x = 10,
            y = 10,
        },
        -- Calc the start pos before (of course) and use that information of left/right to
        -- constrain the direction across the screen left/right within a range
        direction = math.rad(10),
        speed = 10,
    }
end

function disc.update(dt)
    -- Iterate through the discs, updating their position and removing them if they're beyond their opposite screen space

    -- Random chance to spawn a new one
    if math.random(4) == 1 then
        disc.spawn()
    end
end

function disc.draw()
    -- Iterate through the discs and draw them
end

return disc 
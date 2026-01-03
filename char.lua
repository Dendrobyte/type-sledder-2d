-- Define the character as a table I guess
local char = {}

function char.load()
    char.name = "Mark"
    char.move_one = love.graphics.newImage("ski_assets/Tiles/tile_0082.png")
    char.move_two = love.graphics.newImage("ski_assets/Tiles/tile_0083.png")
    char.sprite = char.move_two

    char.x = 400
    char.y = 300
end

local count = 0
local move = {
    counter_x = 0,
    counter_y = 0,
}
function char.update_sprite(dt)
    -- TODO: Something something framerate independent?
    --       Figure out using dt for all the 'player movement'

    -- Slowly approaching the top
    if count % 2 == 0 then
        char.y = char.y - 1
    end

    -- Move if the counters are nonzero. The idea is to gradually move back to 0, hence inversion
    -- TODO: Refactor, just seeing if this works for now
    if move.counter_x ~= 0 then
        if move.counter_x > 0 then
            char.x = char.x + 1
            move.counter_x = move.counter_x - 1
        elseif move.counter_x < 0 then
            char.x = char.x - 1
            move.counter_x = move.counter_x + 1
        end
    end
    if move.counter_y ~= 0 then -- y is always moving in one direction, but the counter increases
        char.y = char.y + 1
        move.counter_y = move.counter_y - 1
    end

    -- Swap sprites back and forth to simulate skiing motions
    if count == 40 then
        char.sprite = char.move_one
    end
    if count == 80 then
        char.sprite = char.move_two
        count = -1
    end
    count = count + 1
end

-- TODO: Make the character move over an animated frame
function char.move(dir)
    move.counter_y = move.counter_y + 40
    if dir == "left" then
        move.counter_x = move.counter_x - 40
    elseif dir == "right" then
        move.counter_x = move.counter_x + 40
    end
end

-- TODO: Function to call when the skiier moves "lanes" and also moves forward a little bit
-- Could probably modify a global var for the char.y-1 line so we don't conflict over frames

return char
-- Define the character as a table I guess
local char = {}
local entities = require("environment.entities")
local const = require("environment.constants") -- ...? make it global? idk. consts will evolve.

function char.load()
    char.name = "Mark"
    char.move_one = love.graphics.newImage("ski_assets/Tiles/tile_0082.png")
    char.move_two = love.graphics.newImage("ski_assets/Tiles/tile_0083.png")
    char.sprite = char.move_two

    char.x, char.y = entities.cell_to_coord(25, 20)
end

local count = 0
local move = {
    counter_x = 0,
    counter_y = 0,
}
function char.update_sprite(dt)
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

    -- Check for collision (TODO: function?)
    -- NOTE: Is this a good spot...? I guess once we move, just check if it hits an invading cell
    in_bounds = char.x >= 0 and char.x < const.PIXEL_W and char.y >= 0 and char.y < const.PIXEL_H
    if not in_bounds then
        print("You hit the top, womp womp")
        return
    end
    is_collision = entities.is_entity_at_position(char.x, char.y)
    if is_collision == true then
        -- TODO: Call state_manager.end_game(), don't change it directly here
        print("womp womp, you collided")
        return
    end

    -- Slowly approaching the top
    -- TODO: Touch this when we do the end of screen collision
    if count % 2 == 0 then
        char.y = char.y - 1
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

-- Move the character based on some number of lanes
function char.move(dir)
    -- TODO: Ensure the movement doesn't have to be symmetrical
    --       The movement will then change entirely, and we may not have to convert to pixels
    --       i.e. this might calc an animation and we just run that in update
    local v_move = 5
    local h_move = 5
    move.counter_y = move.counter_y + entities.cell_to_pixels(v_move)
    if dir == "left" then
        move.counter_x = move.counter_x - entities.cell_to_pixels(h_move)
    elseif dir == "right" then
        move.counter_x = move.counter_x + entities.cell_to_pixels(h_move)
    end
end

-- TODO: Function to call when the skiier moves "lanes" and also moves forward a little bit
-- Could probably modify a global var for the char.y-1 line so we don't conflict over frames

return char
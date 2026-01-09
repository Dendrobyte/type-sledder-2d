
local slope = require("environment.slope")
local entities = require("environment.entities")
local const = require("environment.constants") -- ...? make it global? idk. consts will evolve.

local char = {}

function char.load()
    char.name = "Mark"
    char.move_one = love.graphics.newImage("ski_assets/Tiles/tile_0082.png")
    char.move_two = love.graphics.newImage("ski_assets/Tiles/tile_0083.png")
    char.sprite = char.move_two

    char.x, char.y = entities.cell_to_coord(char.start_position())
end

function char.start_position()
    return 10, 8
end

local count = 0
local move = {
    is_moving = false,
    x_incr = 0,
    y_incr = 0,
    dest_cell = {
        x = nil,
        y = nil,
    }
}
function reset_move_state()
    move = {
        is_moving = false,
        x_incr = 0,
        y_incr = 0,
        dest_cell = {
            x = nil,
            y = nil,
        }
    }
end

function char.update_sprite(dt)
    -- Update character based on move state
    if move.is_moving == true then
        char.x = char.x + x_incr
        char.y = char.y + y_incr
        local curr_cell_c, curr_cell_r = slope.coord_to_cell(char.x, char.y)
        if curr_cell_c == move.dest_cell.x and curr_cell_r == move.dest_cell.y then
           reset_move_state()
        end
    end
    -- Old movement...
    -- if move.counter_x ~= 0 then
    --     if move.counter_x > 0 then
    --         char.x = char.x + 1
    --         move.counter_x = move.counter_x - 1
    --     elseif move.counter_x < 0 then
    --         char.x = char.x - 1
    --         move.counter_x = move.counter_x + 1
    --     end
    -- end

    if move.counter_y ~= 0 then -- y is always moving in one direction, but the counter increases
        char.y = char.y + 1
        move.counter_y = move.counter_y - 1
        print("y move counter=", move.counter_y)
    end

    -- NOTE: Is this a good spot...? I guess once we move, just check if it hits an invading cell
    in_bounds = char.x >= 0 and char.x < const.PIXEL_W and char.y >= 0 and char.y < const.PIXEL_H
    if not in_bounds then
        return
    end
    is_off_slope = slope.does_player_go_off_slope(char.x, char.y)
    is_collision = entities.does_player_collide_with_entity(char.x, char.y)
    if is_off_slope == true or is_collision == true then
        return true
    end

    -- Slowly approaching the top, but slightly slower than scroll
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

function char.reset_movement()
    move = {
        counter_x = 0,
        counter_y = 0,
    }
end

-- Move the character based on some number of lanes
function char.move(dir)
    -- TODO: Ensure the movement doesn't have to be symmetrical
    --       The movement will then change entirely, and we may not have to convert to pixels
    --       i.e. this might calc an animation and we just run that in update
    local v_move = 1
    local h_move = 3
    move.counter_y = move.counter_y + entities.cell_to_pixels(v_move)
    if dir == "left" then
        move.counter_x = move.counter_x - entities.cell_to_pixels(h_move)
    elseif dir == "right" then
        move.counter_x = move.counter_x + entities.cell_to_pixels(h_move)
    end
end

return char
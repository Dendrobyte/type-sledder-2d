
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
        c = nil,
        r = nil,
    }
}
function reset_move_state()
    move = {
        is_moving = false,
        x_incr = 0,
        y_incr = 0,
        dest_cell = {
            c = nil,
            r = nil,
        }
    }
end

function char.update_sprite(dt)
    -- Update character based on move state
    if move.is_moving == true then
        char.x = char.x + move.x_incr
        char.y = char.y + move.y_incr
        local curr_cell_c, curr_cell_r = slope.coord_to_cell(char.x, char.y)
        if curr_cell_c == move.dest_cell.c and curr_cell_r == move.dest_cell.r then
           reset_move_state()
        end
    else
        -- If we're not moving, slowly approach the top, but slightly slower than scroll
        -- Disabled for now until I make the bounding box
        -- if count % 4 == 0 then
        --     char.y = char.y - 1
        -- end
    end

    -- Collision and bounds checks
    in_bounds = char.x >= 0 and char.x < const.PIXEL_W and char.y >= 0 and char.y < const.PIXEL_H
    if not in_bounds then
        return true
    end
    is_off_slope = slope.does_player_go_off_slope(char.x, char.y)
    is_collision = entities.does_player_collide_with_entity(char.x, char.y)
    if is_off_slope == true or is_collision == true then
        return true
    end

    -- Swap sprites back and forth to simulate skiing motions
    -- TODO: Adjust based on scroll speed... maybe count is scroll speed?
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
-- We calculate the increments to move along each axis and then update function moves until we hit our target
function char.move(dir)
    local dir_num = dir == "left" and -1 or 1 -- "and" apparently returns second value if first one is truthy??
    local new_move_state = {
        is_moving = true,
        x_incr = 0,
        y_incr = 0,
        dest_cell = {
            c = nil,
            r = nil,
        }
    }

    -- Represents how many cells over from the current position. Tweak these as necessary.
    local x_move = 3 * dir_num
    local y_move = 0
    slope.incr_scroll_speed()
    local curr_c, curr_r = slope.coord_to_cell(char.x, char.y)
    local dest_c = curr_c + x_move
    local dest_r = curr_r + y_move

    -- Effectively getting the movement vectory
    local dx = dest_c - curr_c
    local dy = dest_r - curr_r
    local dist = math.sqrt(dx*dx + dy*dy)
    new_move_state.x_incr = (dx/dist)
    new_move_state.y_incr = (dy/dist)

    -- Set the dest cell
    new_move_state.dest_cell.c = dest_c
    new_move_state.dest_cell.r = dest_r

    move = new_move_state
end

return char

local slope = require("environment.slope")
local obstacles = require("entities.obstacles")
local const = require("environment.constants") -- ...? make it global? idk. consts will evolve.
local sounds = require("core.sounds")
local points = require("core.points")
local callouts = require("ui.callouts")

local char = {}

function char.load()
    char.move_one = love.graphics.newImage("ski_assets/Tiles/tile_0082.png") -- 82 || 70
    char.move_two = love.graphics.newImage("ski_assets/Tiles/tile_0083.png") -- 83 || 71
    if math.random(1000) == 1 then
        -- 1 in 1000 chance to become a yeti
        char.move_one = love.graphics.newImage("ski_assets/Tiles/tile_0078.png") 
        char.move_two = love.graphics.newImage("ski_assets/Tiles/tile_0079.png")
    end
    char.sprite = char.move_two

    char.reload()
end

function char.reload()
    char.x, char.y = obstacles.cell_to_coord(char.start_position())
    char.center = char.x + (const.TILE_WIDTH/2)
    
    reset_move_state()
end

function char.start_position()
    return 12, 6
end

local count = 0
local move = {
    is_moving = false,
    x_incr = 0,
    y_incr = 0,
    dest_cell = {
        c = nil,
        r = nil,
    },
    curr_dir = "center",
    boost_decay = 0,
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

local in_near_miss_box = false
function char.update_sprite(dt)
    -- Update character based on move state
    if move.is_moving == true then
        char.x = char.x + move.x_incr
        char.y = char.y + move.y_incr
        char.center = char.x + (const.TILE_WIDTH/2)
        local curr_cell_c, curr_cell_r = slope.coord_to_cell(char.x, char.y)
        -- print("curr_c=", curr_cell_c, "curr_r=", curr_cell_r)
        -- print("dest_c=", move.dest_cell.c, "dest_r=", move.dest_cell.r)
        -- NOTE: We can get rid of this check, I prefer not having it end I think
        --       Happy accident
        -- if curr_cell_c == move.dest_cell.c and curr_cell_r == move.dest_cell.r then
        --    reset_move_state()
        -- end
        if move.boost_decay > 0 then
            move.boost_decay = move.boost_decay - 1
        else
            char.move(move.curr_dir, true)
        end
    else
        -- TODO: Bounding box
        -- TODO: Make better (dynamic)
        -- NOTE: This isn't tweened, so we should update the move variable I think with a new field
        --       I believe that's why it's jittery right now
        -- We also want to ensure that if they're at the top, this is smaller
        -- Don't forget we need a counter so they have a chance to come back
        -- Each word boost? Anyway
        -- If we're not moving, slowly approach the top, but slightly slower than scroll
        -- char.y = char.y - .5
    end

    -- Collision and bounds checks
    in_bounds = char.x >= 0 and char.x < const.PIXEL_W and char.y >= 0 and char.y < const.PIXEL_H
    if not in_bounds then
        return true
    end
    is_off_slope = slope.does_player_go_off_slope(char.x, char.y)
    is_collision = obstacles.does_player_collide_with_entity(char.x, char.y)
    if is_off_slope == true or is_collision == true then
        in_near_miss_box = false
        return true
    end

    -- We know collision is false at this point so we have to be outside of it now
    -- Give them the close call when they leave so we don't do it on collision
    is_near_miss = obstacles.does_player_nearly_miss_entity(char.x, char.y)
    if is_near_miss and in_near_miss_box == false then
        in_near_miss_box = true
    elseif is_near_miss == false and in_near_miss_box == true then
        callouts.add_callout("CLOSE CALL!", char.x, char.y-25, callouts.colors.purple)
        sounds.play_whoosh()
        points.incr_close_calls()
        in_near_miss_box = false
    end

    -- Swap sprites back and forth to simulate skiing motions
    -- TODO: Adjust based on scroll speed... maybe count is scroll speed?
    if count == 20 then
        char.sprite = char.move_one
    end
    if count == 30 then
        char.sprite = char.move_two
        count = -1
    end
    count = count + 1
end

-- Move the character based on some number of lanes
-- We calculate the increments to move along each axis and then update function moves until we hit our target
local dir_to_num = {
    left = -1,
    right = 1,
    center = 0,
}
function char.move(dir, reset)
    -- dir = "center" -- somehow, this immediately ends the game???? lol
    local dir_num = dir_to_num[dir]
    local is_boost = move.curr_dir ~= dir and not reset
    local new_move_state = {
        is_moving = true,
        x_incr = 0,
        y_incr = 0,
        dest_cell = {
            c = nil,
            r = nil,
        },
        curr_dir = dir,
        boost_decay = 0,
    }

    slope.incr_scroll_speed() -- ?? why is this here
    --[[
        If the direction is the same, we give a short horizontal boost before returning to prev move
        Otherwise, just change their direction in the respective direction based on dir_num
    ]]

    -- TODO: Handle the center case
    local x_move = dir_num -- Determines x dir for movement vector
    local y_move = is_boost and -3 or 0 -- Horizontal (looking) boost if direction matches
    
    -- Movement vector
    local curr_c, curr_r = slope.coord_to_cell(char.x, char.y)
    local dest_c = curr_c + x_move
    local dest_r = curr_r + y_move
    local dx = dest_c - curr_c
    local dy = dest_r - curr_r
    local dist = math.sqrt(dx*dx + dy*dy)
    new_move_state.x_incr = (dx/dist)
    new_move_state.y_incr = (dy/dist)

    if is_boost then
        new_move_state.x_incr = new_move_state.x_incr * 8 -- arbitrary mult for the horizontal speed
        new_move_state.boost_decay = 20
    end

    -- Set the dest cell
    -- NOTE: Didn't end up using destination cells, so we could refactor this
    --       to just use the vectors and not bother with distance. Until that's certain, it stays?
    new_move_state.dest_cell.c = dest_c
    new_move_state.dest_cell.r = dest_r

    move = new_move_state
end

return char
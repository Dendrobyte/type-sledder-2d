local util = require("core.util")
local const = require("environment.constants")
local points = require("core.points")
local turns = require("environment.turns")

local slope = {}
-- TODOS
-- Use tilemap instead of individual images
-- Scatter ski slope details on the non-snow parts

-- Load up the basic tile images
local tiles = {}
local grid_to_tile = nil
function slope.load()
    local tilePath = "ski_assets/Tiles/"
    tiles.edge = love.graphics.newImage(tilePath .. "tile_0003.png") -- 1
    tiles.snow = love.graphics.newImage(tilePath .. "tile_0000.png") -- 2
    tiles.snow_right = love.graphics.newImage(tilePath .. "tile_0001.png") -- 3 (LEFT EDGE)
    tiles.snow_left = love.graphics.newImage(tilePath .. "tile_0004.png") -- 4 (RIGHT EDGE)
    tiles.sharp_turn_in_start_left = love.graphics.newImage(tilePath .. "tile_0064.png") -- 5
    tiles.sharp_turn_in_end_left = love.graphics.newImage(tilePath .. "tile_0065.png") -- 6
    tiles.sharp_turn_in_start_right = love.graphics.newImage(tilePath .. "tile_0061.png") -- 7
    tiles.sharp_turn_in_end_right = love.graphics.newImage(tilePath .. "tile_0060.png") -- 8
    tiles.sharp_turn_out_start_left = love.graphics.newImage(tilePath .. "tile_0077.png") -- 9
    tiles.sharp_turn_out_end_left = love.graphics.newImage(tilePath .. "tile_0076.png") -- 10
    tiles.sharp_turn_out_start_right = love.graphics.newImage(tilePath .. "tile_0072.png") -- 11
    tiles.sharp_turn_out_end_right = love.graphics.newImage(tilePath .. "tile_0073.png") -- 12
    slope.grid_create()

    grid_to_tile = { -- indices are just starting from 1
        tiles.edge,
        tiles.snow,
        tiles.snow_left,
        tiles.snow_right,
        tiles.sharp_turn_in_start_left,
        tiles.sharp_turn_in_end_left,
        tiles.sharp_turn_in_start_right,
        tiles.sharp_turn_in_end_right,
        tiles.sharp_turn_out_start_left,
        tiles.sharp_turn_out_end_left,
        tiles.sharp_turn_out_start_right,
        tiles.sharp_turn_out_end_right,
    }
end

--[[
    SCROLL SPEED VARIABLE!
    Adjusting these speeds up the whole game. These are accessed in obstacles and char.
]]
local scroll_speed = 100
local starting_scroll_speed = 100
local scroll_speed_incr = 5
function slope.get_scroll_speed()
    return scroll_speed
end

function slope.set_scroll_speed(new_scroll_speed)
    scroll_speed = new_scroll_speed
end

-- Increase the speed on each successful word
function slope.incr_scroll_speed()
    slope.set_scroll_speed(scroll_speed + scroll_speed_incr)
end

function slope.reset_scroll_speed()
    scroll_speed = starting_scroll_speed
end

-- Used explicitly in the menu
function slope.set_init_scroll_speed(init_scroll_speed)
    starting_scroll_speed = init_scroll_speed
    scroll_speed = init_scroll_speed
end

-- Create initial nxm grid
local pixel_w, pixel_h = const.PIXEL_W, const.PIXEL_H
local tile_width = const.TILE_WIDTH
local rows = pixel_w / tile_width
local cols = pixel_h / tile_width + 0.5 -- Need to properly round this, but for now drawing an extra half tile
local grid = {}
local grid_head = nil
function slope.grid_create()
    for i = 1, cols+3 do -- Adding arbitrary constant so we don't get the flickering absent row as the game scrolls
        row = {}
        for j = 1, rows do
            row[j] = 1
        end
        grid[i] = row
    end

    -- Set up start path (can/should move above at some point)
    for i, row in ipairs(grid)  do
        row[const.LEFT_EDGE] = 3
        for j = const.LEFT_EDGE+1, const.RIGHT_EDGE-1 do
            row[j] = 2
        end
        row[const.RIGHT_EDGE] = 4
    end

    grid_head = 1
    grid_tail = #grid-1

    if util.get_debug() == true and nil ~= nil then
        print("---- Start of slope grid ----")
        util.print_matrix(grid)
        print("---- End of slope grid ----")
    end

end

-- We need to make sure we have some way to show the edge tiles if a prev tile is a turn
local followed_by_ice = {[5] = true, [7] = true}
local followed_by_snow = {[11] = true, [9] = true}
local left_edge_pre = {[6] = true, [10] = true}
local right_edge_pre = {[8] = true, [12] = true}
local switched = false -- We don't want to turn twice consecutively
-- Overwrite the row where the current head is, then step head up by 1
function slope.grid_add_next_row()
    -- We use the previous row as our input to generate this row
    -- NOTE: We'll generate chunks... later?
    local prev_row = grid[get_grid_tail()]
    local switch_dir = math.random(6) -- 1/3 chance to turn; 1 is left, 2 is right
    -- TODO: If we're at the edge of our const bounds, force the direction to change

    new_row = {}
    if switch_dir < 3 and switched == false then
        if switch_dir == 1 then
            if prev_row[2] ~= 3 then
                new_row = turns.sharp_turn_left(prev_row)
            else
                new_row = turns.sharp_turn_right(prev_row)
            end
        elseif switch_dir == 2 then
            if prev_row[23] ~= 4 then
                new_row = turns.sharp_turn_right(prev_row)
            else
                new_row = turns.sharp_turn_left(prev_row)
            end
        end
        switched = true
    else
        -- Just duplicate prev row, but account for edge tiles
        for i = 1, rows do -- row major, this shit confuses me
            if left_edge_pre[prev_row[i]] == true then
                new_row[i] = 3
            elseif right_edge_pre[prev_row[i]] == true then
                new_row[i] = 4
            elseif followed_by_ice[prev_row[i]] == true then
                new_row[i] = 1
            elseif followed_by_snow[prev_row[i]] == true then
                new_row[i] = 2
            else
                new_row[i] = prev_row[i]
            end
        end
        switched = false
    end

    -- Replace the head row
    grid[grid_head] = new_row

    if grid_head < #grid then grid_head = grid_head + 1 else grid_head = 1 end
end

function get_grid_tail()
    local grid_tail = grid_head - 1
    if grid_head == 1 then
        grid_tail = #grid
    end
    return grid_tail

end

-- Currently used for slope collision
function slope.get_tile_at_cell(r, c)
    return grid[r][c]
end

-- Currently used for obstacle spawning on snowy paths only
-- Returns [a, b] such that we can spawn an obstacle in that range (all 2s)
-- NOTE: In the future, we'll want to return a list of indices of the 0s
function slope.get_valid_obstacle_indices(curr_head_idx)
    -- There's an assumption here that the entity index head matches slope (they need to be the same size!)
    -- Thus that's the same row being replaced in both, but we'll pass in the index anyway
    local row = grid[curr_head_idx]
    local start_idx, end_idx = nil, nil
    for i, tile_num in ipairs(row) do
        if tile_num == 2 then
            start_idx = start_idx or i -- Gimmicky JS mode activated
            end_idx = i
        end
    end
    return start_idx+1, end_idx-1 -- Don't include the transition tiles

end

-- Function to calculate the shifted row index (i.e. logical index 1 translates to grid_head)
function slope.calc_grid_idx(logical_index)
    return ((grid_head + logical_index - 1) % #grid+1)
end

local scroll_offset = 0
local dir = 1
local dir_counter = 0
function slope.update_grid(dt)
    -- Counter inc to generate a new row
    -- Scroll offset is effectively the pixels we need to account for
    scroll_offset = scroll_offset + scroll_speed * dt
    if scroll_offset > const.TILE_WIDTH then
        slope.grid_add_next_row()
        scroll_offset = scroll_offset - const.TILE_WIDTH
        points.incr_distance()
    end
end

function slope.draw_map()
    -- Draw the map based on the grid
    -- [i,j] serves as our grid coordinate, we just need to mult by 16. Rendering here looks a little backwards but cols are x values in this case
    -- TODO: See the note about using getDimensions -- https://love2d.org/wiki/love.graphics.getPixelDimensions
    for i = 1, #grid do
        idx = slope.calc_grid_idx(i)
        row = grid[idx]
        for j, val in ipairs(row) do
            love.graphics.draw(grid_to_tile[val], (j-1)*const.TILE_WIDTH, (i-1)*const.TILE_WIDTH-scroll_offset, 0, 2)
        end
    end
end

-- Map x,y coordinates to cell, returning c,r for grid[r][c]
-- Adding 1 because sticking to the 1 index cultist ideology
function slope.coord_to_cell(x, y)
    local c, r = math.floor(x/const.TILE_WIDTH)+1, math.floor(y/const.TILE_WIDTH)+1
    -- Need to adjust the row for the cyclic offset, effectively getting the "shifted" grid
    r = r+grid_head+1 -- This is... a little sus... but I think it works. +1 because ????
    if r > #grid then r = r % #grid end
    return c, r
end

function slope.does_player_go_off_slope(char_x, char_y)
    local c, r = slope.coord_to_cell(char_x, char_y)
    return slope.get_tile_at_cell(r, c) == 1
end

return slope
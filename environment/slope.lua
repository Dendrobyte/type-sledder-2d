local slope = {}
local util = require("util")
local const = require("environment.constants")

-- TODOS
-- Use tilemap instead of individual images
-- Scatter ski slope details on the non-snow parts
-- Randomly change the width by 1 or 2 on each side tops
-- Generate a grid and spawn the tiles based on that?
-- Make the draw slope "tick based" so we can speed up over time (and as we test)
-- Make the tile map numbers constants for easier readability

-- Load up the basic tile images
local tiles = {}
local grid_to_tile = nil
function slope.load()
    local tilePath = "ski_assets/Tiles/"
    tiles.edge = love.graphics.newImage(tilePath .. "tile_0003.png") -- 1
    tiles.snow = love.graphics.newImage(tilePath .. "tile_0000.png") -- 2
    tiles.snow_right = love.graphics.newImage(tilePath .. "tile_0001.png") -- 3
    tiles.snow_left = love.graphics.newImage(tilePath .. "tile_0004.png") -- 4
    slope.grid_create()

    grid_to_tile = { -- indices are just starting from 1
        tiles.edge,
        tiles.snow,
        tiles.snow_left,
        tiles.snow_right,
    }
end

-- Create initial nxm grid
local pixel_w, pixel_h = const.PIXEL_W, const.PIXEL_H
local tile_width = const.TILE_WIDTH
local rows = pixel_w / tile_width
local cols = pixel_h / tile_width + 0.5 -- Need to properly round this, but for now drawing an extra half tile
local grid = {}
local grid_head = nil
local left_edge = const.LEFT_EDGE
local right_edge = const.RIGHT_EDGE
function slope.grid_create()
    for i = 1, cols+3 do -- Adding arbitrary constant so we don't get the flickering absent row as the game scrolls
        row = {}
        for j = 1, rows do
            row[j] = 1
        end
        grid[i] = row
    end

    -- Set up path (can/should move above at some point)
    -- TODO: Don't use fixed numbers but it works for now
    for i, row in ipairs(grid)  do
        row[left_edge] = 3
        for j = left_edge+1, right_edge-1 do
            row[j] = 2
        end
        row[right_edge] = 4
    end

    grid_head = 1

    if util.get_debug() == true and nil ~= nil then
        print("---- Start of slope grid ----")
        util.print_matrix(grid)
        print("---- End of slope grid ----")
    end

end

-- Overwrite the row where the current head is, then step head up by 1
-- TODO: Randomize ("procedurally generate") path directional shift, but for now just go back and forth every 2
local shifting = 0
function slope.grid_add_next_row()
    if shifting % 8 == 0 then -- shift
        if shifting % 16 == 0 then -- shift right
            left_edge = left_edge + 1
            right_edge = right_edge + 1
        else -- shift left
            left_edge = left_edge - 1
            right_edge = right_edge - 1
        end
    end -- else, we just add an identical row
    shifting = shifting + 1

    -- Replace the head row
    new_row = {}
    for i = 1, rows do -- row major, this shit confuses me
        if i < left_edge or i > right_edge then
            new_row[i] = 1
        elseif i == left_edge then
            new_row[i] = 3
        elseif i == right_edge then
            new_row[i] = 4
        else -- Snow is the implied case
            new_row[i] = 2
        end
    end
    grid[grid_head] = new_row

    if grid_head < #grid then grid_head = grid_head + 1 else grid_head = 1 end
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

local counter = 0
local dir = 1
local dir_counter = 0
function slope.update_grid(dt)
    -- Counter inc to generate a new row
    counter = counter+1
    if counter == const.TILE_WIDTH then
        slope.grid_add_next_row()

        -- Reset this to zero for when we redraw
        counter = 0
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
            love.graphics.draw(grid_to_tile[val], (j-1)*const.TILE_WIDTH, (i-1)*const.TILE_WIDTH-counter, 0, 2)
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
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
function slope.load()
    edge = love.graphics.newImage("ski_assets/Tiles/tile_0003.png") -- 1
    snow = love.graphics.newImage("ski_assets/Tiles/tile_0000.png") -- 2
    snow_right = love.graphics.newImage("ski_assets/Tiles/tile_0001.png") -- 3
    snow_left = love.graphics.newImage("ski_assets/Tiles/tile_0004.png") -- 4
    slope.grid_create()

    grid_to_tile = { -- indices are just starting from 1
        edge,
        snow,
        snow_left,
        snow_right,
    }
end

-- Create initial nxm grid
local pixel_w, pixel_h = const.PIXEL_W, const.PIXEL_H
local tile_width = const.TILE_WIDTH
local rows = pixel_w / tile_width
local cols = pixel_h / tile_width + 0.5 -- Need to properly round this, but for now drawing an extra half tile
local grid = {}
local grid_head = 1
local left_edge = const.LEFT_EDGE
local right_edge = const.RIGHT_EDGE
function slope.grid_create()

    for i = 1, cols+1 do -- Adding 1 so we don't get the flickering absent row as the game scrolls
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

    -- Shift head
    if grid_head < #grid then
        grid_head = grid_head + 1
    else
        grid_head = 1
    end
end

-- Function to calculate the shifted row index (i.e. logical index 1 translates to grid_head)
function slope.calc_grid_idx(logical_index)
    return ((grid_head + logical_index - 1) % #grid+1)
end

local counter = 0
-- TODO: Do the actual math here (global util functions to translate by 16? maybe when we do the text stuff?)
-- TODO: Function arg to shift the rows, so we can just keep shifting a regular grid at game start (behind the menu) and when player collides, ending game
local dir = 1
local dir_counter = 0
function slope.draw_map()
    -- Draw the map based on the grid
    -- [i,j] serves as our grid coordinate, we just need to mult by 16. Rendering here looks a little backwards but cols are x values in this case
    -- TODO: See the note about using getDimensions -- https://love2d.org/wiki/love.graphics.getPixelDimensions
    for i = 1, #grid do
        idx = slope.calc_grid_idx(i)
        row = grid[idx]
        for j, val in ipairs(row) do
            love.graphics.draw(grid_to_tile[val], (j-1)*16, (i-1)*16-counter, 0, 1)
        end
    end

    -- Counter inc to generate a new row
    counter = counter+1
    if counter == 16 then
        slope.grid_add_next_row()

        -- Reset this to zero for when we redraw
        counter = 0
    end
end

return slope
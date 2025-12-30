local slope = {}
local util = require("util")

-- TODOS
-- Use tilemap instead of individual images
-- Scatter ski slope details on the non-snow parts
-- Randomly change the width by 1 or 2 on each side tops
-- Generate a grid and spawn the tiles based on that?
-- Make the draw slope "tick based" so we can speed up over time (and as we test)

-- Load up the basic tile images
function slope.load()
    edge = love.graphics.newImage("ski_assets/Tiles/tile_0003.png") -- 1
    snow = love.graphics.newImage("ski_assets/Tiles/tile_0000.png") -- 2
    snow_right = love.graphics.newImage("ski_assets/Tiles/tile_0001.png") -- 3
    snow_left = love.graphics.newImage("ski_assets/Tiles/tile_0004.png") -- 4
    tile_width = 16
    slope.grid_create()

    grid_to_tile = { -- indices are just starting from 1
        edge,
        snow,
        snow_left,
        snow_right,
    }
end

-- Create initial nxm grid
local grid = {}
function slope.grid_create()
    pixel_w, pixel_h = love.graphics.getPixelDimensions()
    rows = pixel_w / tile_width
    cols = pixel_h / tile_width + 0.5 -- Need to properly round this, but for now drawing an extra half tile

    for i = 1, cols do
        row = {}
        for j = 1, rows do
            row[j] = 1
        end
        grid[i] = row
    end

    -- Set up path (can/should move above at some point)
    -- TODO: Don't use fixed numbers but it works for now
    local left_edge = 4 -- pxlWidth / 8 -- 1/8th from the left
    local right_edge = 32 -- pxlWidth - (pxlWidth / 8) -- 1/8th from the right
    for i, row in ipairs(grid)  do
        row[left_edge] = 3
        for j = left_edge+1, right_edge-1 do
            row[j] = 2
        end
        row[right_edge] = 4
    end

    util.print_matrix(grid)
    -- TODO: Second grid for extra stuff on top, or odd nums imply snow below or something

end

-- Add a row to the grid, removing the first row
function slope.grid_next_row()

end

local counter = 0
-- TODO: Do the actual math here (global util functions to translate by 16? maybe when we do the text stuff?)
local dir = 1
local dir_counter = 0

function slope.draw_map()
    -- Draw the map based on the grid
    -- [i,j] serves as our grid coordinate, we just need to mult by 16. Rendering here looks a little backwards but cols are x values in this case
    -- TODO: See the note about using getDimensions -- https://love2d.org/wiki/love.graphics.getPixelDimensions
    for i, row in ipairs(grid) do
        for j, val in ipairs(row) do
            love.graphics.draw(grid_to_tile[val], (j-1)*16, (i-1)*16-counter, 0, 1)
        end
    end


    -- Counter inc to generate a new row
    counter = counter+1
    if counter == 16 then
        -- Just for now, change the direction of the path every 4 tiles
        if dir_counter == 8 then -- Incr to slow down shift, decr to speed up shift
            dir = dir * -1 -- flip direction
            dir_counter = 0
        end
        
        left_edge = left_edge + dir
        right_edge = right_edge + dir

        dir_counter = dir_counter + 1

        -- Reset this to zero for when we redraw
        counter = 0
    end
end

return slope
local slope = {}

-- TODOS
-- Use tilemap instead of individual images
-- Scatter ski slope details on the non-snow parts
-- Randomly change the width by 1 or 2 on each side tops
-- Generate a grid and spawn the tiles based on that?
-- Make the draw slope "tick based" so we can speed up over time (and as we test)

-- Load up the basic tile images
function slope.load()
    snow = love.graphics.newImage("ski_assets/Tiles/tile_0000.png") -- 0
    edge = love.graphics.newImage("ski_assets/Tiles/tile_0003.png") -- 1
    snow_right = love.graphics.newImage("ski_assets/Tiles/tile_0001.png") -- 2
    snow_left = love.graphics.newImage("ski_assets/Tiles/tile_0004.png") -- 3
    tile_width = 16
    slope.grid_create()
end

-- Create initial nxm grid
-- TODO: See the note about using getDimensions -- https://love2d.org/wiki/love.graphics.getPixelDimensions
function slope.grid_create()
    pixel_w, pixel_h = love.graphics.getPixelDimensions()
    cols = pixel_w / tile_width
    rows = pixel_h / tile_width + 0.5 -- Need to properly round this, but for now drawing an extra half tile

    -- PICKUP
    -- Have 0,1,3,4 tile numbers generate (based on png names), moving the left_edge and right_edge initialization numbers here
    -- Then have the draw_map logic use the grid instead of the nested for loop

end

-- Add a row to the grid, removing the first row
function slope.grid_add_row()

end

local counter = 0
-- TODO: Do the actual math here (global util functions to translate by 16? maybe when we do the text stuff?)
local left_edge = 4 -- pxlWidth / 8 -- 1/8th from the left
local right_edge = 32 -- pxlWidth - (pxlWidth / 8) -- 1/8th from the right
local dir = 1
local dir_counter = 0
function slope.draw_map()
    -- Generate the 2d array representation
    -- TODO: Change these to draw the tilemaps
    --       https://love2d.org/wiki/Tutorial:Tile-based_Scrolling
    pxlWidth, pxlHeight = love.graphics.getPixelDimensions()
    -- Each tile is 16x16, so we need to adjust accordingly
    pxlWidth = pxlWidth / 16
    pxlHeight = pxlHeight / 16
    for i = 0, pxlWidth do
        for j = 0, pxlHeight do
            if i < left_edge or i > right_edge then
                love.graphics.draw(edge, i*16, j*16-counter, 0, 1)
            end
            if i == left_edge then
                love.graphics.draw(snow_left, i*16, j*16-counter, 0, 1)
            end
            if i == right_edge then
                love.graphics.draw(snow_right, i*16, j*16-counter, 0, 1)
            end
            if i > left_edge and i < right_edge then
                love.graphics.draw(snow, i*16, j*16-counter, 0, 1)
            end
        end
    end

    -- Counter inc to generate a new row
    -- TODO: We need the grid system to hold on to the rows so we don't shift the entire slope
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
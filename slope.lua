local slope = {}
local counter = 0

-- TODOS
-- Use tilemap instead of individual images
-- Scatter ski slope details on the non-snow parts
-- Randomly change the width by 1 or 2 on each side tops
-- Generate a grid and spawn the tiles based on that?

-- Load up the basic tile images
function slope.load()
    snow = love.graphics.newImage("ski_assets/Tiles/tile_0000.png") -- 0
    edge = love.graphics.newImage("ski_assets/Tiles/tile_0003.png") -- 1
    snow_right = love.graphics.newImage("ski_assets/Tiles/tile_0001.png") -- 2
    snow_left = love.graphics.newImage("ski_assets/Tiles/tile_0004.png") -- 3
    tileWidth = 16
    love.graphics.draw(edge, 100, 400, 0, 3)
end

function slope.draw_map()
    love.graphics.draw(snow, 0, 0, 0, 1)
    love.graphics.draw(snow, 16, 16, 0, 1)
    -- Generate the 2d array representation
    -- TODO: Change these to draw the tilemaps
    --       https://love2d.org/wiki/Tutorial:Tile-based_Scrolling
    pxlWidth, pxlHeight = love.graphics.getPixelDimensions()
    -- Each tile is 16x16, so we need to adjust accordingly
    pxlWidth = pxlWidth / 16
    pxlHeight = pxlHeight / 16
    -- TODO: Do the actual math here (global util functions to translate by 16? maybe when we do the text stuff?)
    leftEdge = 4 -- pxlWidth / 8 -- 1/8th from the left
    rightEdge = 32 -- pxlWidth - (pxlWidth / 8) -- 1/8th from the right
    for i = 0, pxlWidth do
        for j = 0, pxlHeight do
            if i < leftEdge or i > rightEdge then
                love.graphics.draw(edge, i*16, j*16, 0, 1)
            end
            if i == leftEdge then
                love.graphics.draw(snow_left, i*16, j*16, 0, 1)
            end
            if i == rightEdge then
                love.graphics.draw(snow_right, i*16, j*16, 0, 1)
            end
            if i > leftEdge and i < rightEdge then
                love.graphics.draw(snow, i*16, j*16, 0, 1)
            end
        end
    end
    counter += 1
end

return slope
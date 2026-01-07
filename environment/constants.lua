-- CONSTANTS FOR GRIDS AND ENVIRONMENTS

local pixel_w, pixel_h = love.graphics.getPixelDimensions()

return {
    TILE_WIDTH = 32,
    PIXEL_W = pixel_w,
    PIXEL_H = pixel_h,
    LEFT_EDGE = 4, -- pxlWidth / 8 -- 1/8th from the left
    RIGHT_EDGE = 20, -- pxlWidth - (pxlWidth / 8) -- 1/8th from the right
    EMPTY_SPACE = 0,
}
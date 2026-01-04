-- CONSTANTS FOR GRIDS AND ENVIRONMENTS

local pixel_w, pixel_h = love.graphics.getPixelDimensions()

return {
    TILE_WIDTH = 16,
    PIXEL_W = pixel_w,
    PIXEL_H = pixel_h,
    LEFT_EDGE = 4, -- pxlWidth / 8 -- 1/8th from the left
    RIGHT_EDGE = 32, -- pxlWidth - (pxlWidth / 8) -- 1/8th from the right
}
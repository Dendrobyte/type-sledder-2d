-- CONSTANTS FOR EVERYTHING I GUESS
local pixel_w, pixel_h = love.graphics.getPixelDimensions()

return {
    TILE_WIDTH = 32,
    PIXEL_W = pixel_w,
    PIXEL_H = pixel_h,
    WORD_POINTS = 10,
    WORD_POINTS_MULT = .03,
    DEFAULT_COLOR = {1, 1, 1}, -- use unpack()
}
local global_const = require("core.constants")
-- CONSTANTS FOR GRIDS AND ENVIRONMENTS

return {
    TILE_WIDTH = global_const.TILE_WIDTH,
    PIXEL_W = global_const.PIXEL_W,
    PIXEL_H = global_const.PIXEL_H,
    LEFT_EDGE = 5, -- pxlWidth / 8 -- 1/8th from the left
    RIGHT_EDGE = 21, -- pxlWidth - (pxlWidth / 8) -- 1/8th from the right
    EMPTY_SPACE = 0,
}
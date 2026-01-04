local const = require("environment.constants")
local util = require("util")

-- This is our grid system responsible for handling collision between player and edge, player and obstacle, etc.
local entities = {}

-- Load assets, etc.
function entities.load()
    -- rock = ...
    entities.grid_create()

end

-- Create a grid akin to slope, but empty
-- NOTE: Intentionally not generalizing here. Might be an opportunity to improve upon this and
--       generally treat it differently with branching logic
local rows = const.PIXEL_W / const.TILE_WIDTH
local cols = const.PIXEL_H / const.TILE_WIDTH
local grid = {}
local grid_head = 1
function entities.grid_create()
    for i = 1, cols+1 do
        row = {}
        for j = 1, rows do
            row[j] = const.EMPTY_SPACE
        end
        grid[i] = row
    end

    if util.get_debug() == true then
        print("Entities grid is ", rows, "x", cols)
    end
end

-- Map a grid cell to x,y coordinates, returning x,y for drawing, etc.
function entities.cell_to_coord(r, c)
    return r*const.TILE_WIDTH, c*const.TILE_WIDTH
end

-- Map x,y coordinates to cell, returning r,c for grid[c][r]
-- Adding 1 because sticking to the 1 index cultist ideology
-- Also following the row major cultist ideology
function entities.coord_to_cell(x, y)
    return math.floor(x/const.TILE_WIDTH)+1, math.floor(y/const.TILE_WIDTH)+1
end

-- Given a number of lines, return that in pixels
function entities.cell_to_pixels(cells)
    return cells*const.TILE_WIDTH
end

-- Draw function that runs on top of the slope draw
function entities.draw_entities()

end

-- TODO: We error out here when we go out of bounds (obviously)
-- Make sure that doesn't still happen since we should be error catching now
function entities.is_entity_at_position(x, y)
    local r, c = entities.coord_to_cell(x, y)
    return grid[c][r] ~= const.EMPTY_SPACE
end

return entities
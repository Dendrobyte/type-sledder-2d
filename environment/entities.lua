local const = require("environment.constants")

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
            row[j] = 0
        end
        grid[i] = row
    end

end

-- Draw function that runs on top of the slope draw
function entities.draw_entities()

end

return entities
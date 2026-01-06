local const = require("environment.constants")
local util = require("util")
local slope = require("environment.slope") -- NOTE: I don't love this dependency being here

-- This is our grid system responsible for handling collision between player and edge, player and obstacle, etc.
local entities = {}

-- Load assets, etc.
-- TODO: Move all the tiles into its own loaded thing? Though if it's just two files, w/e
local tiles = {}
local grid_to_tile = nil
function entities.load()
    local tilePath = "ski_assets/Tiles/"
    tiles.stump = love.graphics.newImage(tilePath .. "tile_0047.png")
    tiles.rock = love.graphics.newImage(tilePath .. "tile_0081.png")

    entities.grid_create()

    grid_to_tile = {
        tiles.stump,
        tiles.rock,
    }

end

-- Create a grid akin to slope, but empty
-- NOTE: Intentionally not generalizing here. Might be an opportunity to improve upon this and
--       generally treat it differently with branching logic
local rows = const.PIXEL_W / const.TILE_WIDTH
local cols = const.PIXEL_H / const.TILE_WIDTH
local grid = {}
local grid_head = 1
function entities.grid_create()
    for i = 1, cols+3 do -- This '3' needs to be the same for the obstacle gen... constant!
        row = {}
        for j = 1, rows do
            row[j] = const.EMPTY_SPACE
        end
        grid[i] = row
    end
end

-- Function to calculate the shifted row index (i.e. logical index 1 translates to grid_head)
-- NOTE: Yes it's a copy from slope :I
function entities.calc_grid_idx(logical_index)
    return ((grid_head + logical_index - 1) % #grid+1)
end

local counter = 0
function entities.update_grid(dt)
    counter = counter+1
    if counter == const.TILE_WIDTH then
        entities.new_row() -- TODO: new_chunk()

        counter = 0
    end
end

-- Some day, this will have to account for larger "chunks" as we generate larger structures on the slopes
-- NOTE: So if it became new_chunk, circular buffer would change
function entities.new_row()
    -- Generate the new item
    new_row = {}
    for i = 1, rows do new_row[i] = const.EMPTY_SPACE end
    if math.random(3) == 1 then
        local snow_start, snow_end = slope.get_valid_obstacle_indices(grid_head)
        local obstacle_idx = math.random(snow_start, snow_end)
        print("Spawning obstacle at", obstacle_idx)
        new_row[obstacle_idx] = math.random(#grid_to_tile)
    end

    -- Update the rows of our grid
    grid[grid_head] = new_row

    if grid_head < #grid then grid_head = grid_head + 1 else grid_head = 1 end

    if util.get_debug() == true then
        print("---- ENTITIES GRID ---- ")
        util.print_matrix(grid)
        print("--------------------------------")
    end
end

-- Map a grid cell to x,y coordinates, returning x,y for drawing, etc.
function entities.cell_to_coord(r, c)
    return r*const.TILE_WIDTH, c*const.TILE_WIDTH
end

-- Map x,y coordinates to cell, returning c,r for grid[r][c]
-- Adding 1 because sticking to the 1 index cultist ideology
function entities.coord_to_cell(x, y)
    local c, r = math.floor(x/const.TILE_WIDTH)+1, math.floor(y/const.TILE_WIDTH)+1
    -- Need to adjust the row for the cyclic offset, effectively getting the "shifted" grid
    r = r+grid_head+1 -- This is... a little sus... but I think it works. +1 because ????
    if r > #grid then r = r % #grid end
    return c, r
end

-- Given a number of lines, return that in pixels
function entities.cell_to_pixels(cells)
    return cells*const.TILE_WIDTH
end

-- Draw function that runs on top of the slope draw
function entities.draw_entities()
    for i = 1, #grid do
        idx = entities.calc_grid_idx(i)
        row = grid[idx]
        for j, val in ipairs(row) do
            if val ~= 0 then love.graphics.draw(grid_to_tile[val], (j-1)*16, (i-1)*16-counter, 0, 1) end
        end
    end
end

-- TODO: We error out here when we go out of bounds (obviously)
-- Make sure that doesn't still happen since we should be error catching now
function entities.is_entity_in_player_area(char_x, char_y, slope_cell)
    -- Given the character x and y, find all the tiles for it
    local tile_coords = {
        {char_x, char_y}, -- top left
        {char_x+const.TILE_WIDTH, char_y}, -- top right
        {char_x, char_y+const.TILE_WIDTH}, -- bottom left
        {char_x+const.TILE_WIDTH, char_y+const.TILE_WIDTH}, -- bottom right
    }
    local c, r = entities.coord_to_cell(char_x, char_y)
    for _, coords in ipairs(tile_coords) do
        local c, r = entities.coord_to_cell(coords[1], coords[2])
        local slope_cell = slope.get_tile_at_cell(r, c)
        if grid[r][c] ~= const.EMPTY_SPACE or slope_cell == 1 then -- If the slope cell is a (full) edge
            return true
        end
    end
end

return entities
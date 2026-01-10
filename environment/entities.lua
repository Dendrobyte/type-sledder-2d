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
    for i = 1, cols+3 do -- Needs to match slope grid
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

-- Storing all obstacles and their positions for the draw function and collision
obstacles = {}
local scroll_offset = 0
function entities.update_grid(dt)
    scroll_offset = scroll_offset + slope.get_scroll_speed() * dt
    if scroll_offset > const.TILE_WIDTH then
        entities.new_row() -- TODO: new_chunk()
        scroll_offset = scroll_offset - const.TILE_WIDTH
    end

    -- Update obstacle coords for drawing based on coordinates to be used w collision
    obstacles = {}
    for i = 1, #grid do
        idx = entities.calc_grid_idx(i)
        row = grid[idx]
        for j, val in ipairs(row) do
            if val ~= 0 then
                table.insert(obstacles, {
                    tile_sprite = val,
                    x_orig = (j-1)*const.TILE_WIDTH,
                    y_orig = (i-1)*const.TILE_WIDTH-scroll_offset,
                    x_end = (j-1)*const.TILE_WIDTH+const.TILE_WIDTH,
                    y_end = (i-1)*const.TILE_WIDTH-scroll_offset+const.TILE_WIDTH,
                })
            end
        end
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



-- Given a number of lines, return that in pixels
function entities.cell_to_pixels(cells)
    return cells*const.TILE_WIDTH
end

-- Draw function that runs on top of the slope draw
function entities.draw_entities()
    for _, obst in ipairs(obstacles) do
        love.graphics.draw(grid_to_tile[obst.tile_sprite], obst.x_orig, obst.y_orig, 0, 2)
        if util.get_debug() == true then
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle('line', obst.x_orig, obst.y_orig, const.TILE_WIDTH, const.TILE_WIDTH)
            love.graphics.setColor(1, 1, 1)
        end
    end

end

-- Check character coords with every obstacle coordinate
-- NOTE: There's a possibility this is off by a pixel or so based on the order of the update calls?
function entities.does_player_collide_with_entity(char_x, char_y, slope_cell)
    for _, obst in ipairs(obstacles) do
        if check_collision(char_x, char_y, obst.x_orig, obst.y_orig) == true then
            return true
        end
    end
    util.add_debug_draw_call(function()
        love.graphics.setColor(.8, .5, 0)
        love.graphics.rectangle('line', char_x, char_y, const.TILE_WIDTH, const.TILE_WIDTH)
        love.graphics.setColor(1, 1, 1)
    end)
end

-- TK: oh maybe I don't need the x/y_end vars in the obstacles? the width is always the same, don't fuck with tile size
-- TODO: Change collision to be just bottom half of sprite
function check_collision(cx_orig, cy_orig, ex_orig, ey_orig)
    w = const.TILE_WIDTH
    -- Logic here is to effectively invert a check if the rectangles overlap. If they don't not overlap, we have a collision
    return
        cx_orig + w > ex_orig and
        cx_orig < ex_orig + w and
        cy_orig + w > ey_orig+w and
        cy_orig < ey_orig+w + w
end

return entities
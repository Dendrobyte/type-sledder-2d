local const = require("environment.constants")
local util = require("core.util")
local slope = require("environment.slope")

local deco = {}

local tiles = {}
local grid_to_tile = nil
function deco.load()
    local tilePath = "ski_assets/Tiles/tile_00"

    tiles.short_tree = love.graphics.newImage(tilePath .. "30.png") -- 1
    tiles.tall_tree_top = love.graphics.newImage(tilePath .. "06.png") -- 2
    tiles.tall_tree_bottom = love.graphics.newImage(tilePath .. "18.png") -- 3
    tiles.shrub = love.graphics.newImage(tilePath .. "31.png") -- 4
    tiles.lift_pole_top = love.graphics.newImage(tilePath .. "42.png") -- 5
    tiles.lift_pole_mid = love.graphics.newImage(tilePath .. "54.png") -- 6
    tiles.lift_pole_bottom = love.graphics.newImage(tilePath .. "66.png") -- 7
    tiles.lift_chair = love.graphics.newImage(tilePath .. "57.png") -- 8
    tiles.lift_wire_plain = love.graphics.newImage(tilePath .. "46.png") -- 9
    tiles.lift_wire_chair_top = love.graphics.newImage(tilePath .. "45.png") -- 10

    grid_to_tile = {
        tiles.short_tree,
        tiles.tall_tree_top,
        tiles.tall_tree_bottom,
        tiles.shrub,
        tiles.lift_pole_top,
        tiles.lift_pole_mid,
        tiles.lift_pole_bottom,
        tiles.lift_chair,
        tiles.lift_wire_plain,
        tiles.lift_wire_chair_top,
    }

    deco.grid_create(true)
end

-- Just gonna have the first grid for now
-- Repeated... one final time????
local pixel_w, pixel_h = const.PIXEL_W, const.PIXEL_H
local tile_width = const.TILE_WIDTH
local rows = pixel_w / tile_width
local cols = pixel_h / tile_width + 0.5 -- Need to properly round this, but for now drawing an extra half tile
local grid = {} -- Grid head matches slope
function deco.grid_create(is_start)
    if is_start then
        -- Set up the manual start setup
        for i = 1, cols+3 do -- Needs to match slope grid
            row = {}
            for j = 1, rows do
                row[j] = const.EMPTY_SPACE
            end
            grid[i] = row
        end
        -- Presumably, grid[1] also doesn't show up here
        grid[3] = {9, 5, 9, 9, 10, 9, 9, 10, 9, 9, 10, 9, 5, 9, 10, 9, 9, 10, 9, 9, 10, 9, 5, 9, 9,}
        grid[4] = {1, 6, 1, 2, 8, 0, 2, 8, 0, 0, 8, 0, 6, 0, 8, 0, 0, 8, 2, 0, 8, 0, 6, 1, 1,}
        grid[5] = {1, 7, 1, 3, 0, 0, 3, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 3, 1, 0, 0, 7, 1, 1,}
    else
        -- This is where we would handle the new chunk and have "two chunks" ongoing
        -- NOTE: For when I do this procgen, is it a lot to do the whole chunk in one frame?
        -- Doubtful, I'm just... still getting my mind blown by computers lol
        -- Also, remember that this won't work. You'll need to always have two grids going
        -- Kind of like needing to move the stone you placed behind you to go ahead and then that ad infinitum
        -- Because of how we're drawing based on the other grid
        -- Append to current grid, adjust for the other grid head, remove the first half of the
        -- grid... etc. etc.
        deco.new_chunk()
    end
end

-- For the moment, we want to make sure that we just constantly add new rows to this that are 0s
-- Thus when the game is reset we can reliably call create to restart it and let the (later) proc gen kick in
function deco.update_grid(dt)
    local scroll_offset = slope.get_scroll_offset()
    -- We're doing 5 for now since that's when the manual grid slides off screen
    -- If we generate two grids to start then we should do when grid head is at the end or whatever
    -- I need to "map" out the grid sizes and stuff a little better...
    if slope.get_grid_head() == 5 then
        deco.new_chunk()
        scroll_offset = scroll_offset - const.TILE_WIDTH
    end
end

function deco.draw_deco()
    local scroll_offset = slope.get_scroll_offset()
    for i = 1, #grid do
        idx = slope.calc_grid_idx(i)
        row = grid[idx]
        for j, val in ipairs(row) do
            if val ~= 0 then
                love.graphics.draw(grid_to_tile[val], (j-1)*const.TILE_WIDTH, (i-1)*const.TILE_WIDTH-scroll_offset, 0, 2)
            end
        end
    end
end

-- TODO: Spawn some random deco here and there
-- The deco grid is the first thing that we will render in "chunks"
function deco.new_chunk()
    -- This is just resetting for now, but here is where we would want to spawn
    -- different deco sprites and group them together, etc. as the rows go
    for i = 1, cols+3 do -- Needs to match slope grid
        row = {}
        for j = 1, rows do
            row[j] = const.EMPTY_SPACE
        end
        grid[i] = row
    end
end

return deco
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

    deco.grid_create()
end

-- Just gonna have the first grid for now
-- Repeated... once final time????
local pixel_w, pixel_h = const.PIXEL_W, const.PIXEL_H
local tile_width = const.TILE_WIDTH
local rows = pixel_w / tile_width
local cols = pixel_h / tile_width + 0.5 -- Need to properly round this, but for now drawing an extra half tile
local grid = {} -- Grid head matches slope
function deco.grid_create()
    for i = 1, cols+3 do -- Needs to match slope grid
        row = {}
        for j = 1, rows do
            row[j] = const.EMPTY_SPACE
        end
        grid[i] = row
    end

    -- Set up the manual start setup
    -- Presumably, grid[1] also doesn't show up here
    grid[3] = {9, 5, 9, 9, 10, 9, 9, 10, 9, 9, 10, 9, 5, 9, 10, 9, 9, 10, 9, 9, 10, 9, 5, 9, 9,}
    grid[4] = {1, 6, 1, 2, 8, 0, 2, 8, 0, 0, 8, 0, 6, 0, 8, 0, 0, 8, 2, 0, 8, 0, 6, 1, 1,}
    grid[5] = {1, 7, 1, 3, 0, 0, 3, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 3, 1, 0, 0, 7, 1, 1,}
    -- util.print_matrix(grid)

    draw_deco_grid = true
end

-- NOTE: This is to avoid redrawing the grid, which we don't want for now
-- The deco grid is probably the first think that will render in "chunks"
local draw_deco_grid = true
function deco.draw_deco()
    if draw_deco_grid == false then
        return
    end
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

    -- This... should not be in the draw function... :I
    if slope.get_grid_head() == 5 then
        draw_deco_grid = false
    end
end

-- TODO: Spawn some random deco here and there

return deco
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
        deco.new_chunk()
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

-- This feels... a little goofy...?
-- Enforcing only one chunk spawn per call
local generated_new_chunk = false

-- For the moment, we want to make sure that we just constantly add new rows to this that are 0s
-- Thus when the game is reset we can reliably call create to restart it and let the (later) proc gen kick in
local scroll_offset = 0
function deco.update_grid(dt)
    scroll_offset = scroll_offset + slope.get_scroll_speed() * dt
    if slope.get_grid_head() == 5 and not generated_new_chunk then
        deco.new_chunk()
        scroll_offset = scroll_offset - const.TILE_WIDTH
        generated_new_chunk = true
    elseif slope.get_grid_head() == 6 then
        generated_new_chunk = false
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

-- The deco grid is the first thing that we will render in "chunks"
-- It'll be double the size, and we regenerate the half we don't show. What could go wrong!!!!
local half_toggle = true
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

    -- Spawn random deco very sparsely on non-snow spaces of the slope grid
    local i = 1
    while i <= #grid-1 do
        -- I'm semi-assuming list order is maintained, but it doesn't really matter here
        -- TODO: Adding in more deco and whatnot
        -- TODO: Creating randomization such that there can be more shrubs but fewer tall trees
        local valid_deco_indices = slope.get_valid_deco_indices(i)
        local deco_count = math.random(4)-1 -- Spawn anywhere from 0 to 3 deco items
        local chosen_height = 1
        if deco_count > 0 and #valid_deco_indices > 0 then
            for j = 1, deco_count do
                local which_deco = math.random(4)
                local where_deco = valid_deco_indices[math.random(#valid_deco_indices)]
                if which_deco == 3 then which_deco = 2 end -- Start with top of tall tree
                grid[i][where_deco] = which_deco

                -- NOTE: Could add a chairlift row pretty easily here then and jump 3...
                if which_deco == 2 then
                    grid[i+1][where_deco] = 3
                    chosen_height = 2
                end

                -- Avoid overwriting
                table.remove(valid_deco_indices, where_deco)
            end
        end

        -- For now, jump two rows if we generate a 2-height item
        i = i + 1 + chosen_height
    end
    util.print_matrix(grid)

end

return deco
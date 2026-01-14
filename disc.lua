local const = require("environment.constants")
local util = require("util")

local disc = {}

disc.tile = love.graphics.newImage("ski_assets/Tiles/tile_disc.png") 

local adv_word_bucket = {
  "velocity","trajectory","algorithm","frequency","synchronize","momentum",
  "precision","calculate","sequence","multiplier","achievement","challenge",
  "obstacle","horizontal","vertical","diagonal","continuous","acceleration",
  "difficulty","intensity","threshold","calibrate","coordinate","percentage",
  "eliminate","randomize","prioritize","consecutive","intermediate","controller",
  "navigation","peripheral","resolution","framerate","inventory","equipment",
  "experience","progression","tournament","competitive","leaderboard","statistics",
  "objective","checkpoint","regenerate","vulnerability","spectacular","magnificent",
  "extraordinary","phenomenal","unpredictable","instantaneous","sophisticated",
  "professional","concentrate","determination","anticipation","observation",
  "recognition","performance","combination","configuration","demonstrate",
  "circumstance","psychological","environmental","fundamental","mechanical",
  "nevertheless","approximately","simultaneously","perpendicular","quadrilateral"
}
local active_words = {}

-- TODO: List of discs flying around to draw
-- disc.discs = {}
local current_disc = nil
local disc_speed = 10
function disc.spawn()
    -- Just one disc at a time so we don't need to worry about checks (yet?)
    local new_word = adv_word_bucket[math.random(#adv_word_bucket)]

    -- Start disc on one side of the screen, then create a vector based on the quadrant it's in
    -- So it should only ever to top-left -> bottom_right, bottom_left -> top_right, etc.
    local start_pos = { x = 0, y = 0 }
    local top_bottom = math.random(2) -- 1 is top, 2 is bottom
    local left_right = math.random(2) -- 1 is left, 2 is right

    local corner_x = left_right == 1 and -const.TILE_WIDTH or const.PIXEL_W + const.TILE_WIDTH
    local corner_y = top_bottom == 1 and -const.TILE_WIDTH or const.PIXEL_H + const.TILE_WIDTH

    -- Randomly offset along one axis
    if math.random(2) == 1 then
        start_pos.x = corner_x
        start_pos.y = math.random(0, const.PIXEL_H)
    else
        start_pos.x = math.random(0, const.PIXEL_W)
        start_pos.y = corner_y
    end

    -- TK: is_top and is_right would be far easier to read
    local angle
    if top_bottom == 1 and left_right == 1 then
        angle = math.rad(math.random(20, 70))
    elseif top_bottom == 1 and left_right == 2 then
        angle = math.rad(math.random(110, 160))
    elseif top_bottom == 2 and left_right == 1 then
        angle = math.rad(math.random(200, 250))
    else
        angle = math.rad(math.random(290, 340))
    end

    -- Return a new disc (in case we have multiple some day)
    -- TODO: Randomize disc speed
    local new_disc = {
        word = new_word,
        pos = start_pos, -- no deep copy needed
        -- Calc the start pos before (of course) and use that information of left/right to
        -- constrain the direction across the screen left/right within a range
        dir = {
            vx = math.cos(angle) * disc_speed,
            vy = math.sin(angle) * disc_speed,
        },
        speed = 10,
    }

    return new_disc
end

function disc.update(dt)
    -- Random chance to spawn a disc if the current one is nil
    if curr_disc == nil then
        if math.random(1) == 1 then
            curr_disc = disc.spawn()
        end
    else
        -- Move our disc position accordingly
        curr_disc.pos.x = curr_disc.pos.x + curr_disc.dir.vx * dt * curr_disc.speed
        curr_disc.pos.y = curr_disc.pos.y + curr_disc.dir.vy * dt * curr_disc.speed
        if curr_disc.pos.x > const.PIXEL_W + const.TILE_WIDTH or curr_disc.pos.x < -1 * const.TILE_WIDTH
            or curr_disc.pos.y > const.PIXEL_H + const.TILE_WIDTH or curr_disc.pos.y < -1 * const.TILE_WIDTH then
                curr_disc = nil
        end
        util.add_debug_draw_call(function()
            love.graphics.setColor(.5, .7, .2)
            love.graphics.rectangle('line', curr_disc.pos.x, curr_disc.pos.y, const.TILE_WIDTH, const.TILE_WIDTH)
            love.graphics.setColor(1, 1, 1)
        end)
        -- TODO: Check if it's out of bounds and d e l e t e
    end

    -- TODO: Iterate through the discs, updating their position and removing them if they're beyond their opposite screen space
    -- Random chance to spawn a new one (for when multiple discs can occur)
    -- if math.random(4) == 1 then
    --     disc.spawn()
    -- end
end

function disc.draw()
    -- Iterate through the discs and draw them (typing library handles word)
    if curr_disc ~= nil then
        love.graphics.draw(disc.tile, curr_disc.pos.x, curr_disc.pos.y, 0, 2)
    end
end

-- Returns the current disc information for use in typing (typing -> discs, never discs -> typing)
function disc.get_current_disc()
    return curr_disc 
end

-- Called when word is finished or out of bounds
-- The word is totally detached from the disc, this is just a sprite flying across the screen with a position and speed
function disc.despawn_disc()
    curr_disc = nil

    -- TODO: Ensure that this resets the word in typing, either there or here
end

return disc 
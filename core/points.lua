local const = require("core.constants")

local points = {}

--[[
    POINTS
    These are for tricks, etc. I should take function args eventually as different
    things are worth differing amounts of points.
]]
local current_points = 0
function points.get_points()
    return current_points
end

function points.reset_points()
    current_points = 0
end

function points.score_points(scroll_speed)
    -- No real differentiation here, revisit with discs
    -- NOTE: Another reason for a general game state
    points = const.WORD_POINTS + math.floor(scroll_speed * const.WORD_POINTS_MULT)
    current_points = current_points + points
end

function points.decr(value)
    current_points = math.max(0, current_points - value)
end

--[[
    DISTANCE POINTS!
    Handled by how much slope is covered. These points should be moved out, esp. when there are more
]]
local current_distance = 0
function points.get_distance()
    return current_distance
end

-- I want to jitter the distance increase and not be constant so we'll adjust based on scroll offset
-- And if the player is going 2x the speed at some point, they should be going 2x the distance
function points.incr_distance(scroll_offset, scroll_speed)
    local base_dist = math.floor(math.max(2, 3*scroll_offset))
    local speed_mult = math.floor(scroll_speed / 100)
    current_distance = current_distance + (base_dist*speed_mult)
end

local close_calls = 0
function points.get_close_calls()
    return close_calls
end

function points.incr_close_calls()
    close_calls = close_calls + 1
end

local close_calls_mult = 30
function points.close_calls_mult()
    return close_calls_mult
end

-- TODO: Slalom points

function points.calc_total_score()
    return current_points + current_distance + close_calls*close_calls_mult
end

function points.reset()
    current_points = 0
    current_distance = 0
    close_calls = 0
end
return points
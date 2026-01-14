local const = require("constants")

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

--[[
    DISTANCE POINTS!
    Handled by how much slope is covered. These points should be moved out, esp. when there are more
]]
local current_distance = 0
function points.get_distance()
    return current_distance
end

function points.reset_distance()
    current_distance = 0
end

-- 1 "meter" per tile? Tweak this over time for sure
function points.incr_distance()
    current_distance = current_distance + 1
end

function points.reset()
    current_points = 0
    current_distance = 0
end
return points
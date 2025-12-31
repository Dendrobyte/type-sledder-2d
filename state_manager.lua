local char = require("char")
local slope = require("slope")
-- Attempt at state management by having the callback call state functions
local states = {}

states.curr_state = { name = "start_screen" } -- Might expand into having more state info?

states.start_screen = {
    draw = function()
        love.graphics.print("TYPESLEDDER", 100, 80)
    end,
    keypressed = function(key)
        if key == "return" or key == "space" then
            states.curr_state.name = "in_game"
        end
    end,
    -- TODO: mouse press for the button click
}

states.in_game = {

    draw = function()
        slope.draw_map()
        -- Draw character on top of e
        -- Change to character.draw function?
        love.graphics.draw(char.sprite, char.x, char.y, 0, 2)
    end,
    keypressed = function(key)
        if key == "return" or key == "space" then
            states.curr_state.name = "in_game"
        end
    end,
}

return states 
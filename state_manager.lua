local char = require("char")
local slope = require("slope")
local menu = require("menu")
-- Attempt at state management by having the callback call state functions
local states = {}

states.curr_state = "start_screen"

states.start_screen = {
    draw = function()
        menu.pre_game.draw_screen()
    end,

    keypressed = function(key, isrepeat)
        if key == "return" or key == "space" then
            states.curr_state = "in_game"
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
        -- TODO: Handle input for the typing in the game stuff
    end,
}

return states 
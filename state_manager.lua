local char = require("char")
local slope = require("environment.slope")
local menu = require("menu")
local typing = require("typing")
local entities = require("environment.entities")
-- Attempt at state management by having the callback call state functions
local states = {}

states.curr_state = "in_game" -- "start_screen"

states.start_screen = {
    draw = function()
        menu.pre_game.draw_screen()
    end,

    keypressed = function(key, isrepeat)
        if key == "return" or key == "space" then
            states.curr_state = "in_game"
        end
    end,

    mousepressed = function(x, y, button, _istouch, _presses)
        if button == 1 then
            is_button_pressed = menu.pre_game.is_button_pressed(x, y)
            if is_button_pressed then states.curr_state = "in_game" end
        end
    end
}

states.in_game = {
    draw = function()
        slope.draw_map()
        entities.draw_entities()
        -- Draw character on top of e
        love.graphics.draw(char.sprite, char.x, char.y, 0, 2)
        typing.draw_words()
    end,

    keypressed = function(key)
        -- TODO: Only send a-z in this, use ascii values
        typing.on_key_press(key)
    end,
}

return states 
local char = require("char")
local slope = require("environment.slope")
local menu = require("menu")
local typing = require("typing")
local entities = require("environment.entities")
-- Attempt at state management by having the callback call state functions
local states = {}

states.curr_state = "in_game" -- "start_screen"

-- TODO: List of valid states to prevent typos, or just consts
function update_state(new_state)
    states.curr_state = new_state
end

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
            -- TODO: entities.trigger_entity_spawning() or whatever
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

    update = function(dt)
        slope.update_grid(dt)
        entities.update_grid(dt)
        collided = char.update_sprite(dt)
        typing.show_floating_message(dt)

        -- So function returns are kind of like "emits" in a way
        if collided == true then
            update_state("end_game")
        end
    end

}

states.end_game = {
    draw = function()
        slope.draw_map()
        entities.draw_entities()
        love.graphics.draw(char.sprite, char.x, char.y, 0, 2)
        love.graphics.setFont(menu.title_font)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("GAME OVER", 0, 200, 800, 'center')
        love.graphics.setColor(1, 1, 1)
    end,
}

return states 
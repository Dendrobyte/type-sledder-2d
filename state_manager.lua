local char = require("char")
local slope = require("environment.slope")
local menu = require("menu")
local typing = require("typing")
local entities = require("environment.entities")
local sounds = require("sounds")
local ui = require("ui")
-- Attempt at state management by having the callback call state functions
local states = {}

states.curr_state = "start_screen"

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
            is_button_pressed = menu.is_button_pressed("start_button", x, y)
            -- TODO: entities.trigger_entity_spawning() or whatever
            if is_button_pressed then states.curr_state = "in_game" end
            if menu.is_button_pressed("speed_decr", x, y) then
                slope.set_init_scroll_speed(slope.get_scroll_speed() - 10)
            end
            if menu.is_button_pressed("speed_incr", x, y) then
                slope.set_init_scroll_speed(slope.get_scroll_speed() + 10)
            end
        end
    end
}

states.in_game = {
    draw = function()
        slope.draw_map()
        entities.draw_entities()
        love.graphics.draw(char.sprite, char.x, char.y, 0, 2)
        typing.draw_words()
        ui.draw_ui()
    end,

    keypressed = function(key)
        -- TODO: Only send a-z in this, use ascii values
        typing.on_key_press(key)

        -- Reset game hotkey
        if key == "r" and love.keyboard.isDown("lctrl") then
            reset_game()
        end
    end,

    update = function(dt)
        slope.update_grid(dt)
        entities.update_grid(dt)
        typing.show_floating_message(dt)
        collided = char.update_sprite(dt)
        ui.update_ui(dt)

        -- So function returns can be treated like "emits"
        if collided == true then
            sounds.stop()
            update_state("end_game") -- TODO: Use a const
        end
    end
}

states.end_game = {
    draw = function()
        slope.draw_map()
        entities.draw_entities()
        love.graphics.draw(char.sprite, char.x, char.y, 0, 2)
        menu.end_game.draw_screen()
    end,

    update = function(dt)
        -- TODO: Have the slope continue to generate and slow down, stopping when player is off the screen
    end,

    keypressed = function(key, isrepeat)
        if key == "return" or key == "space" then
            reset_game()
        end
    end,
    
    mousepressed = function(x, y, button, _istouch, _presses)
        if button == 1 then
            is_button_pressed = menu.is_button_pressed("start_button", x, y)
            -- TODO: entities.trigger_entity_spawning() or whatever
            if is_button_pressed then
                reset_game()
            end
        end
    end
}

-- This feels like the best place for this... uncertain
function reset_game()
    -- Call only the things we need to reset
    slope.grid_create()
    slope.reset_scroll_speed()
    char.x, char.y = entities.cell_to_coord(char.start_position())
    char.reset_movement()
    entities.grid_create()
    typing.reset_words()
    sounds.start()

    update_state("in_game")
end
return states 
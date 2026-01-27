local char = require("entities.char")
local slope = require("environment.slope")
local menu = require("ui.menu")
local typing = require("core.typing")
local obstacles = require("entities.obstacles")
local sounds = require("core.sounds")
local ui = require("ui.ui")
local disc = require("entities.disc")
local points = require("core.points")
local callouts = require("ui.callouts")
local deco = require("environment.deco")
local sentence = require("wpm_test.sentence")

local states = {}

states.curr_state = "wpm_test" -- "start_screen"

states.valid_states = {
    "start_screen",
    "wpm_test",
    "options",
    "in_game",
    "end_game",
}
function update_state(new_state)
    states.curr_state = new_state
end

states.start_screen = {
    draw = function()
        slope.draw_map()
        love.graphics.draw(char.sprite, char.x, char.y, 0, 2)
        deco.draw_deco()
        menu.pre_game.draw_screen()
    end,

    keypressed = function(key, isrepeat)
        if key == "return" or key == "space" then
            states.curr_state = "in_game"
        end
    end,

    mousepressed = function(x, y, button, _istouch, _presses)
        if button == 1 then
            if menu.is_button_pressed("start_button", x, y) then
                states.curr_state = "in_game"
            end

            if menu.is_button_pressed("speed_incr", x, y) then
                menu.speed_change("incr")
            end
            if menu.is_button_pressed("speed_decr", x, y) then
                menu.speed_change("decr")
            end
            if menu.is_button_pressed("wpm_test_button", x, y) then
                states.curr_state = "wpm_test"
            end
        end
    end
}

states.wpm_test = {
    draw = function()
        sentence.draw_sentence()
    end,

    update = function(dt)

    end,

    keypressed = function(key, isrepeat)
        sentence.keypressed(key, isrepeat)
    end,

    mousepressed = function(x, y, button, _istouch, _presses)
        sentence.mousepressed(x, y, button, _istouch, _presses)
    end,
}

states.in_game = {
    draw = function()
        slope.draw_map()
        obstacles.draw_obstacles()
        love.graphics.draw(char.sprite, char.x, char.y, 0, 2)
        deco.draw_deco()
        disc.draw()
        typing.draw_words()
        ui.draw_ui()
    end,

    keypressed = function(key)
        -- TODO: Only send a-z, esc, in this, use ascii values. What about the sentence function though...?
        -- I guess I just want to avoid anything that's typed below, so only if no other key is down, send it
        typing.on_key_press(key)

        -- Reset game hotkey
        if love.keyboard.isDown("lctrl") and key == "r" then
            reset_game()
        end

        -- Pause mode, will need to delete this. Resets speed.
        if love.keyboard.isDown("lctrl") and key == "p" then
            slope.set_scroll_speed(0)
        end
    end,

    update = function(dt)
        slope.update_grid(dt)
        obstacles.update_grid(dt)
        typing.update(dt)
        collided = char.update_sprite(dt)
        ui.update_ui(dt)
        disc.update(dt)

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
        obstacles.draw_obstacles()
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
    char.reload()
    obstacles.grid_create()
    typing.reset_words()
    sounds.start()
    points.reset()
    disc.despawn_disc()
    callouts.reset_callouts()

    update_state("in_game")
end
return states 
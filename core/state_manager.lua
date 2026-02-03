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
local info = require("wpm_test.info")

local states = {}

states.curr_state = "start_screen"

states.valid_states = {
    "loading",
    "start_screen",
    "wpm_test",
    "options",
    "in_game",
    "end_game",
    "info_screen",
}
function update_state(new_state)
    -- Technically this should call reset as well...?
    states.curr_state = new_state
end

states.loading = {
    draw = function()
        love.graphics.setFont(love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 52))
        love.graphics.setBackgroundColor(1, 1, 1)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("LOADING SLOPES", -1, 230+1, 800, 'center')
    end,
}

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
            if menu.is_button_pressed("info_button", x, y) then
                states.curr_state = "info_screen"
            end
        end
    end
}

states.wpm_test = {
    draw = function()
        sentence.draw_sentence()
    end,

    -- All updates are done in response to keypress/mousepress, for better or for worse

    keypressed = function(key, isrepeat)
        sentence.keypressed(key, isrepeat)
        if sentence.is_testing() == false and key == "escape" then
            update_state("start_screen")
        end
    end,

    mousepressed = function(x, y, button, _istouch, _presses)
        -- In some world, I think we return 0, 1, 2, etc. for actions
        -- But for now, if we press the back button, we'll return 0
        -- And I don't hate that, over some wild tree of dependencies lol
        local go_back = sentence.mousepressed(x, y, button, _istouch, _presses)
        if go_back == 0 then
            update_state("start_screen")
        end
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
        -- TODO: Trigger an animation so we slide into the end screen like when you crash in Alto
        slope.draw_map()
        obstacles.draw_obstacles()
        love.graphics.draw(char.sprite, char.x, char.y, math.pi/2, 2)
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
            is_button_pressed = menu.is_button_pressed("try_again_button", x, y)
            -- TODO: entities.trigger_entity_spawning() or whatever
            if is_button_pressed then
                reset_game()
            end
        end
    end
}

states.info_screen = {
    draw = function()
        info.draw_info()
    end,

    -- All updates are done in response to keypress/mousepress, for better or for worse

    keypressed = function(key, isrepeat)
        update_state("start_screen")
    end,

    mousepressed = function(x, y, button, _istouch, _presses)
        update_state("start_screen")
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
    deco.grid_create()

    update_state("in_game")
end

-- Called ONLY from main!
function states.game_loaded()
    update_state("start_screen")
end

return states 
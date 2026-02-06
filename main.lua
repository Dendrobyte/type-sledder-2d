local char = require("entities.char")
local slope = require("environment.slope")
local util = require("core.util")
local states = require("core.state_manager")
local menu = require("ui.menu")
local typing = require("core.typing")
local sounds = require("core.sounds")
local obstacles = require("entities.obstacles")
local deco = require("environment.deco")
local sentence = require("wpm_test.sentence")
local info = require("wpm_test.info")

-- Load default values
function love.load()
    -- Set up some default behaviors
    love.graphics.setDefaultFilter("nearest", "nearest", 0) -- Linear can die :)
    love.window.setTitle("Type Sledder")
    math.randomseed(love.timer.getTime())
    util.set_debug(false)

    -- Menu stuff
    sentence.load()
    info.load()

    -- Set up the background and start it
    slope.load()
    obstacles.load()
    deco.load()

    -- Load "objects"
    -- TODO: Loading bar? It's kinda fast though
    char.load()
    menu.load()
    typing.load()
    sounds.load()

    states.game_loaded()
end

function love.update(dt)
    local curr_state = states[states.curr_state]
    if curr_state.update then curr_state.update(dt) end
end

-- Draw things in the scene. Draw order is dependent on line order, so keep that in mind.
function love.draw()
    local curr_state = states[states.curr_state] -- this... naming feels weird... meh
    if curr_state.draw then curr_state.draw() end
    util.draw_debug_calls()
end

function love.keypressed(key, isrepeat)
    local curr_state = states[states.curr_state]
    if curr_state.keypressed then curr_state.keypressed(key, isrepeat) end

    if key == "up" and love.keyboard.isDown("lshift") then
        util.set_debug(not util.get_debug())
    end
end

function love.mousepressed(x, y, button, _istouch, _presses)
    local curr_state = states[states.curr_state]
    if curr_state.mousepressed then curr_state.mousepressed(x, y, button) end
end


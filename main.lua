local char = require("char")
local slope = require("environment.slope")
local util = require("util")
local states = require("state_manager")
local menu = require("menu")
local typing = require("typing")
local sounds = require("sounds")
local entities = require("environment.entities")

-- Load default values
function love.load()
    -- Set up some default behaviors
    love.graphics.setDefaultFilter("nearest", "nearest", 0) -- Linear can die :)
    love.window.setTitle("Type Sledder")
    math.randomseed(love.timer.getTime())
    util.set_debug(false)

    -- Set up the background and start it
    slope.load()
    entities.load()

    -- Load "objects"
    -- TODO: Loading bar? It's kinda fast though
    char.load()
    menu.load()
    typing.load()
    sounds.load()
end

function love.update(dt)
    local curr_state = states[states.curr_state]
    if curr_state.update then curr_state.update(dt) end
    -- TODO: Move out to the state functions
    char.update_sprite(dt)
    
    -- TODO: Move this... idk, this is a spaghetti moment. Just don't understand dt stuff fully yet
    typing.show_floating_message(dt)
end

-- Draw things in the scene. Draw order is dependent on line order, so keep that in mind.
function love.draw()
    local curr_state = states[states.curr_state] -- this... naming feels weird... meh
    if curr_state.draw then curr_state.draw() end
    if util.get_debug() == true then util.debug_grid(16) end
end

function love.keypressed(key, isrepeat)
    local curr_state = states[states.curr_state]
    if curr_state.keypressed then curr_state.keypressed(key, isrepeat) end
end

function love.mousepressed(x, y, button, _istouch, _presses)
    local curr_state = states[states.curr_state]
    if curr_state.mousepressed then curr_state.mousepressed(x, y, button) end
end
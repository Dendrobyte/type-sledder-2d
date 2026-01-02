local char = require("char")
local slope = require("slope")
local util = require("util")
local states = require("state_manager")
local menu = require("menu")
local typing = require("typing")

-- Load default values
function love.load()
    -- Set up some default behaviors
    love.graphics.setDefaultFilter("nearest", "nearest", 0) -- Linear can die :)
    love.window.setTitle("Type Sledder")

    -- Set up the background and start it
    slope.load()

    -- Load "objects"
    char.load()
    menu.load()
    typing.load()
    debug_mode = false
end

function love.update(dt)
    -- TODO: Move out to the state functions
    char.update_sprite(dt)
end

-- Draw things in the scene. Draw order is dependent on line order, so keep that in mind.
function love.draw()
    if debug_mode == true then util.debug_grid() end
    local curr_state = states[states.curr_state] -- this... naming feels weird... meh
    if curr_state.draw then curr_state.draw() end
end

function love.keypressed(key, isrepeat)
    local curr_state = states[states.curr_state]
    if curr_state.keypressed then curr_state.keypressed(key, isrepeat) end
end

function love.mousepressed(x, y, button, _istouch, _presses)
    local curr_state = states[states.curr_state]
    if curr_state.mousepressed then curr_state.mousepressed(x, y, button) end
end

-- Design notes

-- If the skiier goes to the bottom of the screen, game over.
-- Words will slide up the slope. Upon successful typing of the words (have a text box), the skiier will bump "up" on the screen.
-- This should- visually- look more like the whole "camera" is moving up to show more words.
-- The further away words are a little longer but should slide up a little more and might have coins on the way or something
-- For starters, just have the same tileset constantly generated alongside random words from a text file. Eventually... procedurally generate a path?
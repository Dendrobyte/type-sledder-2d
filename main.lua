local char = require("char")
local slope = require("slope")

-- Attempt at state management by having the callback call state functions
local curr_state = { current = "start_screen" }
local states = {}




-- Load default values
function love.load()
    -- Set up some default behaviors
    love.graphics.setDefaultFilter("nearest", "nearest", 0) -- Linear can die :)
    love.window.setTitle("Type Sledder")

    -- Set up the background and start it
    slope.load()

    -- Load "objects"
    char.load() 
end

function love.update(dt)
    char.update_sprite(dt)
end

-- Draw things in the scene. Draw order is dependent on line order, so keep that in mind.
function love.draw()
    slope.draw_map()
    -- Draw character on top of e
    -- Change to character.draw function?
    love.graphics.draw(char.sprite, char.x, char.y, 0, 2)
end

function love.keypressed(key, isrepeat)
    -- TODO: Handle keypresses as a user is typing words and detect the word being typed, etc.
end

-- Design notes

-- If the skiier goes to the bottom of the screen, game over.
-- Words will slide up the slope. Upon successful typing of the words (have a text box), the skiier will bump "up" on the screen.
-- This should- visually- look more like the whole "camera" is moving up to show more words.
-- The further away words are a little longer but should slide up a little more and might have coins on the way or something
-- For starters, just have the same tileset constantly generated alongside random words from a text file. Eventually... procedurally generate a path?
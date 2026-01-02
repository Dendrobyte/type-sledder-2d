local char = require("char")

local typing = {}

-- TODO: Load a list of a bunch of words
-- For future, this becomes easy, medium, hard, etc. that levels up over times
local word_bucket = {"hello", "world"}

-- Store offsets (may add more words later)
local word_left = {
    x = -75,
    y = 25,
}
local word_right = {
    x = 75,
    y = 25,
}

-- Becomes a map of word -> true so we can check for a word simply (but like... it's 4 words tops...)
-- Used for typing, updated independently from what the left and right words being rendered are
local active_words = {}

-- Stores the words for "left" and "right", updated independently from active words
local rendered_words = {}

function typing.load()
    typing.default_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 24)

    typing.update_word("left", "")
    typing.update_word("right", "")
end

function typing.draw_words()
    love.graphics.setFont(typing.default_font)
    love.graphics.setColor(0, 0, 0)

    -- TODO: Change these to draw what's typed and untyped, just draw over each other
    -- Don't loop or anything, I think it's more readable this way
    love.graphics.print(rendered_words.left, char.x+word_left.x, char.y+word_left.y)
    love.graphics.print(rendered_words.right, char.x+word_right.x, char.y+word_right.y)

    love.graphics.setColor(1, 1, 1) -- font is always set, but color needs to be reset for general drawing it appears
end

-- Given the index in the rendered word list, change it
-- TODO: Constants opportunity for the indices, if/when I come back and add more than just left/right
function typing.update_word(rendered_idx, replaced_word)
    local new_word = word_bucket[math.random(#word_bucket)]
    while active_words[new_word] == true do -- Avoid repeats of what's active
        new_word = word_bucket[math.random(#word_bucket)]
    end
    rendered_words[rendered_idx] = new_word
    active_words[replaced_word] = nil
    active_words[new_word] = true
end

return typing
local typing = {}

local words = {"hello", "world"}

local word_left = {
    x = 100,
    y = 100,
}
local word_right = {
    x = 500,
    y = 100,
}

function typing.load()
    typing.default_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 24)
end

function typing.draw_words()
    love.graphics.setFont(typing.default_font)

    -- TODO: Change these to draw what's typed and untyped, just draw over each other
    print(words)
    love.graphics.printf(words[0], word_left.x, word_left.y)
    love.graphics.printf(words[1], word_right.x, word_right.y)
end

return typing
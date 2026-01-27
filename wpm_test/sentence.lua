local const = require("core.constants")
local util = require("core.util")

local sentence = {}

-- I want a variety so people don't try to game it
local test_sentences = {
    -- Medium
    "the coffee shop on the corner makes the best espresso in town",
    "bright stars filled the night sky as we sat around the campfire",
    "the garden was full of colorful flowers buzzing with bees",
    "he forgot his umbrella and got caught in the afternoon rain",
    "the train arrived late but we still made it to the concert on time",
    "her painting captured the sunset perfectly with warm golden hues",
    "the dog chased the ball across the yard and into the bushes",
    "we found a quiet spot by the river and watched the water flow past",
    "the smell of fresh cookies drifted through the entire house",
    "after the long hike we rested at the summit and enjoyed the view",

    -- Ski themed
    "fresh powder covered the slopes overnight making for perfect conditions",
    "the chairlift carried us above the trees as the valley spread out below",
    "moguls demand quick reflexes and strong legs to navigate smoothly",
    "the ski lodge was warm and cozy after a long day on the mountain",
    "icy patches on the trail kept everyone alert and cautious",
    "goggles fogged up as the temperature dropped near the summit",
    "the rental shop fitted us with boots and poles before our first lesson",
    "snow sprayed behind each turn as the racer flew down the course",
    "hot chocolate tastes best after spending hours in the freezing cold",
    "the bunny hill was crowded with beginners learning to stop and turn",
}

-- We effectively have this one state if testing or not, and we can let them keep trying
-- But just show score and function to map speed rec below start button
local is_testing = false
local show_score = false

-- General bounding box
local bounds = {}
local buttons = {
    start = {}
}
-- When we write text, always increase this by the font size? Just testing
local vert_offset = 0 

function sentence.load()
    sentence.title_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 48)
    sentence.text_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 24)
    sentence.test_info = love.graphics.newFont("ski_assets/bogita_mono/BogitaMono-LightOblique.otf", 18)
    sentence.test_font = love.graphics.newFont("ski_assets/bogita_mono/BogitaMono-UltraBold.otf", 48)

    -- In effect, trying to deefine a box by its padding
    local padding_horizontal = const.PIXEL_W * .1
    local padding_vertical = const.PIXEL_H * .1
    local box_width = const.PIXEL_W - 2*padding_horizontal
    local box_height = const.PIXEL_H - 2*padding_horizontal
    bounds.start_x = padding_horizontal
    bounds.start_y = padding_vertical
    bounds.width = box_width
    bounds.height = box_height

    -- This is used for the mouse hitbox too, but I will probably need one for each button
    buttons.start.x = bounds.start_x+(bounds.width/4)
    buttons.start.y = bounds.start_y+120 -- no vert offset bc we need to use these vals for collision
    buttons.start.w = bounds.width/2
    buttons.start.h = 80
end

function sentence.draw_sentence()
    -- Reset lol
    vert_offset = 0

    if util.get_debug() == true then
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("line", bounds.start_x, bounds.start_y, bounds.width, bounds.height)
        util.reset_color()
    end

    love.graphics.setColor(.7, .2, .1)
    love.graphics.setFont(sentence.title_font)
    love.graphics.printf("Typing Test", bounds.start_x, bounds.start_y+vert_offset, bounds.width, "center")
    vert_offset = vert_offset + 48


    -- TODO: This is going to be a beeg function. But I think I'm okay with that?
    if is_testing == false then
        love.graphics.setColor(.9, .8, 0)
        love.graphics.setFont(sentence.text_font)
        love.graphics.printf("Once you press start (or the \"ENTER\" key), type the sentence as fast as you can. You will get a WPM (Words Per Minute) score and a speed recommendation based on that.",
            bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
        vert_offset = vert_offset + 24*2 -- Above text is 2 lines tall

        love.graphics.setColor(.5, .6, .8)
        vert_offset = vert_offset + 24
        love.graphics.rectangle("fill", buttons.start.x, buttons.start.y, buttons.start.w, buttons.start.h)
        love.graphics.setFont(sentence.title_font)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("START", bounds.start_x+(bounds.width/4), bounds.start_y+vert_offset+16, bounds.width/2, "center")

        if show_score == true then
            -- TODO: Show score and speed rec based on function
        end
    else
        -- Typing test
        love.graphics.setColor(.6, .6, .6, .8)
        love.graphics.setFont(sentence.test_info)
        love.graphics.printf("The test starts on first keypress", bounds.start_x, bounds.start_y+vert_offset, bounds.width, "center")
        vert_offset = vert_offset + 36
        love.graphics.setColor(1, 1, 1) 
        love.graphics.setFont(sentence.test_font)
        love.graphics.printf(sentence.rand_sentence, bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
    end

    util.reset_color()
end

function sentence.keypressed(key, isrepeat)
    if is_testing == false then
        if key == "return" then
            start_test()
        end
    end
end

function sentence.mousepressed(x, y, button, _istouch, _presses)
    if is_testing == false then 
        -- This is moreso, like, "if button on screen". I'm NOT doing this now, but a general system could be
        -- some "substate" that holds what buttons are being drawn.
        -- On each draw instruction, we iterate over those buttons. And then here we check for those buttons too.
        -- But not now :)
        if sentence.is_button_pressed("start", x, y) then -- Vert offset is 120 by the time start is rendered I think
            start_test()
        end
    end
end

sentence.rand_sentence = nil
sentence.start_time = nil
function start_test()
    is_testing = true
    sentence.rand_sentence = test_sentences[math.random(#test_sentences)]
    sentence.start_time = 0
end

-- Yea, this is copied. Could make it a util button tbh
function sentence.is_button_pressed(button_type, x, y)
    button_x = buttons[button_type].x
    button_y = buttons[button_type].y
    button_w = buttons[button_type].w
    button_h = buttons[button_type].h
    print(button_x, button_y, button_w, button_h)
    print(x, y)
    if x > button_x and x < button_x + button_w and y > button_y and y < button_y + button_h then
        return true
    else
        print("false")
        return false
    end
end

return sentence
local const = require("core.constants")
local util = require("core.util")
local sounds = require("core.sounds")

local sentence = {}

-- I want a variety so people don't try to game it
local test_sentences = {
    -- Medium
    "the coffee shop on the corner makes the best espresso in town and every morning there is a line out the door",
    "bright stars filled the night sky as we sat around the campfire telling stories and roasting marshmallows until midnight",
    "the garden was full of colorful flowers buzzing with bees and the sweet scent of roses drifted through the open window",
    "he forgot his umbrella and got caught in the afternoon rain so he ducked into a bookstore and stayed for hours",
    "the train arrived late but we still made it to the concert on time and found our seats just as the lights dimmed",
    "her painting captured the sunset perfectly with warm golden hues that seemed to glow even in the dim gallery light",
    "the dog chased the ball across the yard and into the bushes then emerged covered in leaves looking very proud",
    "we found a quiet spot by the river and watched the water flow past while the sun slowly set behind the hills",
    "the smell of fresh cookies drifted through the entire house and everyone gathered in the kitchen hoping for a taste",
    "after the long hike we rested at the summit and enjoyed the view then unpacked our lunch and watched the clouds roll by",
    -- Ski themed
    "fresh powder covered the slopes overnight making for perfect conditions and the first tracks down the mountain were absolutely flawless",
    "the chairlift carried us above the trees as the valley spread out below and we spotted tiny skiers carving their way down",
    "moguls demand quick reflexes and strong legs to navigate smoothly and by the end of the run my thighs were burning",
    "the ski lodge was warm and cozy after a long day on the mountain and we gathered by the fire to share stories of our runs",
    "icy patches on the trail kept everyone alert and cautious so we slowed down and picked our lines carefully through the shade",
    "goggles fogged up as the temperature dropped near the summit forcing a quick stop to wipe them clear before continuing down",
    "the rental shop fitted us with boots and poles before our first lesson and the instructor showed us how to snowplow to a stop",
    "snow sprayed behind each turn as the racer flew down the course crossing the finish line in record time to cheers from the crowd",
    "hot chocolate tastes best after spending hours in the freezing cold especially when you add extra whipped cream on top",
    "the bunny hill was crowded with beginners learning to stop and turn while more experienced skiers zoomed past on the trails above",
}

-- We effectively have this one state if testing or not, and we can let them keep trying
-- But just show score and function to map speed rec below start button
local is_testing = false
function sentence.is_testing() return is_testing end
local show_score = false

-- General bounding box
local bounds = {}
local buttons = {
    start = {},
    back = {},
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
    buttons.start.y = bounds.start_y+192 -- no vert offset bc we need to use these vals for collision
    buttons.start.w = bounds.width/2
    buttons.start.h = 80

    buttons.back.x = bounds.start_x+(bounds.width/4)
    buttons.back.y = bounds.start_y+392 -- no vert offset bc we need to use these vals for collision
    buttons.back.w = bounds.width/2
    buttons.back.h = 80
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
        vert_offset = vert_offset + 24*3 -- Above text is 2 lines tall
        love.graphics.printf("Due to issues I don't want to fix right now, a word might not wrap onto the next line as you type it.",
            bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
        vert_offset = vert_offset + 24*2 -- Above text is 2 lines tall

        love.graphics.setColor(.5, .8, .6)
        vert_offset = vert_offset + 24
        love.graphics.rectangle("fill", buttons.start.x, buttons.start.y, buttons.start.w, buttons.start.h)
        love.graphics.setFont(sentence.title_font)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("START", bounds.start_x+(bounds.width/4), bounds.start_y+vert_offset+16, bounds.width/2, "center")
        vert_offset = vert_offset + 48 + 48

        if show_score == true then
            love.graphics.printf("FINAL WPM: " .. sentence.wpm_score, bounds.start_x+(bounds.width/4), bounds.start_y+vert_offset, bounds.width/2, "center")
            love.graphics.printf("SPEED REC: " .. wpm_to_speed_rec(sentence.wpm_score), bounds.start_x+(bounds.width/4), bounds.start_y+vert_offset+48, bounds.width/2, "center")
        end

        love.graphics.setColor(.8, .6, .5)
        love.graphics.rectangle("fill", buttons.back.x, buttons.back.y, buttons.back.w, buttons.back.h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(sentence.title_font)
        love.graphics.printf("Back to Start (ESC)", bounds.start_x+(bounds.width/4), bounds.start_y+vert_offset+124, buttons.back.w, "center")
    else
        -- Typing test
        love.graphics.setColor(.6, .6, .6, .8)
        love.graphics.setFont(sentence.test_info)
        if sentence.buffer == "" then
            love.graphics.printf("The test starts on first keypress", bounds.start_x, bounds.start_y+vert_offset, bounds.width, "center")
        else
            love.graphics.setColor(0, .8, 0)
            love.graphics.printf("TEST STARTED", bounds.start_x, bounds.start_y+vert_offset, bounds.width, "center")
        end
        vert_offset = vert_offset + 36
        love.graphics.setColor(1, 1, 1) 
        love.graphics.setFont(sentence.test_font)
        love.graphics.printf(sentence.rand_sentence, bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
        love.graphics.setColor(0, 1, 0) 
        love.graphics.printf(sentence.buffer, bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
    end

    util.reset_color()
end

function sentence.keypressed(key, isrepeat)
    if is_testing == false then
        if key == "return" then
            start_test()
        end
    else
        -- I'm not sure where ELSE this would go?? Feels wrong for some reason
        if #sentence.buffer == 0 then sentence.start_time = love.timer.getTime() end
        -- This does not concern with casing, e.g. SHIFT, so... yea :)
        if key == "space" then key = " " end
        local next_buffer = sentence.buffer .. key
        if sentence.rand_sentence:sub(1, #next_buffer) == next_buffer then
            sounds.play_click()
            sentence.buffer = next_buffer
        else
            -- TODO: Show red on the letter it should be, not the one that was typed
        end

        if #next_buffer == #sentence.rand_sentence then
            local time_elapsed = love.timer.getTime() - sentence.start_time
            is_testing = false
            show_score = true

            -- Measure WPM by 5 chars per second
            local wpm_float = (#sentence.rand_sentence / 5) / (time_elapsed / 60)
            sentence.wpm_score = math.floor(wpm_float + 0.5) -- Add .5 to round up
        end
    end
end

function sentence.mousepressed(x, y, button, _istouch, _presses)
    if is_testing == false then 
        -- This is moreso, like, "if button on screen". I'm NOT doing this now, but a general system could be
        -- some "substate" that holds what buttons are being drawn.
        -- On each draw instruction, we iterate over those buttons. And then here we check for those buttons too.
        -- But not now :)
        if sentence.is_button_pressed("start", x, y) then
            start_test()
        end
        if sentence.is_button_pressed("back", x, y) then
            -- Repeated, but reset stuff in case they come back
            sentence.rand_sentence = nil
            sentence.start_time = nil
            sentence.buffer = ""
            sentence.wpm_score = nil
            return 0
        end
    end
end

sentence.rand_sentence = nil
sentence.start_time = nil
sentence.buffer = "" -- Stores what has currently been typed
sentence.wpm_score = nil
function start_test()
    is_testing = true
    show_score = false
    sentence.rand_sentence = test_sentences[math.random(#test_sentences)]
    sentence.start_time = nil
    sentence.buffer = ""
end

-- Takes wpm and returns the speed rec based on the speeds defined in menu.lua
function wpm_to_speed_rec(wpm)
        local thresholds = {25, 35, 45, 55, 70, 85, 105, 130, 155}
    for i, threshold in ipairs(thresholds) do
        if wpm < threshold then return i end
    end
    return 10
end

-- Yea, this is copied. Could make it a util button tbh
function sentence.is_button_pressed(button_type, x, y)
    button_x = buttons[button_type].x
    button_y = buttons[button_type].y
    button_w = buttons[button_type].w
    button_h = buttons[button_type].h
    if x > button_x and x < button_x + button_w and y > button_y and y < button_y + button_h then
        return true
    else
        return false
    end
end

return sentence
local char = require("char")
local sounds = require("sounds")
local util = require("util")
local slope = require("environment.slope")
local const = require("constants")
local points = require("points")
local disc = require("disc")

local typing = {}

-- TODO: Load a list of a bunch of words
-- For future, this becomes easy, medium, hard, etc. that levels up over times
-- local word_bucket = {
--   "hello","world","game","play","score","speed","track","level","start",
--   "finish","jump","slide","run","move","block","dodge","press","hold","tap",
--   "timer","point","bonus","combo","chain","power","boost","skill","focus",
--   "quick","sharp","clean","smooth","simple","ready","steady","fast","clear",
--   "bright","cool","calm","alert","logic","input","react","shift","enter",
--   "space","mouse","click","touch","screen","pixel","sprite","sound","music",
--   "beat","rhythm","tempo","flow","match","align","stack","drop","build",
--   "break","reset","retry","win","lose","draw","pause","resume","select",
--   "confirm","cancel","escape","finish","victory","perfect"
-- }
local word_bucket = { -- Testing for the text width stuff
    "hi",
    "mark",
    "how",
    "nostradamus",
    "application",
    "word",
    "eel",
    "instantaneous",
    "miscellaneous",
}

-- How far a left word should end and a right word should start from the player
local word_player_offset = {
    x = 30,
    y = 25
}
-- Store all the position data necessary for a word, updates upon reset
-- TODO: Deprecate x,y once you've used the other information properly
local word_pos = {
    left = {
        origin = { x = nil, y = nil }, -- top left corner of bounding rectangle
        width = nil, -- total width of word
    },
    right = {
        origin = { x = nil, y = nil }, -- top left corner of bounding rectangle
        width = nil, -- total width of word
    },
}

-- Gets the rectangle a word should be rendered in
function calc_word_bounds(text, render_idx)
    local font = love.graphics.getFont()
    local width = font:getWidth(text)
    local ascent = font:getAscent() -- distance between the baseline and the top of the glyph that reaches farthest from the baseline

    -- If it's the left word, we know where to end. If it's the right word, we know where to start
    -- TK: Table of functions is another option here
    local origin = {}
    if render_idx == "left" then
        origin = {
            x = char.center - word_player_offset.x - width,
            y = char.y + word_player_offset.y + ascent/2,
        }
    else -- render_idx == "right", we should never be seeing disc here (yet)
        origin = {
            x = char.center + word_player_offset.x,
            y = char.y + word_player_offset.y + ascent/2,
        }
    end

    word_pos[render_idx] = {
        origin = origin,
        width = width,
    }
end

-- Becomes a map of word -> render_idx so we can check for a word simply (but like... it's 4 words tops...)
-- Used for typing, updated independently from what the left and right words being rendered are, but value for accessing it
local active_words = {}

-- Stores the words for "left", "right", and "disc", updated independently from active words
local rendered_words = {}

local floating_messages = {} -- List of messages we can store...? Maybe multiple?

function typing.load()
    typing.default_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 24)

    typing.reset_words()
end

-- Handle the active typing
local current_word = {
    final = nil, -- This comes from active_words when we register the first unique keypress
    buffer = "", -- This is the word they are typing as they type it
    render_idx = "", -- This is the word we end up selecting for them
}
local function reset_current_word()
    current_word.final = nil
    current_word.buffer = ""
    current_word.render_idx = ""
end

function typing.reset_words()
    active_words = {}
    typing.update_word("left", "")
    typing.update_word("right", "")
    typing.update_word("disc", "")
    reset_current_word()

    floating_messages = {}
end

function typing.update(dt)
    -- Show the floating messages
    for i = #floating_messages, 1, -1 do
        local msg = floating_messages[i]
        msg.age = msg.age + dt
        msg.y = msg.y - 10*dt
        if msg.age > 2 then
            table.remove(floating_messages, i)
        end
    end

    -- TK: I don't know how I feel about the way this function is written, versus one
    --     meant to update the bounds (or moving on char move) but no game state so here we are
    calc_word_bounds(rendered_words["left"], "left")
    calc_word_bounds(rendered_words["right"], "right")
    typing.disc_update_check(dt)
end

function typing.on_key_press(key)
    for word, idx in pairs(active_words) do print(word, ",", idx) end
    print("----")
    -- If we're typing and we've assigned a word, match on that wor
    if  #current_word.buffer ~= 0 and current_word.final ~= nil then
        local next_buffer = current_word.buffer .. key
        -- Match the substr by length with the typed word
        if current_word.final:sub(1, #next_buffer) == next_buffer then
            current_word.buffer = next_buffer
        else
            -- Do nothing
            -- TODO: Visual indicator we are wrong
        end

        -- Trigger new word, etc. when we get the word correct
        if current_word.buffer == current_word.final then
            sounds.play_ding()
            table.insert(floating_messages, {
                text = "NICE!", -- TODO: Randomize
                age = 0,
                x = char.x,
                y = char.y-25,
            })
            -- TODO: More robust movement here depending on curr direction, etc.
            if current_word.render_idx == "left" or current_word.render_idx == "right" then
                typing.update_word(current_word.render_idx, current_word.final)
                char.move(current_word.render_idx)
            elseif current_word.render_idx == "disc" then
                -- TK: Reaaaallyy should have thought out the disc integration a bit more
                -- TODO: Make a function within typing to properly clear up the disc word related stuff
                -- Effectively mimicing typing.update_word but relying on the disc's word list
                typing.clear_disc_info()
                disc.despawn_disc()
                points.score_points(20) -- idk, something extra for the disc
            end
            reset_current_word() -- resets the buffer, etc.
            -- TODO: Points for word type
            -- TODO: General game state of scroll speed
            points.score_points(slope.get_scroll_speed())
        end

    -- Otherwise, go until we match on an active word
    else
        -- So the current "buffer" is effectively our prefix, the list is so small
        local next_buffer = current_word.buffer .. key
        local matches = 0
        local matched_word = "" -- It's only ever 1 word when we care about this
        for active_word, _ in pairs(active_words) do
            if active_word:sub(1, #next_buffer) == next_buffer then
                matches = matches + 1
                matched_word = active_word
            end
        end

        -- If we find one match, we have our final word
        -- If we have mult matches, keep building the buffer. Otherwise, don't append to buffer
        if matches == 1 then
            current_word.buffer = next_buffer
            current_word.final = matched_word 
            current_word.render_idx = active_words[matched_word]
        elseif matches > 1 then
            current_word.buffer = next_buffer
        end
    end
end

function typing.draw_words()
    love.graphics.setFont(typing.default_font)
    love.graphics.setColor(0, 0, 0)

    if util.get_debug() == true then
        local height = love.graphics.getFont():getAscent()
        love.graphics.setColor(.2, .2, .3, .2)
        love.graphics.rectangle("fill", word_pos.left.origin.x, word_pos.left.origin.y, word_pos.left.width, height)
        love.graphics.rectangle("fill", word_pos.right.origin.x, word_pos.right.origin.y, word_pos.right.width, height)
        love.graphics.setColor(0, 0, 0)
    end

    -- Don't loop or anything, I think it's more readable this way
    -- TODO: Redrawing with proper word_DIR limits
    love.graphics.printf(rendered_words.left, word_pos.left.origin.x, word_pos.left.origin.y, word_pos.left.width, "right")
    love.graphics.printf(rendered_words.right, word_pos.right.origin.x, word_pos.right.origin.y, word_pos.right.width, "left")
    if curr_disc_info ~= nil then
        -- TODO: Word disc offset value, can also use below... depends on when we get to multiple discs?
        --       Could calc based on word size if I wanted to be real specific I suppose
        love.graphics.print(rendered_words.disc, curr_disc_info.pos.x-20, curr_disc_info.pos.y-30)
    end

    if current_word.final ~= nil then
        typing.draw_word_progress(current_word.render_idx)
    end

    -- Draw a "NICE!" message if it's there
    for _, msg in ipairs(floating_messages) do
        local alpha = 1 - (msg.age / 2) -- 2 is the same elsewhere, could do msg.lifetime
        love.graphics.setColor(0, 1, 0, alpha)
        love.graphics.print(msg.text, msg.x, msg.y)
    end

    if util.get_debug() == true then
        love.graphics.setColor(0, .5, 1)
        love.graphics.print("DEBUG: " .. current_word.buffer, char.x, char.y+50)
    end

    love.graphics.setColor(1, 1, 1) -- font is always set, but color needs to be reset for general drawing it appears

end

-- Given the index in the rendered word list, change it
-- TODO: Constants opportunity for the indices, if/when I come back and add more than just left/right
function typing.update_word(rendered_idx, replaced_word)
    local new_word = word_bucket[math.random(#word_bucket)]
    while active_words[new_word] ~= nil do -- Avoid repeats of what's active
        new_word = word_bucket[math.random(#word_bucket)]
    end
    rendered_words[rendered_idx] = new_word
    active_words[replaced_word] = nil
    active_words[new_word] = rendered_idx

    -- Calculate the position data for the word as we show it on screen
    calc_word_bounds(new_word, rendered_idx)
end

function typing.draw_word_progress()
    local font = love.graphics.getFont()
    local curr_word_x = word_pos[current_word.render_idx].origin.x
    local curr_word_y = word_pos[current_word.render_idx].origin.y
    local alignment = current_word.render_idx == "left" and "right" or "left" 
    
    -- TK: I should have thought this out a little more for the disc stuff...
    if curr_disc_info ~= nil then
        curr_word_x = curr_disc_info.pos.x-20
        curr_word_y = curr_disc_info.pos.y-30
    end

    local final_word = current_word.final
    local typed_len = #current_word.buffer
    local curr_char = final_word:sub(typed_len+1, typed_len+2)
    local remaining_word = final_word:sub(typed_len+2) -- BEWARE OOB!

    local typed_width = font:getWidth(current_word.buffer)
    local curr_width = font:getWidth(curr_char)
    local char_height = font:getHeight()

    -- Calculate positioning

    -- Draw highlight box
    if typed_len > 0 then
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", curr_word_x + typed_width, curr_word_y, curr_width, char_height)
    end
    
    -- Draw the different parts of the word
    love.graphics.setColor(.9, .9, .9)
    love.graphics.print(current_word.buffer, curr_word_x, curr_word_y)

    love.graphics.setColor(.2, .2, .2)
    love.graphics.print(curr_char, curr_word_x + typed_width, curr_word_y)

    love.graphics.setColor(.5, .5, .5)
    love.graphics.print(remaining_word, curr_word_x + typed_width + curr_width, curr_word_y)

    love.graphics.setColor(0, 0, 0)



end

-- Discs despawning and a different word list make it more complicated
-- Clear ALL the disc stuff, rely on disc_update_check to add the new information on spawn
-- That's also different, no immediate reset
function typing.clear_disc_info()
    curr_disc_word = rendered_words["disc"]
    active_words[curr_disc_word] = nil
    if current_word.render_idx == "disc" then
        reset_current_word()
    end
end

-- Check for active disc...?
curr_disc_info = nil
function typing.disc_update_check(dt)
    curr_disc_info = disc.get_current_disc()
    if curr_disc_info ~= nil then
        rendered_words["disc"] = curr_disc_info.word
        active_words[curr_disc_info.word] = "disc"
    else
        typing.clear_disc_info()
    end
end

return typing
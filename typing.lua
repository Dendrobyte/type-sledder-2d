local char = require("char")
local sounds = require("sounds")
local util = require("util")

local typing = {}

-- TODO: Load a list of a bunch of words
-- For future, this becomes easy, medium, hard, etc. that levels up over times
local word_bucket = {
  "hello","world","game","play","score","speed","track","level","start",
  "finish","jump","slide","run","move","block","dodge","press","hold","tap",
  "timer","point","bonus","combo","chain","power","boost","skill","focus",
  "quick","sharp","clean","smooth","simple","ready","steady","fast","clear",
  "bright","cool","calm","alert","logic","input","react","shift","enter",
  "space","mouse","click","touch","screen","pixel","sprite","sound","music",
  "beat","rhythm","tempo","flow","match","align","stack","drop","build",
  "break","reset","retry","win","lose","draw","pause","resume","select",
  "confirm","cancel","escape","finish","victory","perfect"
}


-- Store offsets (may add more words later)
local word_left = {
    x = -75,
    y = 25,
}
local word_right = {
    x = 75,
    y = 25,
}

-- Becomes a map of word -> render_idx so we can check for a word simply (but like... it's 4 words tops...)
-- Used for typing, updated independently from what the left and right words being rendered are, but value for accessing it
local active_words = {}

-- Stores the words for "left" and "right", updated independently from active words
local rendered_words = {}

function typing.load()
    typing.default_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 24)

    typing.update_word("left", "")
    typing.update_word("right", "")
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

-- TODO: This is a super one-off function :\
-- Option 1: Some "animation" manager that we call if this is access from other places, like
--      obstacle dodging, etc.
-- Option 2: Pass dt somewhere further up the chain
local floating_messages = {} -- List of messages we can store...? Maybe multiple?
function typing.show_floating_message(dt)
    for i = #floating_messages, 1, -1 do
        local msg = floating_messages[i]
        msg.age = msg.age + dt
        msg.y = msg.y - 10*dt
        if msg.age > 2 then
            table.remove(floating_messages, i)
        end
    end
end

function typing.on_key_press(key)
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
            typing.update_word(current_word.render_idx, current_word.final)
            sounds.play_ding()
            table.insert(floating_messages, {
                text = "NICE!",
                age = 0,
                x = char.x,
                y = char.y-25,
            })
            char.move(current_word.render_idx)
            reset_current_word()
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

    -- Don't loop or anything, I think it's more readable this way
    love.graphics.print(rendered_words.left, char.x+word_left.x, char.y+word_left.y)
    love.graphics.print(rendered_words.right, char.x+word_right.x, char.y+word_right.y)
    if current_word.final ~= nil then
        -- Draw the working word over its start
        love.graphics.setColor(0, .8, 1)
        local curr_word_x, curr_word_y = -1, -1
        if current_word.render_idx == "left" then
            curr_word_x = char.x+word_left.x
            curr_word_y = char.y+word_left.y
        else
            curr_word_x = char.x+word_right.x
            curr_word_y = char.y+word_right.y
        end
        love.graphics.print(current_word.buffer, curr_word_x, curr_word_y)

    end

    -- Draw a "NICE!" message if it's there
    for _, msg in ipairs(floating_messages) do
        local alpha = 1 - (msg.age / 2) -- 2 is the same elsewhere, could do msg.lifetime
        love.graphics.setColor(0, 1, 0, alpha)
        love.graphics.print(msg.text, msg.x, msg.y)
    end

    -- ## DEBUGGING ##
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
    active_words[replaced_word] = nil -- if someone goes infinitely... is this a good idea??
    active_words[new_word] = rendered_idx
end

return typing
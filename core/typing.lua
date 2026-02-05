local char = require("entities.char")
local sounds = require("core.sounds")
local util = require("core.util")
local slope = require("environment.slope")
local const = require("core.constants")
local points = require("core.points")
local disc = require("entities.disc")
local callouts = require("ui.callouts")

local typing = {}

-- For future, this becomes easy, medium, hard, etc. that levels up over times
-- For now, using 5 letter words to avoid spacing looking like ass
local word_bucket = {
    -- Ski/winter themed
    "skier", "icing", "snowy", "hills", "colds", "windy", "trees", "poles", "turns",
    "peaks", "trail", "edges", "grips", "chill", "frost", "sleds", "based", "lifts",
    "slope", "mogul", "lodge", "cabin", "carve", "steep", "boots", "glove",
    "strap", "froze", "flurr", "crisp", "fresh", "chair", "piste", "polar",
    "cocoa", "flake", "froze", "shive", "cozie", "thaws",
    
    -- Action words
    "dodge", "weave", "sprint", "brake", "leaps", "soars", "coast", "drift",
    "races", "chase", "shove", "pulls", "leans", "ducks", "tucks", "shift",
    "jumps", "lands", "glide", "runs", "zesty", "fasts", "slows", "prowl", "rolls",
    
    -- General game words
    "score", "speed", "track", "level", "start", "ended", "moves", "block",
    "press", "holds", "stops", "point", "bonus", "combo", "chain", "power",
    "boost", "skill", "focus", "quick", "sharp", "glows", "sleek", "ready",
    "stead", "clear", "brisk", "cools", "calms", "alert", "react", "flows",
    "match", "stack", "drops", "build", "break", "reset", "retry", "wins",
    "loses", "pause", "renew", "chose", "ideal",
}
-- local word_bucket = { -- Testing for the text width stuff
--     "hi", "mark", "how", "nostradamus", "application", "word", "eel", "instantaneous", "miscellaneous",
-- }

function typing.load()
    typing.default_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 24)
    typing.down_right_arrow = love.graphics.newImage("ski_assets/UI_Tiles/tile_0075.png")
    typing.down_left_arrow = love.graphics.newImage("ski_assets/UI_Tiles/tile_0076.png")
    typing.down_arrow = love.graphics.newImage("ski_assets/UI_Tiles/tile_0071.png")
    typing.right_arrow = love.graphics.newImage("ski_assets/UI_Tiles/tile_0072.png")
    typing.left_arrow = love.graphics.newImage("ski_assets/UI_Tiles/tile_0073.png")

    typing.reset_words()
end

-- How far a left word should end and a right word should start from the player
local word_player_offset = {
    x = 30,
    y = 25
}
-- Store all the position data necessary for a word, updates upon reset
local word_pos = {
    left = {
        origin = { x = nil, y = nil },
        width = nil,
    },
    right = {
        origin = { x = nil, y = nil }, -- top left corner of bounding rectangle
        width = nil, -- total width of word
    },
    center = {
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
    elseif render_idx == "right" then
        origin = {
            x = char.center + word_player_offset.x,
            y = char.y + word_player_offset.y + ascent/2,
        }
    elseif render_idx == "center" then
        origin = {
            x = char.center - word_player_offset.x + 8,
            y = char.y + word_player_offset.y + 36,
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

-- Handle the active typing
local current_word = {
    final = nil, -- This comes from active_words when we register the first unique keypress
    buffer = "", -- This is the word they are typing as they type it
    render_idx = "", -- This is the word we end up selecting for them
}
-- Sometimes we can match on multiple words, so we need to know what to render for draw_word_progress
-- The current_word.buffer is the only buffer we need though
-- a_matched_word = { final = nil, render_idx = "", }
local current_matched_words = {}
local function reset_current_word()
    current_word.final = nil
    current_word.buffer = ""
    current_word.render_idx = ""
    current_matched_words = {}
end

function typing.reset_words()
    active_words = {}
    typing.update_word("left", "")
    typing.update_word("right", "")
    typing.update_word("center", "")
    typing.update_word("disc", "")
    reset_current_word()
end

function typing.update(dt)
    -- TK: I don't know how I feel about the way this function is written, versus one
    --     meant to update the bounds (or moving on char move) but no game state so here we are
    calc_word_bounds(rendered_words["left"], "left")
    calc_word_bounds(rendered_words["right"], "right")
    calc_word_bounds(rendered_words["center"], "center")
    typing.disc_update_check(dt)
end

function typing.on_key_press(key)
    -- If we're typing and we've assigned a word, match on that wor
    if  #current_word.buffer ~= 0 and current_word.final ~= nil then
        local next_buffer = current_word.buffer .. key
        -- Match the substr by length with the typed word
        if current_word.final:sub(1, #next_buffer) == next_buffer then
            sounds.play_click()
            current_word.buffer = next_buffer
        else
            -- Do nothing
            -- TODO: Visual indicator we are wrong
        end

        -- Trigger new word, etc. when we get the word correct
        if current_word.buffer == current_word.final then
            sounds.play_ding()
            if current_word.render_idx ~= "center" then
                -- TODO: Randomize positioning just a little bit, also randomize word?
                callouts.add_callout("NICE!", char.x-10, char.y-25, callouts.colors.green)
            end

            -- TODO: More robust movement here depending on curr direction, etc.
            if current_word.render_idx == "left" or
               current_word.render_idx == "right" or
               current_word.render_idx == "center" then
                typing.update_word(current_word.render_idx, current_word.final)
                char.move(current_word.render_idx, false)
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
        local matched_words = {} -- Eventually is just 1 word
        for active_word, _ in pairs(active_words) do
            if active_word:sub(1, #next_buffer) == next_buffer then
                table.insert(matched_words, active_word)
                sounds.play_click()
            end
        end

        -- If we find one match, we have our final word
        -- If we have mult matches, keep building the buffer. Otherwise, don't append to buffer
        if #matched_words == 1 then
            local matched_word = matched_words[1]
            current_word.buffer = next_buffer
            current_word.final = matched_word
            current_word.render_idx = active_words[matched_word]
            current_matched_words = {current_word} -- Reset these

            -- In the case of very similar words, e.g. "chain" and "chair", we don't want an extra keypress to be necessary
            -- And yes, I'm just forcing an extra keypress to trigger the check above. Because why not.
            if current_word.buffer == current_word.final then
                typing.on_key_press("enter")
            end
        elseif #matched_words > 1 then
            current_matched_words = {} -- Clear prev matches in case
            current_word.buffer = next_buffer
            -- We want to highlight all the words, so we'll make some second list to render it OK
            -- instead of multiple "current words" because I don't like that anyway
            for _, single_matched_word in ipairs(matched_words) do
                table.insert(current_matched_words, {
                    final = single_matched_word,
                    render_idx = active_words[single_matched_word], 
                })
            end
        end
    end
end

local arrow_offsets = {
    left_x = -50,
    right_x = 66,
    left_right_y = 60,
    center_x = -8,
    center_y = 90,
}
function typing.draw_words()
    love.graphics.setFont(typing.default_font)
    love.graphics.setColor(0, 0, 0)

    if util.get_debug() == true then
        local height = love.graphics.getFont():getAscent()
        love.graphics.setColor(.2, .2, .3, .2)
        love.graphics.rectangle("fill", word_pos.left.origin.x, word_pos.left.origin.y, word_pos.left.width, height)
        love.graphics.rectangle("fill", word_pos.right.origin.x, word_pos.right.origin.y, word_pos.right.width, height)
        love.graphics.rectangle("fill", word_pos.center.origin.x, word_pos.center.origin.y, word_pos.center.width, height)
        love.graphics.setColor(0, 0, 0)
    end

    -- Only render the word if it isn't currently being typed
    -- TODO: I thought we were doing a thing here, but just call the three draws if not. No need for the table.
    local render_dirs = {
        left = function() love.graphics.printf(rendered_words.left, word_pos.left.origin.x, word_pos.left.origin.y, word_pos.left.width, "right") end,
        right = function() love.graphics.printf(rendered_words.right, word_pos.right.origin.x, word_pos.right.origin.y, word_pos.right.width, "left") end,
        center = function() love.graphics.printf(rendered_words.center, word_pos.center.origin.x, word_pos.center.origin.y, word_pos.center.width, "left") end,
    }
    render_dirs["left"]()
    render_dirs["right"]()
    render_dirs["center"]()
    if curr_disc_info ~= nil and current_word.render_idx ~= "disc" then
        -- TODO: Word disc offset value, can also use below... depends on when we get to multiple discs?
        --       Could calc based on word size if I wanted to be real specific I suppose
        love.graphics.print(rendered_words.disc, curr_disc_info.pos.x-20, curr_disc_info.pos.y-30)
    end

    if #current_matched_words > 0 then
        typing.draw_word_progress()
    end

    love.graphics.setColor(1, 1, 1)

    -- Draw direction indicators
    local left_arrow = which_arrow("left")
    local right_arrow = which_arrow("right")
    if current_word.final == nil then
        love.graphics.draw(left_arrow, char.x + arrow_offsets.left_x, char.y + arrow_offsets.left_right_y, 0, 1)
        love.graphics.draw(right_arrow, char.x + arrow_offsets.right_x, char.y + arrow_offsets.left_right_y, 0, 1)
        love.graphics.draw(typing.down_arrow, char.center + arrow_offsets.center_x, char.y + arrow_offsets.center_y, 0, 1)
    elseif current_word.render_idx == "left" then
        love.graphics.setColor(unpack(single_word_color.cursor_box))
        love.graphics.draw(left_arrow, char.x + arrow_offsets.left_x, char.y + arrow_offsets.left_right_y, 0, 1)
    elseif current_word.render_idx == "right" then
        love.graphics.setColor(unpack(single_word_color.cursor_box))
        love.graphics.draw(right_arrow, char.x + arrow_offsets.right_x, char.y + arrow_offsets.left_right_y, 0, 1)
    elseif current_word.render_idx == "center" then
        love.graphics.setColor(unpack(single_word_color.cursor_box))
        love.graphics.draw(typing.down_arrow, char.center + arrow_offsets.center_x, char.y + arrow_offsets.center_y, 0, 1)
    end

    if util.get_debug() == true then
        love.graphics.setColor(0, .5, 1)
        love.graphics.print("DEBUG: " .. current_word.buffer, char.x, char.y-50)
    end

    util.reset_color()
end

-- Either the directional arrow or slanted directional arrow for the given direction
function which_arrow(given_dir)
    -- NOTE: I'm sure I could make this one if statement if I made a chain of tables and keys
    --       But that's overkill
    local move_state = char.get_move_state()
    if given_dir == "right" then
        if move_state.curr_dir == "right" then
            return typing.right_arrow
        else
            return typing.down_right_arrow
        end
    elseif given_dir == "left" then
        if move_state.curr_dir == "left" then
            return typing.left_arrow
        else
            return typing.down_left_arrow
        end
    end
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

-- Draw all words that are potentially being typed
single_word_color = {
    cursor_box = {150/255, 230/255, 160/255},
    buffer = {100/255, 220/255, 120/255},
    char_to_be_typed = {.2, .2, .2},
    remaining = {20/255, 80/255, 35/255},
}
mult_words_color = {
    cursor_box = {254/255, 214/255, 128/255},
    buffer = {230/255, 137/255, 15/255},
    char_to_be_typed = {.2, .2, .2},
    remaining = {44/255, 14/255, 126/255},
}
pink_variant = {
    cursor_box = {255/255, 180/255, 200/255},
    buffer = {255/255, 150/255, 180/255},
    char_to_be_typed = {.2, .2, .2},
    remaining = {120/255, 40/255, 80/255},
}
function typing.draw_word_progress()
    local font = love.graphics.getFont()

    local chosen_color = #current_matched_words == 1 and single_word_color or pink_variant
    for _, matched_word in ipairs(current_matched_words) do
        local curr_word_x = word_pos[matched_word.render_idx].origin.x
        local curr_word_y = word_pos[matched_word.render_idx].origin.y
        -- TODO (this pr?): should all be centered I think, since they're small enough
        local alignment = matched_word.render_idx == "left" and "right" or "left" 
        
        -- TK: I should have thought this out a little more for the disc stuff...
        if matched_word.render_idx == "disc" and curr_disc_info ~= nil then
            curr_word_x = curr_disc_info.pos.x-20
            curr_word_y = curr_disc_info.pos.y-30
        end

        local final_word = matched_word.final
        local typed_len = #current_word.buffer
        local curr_char = final_word:sub(typed_len+1, typed_len+1)
        local remaining_word = final_word:sub(typed_len+2) -- BEWARE OOB...?

        local typed_width = font:getWidth(current_word.buffer)
        local curr_width = font:getWidth(curr_char)
        local char_height = font:getHeight()

        -- Calculate positioning

        -- Draw highlight box
        if typed_len > 0 then
            love.graphics.setColor(unpack(chosen_color.cursor_box))
            love.graphics.rectangle("fill", curr_word_x + typed_width, curr_word_y, curr_width, char_height)
        end
        
        -- Draw the different parts of the word
        love.graphics.setColor(unpack(chosen_color.buffer))
        love.graphics.print(current_word.buffer, curr_word_x, curr_word_y)

        love.graphics.setColor(unpack(chosen_color.char_to_be_typed))
        love.graphics.print(curr_char, curr_word_x + typed_width, curr_word_y)

        love.graphics.setColor(unpack(chosen_color.remaining))
        love.graphics.print(remaining_word, curr_word_x + typed_width + curr_width, curr_word_y)
    end

    util.reset_color()


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
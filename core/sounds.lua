local sounds = {}

function sounds.load()
    sounds.bg_skiing = love.audio.newSource("ski_assets/sound/bg_skiing.mp3", "stream")
    sounds.ding_sound_data = love.audio.newSource("ski_assets/sound/word_complete.mp3", "static")
    sounds.ding_sound_data:setVolume(0.4)

    -- Does not get played! We pull this one apart
    sounds.keyboard_clicks = love.sound.newSoundData("ski_assets/sound/keyboard_clicks.mp3")
    sounds.all_keyboard_clicks = process_click_sounds()

    sounds.start()
end

function sounds.start()
    -- Start background track... this current sound is harsh as hell though
    local enabled = false -- to be replaced with a setting some day
    sounds.bg_skiing:setLooping(true)
    if enabled then sounds.bg_skiing:play() end
end

function sounds.stop()
    sounds.bg_skiing:stop()
end

function sounds.play_ding()
    -- Alternative, if you want multiple of this sound, is to make a pool of sounds...? This feels fine for now
    sounds.ding_sound_data:stop()
    sounds.ding_sound_data:play()
end

function sounds.play_click()
    sounds.all_keyboard_clicks[math.random(#sounds.all_keyboard_clicks)]:play()
end

-- Take apart the sounds programmatically because why not
function process_click_sounds()
    local clip_times = {
        {.099, .149},
        {.217, .305},
        {.454, .540},
        {.947, 1.018},
        {1.266, 1.347},
        {1.365, 1.477},
    }
    local res_clips = {}

    local sample_rate = sounds.keyboard_clicks:getSampleRate()
    local channels = sounds.keyboard_clicks:getChannelCount()
    local bit_depth = sounds.keyboard_clicks:getBitDepth()

    for i, clip_time in ipairs(clip_times) do
        local start_time, end_time = clip_time[1], clip_time[2]
        local start_sample, end_sample = math.floor(start_time * sample_rate), math.floor(end_time * sample_rate)
        local sample_count = end_sample - start_sample
        local clip = love.sound.newSoundData(sample_count, sample_rate, bit_depth, channels)

        -- The new sample is built up akin to how you would built up a string with characters
        for i = 0, sample_count - 1 do
            for c = 1, channels do -- Can have 1 or 2 channels, the loop is just dynamic. I could just choose one though
                clip:setSample(i, c, sounds.keyboard_clicks:getSample(start_sample + i, c))
            end
        end

        res_clips[i] = love.audio.newSource(clip)
    end

    return res_clips
end

return sounds
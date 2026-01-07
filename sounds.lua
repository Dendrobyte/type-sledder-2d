local sounds = {}

function sounds.load()
    sounds.bg_skiing = love.audio.newSource("ski_assets/Sound/bg_skiing.mp3", "stream")
    -- TODO: Experimentation...? Pull this sound apart in code and separate both sounds
    --       This would use love.sound versus love.audio
    sounds.ding_sound_data = love.audio.newSource("ski_assets/Sound/word_complete.mp3", "static")

    sounds.start()
end

function sounds.start()
    -- Start background track
    local enabled = false -- to be replaced with a setting some day
    sounds.bg_skiing:setLooping(true)
    if enabled then sounds.bg_skiing:play() end
end

function sounds.stop()
    sounds.bg_skiing:stop()
end

function sounds.play_ding()
    sounds.ding_sound_data:play()
end

return sounds
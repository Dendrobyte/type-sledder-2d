-- Define the character as a table I guess
local char = {}

function char.load()
    char.name = "Mark"
    char.move_one = love.graphics.newImage("ski_assets/Tiles/tile_0082.png")
    char.move_two = love.graphics.newImage("ski_assets/Tiles/tile_0083.png")
    char.sprite = char.move_two

    char.x = 400
    char.y = 300
end

local count = 0
function char.update_sprite(dt)
    -- TODO: Something something framerate independent?
    --       Figure out using dt for all the 'player movement'

    -- Slowly approaching the top
    -- #### Commenting out just as I work on the typing stuff lol
    -- if count % 2 == 0 then
    --     char.y = char.y - 1
    -- end

    -- Swap sprites back and forth to simulate skiing motions
    if count == 40 then
        char.sprite = char.move_one
    end
    if count == 80 then
        char.sprite = char.move_two
        count = -1
    end
    count = count + 1
end

-- TODO: Function to call when the skiier moves "lanes" and also moves forward a little bit
-- Could probably modify a global var for the char.y-1 line so we don't conflict over frames

return char
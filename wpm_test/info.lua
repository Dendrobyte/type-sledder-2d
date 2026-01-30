local const = require("core.constants")

local info = {}

local bounds = {}
function info.load()
    -- Yoinked from sentence.lua lol
    -- Definitely could refactor this out into the UI file, and drawing within that box with functions
    -- That would be for a large refactor project :P
    info.title_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 48)
    info.text_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 28)
    info.title_color = {.4, .6, 1}
    info.text_color = {.8, .8, .9}

    -- In effect, trying to deefine a box by its padding
    local padding_horizontal = const.PIXEL_W * .1
    local padding_vertical = const.PIXEL_H * .1
    local box_width = const.PIXEL_W - 2*padding_horizontal
    local box_height = const.PIXEL_H - 2*padding_horizontal
    bounds.start_x = padding_horizontal
    bounds.start_y = padding_vertical
    bounds.width = box_width
    bounds.height = box_height
end

local vert_offset = 0
function info.draw_info()
    love.graphics.setColor(unpack(info.title_color))
    love.graphics.setFont(info.title_font)
    love.graphics.printf("How to Play",
        bounds.start_x, bounds.start_y+vert_offset, bounds.width, "center")
    vert_offset = vert_offset + 52
    love.graphics.setColor(unpack(info.text_color))
    love.graphics.setFont(info.text_font)
    love.graphics.printf("Ski down the mountain and score as many points as possible!",
        bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
    vert_offset = vert_offset + 30 
    love.graphics.printf("Your keyboard is your controller. Type the words to your left and right in order to move in that direction.",
        bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
    vert_offset = vert_offset + 30*2 
    love.graphics.printf("Avoid obstacles at all costs! You get extra points at the end for close calls and slaloms.",
        bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
    vert_offset = vert_offset + 30*2


    love.graphics.setColor(unpack(info.title_color))
    love.graphics.setFont(info.title_font)
    vert_offset = vert_offset + 12
    love.graphics.printf("Credits",
        bounds.start_x, bounds.start_y+vert_offset, bounds.width, "center")
    vert_offset = vert_offset + 52
    love.graphics.setColor(unpack(info.text_color))
    love.graphics.setFont(info.text_font)
    love.graphics.printf("Development and Design: Dendrobyte",
        bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
    vert_offset = vert_offset + 36
    love.graphics.printf("Art: Kenney (https://kenney.nl/)\n(except for the discs, which I horribly did in asesprite)",
        bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
    vert_offset = vert_offset + 36*2
    love.graphics.printf("And a very big thank you to the friends and family members who helped test this alpha version out!",
        bounds.start_x, bounds.start_y+vert_offset, bounds.width, "left")
    vert_offset = vert_offset + 36*2

    love.graphics.setColor(unpack(info.title_color))
    love.graphics.printf("Click anywhere, or press any button, to return to the menu",
        bounds.start_x, bounds.start_y+vert_offset, bounds.width, "center")

    vert_offset = 0
end

return info
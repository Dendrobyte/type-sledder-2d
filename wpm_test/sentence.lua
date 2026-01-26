local const = require("core.constants")
local util = require("core.util")

local sentence = {}

local sentence_box = {}
function sentence.load()
    -- In effect, trying to deefine a box by its padding
    local padding_horizontal = const.PIXEL_W * .10
    local padding_vertical = const.PIXEL_H * .7 -- idfk lol
    local box_width = const.PIXEL_W - 2*padding_horizontal
    local box_height = const.PIXEL_H - 2*padding_horizontal
    sentence_box.start_x = padding_horizontal
    sentence_box.start_y = padding_vertical
    sentence_box.width = box_width
    sentence_box.height = box_height
end

function sentence.draw_sentence()
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("line", sentence_box.start_x, sentence_box.start_y, sentence_box.width, sentence_box.height)
    util.reset_color()
    love.graphics.printf("Wait this isn't functional ;-; Exit/refresh to go back", sentence_box.start_x, sentence_box.start_y, sentence_box.width, "left")
end

return sentence
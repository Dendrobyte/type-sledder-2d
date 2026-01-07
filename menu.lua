local util = require("util")

local menu = {}
menu.pre_game = {}
menu.end_game = {}

function menu.load()
    menu.default_font = love.graphics.newFont(16)
    menu.title_font = love.graphics.newFont("ski_assets/simply_mono/SimplyMono-Bold.ttf", 48)
    menu.subtitle_font = love.graphics.newFont("ski_assets/simply_mono/SimplyMono-Book.ttf", 32)
    menu.start_button = {
        x = 200,
        y = 300,
        w = 400,
        h = 40,
    }
end

-- We leave it to the caller to change the graphics
function menu_button(text, x, y, width)
    love.graphics.rectangle("fill",
        menu.start_button.x,
        menu.start_button.y,
        menu.start_button.w,
        menu.start_button.h
    )

    love.graphics.setFont(menu.subtitle_font)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(text, 200, 300, 400, 'center')
    util.reset_color()
end

function menu.pre_game.draw_screen()
    -- TODO: Draw basic set of tiles, change this to black text too
    love.graphics.setFont(menu.title_font)
    love.graphics.printf("TYPE SLEDDER", 0, 200, 800, 'center')

    menu_button("Start Game", 200, 300, 400)

    util.reset_color()
end

function menu.end_game.draw_screen()
        love.graphics.setFont(menu.title_font)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("GAME OVER", 0, 200, 800, 'center')
        util.reset_color()
        menu_button("Try Again?", 200, 300, 400)
end

-- Where 'button_type' is a string, e.g. for now menu[button_type] is chill
function menu.is_button_pressed(button_type, x, y)
    -- Check if it is within button area, and start game if so
    button_x = menu[button_type].x
    button_y = menu[button_type].y
    button_w = menu[button_type].w
    button_h = menu[button_type].h
    if x > button_x and x < button_x + button_w and y > button_y and y < button_y + button_h then
        return true
    else
        return false
    end
end

return menu
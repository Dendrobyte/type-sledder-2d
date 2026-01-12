local util = require("util")
local slope = require("environment.slope") -- Another instance where some global access for these fields would be good
local typing = require("typing") -- Global state would be real nice

local menu = {}
menu.pre_game = {}
menu.end_game = {}

function menu.load()
    menu.default_font = love.graphics.newFont(16)
    menu.title_font = love.graphics.newFont("ski_assets/simply_mono/SimplyMono-Bold.ttf", 48)
    menu.subtitle_font = love.graphics.newFont("ski_assets/simply_mono/SimplyMono-Book.ttf", 32)
    menu.small_font = love.graphics.newFont("ski_assets/simply_mono/SimplyMono-Book.ttf", 16)
    menu.start_button = {
        x = 200,
        y = 300,
        w = 400,
        h = 40,
    }
    menu.speed_decr = {
        x = 300,
        y = 450,
        w = 40,
        h = 40,
    }
    menu.speed_incr = {
        x = 450,
        y = 450,
        w = 40,
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

    -- (Temporary) speed buttons and notes. Replace when we do settings page.
    -- Then again, ideally the whole menu gets a task
    love.graphics.rectangle("fill",
        menu.speed_decr.x,
        menu.speed_decr.y,
        menu.speed_decr.w,
        menu.speed_decr.h
    )
    love.graphics.rectangle("fill",
        menu.speed_incr.x,
        menu.speed_incr.y,
        menu.speed_incr.w,
        menu.speed_incr.h
    )
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("+", menu.speed_incr.x, menu.speed_incr.y, 40, 'center')
    love.graphics.printf("-", menu.speed_decr.x, menu.speed_decr.y, 40, 'center')
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Set your starting speed", 175, 400)
    love.graphics.print(slope.get_scroll_speed(), (menu.speed_incr.x + menu.speed_decr.x) / 2 - 10, menu.speed_incr.y)
    love.graphics.setFont(menu.default_font)
    love.graphics.printf("- Press ENTER or click 'start game' to start\n- Every successful word increases speed by 5\n- Points scored increase the higher your speed goes \n- I would love to hear what your starting speed is and points you end up with. That way I can tune difficulties later on :)", 100, 500, 700, 'left')

    util.reset_color()
end

function menu.end_game.draw_screen()
    love.graphics.setColor(0, .8, 1, .8)
    love.graphics.rectangle("fill", 100, 100, 600, 400)
    love.graphics.setFont(menu.title_font)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("GAME OVER", 0, 200, 800, 'center')
    love.graphics.setFont(menu.small_font)
    love.graphics.printf("Points: " .. typing.points.get_points(), 200, 350, 800, 'left')
    love.graphics.printf("Distance: " .. slope.points.get_distance(), 200, 370, 800, 'left')
    love.graphics.printf("Final Score: " .. typing.points.get_points() + slope.points.get_distance(), 200, 390, 800, 'left')
    util.reset_color()
    -- The x/y don't... do anything rn...
    menu_button("Try Again?", 200, 800, 400)
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
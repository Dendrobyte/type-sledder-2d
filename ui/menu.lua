local util = require("core.util")
local const = require("core.constants")
local slope = require("environment.slope") -- Another instance where some global access for these fields would be good
local typing = require("core.typing") -- Global state would be real nice
local points = require("core.points") -- Points are a good example of a general state

local menu = {}
menu.pre_game = {}
menu.end_game = {}

function menu.load()
    menu.default_font = love.graphics.newFont(16)
    menu.title_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 48)
    menu.subtitle_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 32)
    menu.big_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 24)
    menu.small_font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 16)
    menu.start_speed = 5
    menu.start_button = {
        x = 200,
        y = 300,
        w = 400,
        h = 40,
    }
    menu.speed_decr = {
        x = 400,
        y = 350,
        w = const.TILE_WIDTH,
        h = const.TILE_WIDTH,
    }
    menu.speed_incr = {
        x = 475,
        y = 350,
        w = const.TILE_WIDTH,
        h = const.TILE_WIDTH,
    }
    menu.wpm_test_button = {
        x = 300,
        y = 400,
        w = 200,
        h = 40,
    }
    menu.try_again_button = {
        x = 300,
        y = 530,
        w = 200,
        h = 36,
    }

    menu.plus = love.graphics.newImage("ski_assets/Tiles/tile_0126.png")
    menu.minus = love.graphics.newImage("ski_assets/Tiles/tile_0127.png")
    menu.snowman = love.graphics.newImage("ski_assets/Tiles/tile_0069.png")
    menu.ski_trail = love.graphics.newImage("ski_assets/Tiles/tile_0058.png")
    menu.flag = love.graphics.newImage("ski_assets/Tiles/tile_0009.png")
    menu.rock = love.graphics.newImage("ski_assets/Tiles/tile_0081.png")
    menu.yeti = love.graphics.newImage("ski_assets/Tiles/tile_0080.png")

end

-- We leave it to the caller to change the graphics
function menu_button(button_type, text, font)
    love.graphics.rectangle("fill",
        menu[button_type].x,
        menu[button_type].y,
        menu[button_type].w,
        menu[button_type].h
    )

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(font)
    love.graphics.printf(text, menu[button_type].x, menu[button_type].y, menu[button_type].w, 'center')
    util.reset_color()
end

function menu.pre_game.draw_screen()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(menu.title_font)
    love.graphics.printf("TYPE SKIIER", 0, 230, 800, 'center')
    util.reset_color()

    menu_button("start_button", "Start Game", menu.subtitle_font)

    love.graphics.draw(menu.minus, menu.speed_decr.x, menu.speed_decr.y, 0, 2)
    love.graphics.draw(menu.plus, menu.speed_incr.x, menu.speed_incr.y, 0, 2)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(menu.big_font)
    -- TODO: Consider using printf with some bounding box... See "don't know your speed?"
    love.graphics.print("Start Speed:", 200, 350)

    love.graphics.print(menu.start_speed, 450, 350) -- TODO: Definitely use the font images for this part
    love.graphics.setFont(menu.default_font)

    love.graphics.setColor(1, 1, 1)
    menu_button("wpm_test_button", "Speed Test", menu.big_font)
    -- NOTE: I wonder if it's better to just not have this?
    -- love.graphics.setColor(0, 0, 0)
    -- love.graphics.setFont(menu.default_font)
    -- love.graphics.printf("Don't know your typing speed?", 200, 450, 400, 'center')

    util.reset_color()
end

function menu.end_game.draw_screen()
    -- Background box
    local y_offset = 100

    love.graphics.setFont(menu.title_font)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Your Score", 0, 40, const.PIXEL_W, 'center')
    -- TODO: Custom messages based on what happens
    -- love.graphics.printf("You crashed! Hopefully no ACTL tear...")

    love.graphics.setFont(menu.title_font)
    menu.end_game.draw_bar(menu.snowman, "Points", points.get_points(), y_offset, 1)
    y_offset = y_offset + menu.end_game.bar.h
    menu.end_game.draw_bar(menu.ski_trail, "Distance", points.get_distance(), y_offset, 2, "m")
    y_offset = y_offset + menu.end_game.bar.h
    menu.end_game.draw_bar(menu.flag, "Slaloms", "soon", y_offset, 1, " maybe :)")
    y_offset = y_offset + menu.end_game.bar.h
    menu.end_game.draw_bar(menu.rock, "Close Calls", points.get_close_calls(), y_offset, 2, " x " .. points.close_calls_mult())
    y_offset = y_offset + menu.end_game.bar.h
    menu.end_game.draw_bar(menu.yeti, "Total Points", points.calc_total_score(), y_offset, 2)
    y_offset = y_offset + menu.end_game.bar.h
    
    -- Uses the same position and functionality as the start button
    love.graphics.setColor(.4, .7, .9)
    menu_button("try_again_button", "Try Again?", menu.subtitle_font)

    util.reset_color()
end

menu.end_game.bar = {
    start_x = const.PIXEL_W / 8,
    w = const.PIXEL_W - (const.PIXEL_W / 4),
    h = 80,
    color = {
        [1] = {.2, .8, 1},
        [2] = {.6, .8, 1},
    },
}
function menu.end_game.draw_bar(icon, title, count, y_offset, color_num, addtl_str)
    local addtl_str = addtl_str or ""

    love.graphics.setColor(unpack(menu.end_game.bar.color[color_num]))
    
    love.graphics.rectangle("fill", menu.end_game.bar.start_x, y_offset, menu.end_game.bar.w, menu.end_game.bar.h)

    local padding = 15
    love.graphics.setColor(.5, .5, .9, .6)
    love.graphics.draw(icon, menu.end_game.bar.start_x+padding, y_offset+padding*1.5, 0, 2)
    love.graphics.setColor(.05, .05, .6, .6)
    love.graphics.printf(title, menu.end_game.bar.start_x+padding+const.TILE_WIDTH*1.5, y_offset+padding, menu.end_game.bar.w, "left")
    love.graphics.printf(count .. addtl_str, menu.end_game.bar.start_x, y_offset+padding, menu.end_game.bar.w-padding, "right")
end

-- Where 'button_type' is a string, e.g. for now menu[button_type] is chill
function menu.is_button_pressed(button_type, x, y)
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

-- Update menu speed num and the scroll speed accordingly
-- Used AI to generate this range with some vague input, feels fine
local speed_conversion = {
    [1] = 40,   -- beginner, hunt-and-peck
    [2] = 55,
    [3] = 70,   -- average typist (~40 wpm)
    [4] = 90,
    [5] = 115,  -- above average (~60-70 wpm)
    [6] = 145,
    [7] = 180,  -- fast typist (~100 wpm)
    [8] = 220,
    [9] = 280,  -- very fast (~130-140 wpm)
    [10] = 350, -- for you and other speed demons
}
function menu.speed_change(dir)
    if dir == "incr" then
        menu.start_speed = math.max(1, math.min(menu.start_speed + 1, 10))
    elseif dir == "decr" then
        menu.start_speed = math.max(1, math.min(menu.start_speed - 1, 10))
    end

    slope.set_init_scroll_speed(speed_conversion[menu.start_speed])
end

return menu
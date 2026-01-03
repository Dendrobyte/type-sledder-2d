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

function menu.pre_game.draw_screen()
    -- TODO: Draw basic set of tiles, change this to black text too
    love.graphics.setFont(menu.title_font)
    love.graphics.printf("TYPE SLEDDER", 0, 200, 800, 'center')

    -- Button

    love.graphics.rectangle("fill",
        menu.start_button.x,
        menu.start_button.y,
        menu.start_button.w,
        menu.start_button.h
    )
    love.graphics.setFont(menu.subtitle_font)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Start Game", 200, 300, 400, 'center')

    -- TODO: Create and set some default draw state, because setColor and setFont applies to the whole graphics library.
    --       Makes sense I suppose
    love.graphics.setColor(1, 1, 1)
end

-- NOTE: If there are multiple buttons, I could pass in a string that maps 'em so I don't have to make so many functions
function menu.pre_game.is_button_pressed(x, y)
    -- Check if it is within button area, and start game if so
    button_x = menu.start_button.x
    button_y = menu.start_button.y
    button_w = menu.start_button.w
    button_h = menu.start_button.h
    if x > button_x and x < button_x + button_w and y > button_y and y < button_y + button_h then
        return true
    else
        return false
    end
end

return menu
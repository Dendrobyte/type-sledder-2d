local menu = {}
menu.pre_game = {}
menu.end_game = {}

function menu.load()
    menu.default_font = love.graphics.newFont(16)
    menu.font = love.graphics.newFont("ski_assets/simply_mono/SimplyMono-Bold.ttf", 48)
end

function menu.pre_game.draw_screen()
    love.graphics.setFont(menu.font)
    -- constant for screen width? but i don't see that changing rn
    love.graphics.printf("TYPE SLEDDER", 0, 200, 800, 'center')
end

return menu
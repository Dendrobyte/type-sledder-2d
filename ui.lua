local typing = require("typing")

-- The UI should never be accessed elsewhere, but instead access state from within
local ui = {}

-- I don't think I need a proper load function?
ui.font = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 36)
ui.loc = {
    x = 50,
    y = 50,
    align = 'left',
}

-- Update fields from state
-- TODO: Most convincing argument to have a global game state file right here
function ui.update_ui(dt)
    ui.current_points = typing.points.get_points()
end

function ui.draw_ui()
    love.graphics.setFont(ui.font)
    love.graphics.setColor(.2, .2, .4)
    love.graphics.rectangle("fill", ui.loc.x-5, ui.loc.y-2, 80, 40)
    love.graphics.setColor(250/255, 233/255, 88/255)
    love.graphics.print(ui.current_points, ui.loc.x, ui.loc.y)
    love.graphics.setColor(1, 1, 1)
end

return ui
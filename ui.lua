local typing = require("typing")
local slope = require("environment.slope")

-- The UI should never be accessed elsewhere, but instead access state from within
local ui = {}

-- I don't think I need a proper load function?
ui.font_24 = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 24)
ui.font_36 = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 36)
ui.loc = {
    x = 50,
    y = 50,
    align = 'left',
}

-- Update fields from state
-- TODO: Most convincing argument to have a global game state file right here
function ui.update_ui(dt)
    ui.current_points = typing.points.get_points()
    ui.current_distance = slope.points.get_distance()
end

function ui.draw_ui()
    love.graphics.setColor(.2, .2, .4)
    love.graphics.rectangle("fill", ui.loc.x-5, ui.loc.y-2, 80, 80)
    -- Draw distance
    love.graphics.setColor(250/255, 233/255, 88/255)
    love.graphics.setFont(ui.font_36)
    love.graphics.print(ui.current_distance, ui.loc.x, ui.loc.y)

    -- Draw points
    love.graphics.setFont(ui.font_24)
    love.graphics.setColor(250/255, 233/255, 88/255)
    love.graphics.print(ui.current_points, ui.loc.x, ui.loc.y+40)
    love.graphics.setColor(1, 1, 1)
end

return ui
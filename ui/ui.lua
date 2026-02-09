local points = require("core.points")
local callouts = require("ui.callouts")
local menu = require("ui.menu") -- Colors
local const = require("core.constants")
local util = require("core.util")

local slope = require("environment.slope")

-- The UI should never be accessed elsewhere, but instead access state from within
local ui = {}

-- I don't think I need a proper load function?
ui.font_24 = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 24)
ui.font_36 = love.graphics.newFont("ski_assets/ithaca/Ithaca.ttf", 36)
ui.loc = {
    x = const.PIXEL_W - 25 - 120, -- subtract width
    y = 25,
    width = 120,
    height = 72,
    align = 'right',
}
ui.text_color = {
    pale_cyan = {0.95, 1, 1},
    dark_navy = {0.1, 0.15, 0.3},
}    

-- Update fields from state
-- TODO: Most convincing argument to have a global game state file right here
function ui.update_ui(dt)
    ui.current_points = points.get_points()
    ui.current_distance = points.get_distance()

    callouts.update(dt)
end

function ui.draw_ui()
    -- Draw callouts
    callouts.draw_callouts()

    -- Background box for stats
    love.graphics.setColor(unpack(menu.end_game.bar.color[1]))
    love.graphics.rectangle("fill", ui.loc.x, ui.loc.y-2, ui.loc.width, ui.loc.height, math.pi*2, math.pi*2)
    -- Draw distance
    love.graphics.setColor(unpack(ui.text_color.pale_cyan))
    love.graphics.setFont(ui.font_36)
    love.graphics.printf(ui.current_distance .. "m", ui.loc.x-10, ui.loc.y, ui.loc.width, ui.loc.align)

    -- Draw points
    love.graphics.setFont(ui.font_24)
    love.graphics.setColor(unpack(ui.text_color.dark_navy))
    love.graphics.printf(ui.current_points, ui.loc.x-10, ui.loc.y+40, ui.loc.width, ui.loc.align)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Slope grid head: " .. slope.get_grid_head(), 10, 10)

    util.reset_color()
end

return ui
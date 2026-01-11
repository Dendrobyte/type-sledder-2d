local typing = require("typing")

-- The UI should never be accessed elsewhere, but instead access state from within
local ui = {}

-- Update fields from state
-- TODO: Most convincing argument to have a global game state file right here
function ui.update_ui(dt)
    ui.current_points = typing.points.get_points()
end

function ui.draw_ui()

end

return ui
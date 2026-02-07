local callouts = {}

callouts.colors = {
    green = {0, 1, 0},
    purple = {.5, 0, .5},
    red = {.8, .2, .1},
    orange = {0.85, 0.4, 0.15},
}

local floating_messages = {}
function callouts.update(dt)
    for i = #floating_messages, 1, -1 do
        local msg = floating_messages[i]
        msg.age = msg.age + dt
        msg.y = msg.y - 10*dt
        if msg.age > 2 then
            table.remove(floating_messages, i)
        end
    end
end

function callouts.draw_callouts()
    for _, msg in ipairs(floating_messages) do
        local alpha = 1 - (msg.age / 2) -- 2 is the same elsewhere, could do msg.lifetime
        local r, g, b = unpack(msg.color)
        love.graphics.setColor(r, g, b, alpha)
        love.graphics.print(msg.text, msg.x, msg.y)
    end

    love.graphics.setColor(1, 1, 1)
end

function callouts.add_callout(text, x, y, color)
    table.insert(floating_messages, {
        text = text, -- TODO: Randomize
        age = 0,
        x = x,
        y = y,
        color = color,
    })
end

function callouts.reset_callouts()
    floating_messages = {}
end

return callouts 
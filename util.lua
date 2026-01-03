local util = {}

function util.print_matrix(matrix)

    for i, row in ipairs(matrix) do
        io.write("[")
        for j, col_val in ipairs(row) do
            io.write(col_val .. ", ")
        end
        print("]")
    end

end

-- Debug grid
function util.debug_grid(spacing)
    spacing = spacing or 50

    local w, h = love.graphics.getDimensions()

    -- Save current draw state
    local r, g, b, a = love.graphics.getColor()
    local lineW = love.graphics.getLineWidth()
    local font = love.graphics.getFont()

    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 0.25)

    -- Vertical lines
    for x = 0, w, spacing do
        love.graphics.line(x, 0, x, h)
    end

    -- Horizontal lines
    for y = 0, h, spacing do
        love.graphics.line(0, y, w, y)
    end

    -- Optional coordinate labels (every grid intersection)
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.setFont(love.graphics.newFont(8)) -- simple debug font
    for x = 0, w, spacing do
        for y = 0, h, spacing do
            love.graphics.print(x .. "," .. y, x + 2, y + 2)
        end
    end

    -- Restore draw state
    love.graphics.setFont(font)
    love.graphics.setLineWidth(lineW)
    love.graphics.setColor(r, g, b, a)
end

return util
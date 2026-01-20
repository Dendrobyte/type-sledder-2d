-- Utils to generate turns based on a given row
-- NOTE: Turn into procgen.lua or something?
-- NOTE: Using consts would make this more readable, even if they don't really change

local turns = {}

function turns.sharp_turn_right(prev_row)
    new_row = {}
    local i = 1
    while i <= #prev_row do
        if prev_row[i] == 3 then
            new_row[i] = 5
            new_row[i+1] = 6
            i = i + 2
        elseif prev_row[i] == 4 then
            new_row[i] = 11
            new_row[i+1] = 12
            i = i + 2
        else
            new_row[i] = prev_row[i]
            i = i + 1
        end
    end

    return new_row
end

-- We detract one since we modify to the left
function turns.sharp_turn_left(prev_row)
    new_row = {}
    local i = 1
    while i <= #prev_row do
        if prev_row[i] == 3 then
            new_row[i] = 9
            new_row[i-1] = 10
        elseif prev_row[i] == 4 then
            new_row[i] = 7
            new_row[i-1] = 8
        else
            new_row[i] = prev_row[i]
        end

        i = i + 1
    end

    return new_row
end

return turns
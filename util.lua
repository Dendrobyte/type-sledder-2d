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

return util
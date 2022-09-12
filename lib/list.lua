local listHelpers = {}

function listHelpers.indexOf(table, item)
    for index, v in ipairs(table) do
        if v == item then
            return index
        end
    end
end

return listHelpers
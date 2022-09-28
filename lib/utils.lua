local utils = {}

function utils.remove_item_from_table(t, table_item)
    for i, v in ipairs(t) do
        if v == table_item then
            table.remove(t, i)
            return
        end
    end
end

return utils
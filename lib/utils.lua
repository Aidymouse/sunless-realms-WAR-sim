local utils = {}

---@param table table Table to search
---@param item any Item to find index of
---@return integer index First index of item. -1 if item is not present
function utils.indexOf(table, item)
    for index, v in ipairs(table) do
        if v == item then
            return index
        end
    end
    return -1
end

function utils.get_random_from_list(table)
    return table[love.math.random(1, #table)]
end

function utils.remove_item_from_table(t, table_item)
    for i, v in ipairs(t) do
        if v == table_item then
            table.remove(t, i)
            return
        end
    end
end

return utils

local Gui_manager = {
    active_guis = {}
}

Gui_manager.marked_for_deletion = {}

Gui_manager.GUIS = {
    --movement = require("ui.ui_movement"),

    --tactics = require("ui.ui_tactics"),
    --tactics_unit = require("ui.ui_tactics_unit"),

}

function Gui_manager.register_gui(gui_name, gui)
    Gui_manager.GUIS[gui_name] = gui
end

function Gui_manager.set_gui(gui_name)
    while #Gui_manager.active_guis > 0 do
        table.remove(Gui_manager.active_guis)
    end
    Gui_manager.add_gui(gui_name)
    --print(#Gui_manager.active_guis)
end

function Gui_manager.add_gui(gui_name, init_data)

    if init_data ~= nil then
        Gui_manager.GUIS[gui_name].init(init_data)
    end

    table.insert(Gui_manager.active_guis, gui_name)
end

function Gui_manager.mark_for_deletion(gui_name)
    table.insert(Gui_manager.marked_for_deletion, gui_name)
end

function Gui_manager.delete_all_marked()

    --print(#Gui_manager.marked_for_deletion)


    while #Gui_manager.marked_for_deletion > 0 do
        local gui_name = table.remove(Gui_manager.marked_for_deletion)
        Gui_manager.remove_gui(gui_name)
    end

end

function Gui_manager.remove_gui(gui_name)


    for index = #Gui_manager.active_guis, 0, -1 do

        if Gui_manager.active_guis[index] == gui_name then
            local p = table.remove(Gui_manager.active_guis, index)
        end


    end
end

function Gui_manager.update(dt)
    for _, gui_name in ipairs(Gui_manager.active_guis) do
        Gui_manager.GUIS[gui_name]:update(dt)
        if Gui_manager.GUIS[gui_name].match_state ~= nil then Gui_manager.GUIS[gui_name].match_state() end
    end

    --print(Gui_manager.GUIS["tactics_unit"])
end

function Gui_manager.draw()
    for _, gui_name in ipairs(Gui_manager.active_guis) do
        Gui_manager.GUIS[gui_name]:draw()
    end

end

function Gui_manager.keypressed(key)
    for _, gui_name in ipairs(Gui_manager.active_guis) do
        Gui_manager.GUIS[gui_name]:keypress(key)
    end


end

function Gui_manager.textinput(key)
    for _, gui_name in ipairs(Gui_manager.active_guis) do
        Gui_manager.GUIS[gui_name]:textinput(key)
    end


end

function Gui_manager.mousepressed(x, y, button)
    for _, gui_name in ipairs(Gui_manager.active_guis) do
        Gui_manager.GUIS[gui_name]:mousepress(x, y, button)
    end


end

function Gui_manager.mousereleased(x, y, button)
    for _, gui_name in ipairs(Gui_manager.active_guis) do
        Gui_manager.GUIS[gui_name]:mouserelease(x, y, button)
    end


end

function Gui_manager.wheelmoved(x, y)
    for _, gui_name in ipairs(Gui_manager.active_guis) do
        Gui_manager.GUIS[gui_name]:mousewheel(x, y)
    end


end

return Gui_manager

local Gui_manager = {
    active_guis = {}
}

Gui_manager.GUIS = {
    movement = require("ui.ui_movement"),

    tactics = require("ui.ui_tactics"),
    tactics_unit = require("ui.ui_tactics_unit"),

}

function Gui_manager.set_gui(gui_name)
    while #Gui_manager.active_guis > 0 do
        table.remove(Gui_manager.active_guis)
    end
    Gui_manager.add_gui(gui_name)
end

function Gui_manager.add_gui(gui_name, init_data)

    if init_data ~= nil then
        Gui_manager.GUIS[gui_name].init(init_data)
    end

    table.insert(Gui_manager.active_guis, Gui_manager.GUIS[gui_name])
end

function Gui_manager.update(dt)
    for _, gui in ipairs(Gui_manager.active_guis) do
        gui:update(dt)
    end
end

function Gui_manager.draw()
    for _, gui in ipairs(Gui_manager.active_guis) do
        gui:draw()
    end
end

function Gui_manager.keypressed(key)
    for _, gui in ipairs(Gui_manager.active_guis) do
        gui:keypress(key)
    end

end

function Gui_manager.textinput(key)
    for _, gui in ipairs(Gui_manager.active_guis) do
        gui:textinput(key)
    end

end

function Gui_manager.mousepressed(x, y, button)
    for _, gui in ipairs(Gui_manager.active_guis) do
        gui:mousepress(x, y, button)
    end

end

function Gui_manager.mousereleased(x, y, button)
    for _, gui in ipairs(Gui_manager.active_guis) do
        gui:mouserelease(x, y, button)
    end

end

function Gui_manager.wheelmoved(x, y)
    for _, gui in ipairs(Gui_manager.active_guis) do
        gui:mousewheel(x, y)
    end

end

return Gui_manager
local gspot = require("lib.gspot")
local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local phase_tactics = require("phases.tactics")

local gui_tactics = require("ui.ui_tactics")

local gui_tactics_unit = gspot()
local guiUnit = gui_tactics_unit.style.unit

local BUTTONWIDTH = guiUnit*5
local BUTTONHEIGHT = guiUnit*3




local button_fight = gui_tactics_unit:button("Fight", {w=BUTTONWIDTH, h=BUTTONHEIGHT})
button_fight.click = function() phase_tactics.state.currentlyDeciding = TACTICS.FIGHT end

local button_help = gui_tactics_unit:button("Help", { w = BUTTONWIDTH, h = BUTTONHEIGHT })
button_help.click = function() phase_tactics.state.currentlyDeciding = TACTICS.HELP end

local button_hinder = gui_tactics_unit:button("Hinder", { w = BUTTONWIDTH, h = BUTTONHEIGHT })
button_hinder.click = function() phase_tactics.state.currentlyDeciding = TACTICS.HINDER end

local button_done = gui_tactics_unit:button("Done", { w = BUTTONWIDTH, h = BUTTONHEIGHT })
button_done.click = function()
    phase_tactics.state.currentlyDeciding = nil
    phase_tactics.state.selected_unit = nil
    Gui_manager.set_gui("tactics")
end

local function updateButtonCoords(selected_unit)

    local bottomCenterXY = HL_convert.axialToWorld(selected_unit.occupiedTileCoords)

    -- Since this is GUI code we need to manually adjust for camera offset
    button_fight.pos.x = bottomCenterXY.x - BUTTONWIDTH / 2 + CAMERA.offsetX
    button_fight.pos.y = bottomCenterXY.y + 10 + CAMERA.offsetY

    button_help.pos.x = bottomCenterXY.x - BUTTONWIDTH / 2 - BUTTONWIDTH - 10 + CAMERA.offsetX
    button_help.pos.y = bottomCenterXY.y + 10 + CAMERA.offsetY

    button_hinder.pos.x = bottomCenterXY.x - BUTTONWIDTH / 2 + BUTTONWIDTH + 10 + CAMERA.offsetX
    button_hinder.pos.y = bottomCenterXY.y + 10 + CAMERA.offsetY

    button_done.pos.x = bottomCenterXY.x - BUTTONWIDTH / 2 + CAMERA.offsetX
    button_done.pos.y = bottomCenterXY.y + 10 + BUTTONHEIGHT + 10 + CAMERA.offsetY

end


function gui_tactics_unit.init(init_data)
    updateButtonCoords(init_data.unit)
end



return gui_tactics_unit

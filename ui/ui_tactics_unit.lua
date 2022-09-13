local gspot = require("lib.gspot")
local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions

local gui_tactics = require("ui.ui_tactics")

local gui_tactics_unit = gspot()
local guiUnit = gui_tactics_unit.style.unit

local BUTTONWIDTH = guiUnit*5
local BUTTONHEIGHT = guiUnit*3




local button_fight = gui_tactics_unit:button("Fight", {w=BUTTONWIDTH, h=BUTTONHEIGHT})
button_fight.click = function() STATE.TACTICS.currentlyDeciding = tactics.FIGHT end

local button_help = gui_tactics_unit:button("Help", { w = BUTTONWIDTH, h = BUTTONHEIGHT })

button_help.click = function() STATE.TACTICS.currentlyDeciding = tactics.HELP end

local button_hinder = gui_tactics_unit:button("Hinder", { w = BUTTONWIDTH, h = BUTTONHEIGHT })

button_hinder.click = function() STATE.TACTICS.currentlyDeciding = tactics.HINDER end

local button_done = gui_tactics_unit:button("Done", { w = BUTTONWIDTH, h = BUTTONHEIGHT })

button_done.click = function()
    STATE.TACTICS.currentlyDeciding = nil
    STATE.TACTICS.currentlySelectedUnit = nil
    STATE.activeGuis = {gui_tactics}
end

function gui_tactics_unit.updateButtonCoords(selectedUnit)

    local bottomCenterXY = HL_convert.axialToWorld(selectedUnit.occupiedTileCoords)

    -- Since this is GUI code we need to manually adjust for camera offset
    button_fight.pos.x = bottomCenterXY.x - BUTTONWIDTH/2 + CAMERA.offsetX
    button_fight.pos.y = bottomCenterXY.y + 10 + CAMERA.offsetY

    button_help.pos.x = bottomCenterXY.x - BUTTONWIDTH / 2 - BUTTONWIDTH - 10 + CAMERA.offsetX
    button_help.pos.y = bottomCenterXY.y + 10 + CAMERA.offsetY

    button_hinder.pos.x = bottomCenterXY.x - BUTTONWIDTH / 2 + BUTTONWIDTH + 10 + CAMERA.offsetX
    button_hinder.pos.y = bottomCenterXY.y + 10 + CAMERA.offsetY

    button_done.pos.x = bottomCenterXY.x - BUTTONWIDTH/2 + CAMERA.offsetX
    button_done.pos.y = bottomCenterXY.y + 10 + BUTTONHEIGHT + 10 + CAMERA.offsetY

end


return gui_tactics_unit

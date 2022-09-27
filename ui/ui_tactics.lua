local gspot = require("lib.gspot")

local gui_tactics = gspot()

local phase_tactics = require("phases.tactics")

local Hexlib = require('lib.hexlib')
local HL_convert = Hexlib.coordConversions



local nextButton = gui_tactics:button("Finish Tactics", { x = 150, y = 0, w = 120, h = gspot.style.unit * 2 })
nextButton.click = function(this)

    phase_tactics.state.actingPlayerIndex = phase_tactics.state.actingPlayerIndex + 1

    if phase_tactics.state.actingPlayerIndex > #PLAYERS then
        changePhase( game_phases.ACTION )
    end
end


--[[ HIDDEN MOST OF THE TIME ]]
local guiUnit = gui_tactics.style.unit
local BUTTONWIDTH = guiUnit * 5
local BUTTONHEIGHT = guiUnit * 3

local button_fight = gui_tactics:button("Fight", { w = BUTTONWIDTH, h = BUTTONHEIGHT })
button_fight.click = function() phase_tactics.state.currentlyDeciding = TACTICS.FIGHT end

local button_help = gui_tactics:button("Help", { w = BUTTONWIDTH, h = BUTTONHEIGHT })
button_help.click = function() phase_tactics.state.currentlyDeciding = TACTICS.HELP end

local button_hinder = gui_tactics:button("Hinder", { w = BUTTONWIDTH, h = BUTTONHEIGHT })
button_hinder.click = function() phase_tactics.state.currentlyDeciding = TACTICS.HINDER end

local button_done = gui_tactics:button("Done", { w = BUTTONWIDTH, h = BUTTONHEIGHT })
button_done.click = function()

    phase_tactics.state.currentlyDeciding = nil
    phase_tactics.state.selected_unit = nil

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


function gui_tactics.match_state()

    if phase_tactics.state.selected_unit ~= nil then

        updateButtonCoords(phase_tactics.state.selected_unit)

        button_done:show()
        button_help:show()
        button_hinder:show()
        button_fight:show()
    else
        button_done:hide()
        button_help:hide()
        button_hinder:hide()
        button_fight:hide()
    end

end




return gui_tactics

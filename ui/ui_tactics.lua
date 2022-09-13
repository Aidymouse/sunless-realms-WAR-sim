local gspot = require("lib.gspot")

local gui_tactics = gspot()

local nextButton = gui_tactics:button("Finish Tactics", { x = 150, y = 0, w = 120, h = gspot.style.unit * 2 })
nextButton.click = function(this)

    STATE.TACTICS.actingPlayerIndex = STATE.TACTICS.actingPlayerIndex + 1

    if STATE.TACTICS.actingPlayerIndex > #PLAYERS then
        changePhase( game_phases.ACTION )
    end
end


return gui_tactics

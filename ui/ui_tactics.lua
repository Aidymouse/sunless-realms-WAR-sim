local gspot = require("lib.gspot")

local gui_tactics = gspot()

local phase_tactics = require("phases.tactics")


local nextButton = gui_tactics:button("Finish Tactics", { x = 150, y = 0, w = 120, h = gspot.style.unit * 2 })
nextButton.click = function(this)

    phase_tactics.state.actingPlayerIndex = phase_tactics.state.actingPlayerIndex + 1

    if phase_tactics.state.actingPlayerIndex > #PLAYERS then
        changePhase( game_phases.ACTION )
    end
end


return gui_tactics

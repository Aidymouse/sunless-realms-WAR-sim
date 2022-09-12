local gspot = require("lib.gspot")

local gui_tactics = gspot()

local nextButton = gui_tactics:button("Finish Tactics", { x = 150, y = 0, w = 120, h = gspot.style.unit * 2 })
nextButton.click = function(this)

    changePhase( game_phases.ACTION )

end


return gui_tactics

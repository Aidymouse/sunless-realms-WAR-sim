local gspot = require("lib.gspot")

local gui_movement = gspot()

local nextButton = gui_movement:button("Next!", {x=150, y=0, w=120, h=gspot.style.unit*2})
nextButton.click = function(this)
    changePhase(game_phases.TACTICS)
end


return gui_movement
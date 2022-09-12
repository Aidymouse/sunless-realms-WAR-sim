gui = require("lib.gspot")

local gui_movement = gui()

local nextButton = gui:button("Next!", {x=150, y=0, w=120, h=gui.style.unit*2})
nextButton.click = function(this) print("Okay") end

return gui_movement
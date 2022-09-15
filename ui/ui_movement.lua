local gspot = require("lib.gspot")

local phase_movement = require("phases.movement")

local gui_movement = gspot()

local nextButton = gui_movement:button("Next!", {x=150, y=0, w=120, h=gspot.style.unit*2})
nextButton.click = function(this)

    --if not phase_movement.validateMovement() then return end
    phase_movement.commitMovement()

    table.insert(STATE.MOVEMENT.playersWhoHaveMoved, STATE.MOVEMENT.actingPlayerIndex)
    if #STATE.MOVEMENT.playersWhoHaveMoved == #PLAYERS then
        changePhase(game_phases.TACTICS)
    
    else
        STATE.MOVEMENT.actingPlayerIndex = STATE.MOVEMENT.actingPlayerIndex + 1

        if STATE.MOVEMENT.actingPlayerIndex > #PLAYERS then
            STATE.MOVEMENT.actingPlayerIndex = 1
        end

    end

end


return gui_movement
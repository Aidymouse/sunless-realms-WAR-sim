local gspot = require("lib.gspot")

local phase_movement = require("phases.movement")
local State = phase_movement.state

local gui_movement = gspot()

local nextButton = gui_movement:button("Next!", {x=150, y=0, w=120, h=gspot.style.unit*2})
nextButton.click = function(this)

    --if not phase_movement.validateMovement() then return end

    table.insert(State.playersWhoHaveMoved, State.actingPlayerIndex)
    if #State.playersWhoHaveMoved == #PLAYERS then
        changePhase(game_phases.TACTICS)
    
    else
        State.actingPlayerIndex = State.actingPlayerIndex + 1

        if State.actingPlayerIndex > #PLAYERS then
            State.actingPlayerIndex = 1
        end

    end

    State.actingPlayer = PLAYERS[State.actingPlayerIndex]

end

local undoButton = gui_movement:button("Undo Move", { x = 150, y = gspot.style.unit*2, w = 120, h = gspot.style.unit * 2 })
undoButton.click = phase_movement.undoMovement


return gui_movement
local gspot = require("lib.gspot")

local Utils = require("lib.utils")

local phase_movement = require("phases.movement")
local State = phase_movement.state

local gui_movement = gspot()

local go_first_button = gui_movement:button("Go First", {x=150, y=0, w=120, h=gspot.style.unit*2})
go_first_button.click = function(this)
    State.actingPlayerIndex = Utils.indexOf(PLAYERS, State.player_deciding_to_go_first)
    State.actingPlayer = PLAYERS[State.actingPlayerIndex]

    State.player_deciding_to_go_first = nil

end

local go_second_button = gui_movement:button("Go Second", {x=150+120, y=0, w=120, h=gspot.style.unit*2})
go_second_button.click = function(this)
    State.actingPlayerIndex = Utils.indexOf(PLAYERS, State.player_deciding_to_go_first) + 1
    if State.actingPlayerIndex > #PLAYERS then
        State.actingPlayerIndex = 1
    end
    State.actingPlayer = PLAYERS[State.actingPlayerIndex]
    
    State.player_deciding_to_go_first = nil
    
end

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

function gui_movement.match_state()

    if State.player_deciding_to_go_first ~= nil then
        nextButton:hide()
        undoButton:hide()

        go_first_button:show()
        go_second_button:show()
    else
        nextButton:show()
        undoButton:show()

        go_first_button:hide()
        go_second_button:hide()

    end

    if State.actingPlayerIndex == #PLAYERS then
        nextButton.label = "Next phase"
    else
        nextButton.label = "Next player"
    end

end


return gui_movement
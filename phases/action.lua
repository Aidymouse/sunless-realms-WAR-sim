local Hexlib = require("lib.hexlib")
local HL_convert = Hexlib.coordConversions
local Utils = require("lib.utils")

---@class action
---@field description string
---@field delay number Delay until next action
---@field process function Any code to run

local time_slower = 1
local DELAY = 0.8

local phase_action = {

    state = {
        unit_statuses = {},

        ---@type action[]
        action_queue = {},

        delay_timer = 0,

        messages = {}
    },
    

}

local State = phase_action.state

function phase_action.refresh()
    phase_action.actions = {}
    State.current_action = nil
end

function phase_action.populate_statuses()
    State.unit_statuses = {}

    for _, player in ipairs(PLAYERS) do
        for _, unit in ipairs(player.units) do

            State.unit_statuses[unit] = { helped_by = {}, hindered_by = {} }

        end
    end
end

local function new_message(message_text, xy)
    local message = {
        text = message_text,
        x = xy.x,
        y = xy.y,
        life_timer = 0.8,
    }
    table.insert(State.messages, message)
end

local function get_unit_status(unit)
    if #State.unit_statuses[unit].hindered_by < #State.unit_statuses[unit].helped_by then return UNIT_STATUSES.HELPED -- hlped
    elseif #State.unit_statuses[unit].hindered_by > #State.unit_statuses[unit].helped_by then return UNIT_STATUSES.HINDERED --hindered
    end
    return UNIT_STATUSES.NORMAL -- normal
end

function phase_action.calculate_helpers_and_hinderers()
    for _, player in ipairs(PLAYERS) do
        for _, unit in ipairs(player.units) do
            
            if unit.tactics.target == nil then goto continue end
            if unit.tactics.chosen_tactic == TACTICS.FIGHT then goto continue end

            ---@type unit
            local target = unit.tactics.target

            -- If we are helping or hindering the target fighting us, we cannot help or hinder them
            if target.tactics.target ~= nil and target.tactics.target == unit then
                if target.tactics.chosen_tactic == TACTICS.FIGHT then
                    goto continue
                end
            end

            if unit.tactics.chosen_tactic == TACTICS.HELP then
               table.insert(State.unit_statuses[unit.tactics.target].helped_by, unit)
               
            elseif unit.tactics.chosen_tactic == TACTICS.HINDER then
                table.insert(State.unit_statuses[unit.tactics.target].hindered_by, unit)

            end


            ::continue::
        end
    end
end

---@param unit1 unit Unit to fight
---@param unit2 unit Unit to fight
---@return unit | "tie" winner Unit who won the fight
local function calculate_fight(unit1, unit2)
    local unit1roll = love.math.random(1, 20)
    local unit2roll = love.math.random(1, 20)

    print("[FIGHT] "..tostring(unit1).." {"..unit1roll.."} vs "..tostring(unit2).." {"..unit2roll.."}")

    if unit1roll <= unit1.attack_value and unit2roll > unit2.attack_value then
        return unit1
    
    elseif unit2roll <= unit2.attack_value and unit1roll > unit1.attack_value then
        return unit2
    else
        if unit2roll < unit1roll then
            return unit2
        elseif unit1roll < unit2roll then
            return unit1
        else
            return "tie"
        end
    end

end


local function cleanup_dead_units()
    for _, player in ipairs(PLAYERS) do
        for _, unit in ipairs(player.units) do
            if unit.size <= 0 then

                local occupied_tile_id = tostring(unit.occupiedTileCoords)
                local occupied_tile = Hexfield.tiles[occupied_tile_id]
                occupied_tile.occupant = nil

                Utils.remove_item_from_table(player.units, unit)
            

            end
        end
    end

end

function phase_action.handle_fights()
    for _, player in ipairs(PLAYERS) do

        for _, unit in ipairs(player.units) do

            if unit.tactics.target ~= nil and unit.tactics.chosen_tactic == TACTICS.FIGHT then
                ---@type unit
                local target = unit.tactics.target

                -- If two units fight each other, only one fight should occur
                if target.tactics.target ~= nil and target.tactics.target == unit and
                target.action.has_fought then
                    goto continue
                end
                
                -- Add fight messages
                local unit_bottom_center_XY = HL_convert.axialToWorld(unit.occupiedTileCoords, MAPATTRIBUTES)
                local target_bottom_center_XY = HL_convert.axialToWorld(target.occupiedTileCoords, MAPATTRIBUTES)

                ---@type action
                local new_action = {
                    description="Fight message",
                    delay=DELAY,
                    process=function() 
                        new_message("FIGHT", unit_bottom_center_XY)
                        new_message("FIGHT", target_bottom_center_XY)
                    end
                }

                table.insert(State.action_queue, new_action)


                

                

                local target_status = get_unit_status(target)
                local unit_status = get_unit_status(unit)

                --print(tostring(unit)..": "..unit_status.." -> "..tostring(target)..": "..target_status)

                local fight_winner

                if target_status > unit_status then fight_winner = target
                elseif target_status < unit_status then fight_winner = unit
                else fight_winner = calculate_fight(unit, target) end

                -- You can't inflict casualties if you're not within attack range of the target
                -- In other words, if the attack range of the winner is lower than the distance between fighters, no casualties should occur
                
                if fight_winner ~= "tie" then
                    local in_range = Hexlib.axial_distance(unit.occupiedTileCoords, target.occupiedTileCoords) <= fight_winner.attack_range
                    
                    if fight_winner == unit and in_range then

                        table.insert(State.action_queue, {
                            description="Decrement Target Size",
                            delay=DELAY,
                            process=function()
                                target.size = target.size - 1
                                new_message(-1, HL_convert.axialToWorld(target.occupiedTileCoords, MAPATTRIBUTES))
                            end
                        })
                        
                        --print("Winner: "..tostring(unit).."\n")

                    elseif in_range then
                        table.insert(State.action_queue, {
                            description="Decrement Unit Size",
                            delay = DELAY,
                            process = function()
                                unit.size = unit.size - 1
                                new_message(-1, HL_convert.axialToWorld(unit.occupiedTileCoords, MAPATTRIBUTES))
                            end
                        })

                        --print("Winner: "..tostring(target).."\n")

                    else
                        print("Winner: "..tostring(fight_winner).." but out of range!\n")

                        table.insert(State.action_queue, {
                            description = "Out of range message",
                            delay = DELAY,
                            process = function()
                                new_message("Out of range!", HL_convert.axialToWorld(fight_winner.occupiedTileCoords, MAPATTRIBUTES))
                            end
                        })


                    end
                
                else
                    table.insert(State.action_queue, {
                        description = "Tie message",
                        delay = DELAY,
                        process = function()
                            new_message("Tie!",
                                HL_convert.axialToWorld(unit.occupiedTileCoords, MAPATTRIBUTES))
                            new_message("Tie!",
                                HL_convert.axialToWorld(target.occupiedTileCoords, MAPATTRIBUTES))
                        end
                    })


                    print("Tie!\n")
                end

                


                unit.action.has_fought = true

            end


            
            ::continue::
        end

    end

end

local function end_phase()
    cleanup_dead_units()

    changePhase(game_phases.MOVEMENT)
end

function phase_action.update(dt)

    dt = dt * time_slower

    State.delay_timer = State.delay_timer - dt

    if State.current_action == nil and State.delay_timer <= 0 then
        
        if #State.action_queue == 0 then
            if #State.messages == 0 then
                
                end_phase()
                return
            end
        else
            local cur_action = table.remove(State.action_queue, 1)
            cur_action.process()
            State.delay_timer = cur_action.delay
        end

    end

    -- Update messages
    for _, message in ipairs(State.messages) do
        message.life_timer = message.life_timer - dt
        if message.life_timer < 0 then
            table.remove(State.messages, 1)
        end
    end

    

end

function phase_action.draw()

    for _, message in ipairs(State.messages) do
        love.graphics.print(message.text, message.x, message.y - (0.8-message.life_timer)*30)
    end

    love.graphics.translate(-CAMERA.offsetX, -CAMERA.offsetY)
    
        love.graphics.print(tostring(State.delay_timer), 0, love.graphics.getHeight()-48)

        for index, action in ipairs(State.action_queue) do
            love.graphics.print(action.description, 500, index*16)
        end

    love.graphics.translate(CAMERA.offsetX, CAMERA.offsetY)



end


return phase_action
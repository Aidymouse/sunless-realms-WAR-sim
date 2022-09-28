local Hexlib = require("lib.hexlib")
local Utils = require("lib.utils")

local phase_action = {

    state = {
        unit_statuses = {}
    }

}

local State = phase_action.state

function phase_action.populate_statuses()
    State.unit_statuses = {}

    for _, player in ipairs(PLAYERS) do
        for _, unit in ipairs(player.units) do

            State.unit_statuses[unit] = { helped_by = {}, hindered_by = {} }

        end
    end
end

local function get_unit_status(unit)
    if #State.unit_statuses[unit].hindered_by < #State.unit_statuses[unit].helped_by then return "helped"
    elseif #State.unit_statuses[unit].hindered_by > #State.unit_statuses[unit].helped_by then return "hindered"
    end
    return "normal"
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


function phase_action.cleanup_dead_units()
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
                

                local target_status = get_unit_status(target)
                local unit_status = get_unit_status(unit)

                print(tostring(unit)..": "..unit_status.." -> "..tostring(target)..": "..target_status)

                local fight_winner = calculate_fight(unit, target)

                -- You can't inflict casualties if you're not within attack range of the target
                -- In other words, if the attack range of the winner is lower than the distance between fighters, no casualties should occur
                local in_range = Hexlib.axial_distance(unit.occupiedTileCoords, target.occupiedTileCoords) <= fight_winner.attack_range


                if fight_winner ~= "tie" then
                    if fight_winner == unit and in_range then
                        target.size = target.size - 1
                        print("Winner: "..tostring(unit).."\n")

                    elseif in_range then
                        unit.size = unit.size - 1
                        print("Winner: "..tostring(target).."\n")

                    else
                        print("Winner: "..tostring(fight_winner).." but out of range!\n")

                    end
                
                else

                    print("Tie!\n")
                end


                unit.action.has_fought = true

            end

            
            ::continue::
        end

    end

end

function phase_action.update(dt)

   

    --changePhase(game_phases.MOVEMENT)

end

function phase_action.draw()
end


return phase_action
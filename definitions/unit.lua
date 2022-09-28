---@class unit
---@field type unit_types The type of the unit
---@field occupiedTileCoords coords_axial
---@field size integer The size of the unit
---@field controller player
---@field flyingTimer number
---@field movement unit_movement
---@field tactics unit_tactics
---@field draw function
---@field update function<number>
---@field movement_refresh function
---@field tactics_refresh function

---@class unit_movement
---@field max_moves integer The amount of moves this unit can make
---@field moves_made integer The amount of moves this unit has made so far this round

---@class unit_tactics
---@field chosen_tactic tactics
---@field target unit | nil

---@enum unit_types
UNIT_TYPES = {
    LEVIES = "levies",
    INFANTRY = "infantry",
    ARCHERS = "archers",
    CAVALRY = "cavalry",
    FLYING = "flying",
    WARMACHINE = "warmachine",
}

---@enum tactics
TACTICS = {
    NONE = "none",
    FIGHT = "fight",
    HELP = "help",
    HINDER = "hinder",
}

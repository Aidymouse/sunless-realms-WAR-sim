---@enum hex_orientation
HEX_ORIENTATION = { FLATTOP = "flattop", POINTYTOP = "pointytop" }

---@enum tile_terrain
TERRAIN = {
    PLAINS = "plains",
    SWAMP = "swamp",
    WATER = "water"
}


---@class tile
---@field occupant unit The unit inside this tile
---@field coords coords_axial Axial coordinates of this hex
---@field terrain tile_terrain Terrain type of this hex
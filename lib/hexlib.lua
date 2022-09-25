
local Hexlib = {}


---@param centerXY coords_XY
---@param mapAttr map_attributes
---@returns number[]
function Hexlib.getHexPath(centerXY, mapAttr)

    mapAttr = mapAttr or MAPATTRIBUTES

    local width = mapAttr.hexWidth
    local height = mapAttr.hexHeight
    local orientation = mapAttr.orientation

    -- Flat Top
    if orientation == HEX_ORIENTATION.FLATTOP then
        return {
            centerXY.x - width/4, centerXY.y - height/2,
            centerXY.x + width/4, centerXY.y - height/2,
            centerXY.x + width/2, centerXY.y,
            centerXY.x + width/4, centerXY.y + height/2,
            centerXY.x - width/4, centerXY.y + height/2,
            centerXY.x - width/2, centerXY.y
        }

    elseif orientation == HEX_ORIENTATION.POINTYTOP then

        return {
			centerXY.x, centerXY.y - height / 2,
			centerXY.x + width / 2, centerXY.y - height / 4,
			centerXY.x + width / 2, centerXY.y + height/4,
			centerXY.x,	centerXY.y + height / 2,
			centerXY.x - width / 2,	centerXY.y + height / 4,
			centerXY.x - width / 2, centerXY.y - height / 4,
        }
    end

end

---@param num number The number to round
---@returns integer The rounded number
local function round(num)
    return math.floor(num+0.5)
end

---@param frac coords_axial Fractional axial coords
---@return coords_axial rounded_coords axial rounded to nearest whole coords
function Hexlib.axialRound(frac)
    local fracS = -frac.q-frac.r

    local q = round(frac.q);
	local r = round(frac.r);
	local s = round( fracS );
	local q_diff = math.abs(q - frac.q);
	local r_diff = math.abs(r - frac.r);
	local s_diff = math.abs(s - fracS);

	if (q_diff > r_diff and q_diff > s_diff) then
		q = -r - s;
	elseif (r_diff > s_diff) then
		r = -q - s;
	else
		s = -q - r;
    end

    if q == -0 then q = 0 end
    if r == -0 then r = 0 end

	return Hexlib.coords.axial:New(q, r)
end

---@param cube1 coords_cube
---@param cube2 coords_cube
---@return coords_cube subtracted_coords Coordinates equal to cube1 - cube2
local function cube_subtract(cube1, cube2)

    return {q=cube1.q - cube2.q, r=cube1.r - cube2.r, s=cube1.s-cube2.s}

end

---@param cube1 coords_cube
---@param cube2 coords_cube
---@return integer distance Distance (in hexes) between cube1 and cube2
local function cube_distance(cube1, cube2)

    local vec = cube_subtract(cube1, cube2)
    return ( math.abs(vec.q) + math.abs(vec.r) + math.abs(vec.s) ) / 2

end

---@param axial1 coords_axial
---@param axial2 coords_axial
---@return integer distance Distance (in hexes) between axial1 and axial2
function Hexlib.axial_distance(axial1, axial2)
    return cube_distance(
        {q=axial1.q, r=axial1.r, s=-axial1.q-axial1.r},
        {q=axial2.q, r=axial2.r, s=-axial2.q-axial2.r}
    )
end

-- Coordinates
Hexlib.coords = {
    axial = {},
    xy = {}
}

---@param q number
---@param r number
---@return coords_axial new_coords New axial coordinates object
function Hexlib.coords.axial:New(q, r)
    ---@type coords_axial
    local o = {
        q = q,
        r = r
    }
    if type(q) == "table" then
        o = {
            q = q.q,
            r = q.r
        }
    end
    setmetatable(o, self)
    self.__index = self
    self.__tostring = function(self) return "[Axial]<"..self.q..":"..self.r..">" end
    self.__eq = function(me, you) return me.q == you.q and me.r == you.r end
    return o
end

---@param x number
---@param y number
---@return coords_XY new_coords New XY coordinates object
function Hexlib.coords.xy:New(x, y)
    ---@type coords_XY
    local o = {
        x = x,
        y = y
    }
    if type(x) == "table" then
        o = {
            x = x.x,
            y = x.y
        }
    end
    setmetatable(o, self)
    self.__index = self
    self.__tostring = function(self) return "[XY]<"..self.x..":"..self.y..">" end
    self.__eq = function(me, you) return me.x == you.x and me.y == you.r end
end


-- Coordinate Conversions
Hexlib.coordConversions = {}

---@param axialCoords coords_axial
---@param mapAttr map_attributes
---@return coords_XY
function Hexlib.coordConversions.axialToWorld(axialCoords, mapAttr)

    mapAttr = mapAttr or MAPATTRIBUTES

    local hexWidth = mapAttr.hexWidth
    local hexHeight = mapAttr.hexHeight
    local orientation = mapAttr.orientation

    s = -axialCoords.q-axialCoords.r
    if orientation == HEX_ORIENTATION.FLATTOP then
        local hx = axialCoords.q * hexWidth * 0.75
        local hy = (axialCoords.r * hexHeight) / 2 - (s * hexHeight) / 2

        return {
            x= hx,
            y= hy
        }
    else
        local hx = (axialCoords.q * hexWidth) / 2 - (s * hexWidth) / 2
		local hy = axialCoords.r * hexHeight * 0.75

		return {
			x= hx,
			y= hy
		}
    end
end

---@param worldXY coords_XY
---@param mapAttr? map_attributes
---@return coords_axial axial_coords The rounded axial coords of the hex containing given XY point
function Hexlib.coordConversions.worldToAxial(worldXY, mapAttr)

    mapAttr = mapAttr or MAPATTRIBUTES

    local hexWidth = mapAttr.hexWidth
    local hexHeight = mapAttr.hexHeight
    local orientation = mapAttr.orientation

    --assert(orientation==HEX_ORIENTATION.FLATTOP or orientation==HEX_ORIENTATION.POINTYTOP, "Hex orientation must be of type hex_orientation")

	if orientation == HEX_ORIENTATION.FLATTOP then
	    -- This is the inversion of the axialToWorld
		-- Of course, substituting -q-r in as S

		local q = worldXY.x / (hexWidth * 0.75)
		local r = ((2 * worldXY.y) / hexHeight - q) / 2

		return Hexlib.axialRound( Hexlib.coords.axial:New(q, r) )

	elseif orientation == HEX_ORIENTATION.POINTYTOP then
		local r = worldXY.y / (hexHeight * 0.75)
		local q = ((2 * worldXY.x) / hexWidth - r) / 2

		return Hexlib.axialRound( Hexlib.coords.axial:New(q, r) )
    end

end





return Hexlib
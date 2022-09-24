local Hexlib = {}

-- Enums
Hexlib.hex_orientation = {FLATTOP = "flattop", POINTYTOP = "pointytop"}



-- Methods
function Hexlib.getHexPath(centerXY, mapAttr)

    mapAttr = mapAttr or MAPATTRIBUTES

    width = mapAttr.hexWidth
    height = mapAttr.hexHeight
    orientation = mapAttr.orientation

    -- Flat Top
    if orientation == Hexlib.hex_orientation.FLATTOP then
        return {
            centerXY.x - width/4, centerXY.y - height/2,
            centerXY.x + width/4, centerXY.y - height/2,
            centerXY.x + width/2, centerXY.y,
            centerXY.x + width/4, centerXY.y + height/2,
            centerXY.x - width/4, centerXY.y + height/2,
            centerXY.x - width/2, centerXY.y
        }
    else
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

function round(num)
    return math.floor(num+0.5)
end

function Hexlib.axialRound(frac)
    fracS = -frac.q-frac.r

    q = round(frac.q);
	r = round(frac.r);
	s = round( fracS );
	q_diff = math.abs(q - frac.q);
	r_diff = math.abs(r - frac.r);
	s_diff = math.abs(s - fracS);

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


-- Coordinates
Hexlib.coords = {
    axial = {}
}

function Hexlib.coords.axial:New(q, r)
    o = {
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
    self.__tostring = function(self) return "<"..self.q..":"..self.r..">" end
    self.__eq = function(me, you) return me.q == you.q and me.r == you.r end
    return o
end



-- Coordinate Conversions
Hexlib.coordConversions = {}

function Hexlib.coordConversions.axialToWorld(axialCoords, mapAttr)

    local mapAttr = mapAttr or MAPATTRIBUTES

    local hexWidth = mapAttr.hexWidth
    local hexHeight = mapAttr.hexHeight
    local orientation = mapAttr.orientation

    s = -axialCoords.q-axialCoords.r
    if orientation == Hexlib.hex_orientation.FLATTOP then
        hx = axialCoords.q * hexWidth * 0.75
        hy = (axialCoords.r * hexHeight) / 2 - (s * hexHeight) / 2

        return {
            x= hx,
            y= hy
        }
    else
        hx = (axialCoords.q * hexWidth) / 2 - (s * hexWidth) / 2
		hy = axialCoords.r * hexHeight * 0.75

		return {
			x= hx,
			y= hy
		}
    end
end

function Hexlib.coordConversions.worldToAxial(worldXY, mapAttr)

    mapAttr = mapAttr or MAPATTRIBUTES

    hexWidth = mapAttr.hexWidth
    hexHeight = mapAttr.hexHeight
    orientation = mapAttr.orientation

	if orientation == Hexlib.hex_orientation.FLATTOP then
	    -- This is the inversion of the axialToWorld
		-- Of course, substituting -q-r in as S

		q = worldXY.x / (hexWidth * 0.75)
		r = ((2 * worldXY.y) / hexHeight - q) / 2

		return Hexlib.axialRound( Hexlib.coords.axial:New(q, r) )

	elseif orientation == Hexlib.hex_orientation.POINTYTOP then
		r = worldXY.y / (hexHeight * 0.75)
		q = ((2 * worldXY.x) / hexWidth - r) / 2

		return Hexlib.axialRound( Hexlib.coords.axial:New(q, r) )
    end
end





return Hexlib
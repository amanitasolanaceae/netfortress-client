tileSize = 40

SG.tilesets = {
	["geometry"] = love.graphics.newImage( "graphics/geometry.png" ),
	["people"] = love.graphics.newImage( "graphics/people.png" ),
	["eye"] = love.graphics.newImage( "graphics/eye.png" ),
	["food"] = love.graphics.newImage( "graphics/food.png" ),
	["creatures"] = love.graphics.newImage( "graphics/creatures.png" ),
	["clothing"] = love.graphics.newImage( "graphics/clothing.png" ),
	["clothingWorn"] = love.graphics.newImage( "graphics/clothing_worn.png" ),
	["misc"] = love.graphics.newImage( "graphics/misc.png" ),
}
for _, set in pairs( SG.tilesets ) do
	set:setFilter("nearest", "linear")
end
function newTile( set, x, y )
	return { SG.tilesets[set], love.graphics.newQuad( x * tileSize, y * tileSize, tileSize, tileSize, SG.tilesets[set]:getDimensions() ) }
end
SG.tiles = {
	["turfs"] = {
		["brick"] 		= newTile( "geometry", 2, 9 ),
		["black"] 		= newTile( "geometry", 0, 0 ),
		["cobblestone"] = newTile( "geometry", 2, 10 ),
		["water"] 		= newTile( "geometry", 14, 16 ),
	},
	["mobs"] = {
		["hermit"] 		= newTile( "people", 1, 6 ),
		["slimbo"] 		= newTile( "creatures", 4, 1 ),
	},
	["items"] = {
		["morsel"] 		= newTile( "food", 0, 0 ),
		["shirt"]		= newTile( "clothing", 0, 0 ),
		["pants"]		= newTile( "clothing", 0, 5 ),
		["mask_bone"] 	= newTile( "clothing", 7, 18 ),
	},
	["worn"] = {
		["shirt"]		= newTile( "clothingWorn", 0, 0 ),
		["pants"]		= newTile( "clothingWorn", 1, 0 ),
		["mask_bone"]	= newTile( "clothingWorn", 2, 0 ),
	},
	["eye"] = {
		["frame1"] 		= newTile( "eye", 0, 0 ),
		["frame2"] 		= newTile( "eye", 2, 0 ),
		["frame3"] 		= newTile( "eye", 1, 0 ),
		["interesting"]	= newTile( "eye", 3, 0 ),
	},
	["ui"] = {
		["heart"]		= newTile( "misc", 2, 9 ),
	},
}

local idx = 0
for y=1,5 do
	idx = idx + 1
	SG.tiles["turfs"]["dirt" .. idx] = newTile( "geometry", 1, y );
end

mapX = 1
mapY = 1
tilesDisplayWidth = 18
tilesDisplayHeight = 18

zoomX = 1
zoomY = 1

tileQuads = {}

tileQuads[0] = SG.tiles["turfs"]["dirt1"][2]
tileQuads[1] = SG.tiles["turfs"]["brick"][2]
tileQuads[2] = SG.tiles["turfs"]["water"][2]
tileQuads[3] = SG.tiles["turfs"]["cobblestone"][2]

tilesetBatch = love.graphics.newSpriteBatch(SG.tilesets.geometry, tilesDisplayWidth * tilesDisplayHeight)

updateTilesetBatch()
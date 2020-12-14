SG.renderTypeDraws 		= {}
SG.renderTypeMouseovers = {}

requireDirectory("renders")

SG.particles = {}
SG.emittersPre = {}
SG.emittersPost = {}

pixel = love.graphics.newImage("graphics/pixel.png")

requireDirectory("particles")

function SG:addEmitter( particle, x, y, post )
	particle = particle:clone()
	if( post ) then
		table.insert( self.emittersPost, { particle, x, y, love.timer.getTime() + particle:getEmitterLifetime() } )
	else
		table.insert( self.emittersPre, { particle, x, y, love.timer.getTime() + particle:getEmitterLifetime() } )
	end
end

SG.effects = {}
SG.effects.default = moonshine(moonshine.effects.filmgrain).chain(moonshine.effects.crt).chain(moonshine.effects.chromasep).chain(moonshine.effects.scanlines)
SG.effects.default.filmgrain.size = 5
SG.effects.default.filmgrain.opacity = 0.5
SG.effects.default.chromasep.angle = 90
SG.effects.default.chromasep.radius = 1.5
SG.effects.default.scanlines.width = 2
SG.effects.default.scanlines.opacity = 0.5
SG.effects.default.crt.feather = 0.1
SG.effects.focused = moonshine(moonshine.effects.desaturate)
SG.effects.focused.desaturate.strength = 0

crtFactor = {1.1, 1.1}
focusStrength = 0

function lerp(a,b,t,s) return a + (b-a) * s * t end

function love.draw()
	local state = client:getState();
	local w, h = love.window.getMode();
	local stateMsgs = {
		["disconnected"] = "No connection to NetFortress",
		["connecting"] = "Attempting to connect",
	};
	
	for k, v in pairs( SG.AVswitches ) do
		if( not v ) then
			SG.effects.default.disable(k)
		end
	end
	
	if( not chatting and ( love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") ) ) then
		crtFactor = {lerp(crtFactor[1], 1.3, 0.2, 1), lerp(crtFactor[2], 1.3, 0.2, 1)}
	else
		crtFactor = {lerp(crtFactor[1], 1.1, 0.2, 1), lerp(crtFactor[2], 1.1, 0.2, 1)}
	end
	SG.effects.default.crt.distortionFactor = crtFactor
	
	if( inventoryOpen and SG.AVswitches["focused"] ) then
		focusStrength = lerp(focusStrength, 1, 0.05, 1)
	else
		focusStrength = lerp(focusStrength, 0, 0.2, 1)
	end
	SG.effects.focused.desaturate.strength = focusStrength
	local sort = {}
	local lowest = 0
	for k, v in pairs( SG.atomicTable ) do
		if( ( not v.heldBy or v.heldBy == 0 ) and ( not v.wornBy or v.wornBy == 0 ) ) then
			if( not v.drawPriority ) then
				v.drawPriority = 666
			end
			if( v.drawPriority > lowest ) then
				lowest = v.drawPriority;
			end
			if( not sort[v.drawPriority] ) then
				sort[v.drawPriority] = {}
			end
			table.insert( sort[v.drawPriority], v )
		end
	end
	
	-- draw the actual tile first
	
	SG.effects.default(function()
			SG.effects.focused(function()
				love.graphics.draw(tilesetBatch)
			end)
			local first = true
			for q, p in pairs( sort ) do
				for k, v in pairs( p ) do
					if( v.x_draw and v.x ) then
						v.x_draw = lerp(v.x_draw, v.x, 0.2, 1)
						v.y_draw = lerp(v.y_draw, v.y, 0.2, 1)
						--love.graphics.setColor( 0.5, 0.5, 0.5, 255 );
						if( SG.atomicTable[client.mobid] and SG.atomicTable[client.mobid].hilite_id == v.id ) then
							love.graphics.setColor( 0.75, 0.75 + math.abs( 0.25 * ( math.sin( love.timer.getTime() * 2 ) ) ), 0.75, 255 );
						else
							if( v.color ) then
								love.graphics.setColor( v.color.r, v.color.g, v.color.b, 1 )
							else
								love.graphics.setColor( 1, 1, 1, 1 )
							end
						end
						if( v.hurt ) then
							v.hurt = false;
							v.hurtRed = 1;
						end
						if( v.hurtRed and v.hurtRed > 0.5 ) then
							v.hurtRed = lerp(v.hurtRed, 0, 0.05, 1)
							love.graphics.setColor( v.hurtRed, 1 - v.hurtRed, 1 - v.hurtRed, 1 );
						end
						love.graphics.draw(SG.tiles[v.tile[1]][v.tile[2]][1], SG.tiles[v.tile[1]][v.tile[2]][2], ( ( v.x_draw - ( mapX - 1 ) ) * tileSize ) - tileSize, ( ( v.y_draw - ( mapY - 1 ) ) * tileSize ) - tileSize)
						--love.graphics.setColor( 0.5 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ), 0.5 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ), 0.5 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ), 255 );
					end
				end
				if( first ) then
					-- the iteration is always supposed to be turfs, so we want to draw preemitters on top of them
					first = false
					for k, v in pairs( SG.emittersPre ) do
						love.graphics.draw(v[1], ( ( v[2] - ( mapX - 1 ) ) * 40 ) - 20, ( ( v[3] - ( mapY - 1 ) ) * 40 ) - 20)
					end
				end
			end
		
		-- now do any extra renders for objects that allow them
		
		for q, p in pairs( sort ) do
			for k, v in pairs( p ) do
				if( v.x_draw ) then
					if( v.renderType and SG.renderTypeDraws[v.renderType] ) then
						SG.renderTypeDraws[v.renderType](v)
					end
				end
			end
		end
		
		-- particles
		
		for k, v in pairs( SG.emittersPost ) do
			love.graphics.draw(v[1], ( ( v[2] - ( mapX - 1 ) ) * 40 ) - 20, ( ( v[3] - ( mapY - 1 ) ) * 40 ) - 20)
		end
		
		--love.graphics.draw(tilesetBatch, math.floor(-zoomX*(mapX%1)*tileSize), math.floor(-zoomY*(mapY%1)*tileSize), 0, zoomX, zoomY)
		love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
		if( client and client.mobid and SG.atomicTable[client.mobid] and SG.atomicTable[client.mobid].y ) then
			love.graphics.print("x, y: "..SG.atomicTable[client.mobid].x..", "..SG.atomicTable[client.mobid].y, 10, 30)
		end
		if( stateMsgs[state] ) then
			local pos = ( w / 2 ) - ( SG.fonts.title:getWidth(stateMsgs[state]) / 2 )
			love.graphics.printf(stateMsgs[state], SG.fonts.title, w / 2 - SG.fonts.title:getWidth(stateMsgs[state]) / 2, h / 2, w);
		elseif( not SG.loggedIn ) then
			local pos = ( w / 2 ) - ( SG.fonts.title:getWidth("Attempting login") / 2 )
			love.graphics.printf("Attempting login", SG.fonts.title, w / 2 - SG.fonts.title:getWidth("Attempting login") / 2, h / 2, w);
		elseif( type( SG.loggedIn ) == "string" ) then
			local pos = ( w / 2 ) - ( SG.fonts.title:getWidth(SG.loggedIn) / 2 )
			love.graphics.printf(SG.loggedIn, SG.fonts.title, w / 2 - SG.fonts.title:getWidth(SG.loggedIn) / 2, h / 2, w);
		end
		
		if( mouseHide and love.timer.getTime() < mouseHide ) then
			local x, y = love.mouse.getPosition()
			--love.graphics.print("x, y: "..x..", "..y, 10, 30)
			--love.graphics.print("x2, y2: "..mouseX..", "..mouseY, 10, 40)
			local frame;
			if( ( mouseHide - love.timer.getTime() ) > 1 ) then
				frame = 1;
			elseif( ( mouseHide - love.timer.getTime() ) > 0.5 ) then
				frame = 2;
			else
				frame = 3;
			end
			local fadeStart = mouseHide - 2;
			if( love.timer.getTime() >= fadeStart ) then
				love.graphics.setColor(1, 1, 1, ( mouseHide - love.timer.getTime() ) / 2);
				recognizedCoord = { mouseX, mouseY };
			end
			if( interestedEye ) then
				love.graphics.draw(SG.tiles["eye"]["interesting"][1], SG.tiles["eye"]["interesting"][2], x - 20, y - 20)
			else
				love.graphics.draw(SG.tiles["eye"]["frame"..frame][1], SG.tiles["eye"]["frame"..frame][2], x - 20, y - 20)
			end
			love.graphics.setColor(1, 1, 1, 1);
		end
	end)
end

function updateTilesetBatch()
	if( map ) then
		tilesetBatch:clear()
		for y=0, tilesDisplayHeight-1 do
			for x=0, tilesDisplayWidth-1 do
				if( map[y+math.floor(mapY)] and map[y+math.floor(mapY)][x+math.floor(mapX)] ) then
					tilesetBatch:add(tileQuads[map[y+math.floor(mapY)][x+math.floor(mapX)]],
					x*tileSize, y*tileSize)
				end
			end
		end
		tilesetBatch:flush()
	end
end
 
function adjustMap()
	oldMapX = mapX
	oldMapY = mapY
	if( not client.mob ) then
		for k, v in pairs( SG.atomicTable ) do
			if( v.id == client.mobid ) then
				client.mob = v;
			end
		end
	end
	if( not client.mob ) then
		return;
	end
	if( love.keyboard.isDown( "lshift" ) or love.keyboard.isDown( "rshift" ) ) then
		mapX = math.floor( client.mob.x - ( tilesDisplayWidth / 2 ) );
		mapY = math.floor( client.mob.y - ( tilesDisplayHeight / 2 ) );
	else
		if( tilesDisplayWidth - ( client.mob.x - mapX ) < 3 ) then
			mapX = math.floor( client.mob.x - ( tilesDisplayWidth / 2 ) );
		elseif( tilesDisplayWidth - ( client.mob.x - mapX ) > 13 ) then
			mapX = math.floor( client.mob.x - ( tilesDisplayWidth / 2 ) );
		end
		if( tilesDisplayHeight - ( client.mob.y - mapY ) < 3 ) then
			mapY = math.floor( client.mob.y - ( tilesDisplayHeight / 2 ) );
		elseif( tilesDisplayHeight - ( client.mob.y - mapY ) > 13 ) then
			mapY = math.floor( client.mob.y - ( tilesDisplayHeight / 2 ) );
		end
	end
	--mapX = math.max(math.min(mapX + dx, mapWidth - tilesDisplayWidth), 1)
	--mapY = math.max(math.min(mapY + dy, mapHeight - tilesDisplayHeight), 1)
	-- only update if we actually moved
	if math.floor(mapX) ~= math.floor(oldMapX) or math.floor(mapY) ~= math.floor(oldMapY) then
		--updateTilesetBatch()
	end
end
 
-- central function for moving the map
function moveMap(dx, dy)
	oldMapX = mapX
	oldMapY = mapY
	mapX = math.max(math.min(mapX + dx, mapWidth - tilesDisplayWidth), 1)
	mapY = math.max(math.min(mapY + dy, mapHeight - tilesDisplayHeight), 1)
	-- only update if we actually moved
	if math.floor(mapX) ~= math.floor(oldMapX) or math.floor(mapY) ~= math.floor(oldMapY) then
		--updateTilesetBatch()
	end
end
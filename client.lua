function requireDirectory( dir )
   dir = dir or ""
   local entities = love.filesystem.getDirectoryItems(dir)

   for k, ents in ipairs(entities) do
      trim = string.gsub( ents, ".lua", "")
      require(dir .. "/" .. trim)
   end
end

local sock = require("sock")
inspect = require("inspect")
sha = require("sha")
utf8 = require("utf8")
moonshine = require("moonshine")
tobool = require("toboolean")

function string.explode(str, div)
	assert(type(str) == "string" and type(div) == "string", "invalid arguments")
	local o = {}
	while true do
		local pos1,pos2 = str:find(div)
		if not pos1 then
			o[#o+1] = str
			break
		end
		o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
	end
	return o
end

SG = {}
SG.atomicTable = {}
SG.fonts = {
	title = love.graphics.newFont("/fonts/spixel.ttf", 24),
	label = love.graphics.newFont("/fonts/chill.ttf", 16),
}
SG.loggedIn = false

require("draw")
require("tiles")
require("sounds")
require("controls")

function love.load()
	local serverdata = string.explode( love.filesystem.read("serverinfo.txt"), "\n" )
    client = sock.newClient(serverdata[1], tonumber(serverdata[2]))
	love.mouse.setVisible(false)

    -- Called when a connection is made to the server
    client:on("connect", function(data)
        print("You've successfully connected. Sending credentials, attempting to log in as " .. serverdata[3] .. "...")
		client:send("login", {serverdata[3], serverdata[4]})
    end)
    
    -- Called when the client disconnects from the server
    client:on("disconnect", function(data)
        print("You've lost connection.")
    end)

    -- Custom callback, called whenever you send the event from the server
    client:on("hello", function(msg)
        print(msg)
    end)
	
	client:on("loginSuccess", function(msg)
		SG.loggedIn = true
    end)
	
	client:on("loginFailure", function(msg)
		SG.loggedIn = msg
    end)
	
	client:on("sendobject", function(obj)
		SG.atomicTable[obj.id] = obj
    end)
	
	client:on("deleteobject", function(obj)
		SG.atomicTable[obj.id] = nil
    end)
	
	client:on("sendobjects", function(objs)
		for k, obj in pairs( objs ) do
			SG.atomicTable[obj.id] = obj
		end
    end)
	
	client:on("sendparticle", function(data)
		SG:addEmitter( SG.particles[data.particleName], data.x, data.y, data.post )
    end)
	
	updates = 0
	
	client:on("updateobject", function(data)
		if( not data.id ) then
			return
		end
		if( not SG.atomicTable[data.id] ) then
			SG.atomicTable[data.id] = {}
		end
		for k, v in pairs( data ) do
			SG.atomicTable[data.id][k] = v;
		end
    end)
	
	client:on("updateawareness", function(data)
		if( not client.mob ) then
			return
		end
		local snipped = 0
		local total = 0
		for k, v in pairs( SG.atomicTable ) do
			if( not client.mob.awareTable or not client.mob.awareTable[v.id] ) then
				SG.atomicTable[k] = nil
				snipped = snipped + 1
			end
			total = total + 1
		end
    end)
	
	client:on("sendmap", function(recmap)
		map = recmap
		--updateTilesetBatch()
    end)
	
	client:on("verifyMob", function(id)
		for k, obj in pairs( SG.atomicTable ) do
			if( obj.id == id ) then
				client.mob = obj;
				client.mobid = id;
			end
		end
    end)
	
	client:on("hearSound", function(data)
		-- don't use music or really big files for this
		TEsound.play("sound/" .. data.sound, "static", data.tags or {}, data.volume or 1, data.pitch or 1)
	end)

    client:connect()
	
	love.audio.setEffect("dreamy", {type = "reverb"})
	
	--music = love.audio.newSource("sound/music/whitewaking.mp3", "stream")
	--music:setEffect("dreamy")
	--music:play()
	
end

function love.update(dt)
	if love.keyboard.isDown("up") then
		if( love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt") ) then
			client:send("command", "up?")
		elseif( love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") ) then
			client:send("command", "up+")
		elseif( love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") ) then
			client:send("command", "up-")
		else
			client:send("command", "up")
		end
		--moveMap(0, -0.2 * tileSize * dt)
		adjustMap()
	end
	if love.keyboard.isDown("down") then
		if( love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt") ) then
			client:send("command", "down?")
		elseif( love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") ) then
			client:send("command", "down+")
		elseif( love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") ) then
			client:send("command", "down-")
		else
			client:send("command", "down")
		end
		--moveMap(0, 0.2 * tileSize * dt)
		adjustMap()
	end
	if love.keyboard.isDown("left") then
		if( love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt") ) then
			client:send("command", "left?")
		elseif( love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") ) then
			client:send("command", "left+")
		elseif( love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") ) then
			client:send("command", "left-")
		else
			client:send("command", "left")
		end
		--moveMap(-0.2 * tileSize * dt, 0)
		adjustMap()
	end
	if love.keyboard.isDown("right") then
		if( love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt") ) then
			client:send("command", "right?")
		elseif( love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") ) then
			client:send("command", "right+")
		elseif( love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") ) then
			client:send("command", "right-")
		else
			client:send("command", "right")
		end
		--moveMap(0.2 * tileSize * dt, 0)
		adjustMap()
	end
  
	for k, v in pairs( SG.emittersPre ) do
		v[1]:update(dt)
		if( love.timer.getTime() >= v[4] and v[1]:getCount() <= 0 ) then
			SG.emittersPre[k] = nil
		end
	end
	for k, v in pairs( SG.emittersPost ) do
		v[1]:update(dt)
		if( love.timer.getTime() >= v[4] and v[1]:getCount() <= 0 ) then
			SG.emittersPost[k] = nil
		end
	end
  
	client:update()
	TEsound.cleanup()
	
	if( not mouseHide ) then
		mouseHide 	= love.timer.getTime();
		mouseX		= 0;
		mouseY		= 0;
	end
	
	if( love.timer.getTime() >= mouseHide ) then
		--love.mouse.setVisible(false)
	end
end

function love.keypressed(key)
	if( not SG.keybinds[key] ) then
		return;
	end
	local control = SG.keybinds[key]
	if( control == "chat" ) then
		if( chatting ) then
			chatting = false
			client:send("chat", chatstring)
		else
			chatting = true
		end
		chatstring = ""
		love.keyboard.setKeyRepeat(chatting)
    elseif( control == "chatbackspace" ) then
        local byteoffset = utf8.offset(chatstring, -1)
 
        if byteoffset then
            chatstring = string.sub(chatstring, 1, byteoffset - 1)
			TEsound.play("sound/prespeech.wav", "static", {}, 1, 0.5)
        end
	elseif( not chatting ) then
		if( control == "use" ) then
			if( not inventoryOpen and not inventorySlot and ( not client.mob.hilite_id or client.mob.hilite_id == 0 ) ) then
				TEsound.play("sound/cantuse.wav", "static", {}, 1, 1)
			else
				if( inventorySlot ) then
					client:send("useInventory", inventorySlot)
				else
					client:send("command", "use")
				end
			end
		elseif( control == "inventory" ) then
			if( inventoryOpen ) then
				TEsound.play("sound/inv_close.wav", "static", {}, 1, 1)
			else
				TEsound.play("sound/inv_open.wav", "static", {}, 1, 1)
			end
			inventoryOpen = not inventoryOpen
			inventorySlot = nil
		elseif( control == "drop" ) then
			if( inventoryOpen and inventorySlot ) then
				if( client.mob.inventory[inventorySlot] and client.mob.inventory[inventorySlot].id ) then
					client:send("drop", client.mob.inventory[inventorySlot].id)
				else
					TEsound.play("sound/cantuse.wav", "static", {}, 1, 1)
				end
			else
				if( client.mob.inventory.wielded and client.mob.inventory.wielded.id ) then
					client:send("drop", client.mob.inventory.wielded.id)
				elseif( client.mob.inventory.offhand and client.mob.inventory.offhand.id ) then
					client:send("drop", client.mob.inventory.offhand.id)
				else
					TEsound.play("sound/cantuse.wav", "static", {}, 1, 1)
				end
			end
		elseif( inventoryOpen ) then
			local invslots = {
				["invslotwielded"] = "wielded",
				["invslotoffhand"] = "offhand",
				["invslotheadwear"] = "headwear",
				["invslottorsowear"] = "torsowear",
				["invslotlegwear"] = "legwear",
				["invslotneckwear"] = "neckwear",
				["invslotvessel"] = "vessel",
				["invslottrinket"] = "trinket",
			};
			if( invslots[control] ) then
				if( inventorySlot == invslots[control] ) then
					inventorySlot = nil;
					TEsound.play("sound/inv_emptyslot.wav", "static", {}, 2, 1)
				else
					inventorySlot = invslots[control]
					if( not client.mob.inventory[inventorySlot] or not client.mob.inventory[inventorySlot].id ) then
						TEsound.play("sound/inv_emptyslot.wav", "static", {}, 1, 1)
					end
				end
			end
		end
	end
end

function love.textinput(key)
	if( not client.mob ) then
		return;
	end
	local control = SG.keybinds[key]
	if( chatting ) then
		if( utf8.len(chatstring) >= 80 ) then
			TEsound.play("sound/prespeech.wav", "static", {}, 1, 0.2)
		else
			chatstring = chatstring .. key
			TEsound.play("sound/prespeech.wav", "static", {}, 1, 0.75)
		end
	end
end

function love.mousemoved(x, y)
	mouseHide = love.timer.getTime() + 3;
	local x, y = love.mouse.getPosition();
	local nx, ny = mapX + math.floor( x / 40 ), mapY + math.floor( y / 40 );
	local shouldUpdate = false;
	if( nx ~= mouseX ) then
		mouseX = nx;
		shouldUpdate = true;
	end
	if( ny ~= mouseY ) then
		mouseY = ny;
		shouldUpdate = true;
	end
	if( shouldUpdate ) then
		interestedEye = false;
		for k, v in pairs( SG.atomicTable ) do
			if( v.x == mouseX and v.y == mouseY ) then
				interestedEye = true;
				break;
			end
		end
	end
	--love.mouse.setVisible(true)
end

function love.mousepressed(x, y)
	for k, v in pairs( SG.atomicTable ) do
		if( v.x == mouseX and v.y == mouseY ) then
			mouseHide = love.timer.getTime() + 2.5;
			describingWhen = nil;
			describingObject = v;
			recognizedCoord = { v.x, v.y };
			break;
		end
	end
end
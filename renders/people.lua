SG.renderTypeDraws["@"] = function(mob)
	local w, h = love.window.getMode();
	local name = mob.name
	if( mob.linkdead ) then
		name = name .. " [coma]";
	end
	local textAnchor = ( ( ( mob.x_draw - ( mapX - 1 ) ) * tileSize ) - tileSize / 2 );
	local pos = textAnchor - ( SG.fonts.label:getWidth(name) / 2 );
	if( mob.inventory.wielded and mob.inventory.wielded.id and mob.inventory.wielded.tileHeld ) then
		if( mob.inventory.wielded.color ) then
			love.graphics.setColor( mob.inventory.wielded.color.r, mob.inventory.wielded.color.g, mob.inventory.wielded.color.b, 1 )
		else
			love.graphics.setColor( 1, 1, 1, 1 )
		end
		local offX, offY = 12, 8
		if( mob.inventory.wielded.heldOffsetX ) then
			offX = mob.inventory.wielded.heldOffsetX;
		end
		if( mob.inventory.wielded.heldOffsetY ) then
			offY = mob.inventory.wielded.heldOffsetY;
		end
		love.graphics.draw(SG.tiles[mob.inventory.wielded.tileHeld[1]][mob.inventory.wielded.tileHeld[2]][1],
				SG.tiles[mob.inventory.wielded.tileHeld[1]][mob.inventory.wielded.tileHeld[2]][2],
				( ( mob.x_draw - ( mapX - 1 ) ) * tileSize ) - tileSize - offX, 
				( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) - tileSize + offY)
	end
	if( mob.inventory.offhand and mob.inventory.offhand.id and mob.inventory.offhand.tileHeld ) then
		if( mob.inventory.offhand.color ) then
			love.graphics.setColor( mob.inventory.offhand.color.r, mob.inventory.offhand.color.g, mob.inventory.offhand.color.b, 1 )
		else
			love.graphics.setColor( 1, 1, 1, 1 )
		end
		local offX, offY = 12, 8
		if( mob.inventory.offhand.heldOffsetX ) then
			offX = mob.inventory.offhand.heldOffsetX;
		end
		if( mob.inventory.offhand.heldOffsetY ) then
			offY = mob.inventory.offhand.heldOffsetY;
		end
		love.graphics.draw(SG.tiles[mob.inventory.offhand.tileHeld[1]][mob.inventory.offhand.tileHeld[2]][1],
				SG.tiles[mob.inventory.offhand.tileHeld[1]][mob.inventory.offhand.tileHeld[2]][2],
				( ( mob.x_draw - ( mapX - 1 ) ) * tileSize ) - tileSize + offX, 
				( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) - tileSize + offY)
	end
	local bodyslots = {"headwear", "torsowear", "legwear"}
	for k, v in pairs( bodyslots ) do
		if( mob.inventory[v] and mob.inventory[v].id and mob.inventory[v].tileWorn ) then
			if( mob.inventory[v].color ) then
				love.graphics.setColor( mob.inventory[v].color.r, mob.inventory[v].color.g, mob.inventory[v].color.b, 1 )
			else
				love.graphics.setColor( 1, 1, 1, 1 )
			end
			local offX, offY = 0, 0
			if( mob.inventory[v].wornOffsetX ) then
				offX = mob.inventory[v].wornOffsetX;
			end
			if( mob.inventory[v].wornOffsetY ) then
				offY = mob.inventory[v].wornOffsetY;
			end
			love.graphics.draw(SG.tiles[mob.inventory[v].tileWorn[1]][mob.inventory[v].tileWorn[2]][1],
					SG.tiles[mob.inventory[v].tileWorn[1]][mob.inventory[v].tileWorn[2]][2],
					( ( mob.x_draw - ( mapX - 1 ) ) * tileSize ) - tileSize + offX, 
					( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) - tileSize + offY)
		end
	end
	if( inventoryOpen and SG.atomicTable[client.mobid] == mob ) then
		local slots = {
			["wielded"] 	= {-1, 0, "Bare hand"},
			["offhand"]		= {1, 0, "Other hand"},
			["headwear"]	= {0, -1, "Skull"},
			["torsowear"]	= {0, 0, "Skin"},
			["legwear"]		= {0, 1, "Shame"},
			["neckwear"] 	= {-1, -1, "Lacking vanity"},
			["vessel"] 		= {1, 1, "Lacking storage"},
			["trinket"] 	= {-1, 1, "Lacking novelty"},
		};
		for k, v in pairs( slots ) do
			love.graphics.setColor( 0.2, 0.2, 0.2, 0.5 )
			love.graphics.rectangle( "fill", ( ( mob.x_draw - ( mapX - 1 ) + v[1] ) * tileSize ) - tileSize, ( ( mob.y_draw - ( mapY - 1 ) + v[2] ) * tileSize ) - tileSize, tileSize, tileSize )
			love.graphics.setColor( 0.5, 0.5, 0.5, 0.5 )
			love.graphics.rectangle( "line", ( ( mob.x_draw - ( mapX - 1 ) + v[1] ) * tileSize ) - tileSize, ( ( mob.y_draw - ( mapY - 1 ) + v[2] ) * tileSize ) - tileSize, tileSize, tileSize )
			if( mob.inventory[k] and mob.inventory[k].id ) then
				if( mob.inventory[k].color ) then
					love.graphics.setColor( mob.inventory[k].color.r, mob.inventory[k].color.g, mob.inventory[k].color.b, 0.5 )
				else
					love.graphics.setColor( 1, 1, 1, 0.5 )
				end
				love.graphics.draw(SG.tiles[mob.inventory[k].tile[1]][mob.inventory[k].tile[2]][1], 
						SG.tiles[mob.inventory[k].tile[1]][mob.inventory[k].tile[2]][2], 
						( ( mob.x_draw - ( mapX - 1 ) + v[1] ) * tileSize ) - tileSize, 
						( ( mob.y_draw - ( mapY - 1 ) + v[2] ) * tileSize ) - tileSize)
			end
		end
		if( inventorySlot ) then
			local pos2 = textAnchor - ( SG.fonts.label:getWidth(inventorySlot) / 2 )
			love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
			love.graphics.rectangle("fill", pos2 - 1, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) + ( tileSize * 1.05 ), SG.fonts.label:getWidth(inventorySlot), 20)
			love.graphics.setColor( 1, 1, 1, 1 )
			love.graphics.printf(inventorySlot, SG.fonts.label, pos2, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize + 48 ), w);
			if( mob.inventory[inventorySlot] and mob.inventory[inventorySlot].id ) then
				local pos3 = textAnchor - ( SG.fonts.label:getWidth(mob.inventory[inventorySlot].name) / 2 )
				love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
				love.graphics.rectangle("fill", pos3 - 1, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) + ( tileSize * 1.45 ), SG.fonts.label:getWidth(mob.inventory[inventorySlot].name), 20)
				love.graphics.setColor( 1, 1, 1, 1 )
				love.graphics.printf(mob.inventory[inventorySlot].name, SG.fonts.label, pos3, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize + 64 ), w);
			else
				if( #slots[inventorySlot] > 2 ) then
					local pos3 = textAnchor - ( SG.fonts.label:getWidth( slots[inventorySlot][3] .. "!" ) / 2 )
					love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
					love.graphics.rectangle("fill", pos3 - 1, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) + ( tileSize * 1.45 ), SG.fonts.label:getWidth(slots[inventorySlot][3] .. "!"), 20)
					love.graphics.setColor( 0.5, 0, 0, 1 )
					love.graphics.printf(slots[inventorySlot][3] .. "!", SG.fonts.label, pos3, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize + 64 ), w);
				else
					local pos3 = textAnchor - ( SG.fonts.label:getWidth("Nothing!") / 2 )
					love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
					love.graphics.rectangle("fill", pos3 - 1, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) + ( tileSize * 1.45 ), SG.fonts.label:getWidth("Nothing!"), 20)
					love.graphics.setColor( 0.5, 0, 0, 1 )
					love.graphics.printf("Nothing!", SG.fonts.label, pos3, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize + 64 ), w);
				end
			end
			love.graphics.setColor( 1, 1, 1, 1 )
		end
	else
		love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
		love.graphics.rectangle("fill", pos - 1, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) - ( tileSize * 1.5 ), SG.fonts.label:getWidth(name), 20)
		if( client and SG.atomicTable[client.mobid] == v ) then
			love.graphics.setColor( 1, 1, 1, 1 );
		else
			love.graphics.setColor( 0.8, 0.8, 0.8, 1 );
		end
		love.graphics.printf(name, SG.fonts.label, pos, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) - 54, w);
	end
	if( chatting and SG.atomicTable[client.mobid] == mob ) then
		pos = ( ( ( mob.x_draw - ( mapX - 1 ) ) * tileSize ) - 20 ) - ( SG.fonts.label:getWidth(">" .. chatstring) / 2 );
		love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
		love.graphics.rectangle("fill", pos - 1, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ), SG.fonts.label:getWidth(">" .. chatstring), 20)
		love.graphics.setColor( 0, 1 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ), 0, 1 );
		love.graphics.printf(">" .. chatstring, SG.fonts.label, pos, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) + 4, w);
	end
	if( mob.chat ) then
		if( mob.chat.when == 0 ) then
			mob.chat.when = love.timer.getTime();
			mob.chatNextGlyph = 0
			mob.chatGlyphIndex = 0
		end
		if( ( love.timer.getTime() < mob.chat.when + 5 ) and ( love.timer.getTime() >= ( mob.chatNextGlyph ) ) and ( ( mob.chatGlyphIndex ) < utf8.len(mob.chat.text) ) ) then
			mob.chatNextGlyph = love.timer.getTime() + ( 1 / utf8.len(mob.chat.text) )
			mob.chatGlyphIndex = ( mob.chatGlyphIndex or 0 ) + 1;
			if( not mob.chatShown ) then
				mob.chatShown = ""
			end
			mob.chatShown = mob.chatShown .. string.sub(mob.chat.text, mob.chatGlyphIndex, mob.chatGlyphIndex )
			TEsound.play("sound/speech.wav", "static", {}, 1, 0.7)
		elseif( love.timer.getTime() >= mob.chat.when + 5 ) then
			mob.chatShown = ""
		end
	end
	if( mob.chatShown ) then
		pos = ( ( ( mob.x_draw - ( mapX - 1 ) ) * 40 ) - 20 ) - ( SG.fonts.label:getWidth(mob.chatShown) / 2 );
		love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
		love.graphics.rectangle("fill", pos - 1, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) - ( tileSize * 2 ), SG.fonts.label:getWidth(mob.chatShown), 20)
		love.graphics.setColor( 1, 1, 0, 1 );
		love.graphics.printf(mob.chatShown, SG.fonts.label, pos, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) - 76, w);
	end--[[
	if( mob.popup ) then
		local alpha = ( 1 / mob.popup.duration ) * ( v.end - CurTime() );
		pos = ( ( ( mob.x_draw - ( mapX - 1 ) ) * 40 ) - 20 ) - ( SG.fonts.label:getWidth(mob.chatShown) / 2 );
		love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
		love.graphics.rectangle("fill", pos - 1, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) - ( tileSize * 2 ), SG.fonts.label:getWidth(mob.chatShown), 20)
		love.graphics.setColor( mob.popup.color.r, mob.popup.color.g, mob.popup.color.b,  );
		love.graphics.printf(mob.chatShown, SG.fonts.label, pos, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) - 76, w);
	end--]]
	if( describingObject and describingObject.id == mob.id ) then
		local desc = mob.description or "Nondescript."
		if( not describingWhen ) then
			describingWhen = love.timer.getTime();
			describingNextGlyph = love.timer.getTime()
			describingGlyphIndex = 0
			describingShown = ""
			describingHealthAlpha = 0
		end
		if( ( love.timer.getTime() < describingWhen + 5 ) and ( love.timer.getTime() >= ( describingNextGlyph ) ) and ( ( describingGlyphIndex ) < utf8.len(desc) ) ) then
			describingNextGlyph = love.timer.getTime() + ( 1 / utf8.len(desc) )
			describingGlyphIndex = ( describingGlyphIndex or 0 ) + 1;
			if( not describingShown ) then
				describingShown = ""
			end
			describingShown = describingShown .. string.sub(desc, describingGlyphIndex, describingGlyphIndex)
			TEsound.play("sound/describe.wav", "static", {}, 1, 0.7)
			describingHealthAlpha = lerp( describingHealthAlpha, 1.2, 0.1, 1 )
		elseif( love.timer.getTime() >= describingWhen + 5 ) then
			describingShown = ""
			describingHealthAlpha = lerp( describingHealthAlpha, 0, 0.1, 1 )
		end
		if( describingHealthAlpha ) then
			local hearts = mob.healthMax / 2;
			local radius = 40;
			local angle = love.timer.getTime() % (2 * math.pi)
			local offset = ( (2 * math.pi) / hearts ) * describingHealthAlpha;
			love.graphics.setColor( 1, 1, 1, describingHealthAlpha )
			for h=1, hearts do
				local offsetangle = angle + ( offset * ( h - 1 ) )
				local hx, hy = math.cos(offsetangle) * radius, math.sin(offsetangle) * radius
				local sprite = "heart";
				if( h * 2 > mob.health ) then
					if( h * 2 > ( mob.health + 1 ) ) then
						sprite = "heartDead";
					else
						sprite = "heartHalf";
					end
				end
				love.graphics.draw(SG.tiles.ui[sprite][1], SG.tiles.ui[sprite][2], 
					( ( ( mob.x_draw - ( mapX - 1 ) ) * tileSize ) - tileSize ) + hx,
					( ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) - tileSize ) + hy)
			end
		end
		if( describingWhen ) then
			pos = ( ( ( mob.x_draw - ( mapX - 1 ) ) * tileSize ) - 20 ) - ( SG.fonts.label:getWidth(describingShown) / 2 );
			love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
			love.graphics.rectangle("fill", pos - 1, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ), SG.fonts.label:getWidth(describingShown), 20)
			love.graphics.setColor( 0, 1 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ), 1 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ), 1 );
			love.graphics.printf(describingShown, SG.fonts.label, pos, ( ( mob.y_draw - ( mapY - 1 ) ) * tileSize ) + 6, w);
		end
	end
	love.graphics.setColor( 1, 1, 1, 1 );
end
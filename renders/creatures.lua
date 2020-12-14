SG.renderTypeDraws["mob"] = function(item)
	local w, h = love.window.getMode();
	if( recognizedCoord and recognizedCoord[1] == item.x and recognizedCoord[2] == item.y ) then
		local name = item.name
		local pos = ( ( ( item.x_draw - ( mapX - 1 ) ) * 40 ) - 20 ) - ( SG.fonts.label:getWidth(name) / 2 );
		love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
		love.graphics.rectangle("fill", pos - 1, ( ( item.y_draw - ( mapY - 1 ) ) * 40 ) - 60, SG.fonts.label:getWidth(name), 20)
		love.graphics.setColor( 1, 1, 1, 1 );
		love.graphics.printf(name, SG.fonts.label, pos, ( ( item.y_draw - ( mapY - 1 ) ) * 40 ) - 54, w);
		if( not recognizedID or recognizedID ~= item.id ) then
			recognizedID = item.id
			TEsound.play("sound/recognize.wav", "static", {}, 1, 0.7)
		end
	end
	if( describingObject and describingObject.id == item.id ) then
		local desc = item.description or "Nondescript."
		if( not describingWhen ) then
			describingWhen = love.timer.getTime();
			describingNextGlyph = love.timer.getTime()
			describingGlyphIndex = 0
			describingShown = ""
		end
		if( ( love.timer.getTime() < describingWhen + 5 ) and ( love.timer.getTime() >= ( describingNextGlyph ) ) and ( ( describingGlyphIndex ) < utf8.len(desc) ) ) then
			describingNextGlyph = love.timer.getTime() + ( 1 / utf8.len(desc) )
			describingGlyphIndex = ( describingGlyphIndex or 0 ) + 1;
			if( not describingShown ) then
				describingShown = ""
			end
			describingShown = describingShown .. string.sub(desc, describingGlyphIndex, describingGlyphIndex)
			TEsound.play("sound/describe.wav", "static", {}, 1, 0.7)
		elseif( love.timer.getTime() >= describingWhen + 5 ) then
			describingShown = ""
		end
		if( describingWhen ) then
			pos = ( ( ( item.x_draw - ( mapX - 1 ) ) * 40 ) - 20 ) - ( SG.fonts.label:getWidth(describingShown) / 2 );
			love.graphics.setColor( 0, 0, 0, 0.7 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ) );
			love.graphics.rectangle("fill", pos - 1, ( ( item.y_draw - ( mapY - 1 ) ) * 40 ), SG.fonts.label:getWidth(describingShown), 20)
			love.graphics.setColor( 0, 1 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ), 1 + ( 0.25 * ( math.sin( love.timer.getTime() ) ) ), 1 );
			love.graphics.printf(describingShown, SG.fonts.label, pos, ( ( item.y_draw - ( mapY - 1 ) ) * 40 ) + 6, w);
		end
	end
end
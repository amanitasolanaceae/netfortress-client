SG.keybinds = {}
kbfile = love.filesystem.read("keybinds.txt")
for k, v in pairs( string.explode( kbfile, "\n" ) ) do
	local kb = string.explode( v, "|" )
	if( string.find( kb[2], "\r" ) ) then
		kb[2] = string.gsub(kb[2], "\r", "")
	end
	SG.keybinds[kb[2]] = kb[1];
end

SG.AVswitches = {}
avfile = love.filesystem.read("audiovisual.txt")
for k, v in pairs( string.explode( avfile, "\n" ) ) do
	local kb = string.explode( v, "|" )
	if( string.find( kb[2], "\r" ) ) then
		kb[2] = string.gsub(kb[2], "\r", "")
	end
	SG.AVswitches[kb[1]] = tobool(kb[2]);
end
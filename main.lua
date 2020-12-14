function requireDirectory( dir )
   dir = dir or ""
   local entities = love.filesystem.getDirectoryItems(dir)

   for k, ents in ipairs(entities) do
      trim = string.gsub( ents, ".lua", "")
      require(dir .. "/" .. trim)
   end
end

-- so the tabs don't look the same when editing them both
require("client")
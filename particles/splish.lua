SG.particles.splish = love.graphics.newParticleSystem(pixel, 256)
SG.particles.splish:setParticleLifetime(0.2, 0.2)
SG.particles.splish:setEmitterLifetime(0.2)
SG.particles.splish:setEmissionRate(50)
SG.particles.splish:setSizeVariation(0.5)
SG.particles.splish:setSizes( 0.8, 0.2 )
--SG.particles.splish:setLinearAcceleration(5, 5, 5, 5) -- Random movement in all directions.
SG.particles.splish:setColors(0, 0.4, 0.7, 1, 0, 0.4, 0.7, 0.2) -- Fade to transparency.
SG.particles.splish:setEmissionArea( "ellipse", 10, 10, 0, false )
SG.particles.splish:setSpread( 5 )
SG.particles.splish:setSpeed( 300 )
SG.particles.dust = love.graphics.newParticleSystem(pixel, 256)
SG.particles.dust:setParticleLifetime(2, 4)
SG.particles.dust:setEmitterLifetime(0.2)
SG.particles.dust:setEmissionRate(10)
SG.particles.dust:setSizeVariation(0.5)
SG.particles.dust:setSizes( 1, 0.4 )
SG.particles.dust:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
SG.particles.dust:setColors(0.5, 0.3, 0.2, 1, 0.5, 0.3, 0.2, 0.2) -- Fade to transparency.
SG.particles.dust:setEmissionArea( "ellipse", 10, 10, 0, false )
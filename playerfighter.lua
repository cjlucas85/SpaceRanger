require 'base'
class = require 'class'
require 'rectangle'
gamestate = require 'gamestate'
vector = require 'vector'
require 'fighter'
require 'torpedo'
require 'controls'

playerfighter = class{
	function (self)
		self.fighter = fighter("TriangleFighter")
		self.cam = nil
		self.left = false
		self.right = false
		self.up = false
		self.down = false
		self.accelerateheldtime = 0
		self.speedinc = 20
		self.maxspeed = 250
		self.rotatevelocity = (math.pi)
		self.drift = vector(0, 0)
		self.navigation = true
		self.hitpointsmax = 100
		self.hitpoints = self.hitpointsmax
		self.torpedosmax = 20
		self.torpedos = self.torpedosmax
		self.fuelmax = 100
		self.fuel = self.fuelmax
		self.changed = false
		self.fuelcost = 10 -- per second
		self.fuelregen = 5 -- per second
		self.torpedoregen = 1 -- per second
		self.thrustsound = love.audio.newSource("Sounds/Thrust.wav")
		self.thrustsoundplaying = false
		self.points = 0
		self.lives = 1 -- 3
		self.nextlevelpoints = 500
	end
}

function playerfighter:updateposition(held, dt)
	local s = held * self.speedinc
	local newdrift = self.drift + vector(math.cos(self.fighter.properties.r) * s, math.sin(self.fighter.properties.r) * s)
	if newdrift:len() > self.maxspeed then
		self.drift = newdrift:normalized() * self.maxspeed
	else
		self.drift = newdrift
	end
	local movex = self.drift.x * dt
	local movey = self.drift.y * dt
	self.fighter.properties.x = movex + self.fighter.properties.x
	self.fighter.properties.y = movey + self.fighter.properties.y
	if self.cam then
		self.cam:move(movex, movey)
	end
end

function playerfighter:update(dt)
	local fuelregen = self.fuelregen * dt
	local fuelcost = self.fuelcost * dt
	local rotatevelocity = self.rotatevelocity * dt
	-- Regenerate Torpedos
	if self.torpedos < self.torpedosmax then
		self.torpedos = math.min(self.torpedos + self.torpedoregen * dt, self.torpedosmax)
		self.changed = true
	end
	-- Direction
	if self.left == true and self.right == false then
		self.fighter.properties:rotateBy(-rotatevelocity)
	elseif self.right == true and self.left == false then
		self.fighter.properties:rotateBy(rotatevelocity)
	end
	-- Fuel Drained
	if self.fuel == 0 then
		self.fuel = 1
		self.changed = true
		self:updateposition(0, dt)
		return
	end
	
	if self.up == true and self.down == false and self.fuel >= fuelcost then
		if self.thrustsoundplaying == false then
			self.thrustsound:play()
			self.thrustsoundplaying = true
		end
		self.accelerateheldtime = math.min(self.accelerateheldtime + dt, 1)
		self:updateposition(self.accelerateheldtime, dt)
		self.fuel = math.max(self.fuel - fuelcost, 0)
		self.changed = self.fuel > 0 or self.changed
		self.fighter.showthruster = true
	elseif self.down == true and self.up == false then
		local driftlen = self.drift:len()
		if driftlen < 0.05 then
			self.drift = vector(0,0)
		else
			self.drift = self.drift:normalized() * (driftlen * 0.99)
		end
		self.accelerateheldtime = 0
		self:updateposition(0, dt)
		self.fighter.showthruster = false
	else
		self:updateposition(0, dt)
		self.fuel = math.min(self.fuel + fuelregen, self.fuelmax)
		self.changed = self.fuel < self.fuelmax or self.changed
		self.fighter.showthruster = false
	end
	
	collision = self.fighter:collides(collidepoint.x, collidepoint.y)
end

function playerfighter:keypressed(key, unicode)
	if key == controls.move then self.up = true end
	if key == controls.stop then self.down = true end
	if key == controls.turnleft then self.left = true end
	if key == controls.turnright then self.right = true end
	if key == controls.navigation then self.navigation = not self.navigation end
	if key == controls.fire and self.torpedos >= 1 then
		local tip = self.fighter:frontpoint()
		local t = torpedo(tip.x, tip.y, self.fighter.properties.r, 500)
		self.torpedos = self.torpedos - 1
		if self.callbackmanager then
			self.callbackmanager:add(t)
		end
		self.changed = true
	end
end

function playerfighter:keyreleased(key, unicode)
	if key == controls.move then 
		self.thrustsoundplaying = false
		self.thrustsound:stop()
		self.thrustsound:rewind()
		self.up = false 
	end
	if key == controls.stop then self.down = false end
	if key == controls.turnleft then self.left = false end
	if key == controls.turnright then self.right = false end
end

function playerfighter:draw()
	if self.navigation then
		local x = self.fighter.properties.x
		local y = self.fighter.properties.y
		local w = self.fighter.properties.w
		local h = self.fighter.properties.h
		local frontvector = self.drift:normalized() * 50
		local fvx = frontvector.x
		local fvy = frontvector.y
		love.graphics.line(x + w, y + h, x + w + fvx, y + h + fvy)
	end
	local cp = self.fighter:centerpoint()
	local fp = self.fighter:frontpoint()
	self.fighter:draw()
end

function playerfighter:addpoints(num)
	self.points = self.points + num
	if self.points >= self.nextlevelpoints then 
		self.lives = self.lives + 1
		self.nextlevelpoints = 2 * self.nextlevelpoints
	end
end

function playerfighter:death()
	self.lives = self.lives - 1
	if self.lives > 0 then
		self.immune = true
		self.hitpoints = self.hitpointsmax
		self.changed = true
	else
		-- switch state to game over.
	end
end

function playerfighter:torpedohit()
	self.hitpoints = self.hitpoints - 5
	self.changed = true
	if self.hitpoints <= 0 then
		self:death()
	end
end

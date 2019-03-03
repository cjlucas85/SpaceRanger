require 'base'
class = require 'class'
require 'rectangle'

torpedo = class{
	function(self, x, y, r, speed)
		self.texture = image("Torpedo")
		self.properties = rectangle(x, y, self.texture:getWidth(), self.texture:getHeight(), r)
		self.speed = speed
		self.start = vector(x, y)
		self.current = vector(x, y)
		self.torpedoid = torpedo.maxtorpedoid()
		self.lifespan = 2000
		torpedo.entities[self.torpedoid] = self
		self.timer = 0.1 -- countdown until it's safe to collide
		love.audio.play(love.audio.newSource("Sounds/Torpedo.wav"))
	end
}

torpedo.entities = {}
torpedo.lastid = 0
function torpedo.maxtorpedoid()
	torpedo.lastid = torpedo.lastid + 1
	return torpedo.lastid
end

function torpedo:update(dt)
	if self.torpedoid == 0 then return end
	local x = self.properties.x
	local y = self.properties.y
	x = math.cos(self.properties.r) * self.speed * dt + x
	y = math.sin(self.properties.r) * self.speed * dt + y
	self.current = vector(x, y)
	if (self.current:dist(self.start) > self.lifespan) then
		self:delete()
		return
	end
	self.properties.x = x
	self.properties.y = y
	
	-- Logical Kludge
	-- There's a possibility that the ship runs into it's own bullet, this aims to avoid that.
	self.timer = self.timer - dt
	if self.timer >= 0 then
		self.timer = -1 -- keep it at a negative number
		return
	end
	
	for i, entity in pairs(self.callbackmanager.entities) do
		if entity.fighter and entity.fighter.collides and entity.fighter:collides(x,y) then
			self:delete()
			entity:torpedohit()
			love.audio.play(love.audio.newSource("Sounds/Torpedo Hit.wav"))
		end
	end
end

function torpedo:delete()
	torpedo.entities[self.torpedoid] = nil
	if self.callbackmanager then
		self.callbackmanager:remove(self)
	end
	self.torpedoid = 0
end

function torpedo:draw(dt)
	if self.torpedoid == 0 then return end
	local x = self.properties.x
	local y = self.properties.y
	local r = self.properties.r
	local w = self.properties.w
	local h = self.properties.h
	love.graphics.draw(self.texture, x, y, r, 1, 1, w/2, h/2)
end
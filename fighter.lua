require 'base'
class = require 'class'
require 'rectangle'
gamestate = require 'gamestate'
vector = require 'vector'

collidepoint = vector(400, 400)
collision = false

fighter = class{
	function(self, texturestring)
		self.body = image(texturestring or "TriangleFighter")
		self.thruster = image("Thruster")
		local w = self.body:getWidth()
		local h = self.body:getHeight()
		local x = love.graphics.getWidth() / 2 - (w/2)
		local y = love.graphics.getHeight() / 2 - (h/2)
		self.properties = rectangle(x, y, w, h)
		self.fighterid = fighter.maxentityindex()
		fighter.entities[self.fighterid] = self
		self.showthruster = false
	end
}

fighter.entities = {}
fighter.lastentityid = 0
function fighter.maxentityindex()
	fighter.lastentityid = fighter.lastentityid + 1
	return fighter.lastentityid
end

function fighter:centerpoint()
	local x = self.properties.x + self.properties.w
	local y = self.properties.y + self.properties.h
	return vector(x, y)
end

function fighter:frontpoint()
	local center = self:centerpoint()
	local halflength = self.properties.w / 2
	local middletofront = vector(math.cos(self.properties.r) * halflength, math.sin(self.properties.r) * halflength)
	return center + middletofront
end

-- 10 points until out of craft
function fighter:rightwingcenterpoint()
	local len = 23.3
	local d = 133.26
	local r = self.properties.r + math.rad(d)
	local center = self:centerpoint()
	local halflength = self.properties.h / 2
	local middletofront = vector(math.cos(r) * len, math.sin(r) * len)
	return center + middletofront
end

-- 10 points until out of craft
function fighter:leftwingcenterpoint()
	local len = 23.3
	local d = -133.26
	local r = self.properties.r + math.rad(d)
	local center = self:centerpoint()
	local halflength = self.properties.h / 2
	local middletofront = vector(math.cos(r) * len, math.sin(r) * len)
	return center + middletofront
end

-- 9 points until out of craft
function fighter:cockpitcenterpoint()
	local center = self:centerpoint()
	local len = 17
	local middletofront = vector(math.cos(self.properties.r) * len, math.sin(self.properties.r) * len)
	return center + middletofront
end

function fighter:exhaustpoint()
	local center = self:centerpoint()
	local len = -17
	local middletofront = vector(math.cos(self.properties.r) * len, math.sin(self.properties.r) * len)
	return center + middletofront
end

function fighter:collides(x, y)
	local v = vector(x, y)
	if v:dist(self:centerpoint()) >= 45 then
		return false
	else
		return v:dist(self:leftwingcenterpoint()) <= 10 or 
		v:dist(self:rightwingcenterpoint()) <= 10 or
		v:dist(self:cockpitcenterpoint()) <= 9 or
		v:dist(self:centerpoint()) <= 18
	end
	return false
end

function fighter:collideswithship(x, y)
	local v = vector(x, y)
	if v:dist(self:centerpoint()) >= 90 then
		return false
	else
		return v:dist(self:leftwingcenterpoint()) <= 20 or 
		v:dist(self:rightwingcenterpoint()) <= 20 or
		v:dist(self:cockpitcenterpoint()) <= 18 or
		v:dist(self:centerpoint()) <= 36
	end
	return false
end

function fighter:draw()
	local x = self.properties.x
	local y = self.properties.y
	local w = self.properties.w
	local h = self.properties.h
	love.graphics.draw(self.body, x + w, y + h, 
	self.properties.r, 1, 1, w/2, h/2)
	local exhaust = self:exhaustpoint()
	if self.showthruster then
		love.graphics.draw(self.thruster, exhaust.x, exhaust.y, self.properties.r, 1, 1,14, 8)
	end
end

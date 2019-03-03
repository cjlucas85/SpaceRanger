require 'base'
class = require 'class'
require 'progressbar'

hud = class{
	function(self)
		self.backgroundheight = 20
		self.topleft = vector(0, love.graphics.getHeight() - self.backgroundheight)
		self.font = font("CS", 12)
		self.healthbar = progressbar(65, self.topleft.y + 10, 100, 10, 1)
		self.fuelbar = progressbar(220, self.topleft.y + 10, 100, 10, 1)
		self.torpedobar = progressbar(400, self.topleft.y + 10, 100, 10, 1)
		self.backgroundstart = vector(self.topleft.x, self.topleft.y + 14)
		self.backgroundend = vector(love.graphics.getWidth(), self.topleft.y + 14)
		self.playerfighter = nil
	end
}

function hud:update(dt)
	if self.playerfighter and self.playerfighter.changed then
		self.playerfighter.changed = false
		self.healthbar:setProgress(self.playerfighter.hitpoints / self.playerfighter.hitpointsmax)
		self.fuelbar:setProgress(self.playerfighter.fuel / self.playerfighter.fuelmax)
		self.torpedobar:setProgress(self.playerfighter.torpedos / self.playerfighter.torpedosmax)
		self.healthbar:update(dt)
		self.fuelbar:update(dt)
		self.torpedobar:update(dt)
	end
end

function hud:draw()
	love.graphics.setFont(self.font)
	local r, g, b, a = love.graphics.getColor()
	local h = love.graphics.getLineWidth()
	love.graphics.setLineWidth(self.backgroundheight)
	love.graphics.setColor(0, 0, 0, 255, a)
	love.graphics.line(self.backgroundstart.x, self.backgroundstart.y + 2, self.backgroundend.x, self.backgroundend.y)
	love.graphics.setLineWidth(h)
	love.graphics.setColor(r,g,b,a)
	love.graphics.print("Health:", 15, self.topleft.y + 12)
	self.healthbar:draw()
	love.graphics.print("Fuel:", 185, self.topleft.y + 12)
	self.fuelbar:draw()
	love.graphics.print("Torpedo:", 340, self.topleft.y + 12)
	self.torpedobar:draw()
	love.graphics.print("Lives: " .. self.playerfighter.lives, 515, self.topleft.y + 12)
	love.graphics.print("Score: " .. self.playerfighter.points, 585, self.topleft.y + 12)
end

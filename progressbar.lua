require 'base'
class = require 'class'
require 'rectangle'
vector = require 'vector'

progressbar = class {
	function(self, x, y, w, h, progress)
		self.progress = progress
		self.progressupdate = false
		self.background = {255, 255, 255, 255}
		self.foreground = {255, 0, 0, 255}
		self.start = vector(x, y + h/2)
		self.stop = vector(x + w, y + h/2)
		self.width = w
		self.height = h
		self:updateprogress(progress)
	end
}

function progressbar:updateprogress()
	if self.progress > 1 then self.progress = 1 end
	if self.progress < 0 then self.progress = 0 end
	self.progresspoint = vector(self.start.x + (self.width * self.progress), self.start.y)
end

function progressbar:setProgress(progress)
	self.progress = progress
	self.progressupdate = true
end

function progressbar:update(dt)
	if self.progressupdate then
		self:updateprogress()
	end
end

function progressbar:keypressed(key, unicode)
	if key == " " then
		self:setProgress(self.progress + 0.05)
	end
	if key == 'return' then
		self:setProgress(self.progress - 0.05)
	end
end

function progressbar:draw()
	local r, g, b, a = love.graphics.getColor()
	self.background[4] = a
	self.foreground[4] = a
	local width = love.graphics.getLineWidth()
	love.graphics.setLineWidth(self.height)
	love.graphics.setColor(self.background)
	love.graphics.line(self.start.x, self.start.y, self.stop.x, self.stop.y)
	love.graphics.setColor(self.foreground)
	love.graphics.line(self.start.x, self.start.y, self.progresspoint.x, self.progresspoint.y)
	love.graphics.setColor(r, g, b, a)
	love.graphics.setLineWidth(width)
end
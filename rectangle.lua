class = require 'class'

--[[
Sprite Class

sprite(x-position, y-position, width, height, rotate)
--]]
rectangle = class{
	function(self, ...)
		self.x = arg[1] or 0
		self.y = arg[2] or 0
		self.w = arg[3] or 0
		self.h = arg[4] or 0
		self.r = arg[5] or 0
	end
}

function rectangle:getall()
	return x, y, w, h, r
end

function rectangle:move(x, y)
	self.x = x
	self.y = y
end

function rectangle:moveBy(x, y)
	self.x = self.x + x
	self.y = self.y + y
end

function rectangle:rotate(r)
	self.r = r
end

function rectangle:rotateBy(r)
	self.r = self.r + r
end





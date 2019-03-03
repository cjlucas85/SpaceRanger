require 'base'
class = require 'class'
require 'rectangle'

menu = class{
	function(self, fontname, fontsize, wrap) --selectcolor, color, wrap)
		self.properties = rectangle()
		self.items = {}
		self.callbacks = {}
		self.selected = 0
		self.font = font(fontname, fontsize)
		self.fontheight = self.font:getHeight()
		self.fontlineheight = self.fontheight
		--self.selectcolor = highlight
		--self.color = color
		self.wrap = warp
	end
}

function menu:add(item, callback)
	local itemnumber = #self.items + 1
	self.items[itemnumber] = item
	if callback then
		self.callbacks[#self.callbacks + 1] = callback
	else
		self.callbacks[#self.callbacks + 1] = 0
	end
	if self.selected == 0 then self.selected = 1 end
	return itemnumber
end

function menu:up()
	if #self.items == 0 then return end
	if self.selected == 1 then
		if self.wrap then
			self.selected = #self.items
		end
	else
		self.selected = self.selected - 1
	end
end

function menu:down()
	if #self.items == 0 then return end
	if self.selected == #self.items then
		if self.wrap then
			self.selected = 1
		end
	else
		self.selected = self.selected + 1
	end
end

function menu:draw()
	local y = 0
	local lastFont = love.graphics.getFont()
	love.graphics.setFont(self.font)
	for i, v in ipairs(self.items) do
		if i == self.selected then
			local r, g, b, a = love.graphics.getColor()
			love.graphics.setColor(255, 0, 0)
			love.graphics.print(v, self.properties.x, y * self.fontlineheight + self.properties.y)
			love.graphics.setColor(r, g, b, a)
		else
			love.graphics.print(v, self.properties.x, y * self.fontlineheight + self.properties.y)
		end
		y = y + 1
	end
	if lastFont then love.graphics.setFont(lastFont) end
end

function menu:select()
	if #self.items == 0 then return end
	callback = self.callbacks[self.selected]
	if type(callback) == "function" then
		callback()
	end
end

function menu:setPosition(x, y)
	self.properties:move(x, y)
end

function menu:setSize(width, height)
	self.properties:setSize(width, height)
end

function menu:setSpacing(h)
	self.fontlineheight = self.fontheight + h
end

function menu:setItem(line, msg)
	if line < 0 or line > #self.items then return end
	self.items[line] = msg
end

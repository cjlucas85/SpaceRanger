require 'base'
class = require 'class'

starmap = class{
	function(self, camera)
		-- "Cheap" way of making it more random for star3 to come up
		self.textures = {
			image("Stars1"),
			image("Stars2"),
			image("Stars3"),
			image("Stars4"),
			image("Stars5"),
			image("Stars1"),
			image("Stars2"),
			image("Stars4"),
			image("Stars5"),
			image("Stars1"),
			image("Stars2"),
			image("Stars4"),
			image("Stars5")
		}
		self.texturewidth = self.textures[1]:getWidth()
		self.textureheight = self.textures[1]:getHeight()
		self.backdrop = {} --  backdrop['rows']['columns']
		self.lastupdateposition = vector(0, 0)
		self.vtiles = (love.graphics.getHeight() / self.textureheight) + 1
		self.htiles = (love.graphics.getWidth() / self.texturewidth) + 1
		self.vpos = 0
		self.hpos = 0
		self.vmove = 0
		self.hmove = 0
		self.x = 0
		self.y = 0
		self.cam = camera
		for h = -1, self.htiles  do
			for v = -1, self.vtiles  do
				if type(self.backdrop[h]) == "nil" then self.backdrop[h] = {} end
				self.backdrop[h][v] = self.textures[math.random(1, #self.textures)]
			end
		end
	end
}

function starmap:update()
	
	if self.cam then
		self.x, self.y = self.cam:worldCoords(0,0)
	end
	local htemp = self.x / self.texturewidth
	local vtemp = self.y / self.textureheight
	if vtemp < 0 then
		vtemp = math.floor(vtemp)
	else
		vtemp = math.ceil(vtemp)
	end
	if htemp < 0 then 
		htemp = math.floor(htemp)
	else
		htemp = math.ceil(htemp)
	end
	
	if vtemp ~= self.vpos or htemp ~= self.hpos then
		self.vpos = vtemp
		self.hpos = htemp
		-- evaluate table
		for v = vtemp - 1, vtemp + self.vtiles + 1 do
			for h = htemp - 1, htemp + self.htiles + 1 do
				if type(self.backdrop[h]) == "nil" then
					self.backdrop[h] = {}
				end
				if type(self.backdrop[h][v]) == "nil" then
					self.backdrop[h][v] = self.textures[math.random(1, #self.textures)]
				end
			end
		end
	else
		self.vpos = vtemp
		self.hpos = htemp
	end
end

function starmap:draw()
	for h = self.hpos - 1, self.hpos + self.htiles  do
		for v = self.vpos - 1, self.vpos + self.vtiles  do
			love.graphics.draw(self.backdrop[h][v], h * self.texturewidth, v * self.textureheight)
		end
	end
end

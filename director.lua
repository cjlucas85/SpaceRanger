require 'base'
class = require 'class'

director = class{
	function(self, playerfighter)
		self.playerfighter = playerfighter
		self.timer = 0
		self.respawntime = 2 -- seconds
		local adjustment = 200
		local maxspeed = self.playerfighter.maxspeed
		local w = love.graphics.getWidth() + adjustment
		local h = love.graphics.getHeight() + adjustment
		local s = math.max(maxspeed + w, maxspeed + h)
		self.enemyspacing = s
	end
}

function director:update(dt)
	local enemies = enemyfighter.count or 0
	if enemies < 4 then
		if self.timer < self.respawntime then
			self.timer = self.timer + dt
		else
			self.timer = 0
			local x, y = self.playerfighter.fighter.properties.x, self.playerfighter.fighter.properties.y
			self:spawnenemies(x, y)
		end
	end
end

--[[ Spawn Points

x - spacing, y +spaceing		x, y + spacing 			x + spacing, y + spacing

x - spacing, y				player				x + spacing, y

x - spacing, y - spacing		x, y - spacing			x + spacing, y - spacing
--]]
function director:spawnenemies(x, y)
	local spacing = self.enemyspacing
	-- Clock wise starting with center top
	spawnx ={x, x + spacing, x + spacing, x + spacing, x, x-spacing, x - spacing, x - spacing}
	spawny = {y + spacing, y + spacing, y, y - spacing, y - spacing, y - spacing, y, y + spacing}
	for i, v in pairs(spawnx) do
		local e = enemyfighter(spawnx[i], spawny[i])
		e.player = self.playerfighter
		self.callbackmanager:add(e)
	end
end


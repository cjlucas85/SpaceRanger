require 'base'
class = require 'class'
require 'fighter'

enemyfighter = class {
	function(self, x, y, r)
		self.fighter = fighter("EnemyTriangleFighter")
		self.fighter.properties.x = x or 0
		self.fighter.properties.y = y or 0
		self.fighter.properties.r = r or 0
		self.speedinc = 20
		self.patrolspeed = 100
		self.pursuespeed = 200
		self.evadespeed = 250
		self.rotatevelocity = (math.pi)
		self.drift = vector(0, 0)
		self.hitpoints = 100
		self.hitpointsmax = 100
		self.state = self.examine
		self.player = fighter()
		self.angularvelocity = math.pi / 4
		self.patrolinit = vector(x, y)
		self.patrolxmax = 100
		self.patrolymax = 100
		self.patroldestination = nil
		self.shottimer = 0
		self.shootinterval = 0.5
		self.stunspeed = 150
		self.isdead = false -- make double sure it's dead
		self.pointsforhit = 50
		self.pointsfordeath = 100
		if enemyfighter.count then
			enemyfighter.count = enemyfighter.count + 1
		else
			enemyfighter.count = 1
		end
	end
}

function enemyfighter:update(dt)
	if self.isdead then return end
	self.state(self, dt)
end

function enemyfighter:draw()
	if self.isdead then return end
	self.fighter:draw()
end
--[[
function enemyfighter:driftandstun(dt)
	if type(self.drifttimer) == "nil" then
		self.drifttimer = self.drifttimer + dt
	elseif self.drifttimer > 2
		self.driftimer = nil
		self.state = enemyfighter.examine
	else
		self.drifttimer = 0
	end
	self:applythrust(dt, 150)
end
--]]
function enemyfighter:examine(dt)
	if self:neardeath() then return end
	local player = self.player.fighter:centerpoint()
	local enemy = self.fighter:centerpoint()
	local enemy = self.fighter:centerpoint()
	local playerdist = player:dist(enemy)
	if playerdist > 1000 then
		self.state = enemyfighter.patrol
	elseif playerdist < 500 then
		self.state = enemyfighter.stopandshoot
	else
		self.state = enemyfighter.pursue
	end
end

function enemyfighter:generatepatroldestination()
	local x, y = self.patrolinit.x, self.patrolinit.y
	local lowx = x - self.patrolxmax
	local highx = x + self.patrolxmax
	local lowy = y - self.patrolymax
	local highy = y + self.patrolymax
	x = math.random(lowx, highx)
	y = math.random(lowy, highy)
	self.patroldestination = vector(x, y)
end

function enemyfighter:patrol(dt)
	if self:neardeath() then return end

	if type(self.patroldestination) == "nil" then
		self:generatepatroldestination()
	end
	
	local player = self.player.fighter:centerpoint()
	local playerfront = self.player.fighter:frontpoint()
	local enemy = self.fighter:centerpoint()
	local enemyfront = self.fighter:frontpoint()
	local angle = getAngle(enemyfront, enemy, player)
	
	if player:dist(enemy) >= 5000 then
		self:delete()
	elseif player:dist(enemy) < 800 or self.hitpoints <= 90 then
		self.state = enemyfighter.pursue
		return
	end
	if self.fighter:centerpoint():dist(self.patroldestination) < 50 then
		self.patroldestination = vector(math.random(0, 1000), math.random(0, 1000))
		return
	end
	angle = getAngle(enemyfront, enemy, self.patroldestination)
	if math.abs(angle) < 0.05 then -- keep going
		self:applythrust(dt, self.patrolspeed)
	elseif angle < 0 then -- steer right
		self.fighter.properties:rotateBy(self.rotatevelocity * dt)
		self:applythrust(dt, self.patrolspeed)
	else -- steer left
		self.fighter.properties:rotateBy(-self.rotatevelocity * dt)
		self:applythrust(dt, self.patrolspeed)
	end
end

function enemyfighter:pursue(dt)
	if self:neardeath() then return end
	
	local player = self.player.fighter:centerpoint()
	local enemy = self.fighter:centerpoint()
	local playerdist = player:dist(enemy)
	if playerdist < 450 then
		self.state = enemyfighter.stopandshoot
		return
	elseif playerdist > 1000 then
		self.state = enemyfighter.patrol
	end
	local enemyfront = self.fighter:frontpoint()
	local angle = getAngle(enemyfront, enemy, player)

	if math.abs(angle) < 0.05 then -- keep going
		self:applythrust(dt, self.pursuespeed)
		self:fire(dt)
	elseif angle < 0 then -- steer right
		self.fighter.properties:rotateBy(self.rotatevelocity * dt)
		self:applythrust(dt, self.evadespeed)
	else -- steer left
		self.fighter.properties:rotateBy(-self.rotatevelocity * dt)
		self:applythrust(dt, self.evadespeed)
	end
end

function enemyfighter:stopandshoot(dt)
	if self:neardeath() then return end
	
	local player = self.player.fighter:centerpoint()
	local enemy = self.fighter:centerpoint()
	if player:dist(enemy) > 500 then
		self.state = enemyfighter.pursue
		self.shottimer = 0
		return
	end
	local playerdriftpredict = player
	if self.player.drift.x ~= 0 or self.player.drift.y ~= 0 then
		playerdriftpredict = self.player.drift:normalized() * 80
		playerdriftpredict.x = playerdriftpredict.x + player.x
		playerdriftpredict.y = playerdriftpredict.y + player.y
	end
	local enemyfront = self.fighter:frontpoint()
	local angle = getAngle(enemyfront, enemy, playerdriftpredict)
	
	if math.abs(angle) < 0.05 then -- finished in place turn
		self:fire(dt)
	elseif angle < 0 then -- steer left
		self.fighter.properties:rotateBy(self.rotatevelocity * dt)
	else -- steer right
		self.fighter.properties:rotateBy(-self.rotatevelocity * dt)
	end
end

--[[
To begin evasion is to turn around in place. The player may be too close, so 
this bit of the AI does the work of turning the ship around to setup for the
run
--]]
function enemyfighter:beginevade(dt)
	local player = self.player.fighter:centerpoint()
	local enemy = self.fighter:centerpoint()
	if player:dist(enemy) > 500 then
		self.state = enemyfighter.evade
		return
	end
	local enemyfront = self.fighter:frontpoint()
	local angle = getAngle(enemyfront, enemy, player)

	if math.abs(angle) > 3 then -- finished in place turn
		self.state = enemyfighter.evade
	elseif angle > 0 then -- steer right
		self.fighter.properties:rotateBy(self.rotatevelocity * dt)
	else -- steer left
		self.fighter.properties:rotateBy(-self.rotatevelocity * dt)
	end
end

--[[
This will be the evade portion where the ship makes its getaway.
--]]
function enemyfighter:evade(dt)
	local player = self.player.fighter:centerpoint()
	local enemy = self.fighter:centerpoint()
	if player:dist(enemy) > 3000 then
		self.state = enemyfighter.successfulskirmish
		return
	end
	local enemyfront = self.fighter:frontpoint()
	local angle = getAngle(enemyfront, enemy, player)
	if math.abs(angle) > 3 then -- keep going
		self:applythrust(dt, self.evadespeed)
	elseif angle > 0 then -- steer right
		self.fighter.properties:rotateBy(self.rotatevelocity * dt)
		self:applythrust(dt, self.evadespeed)
	else -- steer left
		self.fighter.properties:rotateBy(-self.rotatevelocity * dt)
		self:applythrust(dt, self.evadespeed)
	end
end

function enemyfighter:fire(dt)
	self.shottimer = self.shottimer + dt
	if self.shottimer > self.shootinterval then
		self.shottimer = self.shottimer - self.shootinterval
	else
		return
	end
	local tip = self.fighter:frontpoint()
	local t = torpedo(tip.x, tip.y, self.fighter.properties.r, 500)
	if self.callbackmanager then
		self.callbackmanager:add(t)
	end
end

function enemyfighter:neardeath()
	if self.hitpoints <= 20 then
		self.state = self.evade
		return true
	end
	return false
end

function enemyfighter:applythrust(dt, speed)
	local properties = self.fighter.properties
	local r = properties.r
	self.drift = vector(math.cos(r), math.sin(r))
	local drift = self.drift
	properties.x = drift.x * speed * dt + properties.x
	properties.y = drift.y * speed * dt + properties.y
end

function enemyfighter:successfulskirmish(dt)
	if self.callbackmanager then
		self:delete()
	end
end

function enemyfighter:torpedohit()
	self.hitpoints = self.hitpoints - 20
	if self.hitpoints == 0 then
		self:delete(true)
		return
	end
	self.player:addpoints(self.pointsforhit)
end

function enemyfighter:delete(playercaused)
	if self.callbackmanager then
		self.callbackmanager:remove(self)
		self.isdead = true
	end
	if playercaused then
		self.player:addpoints(self.pointsfordeath)
	end
	enemyfighter.count = enemyfighter.count - 1
end

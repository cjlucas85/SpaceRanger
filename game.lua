require 'base'
class = require 'class'
require 'hud'
require 'playerfighter'
require 'enemyfighter'
require 'callbackmanager'
require 'fighter'
camera = require 'camera'
require 'starmap'
require 'gameover'
require 'director'
require 'askquit'

game = class{
	function(self)
		self.hud = hud()
		self.cam = camera()
		self.playerfighter = playerfighter()
		self.playerfighter.cam = self.cam
		self.hud.playerfighter = self.playerfighter
		self.backdrop = starmap(self.cam)
		self.cm = callbackmanager(self.playerfighter, director(self.playerfighter))
		self.music = song("Music.wav")
		self.music:setLooping(true)
		self.music:setVolume(0.4)
		love.audio.play(self.music)
	end
}

function game:keypressed(key, unicode)
	if key == "escape" then
		askquit.lastgame = self
		self.callbackmanager:add(askquit)
		self.callbackmanager:remove(self)
	end
	self.cm:execute("keypressed", key, unicode)
end

function game:keyreleased(key, unicode)
	self.cm:execute("keyreleased", key, unicode)
end

function game:update(dt)
	if self.playerfighter.lives <= 0 then
		local go = gameover
		go.lastgame = self
		self.callbackmanager:add(go)
		self.callbackmanager:remove(self)
		love.audio.pause(self.music)
	end
	self.cm:execute("update", dt)
	self.backdrop:update()
	self.hud:update()
end

function game:continue()
	love.audio.play(self.music)
end

function game:exit()
	love.audio.stop(self.music)
end

function game:draw()
	self.cam:attach()
	self.backdrop:draw()
	self.cm:execute("draw", dt)
	self.cam:detach()
	self.hud:draw()
end

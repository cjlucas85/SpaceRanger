require 'base'
require 'greetscreen'

--love.graphics.setMode(0, 0, true)
gamestate = callbackmanager(greetscreen)

function love.load()
	love.mouse.setVisible(false)
	gamestate:execute("load")
end

function love.keypressed(key, unicode)
	gamestate:execute("keypressed", key, unicode)
end

function love.keyreleased(key, unicode)
	gamestate:execute("keyreleased", key, unicode)
end

function love.update(dt)
	gamestate:execute("update", dt)
end

function love.draw()
	gamestate:execute("draw")
end
require 'base'
class = require 'class'
require 'menu'

gameover = {}

function gameover.playagain()
	if gameover.callbackmanager then
		gameover.callbackmanager:add(game())
		gameover.callbackmanager:remove(gameover)
	end
	gameover.init()
end

function gameover.mainmenu()
	if gameover.callbackmanager then
		gameover.callbackmanager:add(greetscreen)
		gameover.callbackmanager:remove(gameover)
	end
	gameover.init()
end

function gameover.quit()
	os.exit(0)
end

function gameover.init()
	gameover.titlefont = font("CS", 48)
	gameover.title = "GAME OVER"
	gameover.lastgame = nil
	gameover.options = menu("CS", 24, true)
	local m = gameover.options
	m:add("Play Again", gameover.playagain)
	m:add("Main Menu", gameover.mainmenu)
	m:add("Quit", gameover.quit)
	m:setPosition(50, 92)
	m:setSpacing(10)
end

gameover.init()

function gameover.keypressed(key, unicode)
	local m = gameover.options
	if key == "w" or key == "up" then
		m:up()
	elseif key == "s" or key == "down" then
		m:down()
	elseif key == "return" or key == " " then
		m:select()
	end
end

function gameover.draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(r, g, b, 50)
	if gameover.lastgame then
		gameover.lastgame:draw()
	end
	love.graphics.setColor(r, g, b, a)
	love.graphics.setFont(gameover.titlefont)
	love.graphics.print(gameover.title, 50, 50)
	gameover.options:draw()
end

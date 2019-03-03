require 'base'
class = require 'class'
require 'menu'

askquit = {}

function askquit.continue()
	if askquit.callbackmanager and askquit.lastgame then
		askquit.callbackmanager:add(askquit.lastgame)
		askquit.callbackmanager:remove(askquit)
		askquit.lastgame:continue()
	end
	askquit.init()
end

function askquit.mainmenu()
	if askquit.callbackmanager then
		--greetscreen.load()
		askquit.callbackmanager:add(greetscreen)
		askquit.callbackmanager:remove(askquit)
		askquit.lastgame:exit()
		askquit.init()
	end
end

function askquit.quit()
	os.exit(0)
end

function askquit.init()
	askquit.titlefont = font("CS", 48)
	askquit.title = "Do you want to quit?"
	askquit.lastgame = nil
	askquit.options = menu("CS", 24, true)
	local m = askquit.options
	m:add("Continue", askquit.continue)
	--m:add("Main Menu", askquit.mainmenu)
	m:add("Quit", askquit.quit)
	m:setPosition(50, 92)
	m:setSpacing(10)
end

askquit.init()

function askquit.keypressed(key, unicode)
	local m = askquit.options
	if key == "w" or key == "up" then
		m:up()
	elseif key == "s" or key == "down" then
		m:down()
	elseif key == "return" or key == " " then
		m:select()
	end
end

function askquit.draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(r, g, b, 50)
	if askquit.lastgame then
		askquit.lastgame:draw()
	end
	love.graphics.setColor(r, g, b, a)
	love.graphics.setFont(askquit.titlefont)
	love.graphics.print(askquit.title, 50, 50)
	askquit.options:draw()
end

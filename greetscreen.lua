require 'base'
class = require 'class'
require 'game'
require 'menu'

greetscreen = {}

function greetscreen.createmenu()
	local m = menu("CS", 24, true)
	m:setPosition(50, 92)
	m:setSpacing(10)
	return m
end

function greetscreen.load()
	greetscreen.titlefont = font("CS", 48)
	greetscreen.title = ""
	greetscreen.mainmenu = greetscreen.createmenu()
	greetscreen.settingsmenu = greetscreen.createmenu()
	greetscreen.inputsettingsmenu = greetscreen.createmenu()
	greetscreen.screensettingsmenu = greetscreen.createmenu()
	local mainmenu = greetscreen.mainmenu
	local settingsmenu = greetscreen.settingsmenu
	local inputsettingsmenu = greetscreen.inputsettingsmenu
	local screensettingsmenu = greetscreen.screensettingsmenu
	mainmenu:add("Start Game", greetscreen.playgame)
	mainmenu:add("Settings", greetscreen.switchsettingsmenu)
	mainmenu:add("Quit", greetscreen.quit)
	settingsmenu:add("Screen Settings", greetscreen.switchscreensettingsmenu)
	settingsmenu:add("Input Settings", greetscreen.switchinputsettingsmenu)
	settingsmenu:add("Back", greetscreen.switchmainmenu)
	greetscreen.fullscreenline = screensettingsmenu:add("Screen: Windowed", greetscreen.togglefullscreen)
	greetscreen.resolutionline = screensettingsmenu:add("Resolution: ", greetscreen.toggleresolution)
	screensettingsmenu:add("Apply Changes", greetscreen.updatevideo)
	screensettingsmenu:add("Back", greetscreen.switchsettingsmenu)
	greetscreen.go = inputsettingsmenu:add("Go: ", greetscreen.setupkeyinputgo)
	greetscreen.turnleft = inputsettingsmenu:add("Turn Left: ", greetscreen.setupkeyinputturnleft)
	greetscreen.turnright = inputsettingsmenu:add("Turn Right: ", greetscreen.setupkeyinputturnright)
	greetscreen.stop = inputsettingsmenu:add("Stop: ", greetscreen.setupkeyinputstop)
	greetscreen.fire = inputsettingsmenu:add("Fire:", greetscreen.setupkeyinputfire)
	greetscreen.navigation = inputsettingsmenu:add("Navigation: ", greetscreen.setupkeyinputnavigation)
	inputsettingsmenu:add("Back", greetscreen.switchsettingsmenu)
	greetscreen.switchmainmenu()
	greetscreen.initscreensettings()
	greetscreen.keyinputcallback = nil
	greetscreen.keyinput = false
	greetscreen.music = song("Intro Music.wav")
	greetscreen.music:setLooping(true)
	love.audio.play(greetscreen.music)
end

function greetscreen.initscreensettings()
	
	greetscreen.settings = {}
	greetscreen.settingschanged = false
	local width, height, fullscreen, vsync, fsaa = love.graphics.getMode( )
	greetscreen.settings.fullscreen = fullscreen
	greetscreen.settings.width = width
	greetscreen.settings.height = height
	greetscreen.settings.modes = love.graphics.getModes()
	greetscreen.settings.modeindex = 0
	greetscreen.updatefullscreenline()
	greetscreen.updateresolutionline(width, height)
end

function greetscreen.quit()
	os.exit(0)
end

function greetscreen.playgame()
	local cm = greetscreen.callbackmanager
	if cm then
		love.audio.stop(greetscreen.music)
		-- if you remove greetscreen before adding it cases problems with cm
		cm:add(game())
		cm:remove(greetscreen)
	end
end

function greetscreen.switchmainmenu()
	greetscreen.title = "Space Ranger"
	greetscreen.focus = greetscreen.mainmenu
end

function greetscreen.switchscreensettingsmenu()
	greetscreen.title = "Screen Settings"
	greetscreen.initscreensettings()
	greetscreen.focus = greetscreen.screensettingsmenu
end

function greetscreen.filter(str)
	if str == " " then return "space" end
	return str
end

function greetscreen.initinputsettings()
	local filter = greetscreen.filter
	local m = greetscreen.inputsettingsmenu
	m:setItem(greetscreen.go, "Go: " .. filter(controls.move))
	m:setItem(greetscreen.turnleft, "Turn Left: " .. filter(controls.turnleft))
	m:setItem(greetscreen.turnright, "Turn Right:" .. filter(controls.turnright))
	m:setItem(greetscreen.stop, "Stop: " .. filter(controls.stop))
	m:setItem(greetscreen.fire, "Fire: " .. filter(controls.fire))
	m:setItem(greetscreen.navigation, "Navigation: " .. filter(controls.navigation))
end

function greetscreen.setupkeyinput(menu, line, callback)
	greetscreen.keyinput = true
	menu:setItem(line, "<Press Key>")
	greetscreen.keyinputcallback = callback
end

function greetscreen.setupkeyinputgo()
	greetscreen.setupkeyinput(greetscreen.inputsettingsmenu, greetscreen.go, greetscreen.receivekeyinputgo)
end
function greetscreen.setupkeyinputstop()
	greetscreen.setupkeyinput(greetscreen.inputsettingsmenu, greetscreen.stop, greetscreen.receivekeyinputstop)
end
function greetscreen.setupkeyinputturnleft()
	greetscreen.setupkeyinput(greetscreen.inputsettingsmenu, greetscreen.turnleft, greetscreen.receivekeyinputturnleft)
end
function greetscreen.setupkeyinputturnright()
	greetscreen.setupkeyinput(greetscreen.inputsettingsmenu, greetscreen.turnright, greetscreen.receivekeyinputturnright)
end
function greetscreen.setupkeyinputnavigation()
	greetscreen.setupkeyinput(greetscreen.inputsettingsmenu, greetscreen.navigation, greetscreen.receivekeyinputnavigation)
end
function greetscreen.setupkeyinputfire()
	greetscreen.setupkeyinput(greetscreen.inputsettingsmenu, greetscreen.fire, greetscreen.receivekeyinputfire)
end

function greetscreen.receivekeyinput(menu, control, line, item, key)
	local filter = greetscreen.filter
	controls[control] = key
	menu:setItem(line, item .. filter(key))
	greetscreen.keyinput = false
end

function greetscreen.receivekeyinputgo(key)
	greetscreen.receivekeyinput(greetscreen.inputsettingsmenu, "move", greetscreen.go, "Go: ", key)
end
function greetscreen.receivekeyinputturnleft(key)
	greetscreen.receivekeyinput(greetscreen.inputsettingsmenu, "turnleft", greetscreen.turnleft, "Turn Left: ", key)
end
function greetscreen.receivekeyinputturnright(key)
	greetscreen.receivekeyinput(greetscreen.inputsettingsmenu, "turnright", greetscreen.turnright, "Turn Right:", key)
end
function greetscreen.receivekeyinputstop(key)
	greetscreen.receivekeyinput(greetscreen.inputsettingsmenu, "stop", greetscreen.stop, "Stop: ", key)
end
function greetscreen.receivekeyinputnavigation(key)
	greetscreen.receivekeyinput(greetscreen.inputsettingsmenu, "navigation", greetscreen.navigation, "Navigation: ", key)
end
function greetscreen.receivekeyinputfire(key)
	greetscreen.receivekeyinput(greetscreen.inputsettingsmenu, "fire", greetscreen.fire, "Fire: ", key)
end

function greetscreen.switchinputsettingsmenu()
	greetscreen.title = "Input Settings"
	greetscreen.initinputsettings()
	greetscreen.focus = greetscreen.inputsettingsmenu
end

function greetscreen.switchsettingsmenu()
	greetscreen.title = "Settings"
	greetscreen.focus = greetscreen.settingsmenu
end

function greetscreen.updatevideo()
	local width, height, fullscreen, vsync, fsaa = love.graphics.getMode( )
	width = greetscreen.settings.width or width
	height = greetscreen.settings.height or height
	fullscreen = greetscreen.settings.fullscreen or fullscreen
	love.graphics.setMode(width, height, fullscreen, vsync, fsaa)
end

function greetscreen.togglefullscreen()
	greetscreen.settings.fullscreen = not greetscreen.settings.fullscreen
	greetscreen.updatefullscreenline()
end

function greetscreen.updatefullscreenline()
	if greetscreen.settings.fullscreen then
		greetscreen.screensettingsmenu:setItem(greetscreen.fullscreenline, "Screen: Fullscreen")
	else
		greetscreen.screensettingsmenu:setItem(greetscreen.fullscreenline, "Screen: Windowed")
	end
end

function greetscreen.toggleresolution()
	local index = greetscreen.settings.modeindex
	local modes = greetscreen.settings.modes
	index = index + 1
	if index > #modes then
		index = 1
	end
	local width = modes[index]['width']
	local height = modes[index]['height']
	greetscreen.updateresolutionline(width, height)
	greetscreen.settings.width = width
	greetscreen.settings.height = height
	greetscreen.settings.modeindex = index
end

function greetscreen.updateresolutionline(width, height)
	local resolution = "Resolution: " .. tostring(width) .. "x" .. tostring(height)
	greetscreen.screensettingsmenu:setItem(greetscreen.resolutionline, resolution)
end

function greetscreen.keypressed(key, unicode)
	if greetscreen.keyinput then
		greetscreen.keyinputcallback(key)
		greetscreen.keyinput = false
		return
	end
	local m = greetscreen.focus
	if key == "w" or key == "up" then
		m:up()
	elseif key == "s" or key == "down" then
		m:down()
	elseif key == "return" or key == " " then
		m:select()
	end
end

function greetscreen.draw()
	love.graphics.setFont(greetscreen.titlefont)
	love.graphics.print(greetscreen.title, 50, 50)
	greetscreen.focus:draw()
end

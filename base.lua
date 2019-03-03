--[[
Author: Chad Lucas
This is a base library for a bunch of things that are useful for making games
with love. There are also some utility functions that make things nice.


	Function List

	font(fontName, size) -> font
This will look in the resources folder under fontsDir in order to load a font
and return it. It also being cached, so multiple calls to this is simply
returning the already loaded font.
Note: This adds the .ttf extension, so just remove that from fontName.
	ifnil(a, b) -> a or b
If a is nil, then b is returned. This also does another thing which is make
sure that a is of type b. For example f(1, "one") will return "one" because 
1 is of type number and "one" is of type string, which means they're not the
same.
	image(imageName)
This will look in the resources folder under imagesDir in order to load an 
image and return it. It will also be cached, so multiple calls to this will
simply return the same image.
Note: This adds the .png extension, so just remove that from the imageName.
	sound(songName)
	song(songName)
Both of these do essentially the same thing by looking at the soundsDir in
order to load a sound file. This caches the file, so every call simply returns
a loaded resource of the file.
--]]

local resources = {
	fonts = {}, 
	images = {}, 
	sounds = {},
	songs = {},
	fontsDir = "Fonts/",
	imagesDir = "Textures/",
	soundsDir = "Sounds/",
}

function font(fontName, size)
	local fnt = resources.fonts[fontName]
	if type(fnt) == "nil" or type(fnt[size]) == "nil" then
		local givenPath = resources.fontsDir .. fontName
		local path = givenPath .. ".ttf"
		local f
		if love.filesystem.exists(path) then
			f = love.graphics.newFont(path, size)
		elseif love.filesystem.exists(givenPath) then
			f = love.graphics.newFont(givenPath, size)
		end
		if type(fnt) == "nil" then
			resources.fonts[fontName] = {}
		end
		resources.fonts[fontName][size] = f
		fnt = resources.fonts[fontName][size]
	else 
		fnt = fnt[size]
	end
	return fnt
end

function ifnil(value, defaultValue)
	return ((type(value) == type(defaultValue)) and value) or defaultValue
end

function image(imageName)
	local img = resources.images[imageName]
	if type(img) == "nil" then
		local givenPath = resources.imagesDir .. imageName
		local path = givenPath .. '.png'
		if love.filesystem.exists(path) then
			img = love.graphics.newImage(path)
		elseif love.filesystem.exists(givenPath) then
			img = love.graphics.newImage(givenPath)
		end
		resources.images[imageName] = img
	end
	return img
end

function sound(soundName)
	local ogg = resources.sounds[soundName]
	if type(ogg) == "nil" then
		local givenPath = resources.soundsDir .. soundName 
		local path = givenPath .. ".ogg"
		if love.filesystem.exists(path) then
			ogg = love.audio.newSource(path)
		elseif love.filesystem.exists(givenPath) then
			ogg = love.audio.newSource(givenPath)
		end
		resources.sounds[soundName] = ogg
	end
	return ogg
end

function song(songName)
	local ogg = resources.songs[songName]
	if type(ogg) == "nil" then
		local givenPath = resources.soundsDir .. songName 
		local path = givenPath .. ".ogg"
		if love.filesystem.exists(path) then
			ogg = love.audio.newSource(path, "stream")
		elseif love.filesystem.exists(givenPath) then
			ogg = love.audio.newSource(givenPath, "stream")
		end
		resources.songs[songName] = ogg
	end
	return ogg
end

function withineqgrain(value, target, grain)
	return value >= target - grain and value <= target + grain
end

function withingrain(value, target, grain)
	return value > target - grain and value < target + grain
end

function within(value, min, max)
	return value > min and value < max
end

function withineq(value, min, max)
	return value >= min and value >= max
end

function debugPrint(line, msg)
	local ypos = line * 12
	love.graphics.print(msg, 0, ypos)
end

function getAngle(a, origin, b)
	local A = vector(a.x - origin.x, a.y -origin.y)
	local B = vector(b.x - origin.x, b.y - origin.y)
	
	local thetaA = math.atan2(A.x, A.y)
	local thetaB = math.atan2(B.x, B.y)
	
	local thetaAB = thetaB - thetaA

	while thetaAB <= -math.pi do
		thetaAB = thetaAB + 2 * math.pi
	end
	while thetaAB > math.pi do
		thetaAB = thetaAB - 2 * math.pi
	end

	return thetaAB
end

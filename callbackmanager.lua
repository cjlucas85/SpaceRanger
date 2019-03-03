class = require 'class'

callbackmanager = class{
	function(self, ...)
		self.entities = {}
		self.callbacks = {}
		self:add(...)
	end
}

callbackmanager.allentities = {}
callbackmanager.lastentityid = 0
function callbackmanager:add(...)
	local function gethighestid()
		callbackmanager.lastentityid = callbackmanager.lastentityid + 1
		return callbackmanager.lastentityid
	end
	local function globallyregistered(id)
		return type(id) == "number" and type(callbackmanager.allentities[id]) == "table"
	end
	local function locallyregistered(id)
		return type(id) == "number" and type(self.entities[id]) == "table"
	end
	local function assignkey(entity)
		local id = entity.entityid
		if globallyregistered(id) == false then
			local newid = gethighestid()
			callbackmanager.allentities[newid] = entity
			entity.callbackmanager = self
			entity.entityid = newid
		end
	end
	
	if locallyregistered(id) then return end
	for i, v in ipairs(arg) do
		if type(v) == "table" then
			assignkey(v)
			self.entities[v.entityid] = v
		end
	end
end

function callbackmanager:remove(entity)
	for i, e in pairs(self.entities) do
		if e.entityid == entity.entityid then
			callbackmanager.allentities[e.entityid] = nil
			self.entities[e.entityid] = nil
			e.entityid = nil
		end
	end
end

function callbackmanager:execute(callback, ...)
	local function isobject(o)
		return type(o) == "table" and type(o.is_a) == "function"
	end
	local function isfunction(f)
		return type(f) == "function"
	end
	if type(callback) ~= "string" then return end
	for i, e in pairs(self.entities) do
		if isobject(e) and isfunction(e[callback]) then
			e[callback](e, ...)
		elseif type(e) == "table" and isfunction(e[callback]) then
			e[callback](...)
		end
	end
end
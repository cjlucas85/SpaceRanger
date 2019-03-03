class = require "class"
--[[
	stack
Author: Chad Lucas
This is an implementation of a basic ADT. It works as expected.

	Method List

	stack:peek()
Returns the element ontop of the stack without removing it.
	stack:pop()
Returns the element ontop of the stack and removes it.
	stack:push(...)
Pushes a number of elements on the stack from zero to many.
--]]


stack = class{
	function(self, ...)
		self:push(...)
	end
}

function stack:peek()
	return self[#self]
end

function stack:pop()
	local t = self[#self]
	self[#self] = nil
	return t
end

function stack:push(...)
	if #arg == 0 then 
		return
	end
	if #arg == 1 then
		self[#self + 1] = arg[1]
		return
	end
	for i, v in ipairs(arg) do
		self[#self + 1] = v
	end
end

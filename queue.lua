class = require 'class'
--[[
	queue
Author: Chad Lucas
This is an implementation of the queue ADT.

	Method List
	
	queue:dequeue()
Removes the element in front of the queue and returns it.
	queue:enqueue(...)
Inserts elements, in order, at the end of the queue.
--]]

queue = class {
	function (self, ...)
	self.front = 0
	self.back = 0
	self.line = {}
	self:enqueue(...)
	end
}

function queue:dequeue(...)
	if self.front == self.back then
		local t = self.line[self.front]
		self.line[self.front] = nil
		self.front = 0
		self.back = 0
		return t
	end
	local t = self.line[self.front]
	self.line[self.front] = nil
	self.front = self.front + 1
	return t
end
last = ""
function queue:enqueue(...)
	if #arg == 0 then return end
	if #arg > 1 then
		for i, v in ipairs(arg) do
			self:enqueue(v)
		end
		return
	end
	-- if #arg == 1
	if self.front == 0 and self.back == 0 then
		self.front = 1
		self.back = 1
		self.line[self.back] = arg[1]
	else
		self.back = self.back + 1
		self.line[self.back] = arg[1]
	end
end

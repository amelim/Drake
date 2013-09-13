--Color.lua
--Andrew Melim

Color = {r=255,g=255,b=255,a=255}

function Color:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function Color:setRGBA(r,g,b,a)
	self.r = r
	self.g = g 
	self.b = b 
	self.a = a 
end

function Color:getRGBA()
	return self.r,self.g,self.b,self.a
end
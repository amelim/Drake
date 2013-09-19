--Tile.lua
--Andrew Melim

Tile = {x=0,y=0,room=0,color={},geometry={}}

function Tile:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
  self.color = Color:new() 
  self.color:setRGBA(0,200,120,255)
	return o
end
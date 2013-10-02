--Entity.lua
--Andrew Melim

require "Color"

Entity = {x=0,y=0,w=0,h=0}

function Entity:new(type,o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
  self.color = Color:new() 
  self.color:setRGBA(200,0,40,255)
	return o
end

function Entity:setSize(w,h)
	self.w = w
	self.h = h
end

function Entity:setPos(x,y)
	self.x = x
	self.y = y
end

function Entity:getPos(x,y)
  return self.x, self.y
end

function Entity:getX()
  return self.x
end

function Entity:getY()
  return self.y
end

function Entity:move(dx,dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

function Entity:setColor(color)
  self.color = color
end

function Entity:getColor()
  r,g,b,a = self.color:getRGBA()
  return r,g,b,a 
end

--@param: width is the single tile width
--@param: height is the single tile height
--@param: imgX is the total width of the tilemap image
--@param: imgY is the total height of the tilemap image
function Entity:setTile(tileX,tileY,width,height,imgX,imgY)
    self.geometry = love.graphics.newQuad(tileX*width,tileY*height,width,height,imgX, imgY)
end
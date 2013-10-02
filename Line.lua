--Line.lua
--Line class which really represents a vector in R2
require "Point2"

Line = {x0_=0, y0_=0, x_=0, y_=0}

function Line:new(o)
  o = o or {}
  setmetatable(o,self)
  self.__index = self
  return o
end

-- Get Functions
function Line:getOrigin()
  return self.x0_, self.y0_
end

function Line:getEnd()
  return self.x_, self.y_
end

-- Set Functions
function Line:setOrigin(x,y)
  self.x0_ = x
  self.y0_ = y
end

function Line:setEnd(x,y)
  self.x_ = x
  self.y_ = y
end

function Line:set(x0,y0,x,y)
  self.x0_ = x0
  self.y0_ = y0
  self.x_ = x
  self.y_ = y
end

function Line:setY(y)
  self.y_ = y
end

function Line:setX(x)
  self.x_ = x
end
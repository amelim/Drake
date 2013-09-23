--Point2.lua
--A Point 2 class which stores an x,y location

Point2 = {x_=0, y_=0}

function Point2:new(o)
  o = o or {}
  setmetatable(o,self)
  self.__index = self
  return o
end

-- Get Functions
function Point2:getX()
  return self.x_
end

function Point2:getY()
  return self.y_
end

-- Set Functions
function Point2:set(x,y)
  self.x_ = x
  self.y_ = y
end

function Point2:setY(y)
  self.y_ = y
end

function Point2:setX(x)
  self.x_ = x
end
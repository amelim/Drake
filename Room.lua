--Room.lua
require "Point2"

Room = {tiles={}, size=0}

function Room:new(o)
  o = o or {}
  setmetatable(o,self)
  self.__index = self
  return o
end

function Room:addPoint2(p)
  table.insert(self.tiles, p)
  self.size = self.size+1
end

function Room:getPoint2(p)
  return self.tiles[p]
end

function Room:getSize()
  return self.size
end
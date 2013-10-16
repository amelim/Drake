--Edge.lua
--Andrew Melim
--Edge stores a line and neighbor information

require "Line"

Edge = {line_ = Line:new(), next_ = false, previous_ = false}

function Edge:new(o)
  o = o or {}
  setmetatable(o,self)
  self.__index = self
  return o
end

function Edge:setLine(l) self.line_ = l end
function Edge:getLine() return self.line_ end

function Edge:setNext(n) self.next_ = n end
function Edge:getNext() return self.next_ end

function Edge:setPrevious(previous) self.previous_ = previous end
function Edge:getPrevious() return self.previous_ end
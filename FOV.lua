--FOV.lua
--Lighting based on Monoco lighting engine
--https://www.facebook.com/notes/monaco/line-of-sight-in-a-tile-based-world/411301481995

require "Line"
require "Edge"

FOV = {}

function FOV:new(o)
  o = o or {}
  setmetatable(o,self)
  self.__index = self
  self.forwardEdges = {}
  self.projections = {}
  return o
end

--*****************************************************************************--
--construct a big list of all "forward facing" edges
--pX,pY : Player x and y position in tiles
--blocked : A 2D array indicating whether a tile blocks or not
--tileW, tileH : A tile width and height
function FOV:findForwardEdges(pX, pY, blocked, blockedW, blockedH, tileW, tileH)
  self.forwardEdges = {}
  --Iterate through the entire blocked
  --blocked is in tiles, when determing FOV, you need to measure in pixels for higher resolution!
  for x=0, blockedW do
    for y=0, blockedH do
      if(blocked[x][y]) then --This tile blocks light, determine which edges are facing the player
        --Left Edge, check top left corner and bottom left corner
        if(pX < x and x > 0) then
          if(not blocked[x-1][y]) then
            line = Line:new()
            line:set(x*tileW,y*tileH,x*tileW,y*tileH+tileH)
            edge = Edge:new()
            edge:setLine(line)
            table.insert(self.forwardEdges, edge)
          end
        end
        --Right Edge
        if(pX > x and x < blockedW) then
          if(not blocked[x+1][y]) then
            line = Line:new()
            line:set(x*tileW+tileW,y*tileH,x*tileW+tileW,y*tileH+tileH)
            edge = Edge:new()
            edge:setLine(line)
            table.insert(self.forwardEdges, edge)
        end
        end
        --Up Edge
        if(pY < y and y > 0) then
          if(not blocked[x][y-1]) then
            line = Line:new()
            line:set(x*tileW,y*tileH,x*tileW+tileW,y*tileH)
            edge = Edge:new()
            edge:setLine(line)
            table.insert(self.forwardEdges, edge)
        end
        end
        --Down Edge
        if(pY > y and y < blockedH) then
          if(not blocked[x][y+1]) then
            line = Line:new()
            line:set(x*tileW,y*tileH+tileH,x*tileW+tileW,y*tileH+tileH)
            edge = Edge:new()
            edge:setLine(line)
            table.insert(self.forwardEdges, edge)
          end
        end
      end
    end
  end
end

function FOV:getForwardEdges()
  return self.forwardEdges
end

function FOV:getProjections()
  return self.projections
end

--*****************************************************************************--
--Next, I link up each of these edges. So now each tile-length edge knows about its neighbors: 
--each has a "next" and a "previous" edge. Some edges are dead-ends, though: they don't have a next or a previous.
function FOV:linkEdges(px,py,tileW,tileH)
  self.links = {}
  for ki,vi in pairs(self.forwardEdges) do
    for kj,vj in pairs(self.forwardEdges) do
      --Check to see if edge i links up with edge j at some point
      if(kj ~= ki) then
        viX, viY = vi:getLine():getEnd()
        vjX, vjY = vj:getLine():getOrigin()
        if (viX == vjX) and (viY == vjY) then
          vi:setNext(kj)
        end
        viX, viY = vi:getLine():getOrigin()
        vjX, vjY = vj:getLine():getEnd()
        if (viX == vjX) and (viY == vjY) then
          vi:setPrevious(kj)
        end

        viX, viY = vi:getLine():getEnd()
        vjX, vjY = vj:getLine():getEnd()
        if (viX == vjX) and (viY == vjY) then
          vi:setNext(kj)
        end
        viX, viY = vi:getLine():getOrigin()
        vjX, vjY = vj:getLine():getOrigin()
        if (viX == vjX) and (viY == vjY) then
          vi:setPrevious(kj)
        end
      end
    end
  end
  for k,edge in pairs(self.forwardEdges) do
    edge:setDist(edge:getLine():minDist(px*tileW,py*tileH))
  end
  table.sort(self.forwardEdges, function(a,b) return a:getDist() < b:getDist() end)
end

--*****************************************************************************--
--px,py : Player x and y position, tile coordinates

-- Temporarily set the projection line end to the player
function FOV:project(px, py, tileW, tileH)
  self.projections = {}
  for k,edge in pairs(self.forwardEdges) do
    if not edge:getNext() then
      pline = Line:new()
      pline:setEnd(px*tileW + tileW/2, py*tileH + tileH/2)
      pline:setOrigin(edge:getLine():getEnd())

      projection = Edge:new()
      projection:setLine(pline)
      table.insert(self.projections, projection)
    end

    if not edge:getPrevious() then
      pline = Line:new()
      pline:setEnd(px*tileW + tileW/2, py*tileH + tileH/2)
      pline:setOrigin(edge:getLine():getOrigin())

      projection = Edge:new()
      projection:setLine(pline)
      table.insert(self.projections, projection)
    end
  end
  local newEdges = {}
  -- Check of intersections and set projection end at intersection point
  for kp,p in pairs(self.projections) do
    local inter = false
    for ke,edge in pairs(self.forwardEdges) do
      ix,iy = self:intersection(p:getLine(), edge:getLine(), true, true)
      --Intersection!!
      if(ix and not inter) then
        p:getLine():setEnd(ix,iy)
        splitE = table.remove(self.forwardEdges, ke)
        eA, eB = self:splitEdges(splitE, ix, iy)
        table.insert(self.forwardEdges, eA)
        table.insert(self.forwardEdges, eB)
        inter = true
      end
    end
    
    if inter then
      table.insert(newEdges, p)
    end

  end
  for k,e in pairs(newEdges) do
    table.insert(self.forwardEdges, e)
  end
end

function FOV:splitEdges(edge, ix, iy)
  lineA = Line:new()
  lineA:setOrigin(edge:getLine():getOrigin())
  lineA:setEnd(ix,iy)
  edgeA = Edge:new()
  edgeA:setLine(lineA)

  lineB = Line:new()
  lineB:setOrigin(ix,iy)
  lineB:setEnd(edge:getLine():getEnd())
  edgeB = Edge:new()
  edgeB:setLine(lineB)

  return edgeA, edgeB
end

--*****************************************************************************--
--Find the intersection of two lines
--https://github.com/kennethdamica/Monocle/blob/master/monocle.lua
function FOV:intersection(lineA, lineB, interA, interB)
  local tol = 1e-8
  local x1,y1 = lineA:getOrigin()
  local x2,y2 = lineA:getEnd()

  local x3,y3 = lineB:getOrigin()
  local x4,y4 = lineB:getEnd()
  --Utilize determinate method for intersection
  -- Px,Py defines the point of intersection
  local det = (x1-x2)*(y3 - y4) - (y1 - y2)*(x3 - x4)
  if det==0 then return false end
  local Px_numer = (x1*y2 - y1*x2)*(x3-x4) - (x1 - x2)*(x3*y4 - y3*x4)
  local Px = Px_numer/det

  local Py_numer = (x1*y2 - y1*x2)*(y3-y4) - (y1 - y2)*(x3*y4 - y3*x4)
  local Py = Py_numer/det

  --If there is a point of intersection, see if it lies between to actual two line segements
  local min, max = math.min, math.max
  if interA and not (min(x1,x2) <= (Px+tol) and Px <= max(x1,x2)+tol 
    and min(y1,y2) <= (Py+tol) and Py <= max(y1,y2)+tol) then
    return false
  end
  if interB and not (min(x3,x4) <= (Px+tol) and Px <= max(x3,x4)+tol 
    and min(y3,y4) <= (Py+tol) and Py <= max(y3,y4)+tol) then
    return false
  end
  -- Intersection
  return Px,Py
end
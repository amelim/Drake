--FOV.lua
--Lighting based on Monoco lighting engine
--https://www.facebook.com/notes/monaco/line-of-sight-in-a-tile-based-world/411301481995

require "Line"

FOV = {}

function FOV:new(o)
  o = o or {}
  setmetatable(o,self)
  self.__index = self
  self.forwardEdges = {}
  return o
end

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
            edge = Line:new()
            edge:set(x*tileW,y*tileH,x*tileW,y*tileH+tileH)
            table.insert(self.forwardEdges, edge)
          end
        end
        --Right Edge
        if(pX > x and x < blockedW) then
          if(not blocked[x+1][y]) then
            edge = Line:new()
            edge:set(x*tileW+tileW,y*tileH,x*tileW+tileW,y*tileH+tileH)
            table.insert(self.forwardEdges, edge)
        end
        end
        --Up Edge
        if(pY < y and y > 0) then
          if(not blocked[x][y-1]) then
            edge = Line:new()
            edge:set(x*tileW,y*tileH,x*tileW+tileW,y*tileH)
            table.insert(self.forwardEdges, edge)
        end
        end
        --Down Edge
        if(pY > y and y < blockedH) then
          if(not blocked[x][y+1]) then
            edge = Line:new()
            edge:set(x*tileW,y*tileH+tileH,x*tileW+tileW,y*tileH+tileH)
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




--Next, I link up each of these edges. So now each tile-length edge knows about its neighbors: 
--each has a "next" and a "previous" edge. Some edges are dead-ends, though: they don't have a next or a previous.
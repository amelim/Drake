--Dungeon.lua
--Andrew Melim

require "Entity"
require "BSP"

Dungeon = {w=love.window.getWidth()/16, h=love.window.getHeight()/24}

function Dungeon:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.floor = {} -- Tile
	self.blocked = {} -- 2D array on whether the position is blocked or not
	self.type = {}
	self.typeColor = {}
	-- There should be a better way to handle this

	self.type[1] = {0,15} --water
	self.typeColor[1] = Color:new({r=21,g=51,b=173,a=120})
	self.type[2] = {0,21} --grass
	self.typeColor[2] = Color:new({r=139,g=234,b=0,a=120})

	self.bsp = BSP:new()
	return o
end

--Returns wall tile entity
--Flag = 0 : Horizontal wall
--Falg = 1 : Vertical wall
function Dungeon:buildWall(x,y,imgX,imgY)

  local color = Color:new({r=214,g=0,b=98,a=120})
  tile = Entity:new()
  tile:setPos(x,y)

  tile:setTile(0, 12, 16, 24, imgX, imgY)
  tile:setColor(color)

  if(x==0 or y==0 or x+1 == self.w or y+1 == self.h) then 
    self.floor[x][y] = tile
    self.blocked[x][y] = true
  else
    if(math.random(0,100) < 70) then 
      self.floor[x][y] = tile 
      self.blocked[x][y] = true
    end
  end
end

function Dungeon:wallSmooth(imgX, imgY)
  for x=0, self.w do
    for y=0, self.h-2 do
     
      if(self.floor[x][y]) then
        if(self.blocked[x][y+1] and self.blocked[x][y]) then
          self.floor[x][y]:setTile(7,12,16,24,imgX,imgY)
        end
      end
    end
  end
end

--Returns wall tile entity
function Dungeon:colorWall(x,y,imgX,imgY,color)
  tile = Entity:new()
  tile:setPos(x,y)
  tile:setTile(0, 12, 16, 24, imgX, imgY)
  tile:setColor(color)
  return tile
end

--Returns water tile entity
function Dungeon:addWater(x,y,imgX,imgY)
  local color = Color:new({r=21,g=51,b=173,a=120})
  tile = Entity:new()
  tile:setPos(x,y)
  tile:setTile(0, 15, 16, 24, imgX, imgY)
  tile:setColor(color)
  return tile
end

--Returns water tile entity
function Dungeon:growVegetation(x,y,imgX,imgY)
  local color = Color:new({r=139,g=234,b=0,a=120})
  tile = Entity:new()
  tile:setPos(x,y)
  plant = math.floor(math.random(0,2))
  tile:setTile(plant, 21, 16, 24, imgX, imgY)
  tile:setColor(color)
  return tile
end

--Returns true if the location is passable by a creature
function Dungeon:free(x,y)
	if( x<0 or y<0 or x > self.w-1 or y > self.h-1) then
		return false
	end
	return not self.blocked[x][y]
end

--Creates one dungeon level
function Dungeon:createFloor(imgX,imgY)
  self.bsp:generate(self.w,self.h)
  --self.bsp:print(self.bsp.root)
  for x=0, self.w do
    self.floor[x] = {}
    self.blocked[x] = {}    
    for y=0, self.h do
      self.blocked[x][y] = false
    end
  end

  self:digRoom(self.bsp.root, imgX, imgY)
  self:wallSmooth(imgX, imgY)
end

--Recursively build dungeon from BSP
function Dungeon:digRoom(node, imgX, imgY)
  if(not node) then
    return 1
  end

  --If we have a node left or right, dig
  if(not node.leaf) then
    self:digRoom(node.left, imgX, imgY)
    self:digRoom(node.right, imgX, imgY)
  end

  if(node.leaf) then
    --self.bsp:print(node)
    local r = math.random(0,255)
    local g = math.random(0,255)
    local b = math.random(0,255)
    local color = Color:new({r=math.random(0,255),g=math.random(0,255),b=math.random(0,255),a=120})
    for x=node.x, node.x+node.w do
      for y=node.y, node.y+node.h do
        ---Tiles---
        if(self:free(x,y)) then
          if(y == node.y or y == node.y + node.h or x == node.x or x == node.x + node.w) then
            self:buildWall(x,y,imgX,imgY)
          else
            if(math.random(0,100) < 5) then 
              self.floor[x][y] = self:growVegetation(x,y,imgX,imgY)
            end
          end
        end
        ---END Tiles---
      end
    end
  end
end

-- A floor is a 2D array of tile Entities which currently only contain tile and color info
function Dungeon:randomFloor(imgX,imgY)
   for x=0,self.w-1 do
  	self.blocked[x] = {}
    for y=0,self.h-1 do
      local rand = math.random(0,2)
      local tile = Entity:new()
      tile:setPos(x,y)
      tile:setTile(self.type[rand][1],self.type[rand][2], 16, 24, imgX, imgY)
      tile:setColor(self.typeColor[rand])
      table.insert(self.floor, tile)

      -- Set whether the tile is passable
      if(rand == 0) then
      	self.blocked[x][y] = true
      else
      	self.blocked[x][y] = false
      end

    end
  end
end



--Dungeon.lua
--Andrew Melim

require "Entity"
require "BSP"

Dungeon = {w=love.window.getWidth()/16, h=love.window.getHeight()/24}

function Dungeon:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.floor = {} -- Tiles
	self.blocked = {} -- 2D array on whether the position is blocked or not
  self.rooms = {} -- 2D array that maps x,y loc to room number
	self.type = {}
	self.typeColor = {}
	-- There should be a better way to handle this

	self.type[1] = {0,15} --water
	self.typeColor[1] = Color:new({r=21,g=51,b=173,a=120})
	self.type[2] = {0,21} --grass
	self.typeColor[2] = Color:new({r=139,g=234,b=0,a=120})

  --Init floor and blocked arrays
  for x=0, self.w do
    self.floor[x] = {}
    self.blocked[x] = {}
    self.rooms[x] = {}
    for y=0, self.h do
      self.blocked[x][y] = false
      self.rooms[x][y] = 0
    end
  end

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

  self.floor[x][y] = tile
  self.blocked[x][y] = true

end
--Smooths the wall tiles  such that only the bottom tile will show the bricks
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

function Dungeon:fillRect(x,y,w,h,imgX,imgY)
  for i=x, w do
    for j=y, h do
      self:buildWall(i,j,imgX,imgY)
    end
  end
end

function Dungeon:clearRect(x,y,w,h,imgX,imgY)
  for i=x, x+w do
    for j=y, y+h do
      if(i > 1 and i < self.w-1 and j > 1 and j < self.h-1) then
        self.floor[i][j] = false
        self.blocked[i][j] = false
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

-- Does not actually create rect behind
function Dungeon:randRect(x,y,w,h)
  randX = math.random(1,self.w - 1)
  randY = math.random(1,self.h - 1)
  randW = math.random(1,4)
  randH = math.random(1,4)

  return randX, randY, randW, randH
end

--Ruins style room
function Dungeon:ruinsFloor(imgX, imgY)
  self:fillRect(0,0,self.w,self.h,imgX,imgY)
  local lastX, lastY, lastW, lastH;
  lastX = self.w/2;
  lastY = self.h/2;
  lastW = 5;
  lastH = 5;

  for i=0, 100 do
    x,y,w,h = self:randRect(lastX, lastY, lastW, lastH)
    self:clearRect(x,y,w,h,imgX,imgY)
    lastX, lastY, lastW, lastH = x,y,w,h
  end
  self:findRooms()
  self:wallSmooth(imgX, imgY)
end

function Dungeon:findRooms()
  roomCount = 1
  for x=1, self.w-1 do
    for y=1, self.h-1 do
      if self:free(x,y) then
        if self.rooms[x][y]==0 then 
          self:floodFill(x,y,roomCount)
          roomCount = roomCount + 1
        end
      end
    end
  end
end

function Dungeon:floodFill(x,y,room)
  if self.blocked[x][y] then return end

  self.rooms[x][y] = room

  if x > 0 then
    if self.rooms[x-1][y]==0 then
      self:floodFill(x-1, y, room) end
  end
  if y > 0 then
    if self.rooms[x][y-1]==0 then
      self:floodFill(x, y-1, room) end
  end
  if x < self.w then
    if self.rooms[x+1][y]==0 then
      self:floodFill(x+1, y, room) end
  end
  if y < self.h then 
    if self.rooms[x][y+1]==0 then
      self:floodFill(x, y+1, room) end
  end

end

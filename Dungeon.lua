--Dungeon.lua
--Andrew Melim

require "Entity"
require "Room"

Dungeon = {w=love.window.getWidth()/16, h=love.window.getHeight()/24}

function Dungeon:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.floor = {} -- Tiles
	self.blocked = {} -- 2D array on whether the position is blocked or not
  self.rooms = {} -- 2D array that maps x,y loc to room number
  self.roomMap = {} -- A 2D array of Room objects
	self.type = {}
	self.typeColor = {}
  self.roomCount = 0;
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

function Dungeon:clearLine(x1,y1,x2,y2)
  local startX = math.min(x1,x2)
  local endX = math.max(x1,x2)
  if startX==x1 then
    cutY = y1
  else
    cutY = y2
  end 

  local startY = math.min(y1,y2)
  local endY = math.max(y1,y2)
  if startY==y1 then
    cutX = x1
  else
    cutX = x2
  end

  --Cut x component
  for x=startX, endX do
    self.floor[x][cutY] = false
    self.blocked[x][cutY] = false
  end

  --Cut y component
  for y=startY, endY do
    self.floor[cutX][y] = false
    self.blocked[cutX][y] = false
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
  randW = math.random(2,3)
  randH = math.random(2,3)

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

  for i=0, 80 do
    x,y,w,h = self:randRect(lastX, lastY, lastW, lastH)
    self:clearRect(x,y,w,h,imgX,imgY)
    lastX, lastY, lastW, lastH = x,y,w,h
  end
  self:findRooms()
  self:connectRooms()
  self:wallSmooth(imgX, imgY)
end

function Dungeon:findRooms()
  roomCount = 0
  
  for x=1, self.w-1 do
    for y=1, self.h-1 do
      if self:free(x,y) then
        if self.rooms[x][y]==0 then 
          
          roomCount = roomCount + 1
          self.roomMap[roomCount-1] = {}
          self:floodFill(x,y,roomCount)
          
        end
      end
    end -- End for y
  end -- End for x
  self.roomCount = roomCount-1;
end

function Dungeon:floodFill(x,y,room)
  if self.blocked[x][y] then return end

  self.rooms[x][y] = room
  p = Point2:new()
  p:set(x,y)
  --self.roomMap[room-1]:addPoint2(p)
  table.insert(self.roomMap[room-1], p)
  
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

--TODO: Still not perfect
function Dungeon:connectRooms()
  print(self.roomCount)
  --Iteratively connect successive rooms to each other
  for i=0, self.roomCount-1 do
    local j = i+1
    randP1 = math.random(0, table.getn(self.roomMap[i]))
    p1 = self.roomMap[i][randP1]
    randP2 = math.random(0, table.getn(self.roomMap[j]))
    p2 = self.roomMap[j][randP2]

    self:clearLine(p1:getX(), p1:getY(), p2:getX(), p2:getY())
  end -- End i
end

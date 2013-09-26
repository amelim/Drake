--Tiles
--Functions which return specific tiles
require "Entity"

--Returns wall tile entity
--Flag = 0 : Horizontal wall
--Falg = 1 : Vertical wall
function buildWall(x,y,imgX,imgY)
  local color = Color:new({r=214,g=0,b=98,a=120})
  tile = Entity:new()
  tile:setPos(x,y)
  tile:setTile(0, 12, 16, 24, imgX, imgY)
  tile:setColor(color)
  return tile
end

--Return a tile of a specific colored wall
function colorWall(x,y,imgX,imgY,color)
  tile = Entity:new()
  tile:setPos(x,y)
  tile:setTile(0, 12, 16, 24, imgX, imgY)
  tile:setColor(color)
  return tile
end

--Returns water tile entity
function addWater(x,y,imgX,imgY)
  local color = Color:new({r=21,g=51,b=173,a=120})
  tile = Entity:new()
  tile:setPos(x,y)
  tile:setTile(0, 15, 16, 24, imgX, imgY)
  tile:setColor(color)
  return tile
end

--Returns random vegetation tile entity
function growVegetation(x,y,imgX,imgY)
  local color = Color:new({r=139,g=234,b=0,a=120})
  tile = Entity:new()
  tile:setPos(x,y)
  -- Randomly select a plant tile
  plant = math.floor(math.random(0,2))
  tile:setTile(plant, 21, 16, 24, imgX, imgY)
  tile:setColor(color)
  return tile
end

--Return door tile
function addDoor(x,y,imgX,imgY)
  local color = Color:new({r=73,g=101,b=214,a=120})
  tile = Entity:new()
  tile:setPos(x,y)
  plant = math.floor(math.random(0,2))
  tile:setTile(2, 16, 16, 24, imgX, imgY)
  tile:setColor(color)
  return tile
end
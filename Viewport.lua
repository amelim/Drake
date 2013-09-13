--Viewport.lua
--Andrew Melim

--Contains a list of all object currently viewed on the screen

Viewport = {width = love.window.getWidth()/16, height = love.window.getHeight()/24, objects = {}, dungeon = {}}

function Viewport:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
  self.zoomX = 1
  self.zoomY = 1
	return o
end

--Loads the tileset image and inits the SpriteBatch object
--Currently Assumes that display w/h are the same as tile w/h
function Viewport:setTileset(tileset,tileW,tileH)
  self.tilesetImage = love.graphics.newImage(tileset)
  self.tilesetImage:setFilter("nearest", "linear")
  self.tileWidth = tileW
  self.tileHeight = tileH
  self.tilesetBatch = love.graphics.newSpriteBatch(self.tilesetImage, tileW*tileH)
  self.dungeonBatch = love.graphics.newSpriteBatch(self.tilesetImage, self.width*self.height*10)
end

function Viewport:getTilesetSize()
  return self.tilesetImage:getWidth(), self.tilesetImage:getHeight()
end

--Register an active object to the Viewport
function Viewport:register(object)
  table.insert(self.objects,object)
end

function Viewport:registerDungeon(dungeon)
  self.dungeonBatch:clear()
  for x=0, dungeon.w do
    for y=0, dungeon.h do
      local tile = dungeon.floor[x][y]
      if(tile) then
        r,g,b,a = tile:getColor()
        self.dungeonBatch:setColor(r,g,b,a)
        self.dungeonBatch:addg(tile.geometry, tile.x*self.tileWidth, tile.y*self.tileHeight)
      end
    end
  end
end

function Viewport:updateTileset()
  self.tilesetBatch:clear()
  for key,value in pairs(self.objects) do
    r,g,b,a = value:getColor()
    self.tilesetBatch:setColor(r,g,b,a)
    self.tilesetBatch:addg(value.geometry, value.x*self.tileWidth, value.y*self.tileHeight)
  end
end

function Viewport:render()
  self:updateTileset()
  love.graphics.draw(self.dungeonBatch,0,0) 
  love.graphics.draw(self.tilesetBatch,
     math.floor(-self.zoomX*(50%1)*self.tileWidth), math.floor(-self.zoomY*(25%1)*self.tileHeight),
     0, self.zoomX, self.zoomY)
end

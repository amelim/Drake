-- Andrew Melim
-- Drake Roguelike
local rogue
local viewport
local bloom

require "Entity"
require "Viewport"
require "Dungeon"

function love.load()
  --canvas = love.graphics.newCanvas(800, 800)

  viewport = Viewport:new()
  viewport:setTileset("oryx_roguelike_16x24_alpha.png",16,24)

  dungeon = Dungeon:new()
  dungeon:createFloor(viewport:getTilesetSize())
  viewport:registerDungeon(dungeon)

  rogue = Entity:new()
  rogue:setTile(1,25,16,24,viewport:getTilesetSize())
  rogue:setPos(1,1)
  viewport:register(rogue)

  local f = love.graphics.newFont(12)
  love.graphics.setFont(f)
end

function love.keypressed(key)   -- we do not need the unicode, so we can leave it out
   if key == "escape" then
      love.event.push("quit")   -- actually causes the app to quit
   end
end

function love.update(dt)
   if love.keyboard.isDown("escape")  then
      love.event.push("quit")   -- actually causes the app to quit
  end 
  x,y = rogue:getPos()
  if love.keyboard.isDown("up") and 
    dungeon:free(x,y-1)  then
    rogue:move(0, -1)
  end
  if love.keyboard.isDown("down")  and
    dungeon:free(x,y+1)  then
    rogue:move(0, 1)
  end
  if love.keyboard.isDown("left")  and
    dungeon:free(x-1,y) then
    rogue:move(-1, 0)
  end
  if love.keyboard.isDown("right")  and
    dungeon:free(x+1,y) then
    rogue:move(1, 0)
  end
end

function love.draw()
  viewport:render()
  love.event.wait( )
  --love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
  --love.graphics.print("Dungeon W:"..dungeon.w.."Dungeon H:"..dungeon.h, 10, 40)
  --love.graphics.print("Player Pos:"..rogue.x..","..rogue.y,10,60)
end
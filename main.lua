-- Andrew Melim
-- Drake Roguelike
local rogue
local viewport
local bloom

require "Entity"
require "Viewport"
require "Dungeon"

debug = false

function love.load()
  effect = love.graphics.newShader [[
    extern vec2 pos;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
      vec4 texcolor = Texel(texture, texture_coords);
      number alpha = 1/sqrt(pow((pixel_coords.x - pos.x),2) + pow((600-pixel_coords.y - pos.y),2));
      return vec4(1, 1, 1, alpha*60) * texcolor * color;
    }
  ]]

  --canvas = love.graphics.newCanvas(800, 800)
  love.window.setMode(800,600,{})
  viewport = Viewport:new()
  viewport:setTileset("oryx_roguelike_16x24_alpha.png",16,24)
  dungeon = Dungeon:new()
  dungeon:ruinsFloor(viewport:getTilesetSize())
  viewport:registerDungeon(dungeon)

  rogue = Entity:new()
  rogue:setTile(1,25,16,24,viewport:getTilesetSize())

  --Find empty space to start
  placed = false
  for x=1, dungeon.w do
    for y=1, dungeon.h do
      if(dungeon:free(x,y)) then
        rogue:setPos(x,y)
        placed = true
      end
      if(placed) then break end
    end
    if(placed) then break end
  end
  
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
  if love.keyboard.isDown("d") then debug = not debug end

  effect:send("pos", {8+x*16, 12+y*24})
end

function love.draw()
  love.graphics.setShader(effect)
  viewport:render()
  if debug then
    viewport:printRooms()
  end
  --love.event.wait( )
  
  --love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
  --love.graphics.print("Dungeon W:"..dungeon.w.."Dungeon H:"..dungeon.h, 10, 40)
  --love.graphics.print("Player Pos:"..rogue.x..","..rogue.y,10,60)
end
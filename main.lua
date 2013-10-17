-- Andrew Melim
-- Drake Roguelike
local rogue
local viewport
local bloom

require "Entity"
require "Viewport"
require "Dungeon"
require "FOV"

debug = false

function love.load()
  effect = love.graphics.newShader [[
    extern vec2 pos;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
      number radius = 300;
      vec4 texcolor = Texel(texture, texture_coords);
      number sqdist = pow((pixel_coords.x - pos.x),2) + pow((600-pixel_coords.y - pos.y),2);
      //intensityCoef2 = intensityCoef1 - 1.0/(1.0+radius*radius);
      //intensityCoef3 = intensityCoef2 / (1.0 - 1.0/(1.0+radius*radius));
      number if1 = 1/(1 + sqdist/20);
      number if2 = if1 - 1/(1+radius);
      number if3 = if2 / (1 - 1/(1 + radius));
      return vec4(1, 1, 1, if3*radius) * texcolor * color;
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

  fov = FOV:new()

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
  effect:send("pos", {8+x*16, 12+y*24})
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
  x,y = rogue:getPos()
  effect:send("pos", {8+x*16, 12+y*24})
  tW,tH = dungeon:getFloorSize()

  fov:findForwardEdges(x, y, dungeon:getBlocked(), tW, tH, 16, 24)
  fov:linkEdges(x,y,16,24)
  fov:project(x,y,16,24)
  
end

function love.draw()
  if not debug then
    love.graphics.setShader(effect)
  else
    love.graphics.setShader()
    viewport:printRooms()
    forwardEdges = fov:getForwardEdges()
    projections = fov:getProjections()

    local r=255
    local g=0
    local b=0
    for k,e in pairs(forwardEdges) do
      v = e:getLine()
      x0,y0 = v:getOrigin()
      x,y = v:getEnd()
      love.graphics.setColor(r,g,b)
      if g<255 then
        g = g+5
      elseif b < 255 then
        b = b+1
      end
      love.graphics.line(x0,y0,x,y)
    end

    
    love.graphics.print("Dungeon W:"..dungeon.w.."Dungeon H:"..dungeon.h, 10, 40)
    love.graphics.print("Player Pos:"..rogue.x..","..rogue.y,10,60)
  end
  love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
  viewport:render()
  love.event.wait()
  

end
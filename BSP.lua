--BSP.lua
--Andrew Melim
--http://roguebasin.roguelikedevelopment.org/index.php?title=Basic_BSP_Dungeon_generation

BSP = {width=0,height=0, max_depth=5}

function BSP:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function BSP:generate(w,h)
  self.root = {}
  self.root.depth = 0
  --Top left corner of this leaf
  self.root.x = 0
  self.root.y = 0
  --Width and height of this leaf
  self.root.w = w-1
  self.root.h = h-1

  self.min_w = 5
  self.min_h = 5
  self.leaf = false

  self:split(self.root)
end

--choose a random direction : horizontal or vertical splitting
--choose a random position (x for vertical, y for horizontal)
--split the dungeon into two sub-dungeons
function BSP:split(parent)

  if(parent.w <= self.min_w) then
    return parent
  end
  if(parent.h <= self.min_h) then
    return parent
  end

  parent.leaf = false

  --Determine if this is vertical or horizontal split
  local rand = math.random(0,10)

  left = {}
  right = {}

  left.depth = parent.depth + 1
  right.depth = parent.depth + 1
  left.leaf = true
  right.leaf = true

  local cut
  --Verify we have a minimum room size
  if(rand > 4)then
    --Vertical cut
    local cut = math.floor(parent.w/2)
    cut = cut + math.floor(math.random(0,parent.w/3))

    left.x = parent.x
    left.y = parent.y
    left.w = cut - left.x 
    left.h = parent.h


    --Add 1 to prevent overlap
    right.x = cut
    right.y = parent.y
    right.w = parent.w+parent.x-cut
    right.h = parent.h

  else
    --Horizontal Cut
    local cut = math.floor(parent.h/2)
    cut = cut + math.floor(math.random(0,parent.h/3))

    -- Left leaft is top slice
    left.x = parent.x
    left.y = parent.y
    left.w = parent.w
    left.h = cut - left.y

    right.x = parent.x
    --Add 1 to prevent overlap
    right.y = cut
    right.w = parent.w
    right.h = parent.h+parent.y-cut
  end

  parent.left = left
  parent.right = right

  -- Recusively split the leaves  
  if(parent.depth+1 < self.max_depth) then
    if(math.random(0,1)>0) then
      self:split(parent.left)  
      self:split(parent.right)  
    else
      self:split(parent.right)  
      self:split(parent.left)
    end
  end


  return parent
end

function BSP:addLeaf(parent, leaf)
  table.insert(parent, leaf)
end

function BSP:printNode(node)
  print("______________")
  print("Node Depth: "..node.depth)
  print("Node X: "..node.x.." Node Y: "..node.y)
  print("Node W: "..node.w.." Node H: "..node.h)
  print(string.format("Leaf: %s",tostring(node.leaf)))
end

function BSP:print(node)
  if(not node) then
    return 1
  end
  self:printNode(node)
 
  self:print(node.right)
  self:print(node.left)
end

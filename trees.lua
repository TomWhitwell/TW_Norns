-- scriptname: short script description
-- v1.0.0 @author
-- llllllll.co/t/22222
--[[
g, angle = love.graphics, 26 * math.pi / 180
wid, hei = g.getWidth(), g.getHeight()
function rotate( x, y, a )
  local s, c = math.sin( a ), math.cos( a )
  local a, b = x * c - y * s, x * s + y * c
  return a, b
end
function branches( a, b, len, ang, dir )
  len = len * .76
  if len < 5 then return end
  g.setColor( len * 16, 255 - 2 * len , 0 )
  if dir > 0 then ang = ang - angle
  else ang = ang + angle 
  end
  local vx, vy = rotate( 0, len, ang )
  vx = a + vx; vy = b - vy
  g.line( a, b, vx, vy )
  branches( vx, vy, len, ang, 1 )
  branches( vx, vy, len, ang, 0 )
end
function createTree()
  local lineLen = 127
  local a, b = wid / 2, hei - lineLen
  g.setColor( 160, 40 , 0 )
  g.line( wid / 2, hei, a, b )
  branches( a, b, lineLen, 0, 1 ) 
  branches( a, b, lineLen, 0, 0 )
end

function love.load()
  canvas = g.newCanvas( wid, hei )
  g.setCanvas( canvas )
  createTree()
  g.setCanvas()
end
function love.draw()
  g.draw( canvas )
end

]]--

    branchIteration = 0 

treeHeight = 15
density = 0.76 
curlyness = 1000

wid, hei = 128, 64

function rotate( x, y, a )
  local s, c = math.sin( a ), math.cos( a )
  local a, b = x * c - y * s, x * s + y * c
  return a, b
end



function branches( a, b, len, ang, dir, density, curlyness)
    branchIteration = branchIteration + 1
  -- angle =  26 * math.pi / 180 -- 26 = spread 
  angle =  (26) * math.pi / 180 -- 26 = SPREAD 
  
  len = len * density  -- DENSITY - HIGHER THE DENSER 
  if len < 5 then return end

  if dir > 0 then ang = ang - angle
  else ang = ang + angle 
  end
  local vx, vy = rotate( 0, len, ang + (branchIteration / curlyness) ) -- ADDING BRANCH ITERATION = TWISTYNESS 
  vx = a + vx; vy = b - vy
  screen.level( math.floor(len/2)  )
screen.move(a,b)
screen.line(vx,vy)
screen.stroke()
  -- screen.line( a, b, vx, vy )
  branches( vx, vy, len, ang, 1, density, curlyness )
  branches( vx, vy, len, ang, 0 , density, curlyness)
end


function createTree(height, offsetX, offsetY, density, curlyness) -- density = 0.9 very 0.5 not very /// curlyness 100000 = not very 100 = very 
  local lineLen = height
  local a, b = wid / 2 + offsetX, hei - (lineLen/2)+offsetY
  screen.level(15)

screen.move(wid / 2 + offsetX, hei + offsetX)
screen.line(a,b)
screen.stroke()

  branches( a, b, lineLen, 0, 1, density, curlyness ) 
  branches( a, b, lineLen, 0, 0 , density, curlyness)
end


function init()
  -- initialization
  
    counter = metro.init()
  counter.time = 0.11
  counter.count = -1
  counter.event = count
  counter:start()

enc(2,1)

end

function count(c)
  treeHeight = util.clamp(treeHeight *1.005, 8, 150)
  redraw()
end


function key(n,z)
  -- key actions: n = number, z = state
end

function enc(n,d)
  -- encoder actions: n = number, d = delta
  if n == 2 then
    treeHeight = util.clamp(treeHeight + d, 8, 150)
    redraw()
  end 
  
  if n == 1 then 
    curlyness = util.clamp(curlyness + (d*10), -1000, 1000)
    -- print (curlyness)
    redraw()
    end 

  if n == 3 then 
    density = util.clamp(density + (d/100), 0.5, 0.9)
    -- print (density)
    redraw()
    end 

  
end

function redraw()
  
   screen.clear()
      print (branchIteration)
if branchIteration > 75000 then 
  density = 0.76 
  curlyness = 10000 
  treeHeight = 20 
  end 
    branchIteration = 0 
-- print(treeHeight)
    createTree(treeHeight, 0, 0, density, curlyness )
    createTree(treeHeight*0.75, 20, 10, density, curlyness )

  
  
screen.stroke()
screen.update()
end

function cleanup()
  -- deinitialization
end
-- Apple demo
-- v1.0.0 @tomwhitwell
-- llllllll.co/t/22222



function init()
  -- initialization
end

function key(n,z)
  -- key actions: n = number, z = state
end

winx = 0
winy = 0


function enc(n,d)
  if n == 3 then
    winx = winx + d
  end

  if n == 2 then
    winy = winy + d
  end

  redraw()
end



function redraw()
  -- screen redraw
  
  screen.clear()
  
  
  for x = 1,128,1 do
    for y = 1, 64,1 do
    if ((x+y) % 2 == 0) then
      screen.pixel(x,y)
      end
 
    
    
    end 
    end 
   screen.fill()
   screen.update()
 screen.display_png(_path.dust.."code/aaaTom/appl.png",winx,winy)
  screen.update()
  
  
end

function cleanup()
  -- deinitialization
end
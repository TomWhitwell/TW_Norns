-- triangular random: 
-- v0.0.1 @tomwhitwell
-- musicthing.co.uk
--
--


function triangularRandom(low, high, mode)
u = math.random()
c = (mode - low) / (high - low)
if u > c then 
  u = 1.0 - u
  c = 1.0 - c
  low, high = high, low
end 
  return low + (high - low) * math.sqrt(u * c)
end



    -- def expovariate(self, lambd):
    --     """Exponential distribution.
    --     lambd is 1.0 divided by the desired mean.  It should be
    --     nonzero.  (The parameter would be called "lambda", but that is
    --     a reserved word in Python.)  Returned values range from 0 to
    --     positive infinity if lambd is positive, and from negative
    --     infinity to 0 if lambd is negative.
    --     """
    --     # lambd: rate lambd = 1/mean
    --     # ('lambda' is a Python reserved word)

    --     # we use 1-random() instead of random() to preclude the
    --     # possibility of taking the log of zero.
    --     return -_log(1.0 - self.random())/lambd


function expoVariate(lambd)
  return -math.log(1.0 - math.random())/lambd
  end 
  
  
  -- def paretovariate(self, alpha):
  --       """Pareto distribution.  alpha is the shape parameter."""
  --       # Jain, pg. 495

  --       u = 1.0 - self.random()
  --       return 1.0 / u ** (1.0/alpha)
  
  
function pareto(alpha)
  u = 1.0 - math.random()
  return 1.0 / u ^ (1.0/alpha)
  end 
  


distributions = {"Flat", "Triangular", "Pareto", "Expo"}

modePoint = 90
distribution = 1 

function init()
  -- initialization
  
  counter = metro.init()
  counter.time = .1
  counter.count = -1
  counter.event = count
  counter:start()
  


end 

function key(n,z)
 if n == 2 and z == 1 then 
   distribution = distribution + 1 
   if distribution > 4 then distribution = 1 end 
   end 
 
  -- key actions: n = number, z = state
end

function enc(n,d)
  -- encoder actions: n = number, d = delta
  if n == 2 then
  end   
  
  if n == 3 then
    modePoint = (modePoint + d ) % 128
  end
end

function redraw()
  -- screen redraw
results = {}  
for i = 1,128,1 do 
results[i] = 0
end 

for i = 1,2000,1 do 

if distribution == 1 then 
  sample = math.random(128)
elseif distribution == 2 then    
sample = (triangularRandom(1,128,modePoint))
elseif distribution == 3 then 
sample = pareto((modePoint / 64))*8
if sample > 128 then sample = 128 end 
if sample < 0 then sample = 0 end 


elseif distribution == 4 then 
lambd = modePoint / 128.0
sample = expoVariate(lambd) * 128

if sample > 128 then sample = 18 end 
if sample < 1 then sample = 1 end 

end 
sample = util.round(sample,1)
results[sample] = results[sample]+1
end

screen.clear()
screen.move(0,10)
screen.text(distribution .. " " .. distributions[distribution])
for i = 1,128,1 do 
screen.move(i,63)
screen.line_rel(0,-results[i])
screen.stroke()
end  
  screen.update()
  
end

function count(c)
  redraw()
  end

function cleanup()
  -- deinitialization
end
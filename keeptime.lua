-- Keeping track of time

numVoices = 6
activeSoundNames = {}
soundNames = {}
soundNames[1] = {}
soundNames[2] = {}
updateTimes = {}
rate = {1,0.01}

trackPosition = {} 


function init()

softcut.buffer_read_mono(_path.dust.. "audio/common/RadioMusic/Cage-John_Diary-1.mp3.wav",0, 1, 100, 1, 1)


  -- initialization
softcut.enable(1,1)
softcut.rate(1,rate[1])
softcut.fade_time(1,0.001)
softcut.buffer(1,1)
softcut.level(1,1.0)
softcut.loop(1,1)
softcut.loop_start(1,5)
softcut.loop_end(1,5.2)
softcut.position(1,1)
softcut.play(1,1)
    softcut.pan(1,0.5)

softcut.phase_quant(1,0.1)
softcut.event_phase(update_positions)
softcut.poll_start_phase()

softcut.enable(2,1)
softcut.buffer(2,1)
softcut.rate(2,rate[2])
softcut.fade_time(2,0.001)

softcut.level(2,1.0)
softcut.loop(2,0)
softcut.loop_start(2,0)
softcut.loop_end(2,200)
softcut.position(2,1)
softcut.play(2,1)
softcut.phase_quant(2,0.1)
    softcut.pan(2,0.5)
softcut.event_phase(update_positions)
softcut.poll_start_phase()

  counter = metro.init()
  counter.time = 0.1
  counter.count = -1
  counter.event = count
  counter:start()

redraw()
end

function key(n,z)
  -- key actions: n = number, z = state
end


function enc(n,d)
  if n == 2 then
    rate[1] = rate[1] + (d/100)
    print(rate[1])
softcut.rate(1,rate[1])
  end
  if n == 3 then
    rate[2] = rate[2] + (d/100)
    print(rate[2])
    softcut.rate(2,rate[2])
  end
  
  if n == 1 then 
  counter.time = counter.time + (d/100)
  if counter.time < 0.1 then
    counter.time = 0.1
    end 
  print(counter.time)
  end

end

function update_positions(voice,position)
trackPosition[voice] = position
redraw()
end

function redraw()
 screen.clear()
  for i = 1, 2, 1 do

 screen.move(10+i*20, 10)
   screen.text(rate[i])
   screen.move(0,10+(i*10)) 
      screen.line_width(8)
screen.line_rel(trackPosition[i],0)
end
screen.stroke()
screen.update()
end

function count(c)
-- softcut.position(1,math.random(120))
-- softcut.position(2,math.random(120))


end



function cleanup()
  -- deinitialization
end
-- Williams Mix: 6 channel version 
-- v0.0.1 @tomwhitwell
-- musicthing.co.uk

-- correct pan spread logic for 2-6 voices: 
-- =(voice-1)*(1/(numVoices-1))


--[[

Principles 

6 paths of audio 
each playing back from one (or two) buffer(s)
Looping through 10 second chunks of audio written across the buffer

Paths can be playing at different speeds
As the path proceeds, various audio actions things can happen: 
1. starts from stop, with slew 
2. fades in from silent 
3. fades to new audio
4. fades to self at a different playhead point 
5. fades to silence 
6. stops (with slew) -- the path continues to proceed until a start message is triggered 

Fade and Slew would be set at each point using softcut / slew 

Create a silent space in the buffer to fade into 

Path speeds might be user adjustable - midi with speed and direction and volume? 

Would need a 'score' with the changes that progresses in line with the play speed 
Which might be measured in seconds / milliseconds 
The slews / crossfades would be relative to the playback speed - 
so at 1 ips a 45 degree cut on a 1/4 in tape would take approx 1/4 second to pass 
but at 4ips that same cut would take 1/16 second 

score schema: 


]]--


seedIterate = 1
math.randomseed(seedIterate)
numVoices = 6
activeSoundNames = {}
soundNames = {}
soundNames[1] = {}
soundNames[2] = {}
updateTimes = {}

filePath = "audio/common/WilliamsMix/"

-- scan directory, store files in directory 
directory = util.scandir(_path.dust.. filePath)
-- directory = util.scandir(_path.dust.. "audio/common/RadioMusic/")



print (#directory .. " files found")

function init()

  counter = metro.init()
  counter.time = 0.15
  counter.count = -1
  
  counter:start()
  counter.event = bang

-- var for toggling on off 
  outputLevel = 1


-- fill buffers with random ten second snippets of files 
-- store names in soundnames[1 or 2][] 
  for i = 1,30,1 do 
    chosenfile = directory[math.random(#directory)]
    randomfilepath =  (_path.dust .. filePath .. chosenfile)
    print ("file details")
    print(audio.file_info(randomfilepath) )
    soundNames[1][i] = string.sub(randomfilepath, 40,-5)
    softcut.buffer_read_mono(randomfilepath, 0, 1+(i*10), 10, 1, 1)
    chosenfile = directory[math.random(#directory)]
    randomfilepath =  (_path.dust..filePath .. chosenfile)
    soundNames[2][i] = string.sub(randomfilepath, 40,-5)
    softcut.buffer_read_mono(randomfilepath, 0, 1+(i*10), 10, 1, 2)

  end


-- intitialise 6 voices 
-- playing the first 6 sounds in buffer 1 

for i=1,numVoices do
  -- enable voice i
  softcut.enable(i,1)
  -- set voice i to buffer 1
  softcut.buffer(i,1)
  -- set voice i level to 1.0
  softcut.level(i,1)
  -- voice i enable loop
  softcut.loop(i,1)
  -- set voice i loop start to 1+i*10
  softcut.loop_start(i,1+i*10)
  activeSoundNames[i] = soundNames[1][i]
  print (" just started " .. activeSoundNames[i])
  -- set voice i loop end to 60
  softcut.loop_end(i,11+i*10)
  -- set voice i position to 1
  softcut.position(i,1)
  -- set voice i rate to 1.0
  softcut.rate(i,1.0)
  -- enable voice 1 play
  softcut.play(i,1)
  -- set pan position 
  
  -- correct pan spread logic for 2-6 voices: 
-- =(voice-1)*(1/(numVoices-1))
panLevel = (i-1)*(1/(numVoices-1))
print("track ".. i .. " pan ".. panLevel)
  softcut.pan(i,panLevel)
  
  softcut.fade_time(i,0.05)
  updateTimes[i] = 1
  -- softcut.phase_quant(i,updateTimes[i])
end

  -- softcut.event_phase(update_positions)
  -- softcut.poll_start_phase()

  redraw()
end

function key(n,z)
  -- key actions: n = number, z = state
  if n == 3 and z == 1 then 
    seedIterate = seedIterate + 1 
math.randomseed(seedIterate)
print("randomising from " ..  seedIterate)
    init()
    end
    
      if n == 2 and z == 1 then
      -- trick below to toggle between 0 and 1
      outputLevel = 1 - outputLevel
       for i = 0,6,1 do 
             softcut.rate_slew_time(i,math.random(0.1))
    softcut.rate(i,outputLevel * (1.0))
          -- softcut.level(i,outputLevel * (1.0/numVoices))
       end 
    end
    
end

function enc(n,d)
  -- encoder actions: n = number, d = delta
end

function redraw()
  screen.clear()
  for i = 1,numVoices,1 do
    screen.move(10,(i*10))
    screen.text(activeSoundNames[i] .. " / " .. updateTimes[i])
  end
  screen.update()
end

function cleanup()
  -- deinitialization
end

function bang(c)
voice = math.random(numVoices)
  track = math.random(30)
  activeSoundNames[voice] = soundNames[1][track]
  redraw()
  softcut.loop_start(voice,(track*10))
  softcut.loop_end(voice,10+(track*10))
  if (math.random(10) > 5) then
    softcut.rate_slew_time(voice,1)
    softcut.rate(voice,0)
    -- print ("kill voice " .. voice )
    else
    -- print ("continue voice " .. voice )

    softcut.rate_slew_time(voice,1)
    softcut.rate(voice,1.0)

    end 



end

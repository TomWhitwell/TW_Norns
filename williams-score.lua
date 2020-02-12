-- Williams Mix: 6 channel version
-- v0.0.1 @tomwhitwell
-- musicthing.co.uk
-- math.randomseed(1)




local controlspec = require "controlspec"


numVoices = 6

playbackSpeeds = {1,1,1,2,3,4}
playbackPosition = {0,0,0,0,0,0}
scoreLength = 1000
scoreStep = {1,1,1,1,1,1}
timeDivider = 100;
activeSoundNames = {}
soundNames = {}
soundNames[1] = {}
soundNames[2] = {}


-- score schema
-- score[channel][1]  -- timecode
-- score[channel][2]  -- action
-- 1. starts from stop, with slew
-- 2. fades in from silent
-- 3. fades to new audio
-- 4. fades to self at a different playhead point
-- 5. fades to silence
-- 6. stops (with slew) -- the path continues to proceed until a start message is triggered
-- score[channel][3]  -- sound - 2-30, 1 is silence
-- score[channel][4]  -- slew rate


-- score [channel][step][1] == timecoder
-- score [channel][step][2] == action
-- score [channel][step][3] == filename
-- score [channel][step][4] == slew

score = {}

function printScore()
  print ("SCORE")
  print ("------")
  for i = 1, 6, 1 do
    print ("Path " ..  i)
    print ("----------")
    for j = 1,scoreLength,1 do
      print(j .. ": " .. " Timecode: " .. score[i][j][1] .. " Action: " .. score[i][j][2].. " File: " .. score[i][j][3] .. " Slew: " .. score[i][j][4] )
    end
    print("-----")
  end
  print("-SCORE END- ")
end

function randomizeScore(density)
  -- Create score
  print("randomising with density:" .. density)
  for i = 1, 6, 1 do
    score [i] = {}
    score[i][1] = {0,math.random(6),math.random(30), math.random(10)/4}

    for j = 2,scoreLength,1 do
      score[i][j] = {(math.random(density)/10 ) + score[i][j-1][1], math.random(6),math.random(30), math.random(2)/10}
    end
  end

end

-- scan directory, store files in directory
directory = util.scandir(_path.dust.. "audio/common/WilliamsMix/")
print (#directory .. " files found")


function init()


  params:add{type = "number", id = "one_start", name = "Number of voices", min=1, max=6,
  default=6,
  action=function(x) numVoices = x end }

  params:add{type = "number", id = "one_start", name = "Score density", min=5, max=200,
  default=100,
  action=function(x) randomizeScore(x) end }

  speed_cs = controlspec.new(-400,400,'lin',0,100,'%')
level_cs = controlspec.new(0,1.0,'lin',0,1.0,'')
params:add_control("rateAll","Rate All", speed_cs)
params:set_action("rateAll", function(x)   params:set("rate1", x)   params:set("rate2", x)   params:set("rate3", x)   params:set("rate4", x)   params:set("rate5", x)   params:set("rate6", x) end)
  
  for i = 1,6,1 do
        name = ("rate" .. i)
        text = ("Rate " .. i)
        params:add_control(name, text, speed_cs)
        params:set_action(name, function(x) playbackSpeeds[i] = x/100 softcut.rate(i,playbackSpeeds[i]) end)
    end 

params:add_control("levelAll","Level All", level_cs)
params:set_action("levelAll", function(x)   params:set("level1", x)   params:set("level2", x)   params:set("level3", x)   params:set("level4", x)   params:set("level5", x)   params:set("level6", x) end)

      for i = 1,6,1 do
        name = ("level" .. i)
        text = ("Level " .. i)
        params:add_control(name, text, level_cs)
        params:set_action(name, function(x) softcut.level(i,x) end)
    end 

  -- initialization
  randomizeScore(200)

  -- fill buffers with random ten second snippets of files
  -- store names in soundnames[1 or 2][]
  for i = 2,30,1 do
    chosenfile = directory[math.random(#directory)]
    randomfilepath =  (_path.dust.."audio/common/WilliamsMix/" .. chosenfile)
    soundNames[1][i] = string.sub(randomfilepath, 40,-5)
    softcut.buffer_read_mono(randomfilepath, 0, 1+(i*10), 10, 1, 1)
    chosenfile = directory[math.random(#directory)]
    randomfilepath =  (_path.dust.."audio/common/WilliamsMix/" .. chosenfile)
    soundNames[2][i] = string.sub(randomfilepath, 40,-5)
    softcut.buffer_read_mono(randomfilepath, 0, 1+(i*10), 10, 1, 2)
  end


  for i=1,numVoices do
    -- enable voice i
    softcut.enable(i,1)
    -- set voice i to buffer 1
    softcut.buffer(i,1)
    -- set voice i level to 1.0
    softcut.level(i,1/numVoices)
    -- voice i enable loop
    softcut.loop(i,1)
    -- set voice i loop start to 1+i*10
    softcut.loop_start(i,1+i*10)
    -- set voice i loop end to 60
    softcut.loop_end(i,11+i*10)
    -- set voice i position to 1
    softcut.position(i,1)
    -- set voice i rate to 1.0
    softcut.rate(i,1.0)
    -- enable voice 1 play
    softcut.play(i,1)
    -- set pan position
    softcut.pan(i,1/i)
    softcut.fade_time(i,5)
  end





  tick = metro.init()
  tick.time = 1/timeDivider
  tick.count = -1
  tick:start()
  tick.event = tock

  redraw()
end

function key(n,z)
  -- key actions: n = number, z = state
end

function enc(n,d)
  -- encoder actions: n = number, d = delta
end

function scoreCheck (path)
  -- if playback position has passed the next event in the score
  payload = ""
  if playbackPosition[path] >= score[path][scoreStep[path]][1] then
    -- then act on the event
    slewTime = score[path][scoreStep[path]][4]
    soundNumber = score[path][scoreStep[path]][3]
    action = score[path][scoreStep[path]][2]

    softcut.rate_slew_time(path,slewTime)
    softcut.fade_time(path,slewTime)


    -- 1. starts from stop, with slew
    -- 2. fades in from silent
    -- 3. fades to new audio
    -- 4. fades to self at a different playhead point
    -- 5. fades to silence
    -- 6. stops (with slew) -- the path continues to proceed until a start message is triggered

    if action == 1 then
      -- 1. starts from stop, with slew
      -- stop, then restart
      softcut.play(path, 0)

      softcut.loop_start(path,1+soundNumber*10)
      softcut.loop_end(path,11+soundNumber*10)

      softcut.play(path, 1)

      -- print("start playing voice ".. path .. " sound " .. soundNumber .. " slew:" .. slewTime .. " action:" .. action)

    elseif action == 2 then
      -- 2. fades in from silent
      softcut.play(path, 1)
      softcut.loop_start(path,1+soundNumber*10)
      softcut.loop_end(path,11+soundNumber*10)

    elseif action == 3 then
      -- 3. fades to new audio
      softcut.play(path, 1)
      softcut.loop_start(path,1+soundNumber*10)
      softcut.loop_end(path,11+soundNumber*10)

    elseif action == 4 then
      -- 4. fades to self at a different playhead point
      softcut.rate(path,-1.0)
      -- print ("<<<<")
    elseif action == 5 then
      -- 5. fades to silence
      softcut.rate(path,1.0)
      -- print(">>>>")
    elseif action == 6 then
      -- 6. stops (with slew) -- the path continues to proceed until a start message is triggered
      softcut.rate(path,0)
      -- print("|||||")
    else
      -- Do nothing
    end

    -- payload = to display
    payload = score[path][scoreStep[path]][2] .. " | " .. score[path][scoreStep[path]][3] .. "| " .. score[path][scoreStep[path]][4]



    -- and update the scoreStep by 1 so we are
    scoreStep[path] = scoreStep[path] + 1
    -- print ('path ' .. path .. " is on step ".. scoreStep[path])
    if scoreStep[path] >= scoreLength then
      scoreStep[path] = 1
      playbackPosition[path] = 1
    end
  end

  return payload
end


function redraw()
  screen.clear()
  screen.line_width(1)
  screen.rect(40,1,10,60)
  screen.level(1)
  screen.stroke()

  -- screen.line_width(8)
  for i = 1,numVoices,1 do

    timeLeft =  score[i][scoreStep[i]][1] - playbackPosition[i]
    timePrevious =  score[i][(scoreStep[i]-1) % scoreLength][1] - playbackPosition[i]

    screen.line_width(8)
    screen.level(15)
    screen.move(45, (i*10)-5)
    screen.line_rel(timeLeft*20,0)
    screen.stroke()
    screen.level(6)
    screen.move(45, (i*10)-5)
    screen.line_rel(timePrevious*20,0)



    screen.stroke()



  end
  screen.update()
end



function tock(c)
  for i = 1,numVoices,1 do
    playbackPosition[i] = playbackPosition[i] + (playbackSpeeds[i] / timeDivider)
    scoreCheck(i)
  end
  redraw()

end

function cleanup()
  -- deinitialization
end
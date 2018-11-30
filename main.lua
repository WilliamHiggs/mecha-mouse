
-- Main.lua Löve file
-- Imports
Timer = require "hump.timer"
Gamestate = require "hump.gamestate"
-- Game States
local startMenu = {}
local game = {}
-- run time table
local runTimes = {}
-- Main Load
function love.load()
  -- GLOBAL VARIABLES
  function initGlobals()
    player = {}
    obstacles = {}
    gameSpeed = 300
    floorLevel = 500
    windowx = love.graphics.getWidth()
    windowy = love.graphics.getHeight()
  end

  -- Trunacates the timers trailing decimals
  function truncateTime(number)
    local decimals = 2
    local power = 10^decimals
    return math.floor(number * power) / power
  end

 -- Inserts latest run, sorts and returns the longest time
  function bestRunTime(thisTable, runTime)
    table.insert(thisTable, runTime)
    table.sort(thisTable, function(a,b) return a > b end)
    return tostring(thisTable[1])
  end

  -- Creates a new animation out of a sprite
  function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}

    for y = 0, image:getHeight() - height, height do
      for x = 0, image:getWidth() - width, width do
        table.insert(
          animation.quads,
          love.graphics.newQuad(
            x,
            y,
            width,
            height,
            image:getDimensions()
          )
        )
      end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
  end

  -- Tracks the current sprite showing
  function spriteNum(item)
    local item = item
    return math.floor(item.img.currentTime / item.img.duration * #item.img.quads) + 1
  end

  -- Animates the sprites in game.update
  function animate(animation, dt)
    animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
      animation.currentTime = animation.currentTime - animation.duration
    end
  end

  -- Creates a new obstacle
  function newObstacle(img, x, y, w, h)
    local obstacle = {}
    obstacle.x = x
    obstacle.y = y
    obstacle.img = img
    obstacle.width = w
    obstacle.height = h
    obstacle.removed = false
    table.insert(obstacles, obstacle)
  end

  -- Creates the player object
  function loadPlayer(img, x, y, w, h)
    player.x = x
  	player.y = y
    player.width = w
    player.height = h
  	player.img = img
  	player.ground = player.y
  	player.y_velocity = 0
  	player.jump_height = -600
  	player.gravity = -1000
    player.mode = "mouse"
  end

  -- boundingBox Collision detection
  function CheckCollision(box1x, box1y, box1w, box1h, box2x, box2y, box2w, box2h)
      if box1x > box2x + box2w - 5 or -- Is box1 on the right side of box2?
         box1y > box2y + box2h - 5 or -- Is box1 under box2?
         box2x > box1x + box1w - 5 or -- Is box2 on the right side of box1?
         box2y > box1y + box1h - 5    -- Is b2 under b1?
      then
          return false
      else
          return true
      end
  end

  -- Gamestate loading
  function loadMenu()
    Gamestate.registerEvents()
    Gamestate.switch(startMenu)
  end
  -- Load Timers
  function loadTimers()
    startTime = love.timer.getTime()
    spawnTimer = Timer.new()
    -- Spawn timer: spwans a random obstacle every two seconds
    spawnTimer:every(2, function()
      gameSpeed = gameSpeed + 20
      local function getRandom()
        return love.math.random(0, 2)
      end
      local randomNumber = getRandom()
      if randomNumber == 0 then
        obstacle1 = newObstacle(poopImg, 1200, floorLevel - 100, 100, 100)
        obstacle3 = newObstacle(flySprite, 1200, floorLevel - 500, 100, 100)
      elseif randomNumber == 1 then
        obstacle2 = newObstacle(cokeImg, 1200, floorLevel - 200, 90, 200)
      elseif randomNumber == 2 then
        obstacle4 = newObstacle(racoonSprite, 1200, floorLevel - 144, 100, 144)
      end
    end)
  end
  -- Load sounds
  function loadSounds()
    sounds = {}
    sounds.mouseSqueak = {}
    sounds.mouseSqueak.audio = love.audio.newSource("/assets/mouseSqueak.mp3", "static")
    sounds.mouseSqueak.played = false
  end
  --Load background music
  function loadBackgroundMusic()
    sounds.backgroundMusic = {}
    sounds.backgroundMusic.audio = love.audio.newSource("/assets/mecha-mouse-track.wav", "stream")
    if sounds.backgroundMusic.audio:isPlaying() == false then
      sounds.backgroundMusic.audio:setLooping(true)
      sounds.backgroundMusic.audio:play()
    end
  end
  -- Load fonts
  function loadFonts()
    menuFont = love.graphics.newFont("/assets/COMPUTERRobot.ttf", 25)
    largeFont = love.graphics.newFont("/assets/COMPUTERRobot.ttf", 50)
  end
  -- Load images
  function loadImages()
    mouseSprite = newAnimation(love.graphics.newImage("/assets/mouse.png"), 100, 100, 0.8)
    mouseJumpImg = love.graphics.newImage("/assets/mouseJump.png")
    mechaSprite = newAnimation(love.graphics.newImage("/assets/mecha.png"), 100, 100, 0.8)
    mechaJumpImg = love.graphics.newImage("/assets/mechaJump.png")
    deadMouseSprite = newAnimation(love.graphics.newImage("/assets/deadMouse.png"), 100, 100, 0.9)
    poopImg = love.graphics.newImage("/assets/poop.png")
    cokeImg = love.graphics.newImage("/assets/coke-can.png")
    flySprite = newAnimation(love.graphics.newImage("/assets/flySprite.png"), 128, 128, 0.8)
    racoonSprite = newAnimation(love.graphics.newImage("/assets/racoon.png"), 100, 144, 1)
  end
  -- BACKGROUND LOAD
  function loadBackground()
    bgImg = love.graphics.newImage("/assets/curbSprite.png")

    bg1 = {}
    bg1.img = love.graphics.newQuad(0, 0, 800, 450, 1600, 450)
    bg1.x = 0
    bg1.width = windowx

    bg2 = {}
    bg2.img = love.graphics.newQuad(800, 0, 800, 450, 1600, 450)
    bg2.x = -windowx
    bg2.width = windowx

    -- PLATFORM LOAD
    pfImg = love.graphics.newImage("/assets/Road_035.png")

    pf1 = {}
    pf1.img = love.graphics.newQuad(0, 0, 800, 200, 1400, 200)
    pf1.x = 0
    pf1.width = windowx

    pf2 = {}
    pf2.img = love.graphics.newQuad(0, 0, 800, 200, 1400, 200)
    pf2.x = -windowx
    pf2.width = windowx
  end

  initGlobals()
  loadImages()
  loadFonts()
  loadPlayer(mouseSprite, 5, floorLevel - 100, 100, 100)
  loadSounds()
  loadBackgroundMusic()
  loadBackground()
  loadMenu()
  loadTimers()

end

-- STARTMENU SWITCH
function startMenu:update(dt)
  animate(racoonSprite, dt)
  function startMenu:keypressed(key)
    if key == "return" then
      Gamestate.switch(game)
    end
  end
end
-- STARTMENU DRAW
function startMenu:draw()
  string = [[
  UP - To jump
  SPACE - To change mode
  ESC - To quit
  ]]
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setFont(largeFont)
  love.graphics.print("MECHA-MOUSE", 200, 100)
  love.graphics.setFont(menuFont)
  love.graphics.print(string, 200, 200)
  love.graphics.print("PRESS ENTER TO START", 200, 300)
  love.graphics.draw(player.img.spriteSheet, player.img.quads[1], player.x, player.y)
  love.graphics.draw(racoonSprite.spriteSheet, racoonSprite.quads[1], 600, floorLevel - 144)
end

-- GAME UPDATE
function game:update(dt)
  spawnTimer:update(dt)
  -- PLATFORM UPDATE
  pf1.x = pf1.x - gameSpeed * dt
  pf2.x = pf2.x - gameSpeed * dt

  if pf1.x < -windowx then
    pf1.x = pf2.x + pf1.width
  end
  if pf2.x < -windowx then
    pf2.x = pf1.x + pf2.width
  end

  -- BACKGROUND UPDATE
  bg1.x = bg1.x - gameSpeed * dt
  bg2.x = bg2.x - gameSpeed * dt

  if bg1.x < -windowx then
    bg1.x = bg2.x + bg1.width
  end
  if bg2.x < -windowx then
    bg2.x = bg1.x + bg2.width
  end

  animate(mouseSprite, dt)
  animate(mechaSprite, dt)
  animate(deadMouseSprite, dt)
  animate(flySprite, dt)
  animate(racoonSprite, dt)

  if love.keyboard.isDown("up") then
    if player.y_velocity == 0 then
      player.y_velocity = player.jump_height
    end
  end

  if player.y_velocity ~= 0 then
    player.y = player.y + player.y_velocity * dt
    player.y_velocity = player.y_velocity - player.gravity * dt
  end

  if player.y > player.ground then
    player.y_velocity = 0
    player.y = player.ground
  end

  function love.keypressed(key)
    if key == "escape" then
      love.event.push("quit")
    end

    if key == "space" then
      if player.mode == "mouse" then
        --player.img = -- mecha sprite
        player.jump_height = -800 -- mecha jump height
        player.mode = "mecha"
      elseif player.mode == "mecha" then
        --player.img = -- mouse sprite
        player.jump_height = -600 -- mouse jump height
        player.mode = "mouse"
      end
    end

    if key == "return" and player.mode == "dead" then
      initGlobals()
      loadSounds()
      loadPlayer(mouseSprite, 5, floorLevel - 100, 100, 100)
      loadTimers()
    end

  end

  for i = #obstacles, 1, -1 do
    local obstacle = obstacles[i]
  if not obstacle.removed then
    obstacle.x = obstacle.x - gameSpeed * dt
    else table.remove(obstacles, i) end
  end

end

-- GAME DRAW
function game:draw()
  -- SET TIMER
  if player.mode ~= "dead" then
    gameTimer = love.timer.getTime() - startTime
  end
  -- BACKGROUND + PLATFORM
  love.graphics.draw(bgImg, bg1.img, bg1.x, 0)
  love.graphics.draw(bgImg, bg2.img, bg2.x, 0)
  love.graphics.draw(pfImg, pf1.img, pf1.x, floorLevel - 50)
  love.graphics.draw(pfImg, pf2.img, pf2.x, floorLevel - 50)
  -- DRAW TIMER
  love.graphics.setFont(menuFont)
  love.graphics.print(truncateTime(gameTimer), 500, 20)
  -- PLAYER MODE
  love.graphics.print(player.mode, 40, 20)
  -- OBSTACLES
  for i = #obstacles, 1, -1 do
    local obstacle = obstacles[i]

    if type(obstacle.img) == "table" then
      local obstacleSpriteNum = spriteNum(obstacle)
      love.graphics.draw(obstacle.img.spriteSheet, obstacle.img.quads[obstacleSpriteNum], obstacle.x, obstacle.y)
    else
      love.graphics.draw(obstacle.img, obstacle.x, obstacle.y)
    end

    if CheckCollision(player.x, player.y, player.width, player.height, obstacle.x, obstacle.y, obstacle.width, obstacle.height) then
      -- If collision player is dead
      player.mode = "dead"
    end
  end

  -- PLAYER
  if (player.mode == "mouse") then
    if (player.y_velocity ~= 0) then
      player.img = mouseJumpImg
      love.graphics.draw(player.img, player.x, player.y)
    else
      player.img = mouseSprite
      local mouseSpriteNum = spriteNum(player)
      love.graphics.draw(player.img.spriteSheet, player.img.quads[mouseSpriteNum], player.x, player.y)
    end
  elseif (player.mode == "mecha") then
    if (player.y_velocity ~= 0) then
      player.img = mechaJumpImg
      love.graphics.draw(player.img, player.x, player.y)
    else
      player.img = mechaSprite
      local mechaSpriteNum = spriteNum(player)
      love.graphics.draw(player.img.spriteSheet, player.img.quads[mechaSpriteNum], player.x, player.y)
    end
  elseif (player.mode == "dead") then
    player.img = deadMouseSprite
    local deadMouseSpriteNum = spriteNum(player)
    love.graphics.draw(player.img.spriteSheet, player.img.quads[deadMouseSpriteNum], player.x, player.y)
    -- Play squeak once only
    if (sounds.mouseSqueak.played == false) then
      sounds.mouseSqueak.audio:play()
      sounds.mouseSqueak.played = true
    end
    -- clear globals
    player.jump_height = 0
    gameSpeed = 0
    spawnTimer:clear()
    -- show game times
    local thisRunTime = truncateTime(gameTimer)
    love.graphics.print("Press enter to restart", 300, 375)
    love.graphics.setFont(largeFont)
    love.graphics.print("This run: " .. thisRunTime, 300, 400)
    love.graphics.print("Best run: " .. bestRunTime(runTimes, thisRunTime), 300, 450)
  end

end

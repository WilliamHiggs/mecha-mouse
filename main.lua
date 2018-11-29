
-- Main.lua Löve file
--local platform = {}
local player = {}
local obstacles = {}
local gameSpeed = 300
local floorLevel = 500
local windowx = love.graphics.getWidth()
local windowy = love.graphics.getHeight()
local Timer = require "hump.timer"
local Gamestate = require "hump.gamestate"
local startMenu = {}
local game = {}
local endMenu = {}

function truncateTime(number)
  local decimals = 2
  local power = 10^decimals
  return math.floor(number * power) / power
end

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

function spriteNum(item)
  local item = item
  return math.floor(item.img.currentTime / item.img.duration * #item.img.quads) + 1
end

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

-- LOAD
function love.load()
  -- Gamestate loading
  Gamestate.registerEvents()
  Gamestate.switch(startMenu)
  -- Load Timers
  startTime = love.timer.getTime()
  spawnTimer = Timer.new()
  -- Load sounds
  sounds = {}
  sounds.mouseSqueak = {}
  sounds.mouseSqueak.audio = love.audio.newSource("/assets/mouseSqueak.mp3", "static")
  sounds.mouseSqueak.played = false
  sounds.backgroundMusic = {}
  sounds.backgroundMusic.audio = love.audio.newSource("/assets/mecha-mouse-track.wav", "stream")
  sounds.backgroundMusic.audio:setLooping(true)
  sounds.backgroundMusic.audio:play()
  -- Load fonts
  menuFont = love.graphics.newFont("/assets/COMPUTERRobot.ttf", 25)
  largeFont = love.graphics.newFont("/assets/COMPUTERRobot.ttf", 100)
  -- Load images
  mouseSprite = newAnimation(love.graphics.newImage("/assets/mouse.png"), 100, 100, 1)
  mouseJumpImg = love.graphics.newImage("/assets/mouseJump.png")
  mechaSprite = newAnimation(love.graphics.newImage("/assets/mecha.png"), 100, 100, 1)
  mechaJumpImg = love.graphics.newImage("/assets/mechaJump.png")
  deadMouseSprite = newAnimation(love.graphics.newImage("/assets/deadMouse.png"), 100, 100, 0.9)
  poopImg = love.graphics.newImage("/assets/poop.png")
  cokeImg = love.graphics.newImage("/assets/coke-can.png")
  flySprite = newAnimation(love.graphics.newImage("/assets/flySprite.png"), 128, 128, 0.8)

  -- BACKGROUND LOAD
  bgImg = love.graphics.newImage("/assets/curbSprite.png")

  bg1 = {}
  bg1.img = love.graphics.newQuad(0, 0, 800, 450, 1600, 450)
  bg1.x = 0
  bg1.width = 800

  bg2 = {}
  bg2.img = love.graphics.newQuad(800, 0, 800, 450, 1600, 450)
  bg2.x = -windowx
  bg2.width = 800

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

  --loadPlatform(platformSprite)

  loadPlayer(mouseSprite, 5, floorLevel - 100, 100, 100)

  function animate(animation, dt)
    animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
      animation.currentTime = animation.currentTime - animation.duration
    end
  end

  spawnTimer:every(2, function()
    gameSpeed = gameSpeed + 15
    local function getRandom()
      return love.math.random(0, 1)
    end
    local randomNumber = getRandom()
    if randomNumber == 1 then
      obstacle1 = newObstacle(poopImg, 1200, floorLevel - 100, 100, 100)
      obstacle3 = newObstacle(flySprite, 1200, floorLevel - 500, 100, 100)
    else
      obstacle2 = newObstacle(cokeImg, 1200, floorLevel - 200, 90, 200)
    end
  end)
end

-- STARTMENU DRAW
function startMenu:draw()
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setFont(menuFont)
  love.graphics.print("PRESS ENTER TO START", 200, 200)
end

-- STARTMENU SWITCH
function startMenu:keypressed(key)
  if key == "return" then
    Gamestate.switch(game)
  end
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
  -- TIMER
  if player.mode ~= "dead" then
    gameTimer = love.timer.getTime() - startTime
  end
  -- BACKGROUND
  love.graphics.draw(bgImg, bg1.img, bg1.x, 0)
  love.graphics.draw(bgImg, bg2.img, bg2.x, 0)
  -- PLATFORM
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
    -- draw stuff
    if type(obstacle.img) == "table" then
      local obstacleSpriteNum = spriteNum(obstacle)
      love.graphics.draw(obstacle.img.spriteSheet, obstacle.img.quads[obstacleSpriteNum], obstacle.x, obstacle.y)
    else
      love.graphics.draw(obstacle.img, obstacle.x, obstacle.y)
    end

    if CheckCollision(player.x, player.y, player.width, player.height, obstacle.x, obstacle.y, obstacle.width, obstacle.height) then
      -- Player death sequence
      if (sounds.mouseSqueak.played == false) then
        sounds.mouseSqueak.audio:play()
        sounds.mouseSqueak.played = true
      end
      player.mode = "dead"
      player.jump_height = 0
      gameSpeed = 0
      spawnTimer:clear()
      love.graphics.setFont(largeFont)
      love.graphics.print(truncateTime(gameTimer), 400, 400)
    end
  end
  -- PLAYER
  if (player.mode == "mouse") then
    if (player.y_velocity > 0) then
      player.img = mouseJumpImg
      love.graphics.draw(player.img, player.x, player.y)
    else
      player.img = mouseSprite
      local mouseSpriteNum = spriteNum(player)
      love.graphics.draw(player.img.spriteSheet, player.img.quads[mouseSpriteNum], player.x, player.y)
    end
  elseif (player.mode == "mecha") then
    if (player.y_velocity > 0) then
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
  end

end

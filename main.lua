
-- Main.lua Löve file
local platform = {}
local player = {}
local obstacles = {}
local gameSpeed = 300
local floorLevel = 500
local Timer = require "hump.timer"
local startTime = love.timer.getTime()
spawnTimer = Timer.new()

function truncateTime(x)
  local numStr = tostring(x)
  local trunStr = string.sub(numStr, 1, -12)
  return trunStr
end

function newAnimation(image, width, height, duration)
  local animation = {}
  animation.spriteSheet = image;
  animation.quads = {};

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

function loadPlatform(img)
  platform.width = love.graphics.getWidth()
	platform.height = love.graphics.getHeight()
	platform.x = 0
	platform.y = floorLevel
  platform.img = img
end

function loadPlayer(x, y, w, h)
  player.x = x
	player.y = y
  player.width = w
  player.height = h
	player.img = nil --love.graphics.newImage('/assets/test.png')
	player.ground = player.y
	player.y_velocity = 0
	player.jump_height = -600
	player.gravity = -900
  player.mode = "mouse"
end

-- boundingBox Collision detection
function CheckCollision(box1x, box1y, box1w, box1h, box2x, box2y, box2w, box2h)
    if box1x > box2x + box2w - 1 or -- Is box1 on the right side of box2?
       box1y > box2y + box2h - 1 or -- Is box1 under box2?
       box2x > box1x + box1w - 1 or -- Is box2 on the right side of box1?
       box2y > box1y + box1h - 1    -- Is b2 under b1?
    then
        return false
    else
        return true
    end
end

-- LOAD
function love.load()
  -- Load fonts
  menuFont = love.graphics.newFont("/assets/COMPUTERRobot.ttf", 25)
  largeFont = love.graphics.newFont("/assets/COMPUTERRobot.ttf", 100)
  -- Load images
  poopImg = love.graphics.newImage("/assets/poop.png")
  flySprite = newAnimation(love.graphics.newImage("/assets/flySprite.png"), 128, 128, 0.4)
  platformSprite = newAnimation(love.graphics.newImage("/assets/Road_035.png"), 800, 200, 1)

  loadPlayer(5, floorLevel - 100, 100, 100)

  loadPlatform(platformSprite)

  function animate(animation, dt)
    animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
      animation.currentTime = animation.currentTime - animation.duration
    end
  end

  spawnTimer:every(2, function()
    local function getRandom()
      return love.math.random(0, 1)
    end
    local randomNumber = getRandom()
    if randomNumber == 1 then
      obstacle1 = newObstacle(poopImg, 1200, floorLevel - 100, 100, 100)
      obstacle3 = newObstacle(flySprite, 1200, floorLevel - 500, 100, 100)
    else
      obstacle2 = newObstacle(poopImg, 1200, floorLevel - 200, 100, 200)
    end
  end)
end

-- UPDATE
function love.update(dt)
  spawnTimer:update(dt)

  animate(flySprite, dt)
  animate(platformSprite, dt)

  if love.keyboard.isDown("up") then
    gameSpeed = gameSpeed + 2
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

-- DRAW
function love.draw()
  -- TIMER
  if player.mode ~= "dead" then
    gameTimer = love.timer.getTime() - startTime
  end
  love.graphics.setFont(menuFont)
  love.graphics.print(truncateTime(gameTimer), 500, 20)
  -- PLAYER MODE
  love.graphics.print(player.mode, 40, 40)
  -- BACKGROUND
  love.graphics.setBackgroundColor(0, 1, 1)
  -- PLATFORM
  --love.graphics.setColor(0,1,0)
	--love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
  local platformSpriteNum = spriteNum(platform)
  love.graphics.draw(platform.img.spriteSheet, platform.img.quads[platformSpriteNum], platform.x, platform.y)
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
      player.mode = "dead"
      player.jump_height = 0
      gameSpeed = 0
      spawnTimer:clear()
      love.graphics.setFont(largeFont)
      love.graphics.setColor(0, 0, 0)
      love.graphics.print(truncateTime(gameTimer), 400, 400)
    end
  end
  -- PLAYER
  --love.graphics.draw(player.img, player.x, player.y)
  love.graphics.setColor(50, 50, 50)
  love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

end

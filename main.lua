
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

function newObstacle(x, y, w, h)
  local obstacle = {}
  obstacle.x = x
  obstacle.y = y
  obstacle.img = nil--love.graphics.newImage('/assets/obs.png')
  obstacle.width = w
  obstacle.height = h
  obstacle.removed = false
  table.insert(obstacles, obstacle)
end

function loadPlatform()
  platform.width = love.graphics.getWidth()
	platform.height = love.graphics.getHeight()
	platform.x = 0
	platform.y = floorLevel
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

  menuFont = love.graphics.newFont("/assets/COMPUTERRobot.ttf", 25)

  loadPlayer(5, floorLevel - 100, 100, 100)

  loadPlatform()

  spawnTimer:every(2, function()
    local function getRandom()
      return love.math.random(0, 1)
    end
    local randomNumber = getRandom()
    if randomNumber == 1 then
      obstacle1 = newObstacle(1200, floorLevel - 100, 100, 100)
    else
      obstacle2 = newObstacle(1200, floorLevel - 200, 100, 200)
    end
  end)
end

-- UPDATE
function love.update(dt)
  spawnTimer:update(dt)

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
  gameTimer = love.timer.getTime() - startTime
  love.graphics.setFont(menuFont)
  love.graphics.print(truncateTime(gameTimer), 500, 20)
  -- PLAYER MODE
  love.graphics.print(player.mode, 40, 40)
  -- BACKGROUND
  love.graphics.setBackgroundColor( 0, 1, 1 )
  -- PLATFORM
  love.graphics.setColor(0,1,0)
	love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
  -- OBSTACLES
  for i = #obstacles, 1, -1 do
    local obstacle = obstacles[i]
    -- draw stuff
    --love.graphics.draw(obstacle.img, obstacle.x, obstacle.y)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", obstacle.x, obstacle.y, obstacle.width, obstacle.height)

    if CheckCollision(player.x, player.y, player.width, player.height, obstacle.x, obstacle.y, obstacle.width, obstacle.height) then
      -- Player death sequence
      gameSpeed = 0
      spawnTimer:clear()
      love.graphics.print(truncateTime(gameTimer), 80, 80)
    end
  end
  -- PLAYER
  --love.graphics.draw(player.img, player.x, player.y)
  love.graphics.setColor(50, 50, 50)
  love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

end

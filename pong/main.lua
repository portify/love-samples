local WIN_DEATH_COUNT = 10
local WIN_PAUSE_TIME = 1
local DEATH_PAUSE_TIME = 0.5

local BALL_SIZE = 20
local BALL_SPEED_INITIAL = 100
local BALL_SPEED_BOUNCED = 1.1

local PADDLE_WIDTH = 20
local PADDLE_HEIGHT = 150
local PADDLE_SPEED = 200

local player1, player2, ball
local pause_time, pause_func

local function reset_ball()
  local width, height = love.window.fromPixels(love.graphics.getDimensions())

  ball = {
    x = width / 2,
    y = height / 2,
    velx = (love.math.random(0, 1) - 0.5) * 2 * BALL_SPEED_INITIAL,
    vely = (love.math.random(0, 1) - 0.5) * 2 * BALL_SPEED_INITIAL,
  }
end

local function reset_game()
  local width, height = love.window.fromPixels(love.graphics.getDimensions())

  pause_time = nil
  pause_func = nil

  player1 = {deaths = 0, paddle = height / 2 - PADDLE_HEIGHT / 2}
  player2 = {deaths = 0, paddle = height / 2 - PADDLE_HEIGHT / 2}

  reset_ball()
end

function love.load()
  love.graphics.setFont(love.graphics.newFont(64))
  reset_game()
end

function love.update(dt)
  if pause_time then
    if pause_time <= 0 then
      pause_time = nil
      pause_func()
    else
      pause_time = pause_time - dt
      return
    end
  end

  local width, height = love.window.fromPixels(love.graphics.getDimensions())
  local dir

  -- Player 1 input
  dir =
    (love.keyboard.isDown("down") and  1 or 0) +
    (love.keyboard.isDown("up"  ) and -1 or 0)

  player1.paddle = player1.paddle + dir * PADDLE_SPEED * dt
  player1.paddle = math.max(0, math.min(height - PADDLE_HEIGHT, player1.paddle))

  -- For seeing if we just entered a paddle
  local old_x = ball.x

  ball.x = ball.x + ball.velx * dt
  ball.y = ball.y + ball.vely * dt

  -- Bounce off of walls
  if ball.y < 0 or ball.y + BALL_SIZE > height then
    ball.y = ball.y - ball.vely * dt
    ball.vely = ball.vely * -1
  end

  -- This part could be improved a lot

  -- Bounce off of paddles
  if old_x >= PADDLE_WIDTH and ball.x < PADDLE_WIDTH then
    if
      ball.y + BALL_SIZE >= player1.paddle and
      ball.y < player1.paddle + PADDLE_HEIGHT
    then
      ball.x = ball.x - ball.velx * dt
      ball.velx = ball.velx * -BALL_SPEED_BOUNCED
    end
  elseif old_x + BALL_SIZE < width - PADDLE_WIDTH and ball.x + BALL_SIZE >= width - PADDLE_WIDTH then
    if
      ball.y + BALL_SIZE >= player2.paddle and
      ball.y < player2.paddle + PADDLE_HEIGHT
    then
      ball.x = ball.x - ball.velx * dt
      ball.velx = ball.velx * -BALL_SPEED_BOUNCED
    end
  end

  -- Hit side walls and give points!
  if ball.x < 0 then
    player1.deaths = player1.deaths + 1

    if player1.deaths >= WIN_DEATH_COUNT then
      pause_time = WIN_PAUSE_TIME
      pause_func = reset_game
    else
      pause_time = DEATH_PAUSE_TIME
      pause_func = reset_ball
    end
  elseif ball.x + BALL_SIZE >= width then
    player2.deaths = player2.deaths + 1

    if player2.deaths >= WIN_DEATH_COUNT then
      pause_time = WIN_PAUSE_TIME
      pause_func = reset_game
    else
      pause_time = DEATH_PAUSE_TIME
      pause_func = reset_ball
    end
  end
end

function love.draw()
  local width, height = love.graphics.getDimensions()
  local center = width / 2

  -- Draw stiple
  local y = 0

  while y < height - 5 do
    love.graphics.rectangle("fill", width / 2 - 5, y, 10, 10)
    y = y + 20
  end

  -- Draw scores
  love.graphics.printf(player2.deaths, 0, 5, center - 20, "right")
  love.graphics.printf(player1.deaths, center + 20, 5, center - 20, "left")

  -- Draw ball & paddles
  if not pause_time then
    love.graphics.rectangle("fill", ball.x, ball.y, BALL_SIZE, BALL_SIZE)
  end

  love.graphics.rectangle("fill", 0,                    player1.paddle, PADDLE_WIDTH, PADDLE_HEIGHT)
  love.graphics.rectangle("fill", width - PADDLE_WIDTH, player2.paddle, PADDLE_WIDTH, PADDLE_HEIGHT)
end

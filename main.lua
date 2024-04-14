require 'src/player'

function love.load()
  love.graphics.setDefaultFilter('nearest')

  game = {
    scale = 6,
    time = 0
  }

  test_map = require 'map/test'
  
  game.gfx = {}
  game.gfx.forest = {}
  game.gfx.forest.i = love.graphics.newImage('gfx/forest.png')
  game.gfx.forest.q = {
    love.graphics.newQuad(0, 0, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(8, 0, 8, 8, game.gfx.forest.i)
  }
  game.gfx.home = {}
  game.gfx.home.i = love.graphics.newImage('gfx/home.png')
  game.gfx.home.q = {
    love.graphics.newQuad(0, 0, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(8, 0, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(0, 8, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(8, 8, 8, 8, game.gfx.home.i)
  }

  love.resize()

  player.load()

  input = {
    up = false,
    dn = false,
    lt = false,
    rt = false,
    prev = {
      up = false,
      dn = false,
      lt = false,
      rt = false,
    }
  }
end

function simple_grid()
  local w = math.floor(love.graphics.getWidth() / game.scale)
  local h = math.floor(love.graphics.getHeight() / game.scale)
  local canvas = love.graphics.newCanvas(w, h)

  love.graphics.setCanvas(canvas)
  local tile = game.gfx.forest.i
  local quad = game.gfx.forest.q
  for x = 0, w, 8 do
    for y = 0, h, 8 do
      local q = quad[1]
      if math.random() > 0.5 then
        q = quad[math.random(2)]
      end
      love.graphics.draw(tile, q, x, y)
    end
  end
  draw_object(game.object.home, game.gfx.home.i, game.gfx.home.q, 8, 8)
  love.graphics.setCanvas()

  return canvas
end

function map()
  local w = test_map.width * 8
  local h = test_map.height * 8
  local canvas = love.graphics.newCanvas(w, h)
  local x = 0
  local y = 0
  
  love.graphics.setCanvas(canvas)
  for i = 1, #test_map.string do
    local c = test_map.string:sub(i, i)

    if c == '.' then
      local tile = game.gfx.forest.i
      local quad = game.gfx.forest.q[math.random(2)]
      love.graphics.draw(tile, quad, x, y)
      x = x + 8
    elseif c == 'W' then
      local tile = game.gfx.home.i
      local quad = game.gfx.home.q[2]
      love.graphics.draw(tile, quad, x, y)
      x = x + 8
    elseif c == 'D' then
      local tile = game.gfx.home.i
      local quad = game.gfx.home.q[1]
      love.graphics.draw(tile, quad, x, y)
      x = x + 8
    elseif c == '\n' then
      x = 0
      y = y + 8
    end
  end
  love.graphics.setCanvas()

  return canvas
end

function love.resize()
  -- canvas = simple_grid()
  canvas = map()
end

function love.update(dt)
  game.time = game.time + dt

  input.up = love.keyboard.isScancodeDown('w', 'up')
  input.dn = love.keyboard.isScancodeDown('s', 'down')
  input.lt = love.keyboard.isScancodeDown('a', 'left')
  input.rt = love.keyboard.isScancodeDown('d', 'right')

  player.update(dt)

  input.prev.up = input.up
  input.prev.dn = input.dn
  input.prev.lt = input.lt
  input.prev.rt = input.rt
end

function love.draw()
  love.graphics.draw(canvas, 0, 0, 0, game.scale)
  player.draw()
end
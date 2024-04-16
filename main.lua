require 'src/player'

function love.load()
  love.graphics.setDefaultFilter('nearest')

  game = {
    scale = 6,
    time = 0
  }

  test_map = require 'map/test'

  game.map = {}
  game.map.width = 0
  game.map.height = 0
  game.map.layout = {}
  game.map.is_wall = function(x, y)
    local within_x = 0 <= x and x < game.map.width
    local within_y = 0 <= y and y < game.map.height
    if within_x and within_y then
      local cell = (x + y * game.map.width) + 1
      if bit.band(game.map.layout[cell], 0x80) == 0 then
        return false
      end
    end
    return true
  end
  
  game.gfx = {}
  game.gfx.forest = {}
  game.gfx.forest.i = love.graphics.newImage('gfx/forest.png')
  game.gfx.forest.q = {
    love.graphics.newQuad(0, 0, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(8, 0, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(0, 8, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(8, 8, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(0, 16, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(8, 16, 8, 8, game.gfx.forest.i),
  }
  game.gfx.home = {}
  game.gfx.home.i = love.graphics.newImage('gfx/home.png')
  game.gfx.home.q = {
    love.graphics.newQuad(0, 0, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(8, 0, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(0, 8, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(8, 8, 8, 8, game.gfx.home.i)
  }
  
  generate_simple_map()
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

function generate_simple_map()
  game.map.width = test_map.width
  game.map.height = test_map.height
  local cells = {
    ['.'] = string.byte('.'),
    ['D'] = string.byte('D'),
    ['W'] = string.byte('W') + 0x80,
  }
  
  local offset = 0
  for i = 1, #test_map.string do
    local char = test_map.string:sub(i, i)

    if char == '\n' then
      offset = offset + 1
    else
      game.map.layout[i - offset] = cells[char]
    end
  end
end

function simple_map_canvas()
  local canvas = love.graphics.newCanvas(w, h)
  
  love.graphics.setCanvas(canvas)
  for i = 1, #game.map.layout do
    local tile, quad
    local cell = string.char(bit.band(game.map.layout[i], 0x7F))

    if cell == '.' then
      tile = game.gfx.forest.i
      if math.random() > 0.5 then
        quad = game.gfx.forest.q[1]
      else
        quad = game.gfx.forest.q[3]
      end
    elseif cell == 'W' then
      tile = game.gfx.home.i
      quad = game.gfx.home.q[2]
    elseif cell == 'D' then
      tile = game.gfx.home.i
      quad = game.gfx.home.q[1]
    end

    local x = (i - 1) % game.map.width
    local y = math.floor((i - 1) / game.map.width)

    love.graphics.draw(tile, quad, x * 8, y * 8)
  end
  love.graphics.setCanvas()

  return canvas
end

function love.resize()
  -- canvas = simple_grid()
  canvas = simple_map_canvas()
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
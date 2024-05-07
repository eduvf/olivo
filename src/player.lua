player = {
  -- cells
  x = 0,
  y = 0,
  -- pixels
  px = 0,
  py = 0,
  flip = false,
  anim = 1
}

function player.load()
  player.image = love.graphics.newImage('gfx/player.png')
  player.quad = {
    love.graphics.newQuad(0, 0, 8, 8, player.image),
    love.graphics.newQuad(8, 0, 8, 8, player.image),
    love.graphics.newQuad(0, 8, 8, 8, player.image),
    love.graphics.newQuad(8, 8, 8, 8, player.image),
    love.graphics.newQuad(0, 16, 8, 8, player.image),
    love.graphics.newQuad(8, 16, 8, 8, player.image),
    love.graphics.newQuad(0, 24, 8, 8, player.image),
    love.graphics.newQuad(8, 24, 8, 8, player.image),
  }
end

function player.update(dt)
  local x, y = 0, 0
  local dx, dy = 0, 0

  if input.lt then x = x - 1 end
  if input.rt then x = x + 1 end
  if input.up then y = y - 1 end
  if input.dn then y = y + 1 end

  local dist = 0.5
  local dist_x = math.abs(player.px - player.x * 8)
  local dist_y = math.abs(player.py - player.y * 8)
  if dist_x < dist and dist_y < dist then
    if x ~= 0 or y ~= 0 then
      dx = dx + x
      dy = dy + y
    end
  else
    if input.lt and not input.prev.lt then dx = dx - 1 end
    if input.rt and not input.prev.rt then dx = dx + 1 end
    if input.up and not input.prev.up then dy = dy - 1 end
    if input.dn and not input.prev.dn then dy = dy + 1 end
  end

  if dx ~= 0 or dy ~= 0 then
    if game.map.is_wall(player.x + dx, player.y + dy) then
      player.px = player.px + dx * 4
      player.py = player.py + dy * 4
      game.map.check_panel(player.x + dx, player.y + dy)
    else
      player.x = player.x + dx
      player.y = player.y + dy
    end
  end

  local diff = dt * 6
  player.px = player.px - (player.px - player.x * 8) * diff
  player.py = player.py - (player.py - player.y * 8) * diff

  if input.lt then player.flip = true end
  if input.rt then player.flip = false end

  if love.keyboard.isScancodeDown('1') then player.anim = 1 end
  if love.keyboard.isScancodeDown('2') then player.anim = 2 end
  if love.keyboard.isScancodeDown('3') then player.anim = 3 end
  if love.keyboard.isScancodeDown('4') then player.anim = 4 end
end

function player.draw()
  local frame = math.floor(game.time * 2) % 2 + (player.anim * 2 - 1)
  
  local x = player.px * game.scale
  local y = player.py * game.scale
  local sx, sy = game.scale, game.scale
  local ox, oy = 0, 0
  if player.flip then
    x = x + game.scale
    sx = sx * -1
    ox = game.scale
  end

  love.graphics.setColor(0, 0, 0, 0.5)
  local rect_scale = 8 * game.scale
  local rect_x = player.x * rect_scale
  local rect_y = player.y * rect_scale
  love.graphics.rectangle('fill', rect_x, rect_y, rect_scale, rect_scale)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(player.image, player.quad[frame], x, y, 0, sx, sy, ox, oy)
end

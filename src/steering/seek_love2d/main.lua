local Object = require('vendor/object')
local vector = require('vendor/vector')

local debug = true
local seekType = 'default' -- 'default' or 'approach'
local ww, wh = love.graphics.getDimensions()

local Mob = Object:extend()

function Mob:new ()
  self.width = 30
  self.height = 30
  self.pos = vector(love.math.random(ww), love.math.random(wh))
  self.maxVelocity = 150
  self.vel = vector(self.maxVelocity, 0):rotated(love.math.random(360))
  self.acc = vector(0, 0)
  self.maxSeekForce = 200
  self.approachRadius = 100
  self.color = {
    r = 2,
    g = 217,
    b = 94
  }
end

function Mob:getCenter ()
  local ox = self.width / 2
  local oy = self.height / 2

  return {
    x = self.pos.x + ox,
    y = self.pos.y + oy,
    ox = ox,
    oy = oy
  }
end

function Mob:checkBounds ()
  if self.pos.x < 0 then
    self.pos.x = ww
  elseif self.pos.x > ww then
    self.pos.x = 0
  end

  if self.pos.y < 0 then
    self.pos.y = wh
  elseif self.pos.y > wh then
    self.pos.y = 0
  end
end

function Mob:followMouse ()
  local mpos = vector(love.mouse.getPosition())

  return (mpos - self.pos):normalized()
end

function Mob:seek (target)
  self.desiredVelocity = (target - self.pos):normalized() * self.maxVelocity

  local steer = (self.desiredVelocity - self.vel)

  if steer:len() > self.maxSeekForce then
    steer = steer:trimmed(self.maxSeekForce)
  end

  return steer
end

function Mob:seekWithApproach (target)
  local toTarget = (target - self.pos)
  local distance = toTarget:len()

  toTarget:normalizeInplace()

  if distance < self.approachRadius then
    self.desiredVelocity = toTarget * distance / self.approachRadius * self.maxVelocity
  else
    self.desiredVelocity = toTarget * self.maxVelocity
  end

  local steer = (self.desiredVelocity - self.vel)

  if steer:len() > self.maxSeekForce then
    steer = steer:trimmed(self.maxSeekForce)
  end

  return steer
end

function Mob:update (dt)
  local mousePosition = vector(love.mouse.getPosition())

  if seekType == 'approach' then
    self.acc = self:seekWithApproach(mousePosition)
  else
    self.acc = self:seek(mousePosition)
  end

  self.vel = self.vel + self.acc * dt

  if self.vel:len() > self.maxVelocity then
    self.vel = self.vel:trimmed(self.maxVelocity)
  end

  self.pos = self.pos + self.vel * dt

  self:checkBounds()
end

function Mob:draw ()
  love.graphics.setColor(self.color.r, self.color.g, self.color.b)
  love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.width, self.height)

  -- debug lines
  if debug then
    self:drawDebug()
  end
end

function Mob:drawDebug ()
  local center = self:getCenter()
  local mx, my = love.mouse.getPosition()

  love.graphics.setLineWidth(2)

  -- velocity
  love.graphics.setColor(32, 144, 204)
  love.graphics.line(center.x, center.y, center.x + self.vel.x, center.y + self.vel.y)

  -- desired velocity
  if self.desiredVelocity then
    love.graphics.setColor(236, 94, 103)
    love.graphics.line(center.x, center.y, center.x + self.desiredVelocity.x, center.y + self.desiredVelocity.y)
  end

  -- approach radius
  love.graphics.setLineWidth(1)
  love.graphics.setColor(249, 252, 251)
  love.graphics.circle('line', mx, my, self.approachRadius)
end

local mob = nil

function love.load ()
  mob = Mob()
end

function love.update (dt)
  mob:update(dt)
end

function love.draw ()
  mob:draw()
end

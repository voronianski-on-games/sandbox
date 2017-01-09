local Object = require('vendor/object')
local vector = require('vendor/vector')

local Mob = Object:extend()

function Mob:new ()
  local width, height = love.graphics.getDimensions()

  self.width = 30
  self.height = 30
  self.pos = vector(10, 10)
  self.vel = vector(0, 0)
  self.acc = vector(0, 0)
  self.maxVelocity = 350
  self.maxSeekForce = 100
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
  local width, height = love.graphics.getDimensions()

  if self.pos.x < 0 then
    self.pos.x = width
  elseif self.pos.x > width then
    self.pos.x = 0
  end

  if self.pos.y < 0 then
    self.pos.y = height
  elseif self.pos.y > height then
    self.pos.y = 0
  end
end

function Mob:followMouse ()
  mpos = vector(love.mouse.getPosition())
  return (mpos - self.pos):normalized()
end

function Mob:seek (target)
  self.desired = (target - self.pos):normalized() * self.maxVelocity

  local steer = self.desired - self.vel

  if steer:len() > self.maxSeekForce then
    steer = steer:normalized() * self.maxSeekForce
  end

  return steer
end

function Mob:update (dt)
  self.acc = self:seek(vector(love.mouse.getPosition()))
  self.vel = self.vel + self.acc * dt

  if self.vel:len() > self.maxVelocity then
    self.vel = self.vel:normalized() * self.maxVelocity
  end

  self.pos = self.pos + self.vel * dt
  self:checkBounds()
end

function Mob:draw ()
  local center = self:getCenter()

  love.graphics.setColor(self.color.r, self.color.g, self.color.b)
  love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.width, self.height)

  -- debug lines
  love.graphics.setLineWidth(2)
  -- velocity
  love.graphics.setColor(32, 144, 204)
  love.graphics.line(center.x, center.y, center.x + self.vel.x, center.y + self.vel.y)
  -- desired
  if self.desired then
    love.graphics.setColor(68, 214, 250)
    love.graphics.line(center.x, center.y, center.x + self.desired.x, center.y + self.desired.y)
  end
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
local Object = require('vendor/object')
local vector = require('vendor/vector')

local debug = true
local ww, wh = love.graphics.getDimensions()
local Mob = Object:extend()

function Mob:new ()
  self.width = 30
  self.height = 30
  self.pos = vector(math.random(0, ww), math.random(0, wh))
  self.vel = vector(0, 0)
  self.acc = vector(0, 0)
  self.maxVelocity = 150
  self.maxSeekForce = 20
  self.target = vector(math.random(0, ww), math.random(0, wh))
  self.targetLived = 0
  self.targetLifeTime = 0.5
  self.wanderRingDistance = 150
  self.wanderRingRadius = 60
  self.wanderType = 'improved'
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
  self.desired = (target - self.pos):normalized() * self.maxVelocity

  local steer = (self.desired - self.vel)

  if steer:len() > self.maxSeekForce then
    steer = steer * self.maxSeekForce
  end

  return steer
end

function Mob:wander (dt)
  self.targetLived = self.targetLived + dt

  if self.targetLived > self.targetLifeTime then
    self.targetLived = 0
    self.target = vector(math.random(0, ww), math.random(0, wh))
  end

  return self:seek(self.target)
end

function Mob:wanderImproved ()
  local circlePosition = self.pos + self.vel:normalized() * self.wanderRingDistance
  local target = circlePosition + vector(self.wanderRingRadius, 0):rotated(math.random(0, 360))

  self.displacement = target

  return self:seek(target)
end

function Mob:update (dt)
  if self.wanderType == 'random' then
    self.acc = self:wander(dt)
  else
    self.acc = self:wanderImproved()
  end

  self.vel = self.vel + self.acc * dt

  if self.vel:len() > self.maxVelocity then
    self.vel = self.vel * self.maxVelocity
  end

  self.pos = self.pos + self.vel * dt
  self:checkBounds()
end

function Mob:draw ()
  local mx, my = love.mouse.getPosition()

  -- entity
  love.graphics.setColor(self.color.r, self.color.g, self.color.b)
  love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.width, self.height)

  -- debug lines
  if debug then
    self:drawDebug()
  end
end

function Mob:drawDebug ()
  local center = self:getCenter()

  love.graphics.setLineWidth(2)

  -- velocity
  love.graphics.setColor(32, 144, 204)
  love.graphics.line(center.x, center.y, center.x + self.vel.x, center.y + self.vel.y)

  -- desired
  if self.desired then
    love.graphics.setColor(68, 214, 250)
    love.graphics.line(center.x, center.y, center.x + self.desired.x, center.y + self.desired.y)
  end

  if self.wanderType == 'random' then
    love.graphics.setColor(244, 217, 66)
    love.graphics.circle('fill', self.target.x, self.target.y, 5)
  else
    if self.displacement then
      local circlePosition = self.pos + self.vel:normalized() * self.wanderRingDistance

      love.graphics.setLineWidth(1)
      love.graphics.setColor(249, 252, 251)
      love.graphics.circle('line', circlePosition.x, circlePosition.y, self.wanderRingRadius)
      love.graphics.setColor(66, 244, 146)
      love.graphics.line(circlePosition.x, circlePosition.y, self.displacement.x, self.displacement.y)
    end
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

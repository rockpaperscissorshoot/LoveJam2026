love.physics.setMeter(64)

local RADIUS = 12
local MOVEMENT_FORCE = 198
local ACCELERATION = 20
local VELOCITY_LIMIT = 28
local TARGETMAXVELOCITY = 448
local WorldDt = 0

local world = love.physics.newWorld(0, 900, true)

local groundWidth =14000
local groundHeight = 80
local screenHeight = love.graphics.getHeight()
local groundBody = love.physics.newBody(world, 0, screenHeight, "static")
local groundShape = love.physics.newRectangleShape(groundWidth, groundHeight)
local groundFixture = love.physics.newFixture(groundBody, groundShape)
groundFixture:setFriction(0.4)
groundFixture:setRestitution(0.0)
groundFixture:setUserData("platform")

local playerBody = love.physics.newBody(world, 80, 490, "dynamic")
playerBody:setFixedRotation(true)
playerBody:setLinearDamping(0.27)
playerBody:setMass(62)
local playerShape = love.physics.newCircleShape(RADIUS)
local playerFixture = love.physics.newFixture(playerBody, playerShape, 1.0)
playerFixture:setFriction(0.4)
playerFixture:setRestitution(0.0)
local facing = 1
local onGround = false


local Camera = {}
local CAMERA_SPEED = 6
Camera.__index = Camera


--=============
--==Functions==
--=============
function detectGround()
    local px = playerBody:getX()
    local py = playerBody:getY()
    onGround = false
    world:queryBoundingBox(
        playerBody:getX() - RADIUS - 1, 
        playerBody:getY() - RADIUS - 1, 
        playerBody:getX() + RADIUS + 1, 
        playerBody:getY() + RADIUS + 1, 
        function(fixture)
            if fixture:getUserData() == "platform" then
                onGround = true
            end
            return true
        end
    )
end

function getDamping (vx)
    playerVelocity=vx
    local damping
    damping = math.max (0,(TARGETMAXVELOCITY- playerVelocity) / TARGETMAXVELOCITY )
    return damping
end

-------------------------------------------------------------------------------

function Camera.new(width, Height)
    local x = 0
    local y = 0
    local width = width
    local height = Height
    local speed = CAMERA_SPEED

    return setmetatable({x,y,width,height,speed}, Camera)
end

function Camera:update(target, dt)
    local targetX = target.x - self.width * 0.5
    local targetY = target.y - self.height * 0.45

    self.x = self.x + (targetX - self.x) * self.speed * dt
    self.y = self.y + (targetY - self.y) * self.speed * dt
end

function Camera:apply()
    love.graphics.push()
    love.graphics.translate(-math.floor(self.x), -math.floor(self.y))
end

function Camera:release()
    love.graphics.pop()
end

local cam = Camera.new(love.graphics.getWidth(), love.graphics.getHeight())

function love.load()
    love.window.setFullscreen(true)
end

function love.update(dt)
    
    detectGround()

    local vx, vy = playerBody:getLinearVelocity()
    local movingLeftBoolean = love.keyboard.isDown("a")
    local movingRightBoolean = love.keyboard.isDown("d")

    
    if movingLeftBoolean then
        local damping = getDamping(-vx)
        playerBody:applyForce(-MOVEMENT_FORCE * damping, 0)
        facing = -1
    end
    if movingRightBoolean then
        local damping = getDamping(vx)
        playerBody:applyForce(MOVEMENT_FORCE * damping, 0)
        facing = 1
    end

    worldDt = dt

    world:update(dt)
end

function love.keypressed(key)
    if key == "space" and onGround then 
        playerBody:applyLinearImpulse(0, -80)
    end

    if key == "escape" then
        love.event.quit()
    end

    if key == "e" then
        playerBody:applyLinearImpulse(100* facing, -87)
    end
end

function love.draw()

    love.graphics.setColor(1, 0.4, 0.4, 0.7)
    love.graphics.circle("fill", playerBody:getX(), playerBody:getY(), RADIUS)

    love.graphics.setColor(0.4, 0.8, 1, 0.7)
    love.graphics.polygon("fill", groundBody:getWorldPoints(groundShape:getPoints()))

    love.graphics.setColor(1, 1, 1)
    local vx, vy = playerBody:getLinearVelocity()
    love.graphics.print(vx, 10, 10)
    love.graphics.print(worldDt, 10, 30)
end
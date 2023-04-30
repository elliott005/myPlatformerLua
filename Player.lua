Player = Object:extend()

function Player:new()
    self.width = 50
    self.height = 75
    self.rect = createRect(100, 500, self.width, self.height, "dynamic", 1)
    self.rect.body:setFixedRotation(true)
    self.rect.body:setLinearDamping(0.9)
    self.rect.fixture:setUserData("player")
    self.rect.fixture:setMask(2)
    self.rect.fixture:setCategory(3)
    self.rect.fixture:setFriction(0.4)
    -- self.rect.fixture:setFriction(1.0)
    self.tom = love.graphics.newImage("images/Animation/walk_1.png")
    self.attackFrames = {}
    for i = 1,4 do
        table.insert(self.attackFrames, love.graphics.newImage("images/Animation/swoosh_" .. i .. ".png"))
    end
    self.slashFrames = {}
    for i = 1,3 do
        table.insert(self.slashFrames, love.graphics.newImage("images/Animation/slash_" .. i .. ".png"))
    end
    self.slashTime = 1
    self.swoosh = love.graphics.newImage("images/Animation/swoosh_2.png")
    -- self.swooshRect = createRect(self.rect.body:getX() + self.width, self.rect.body:getY(), self.width, self.height, "static", 1, false)
    self.attack = false
    self.attackTime = 1
    self.tomRight = true
    self.walkFrames = {}
    for i = 1,4 do
        table.insert(self.walkFrames, love.graphics.newImage("images/Animation/walk_" .. i .. ".png"))
    end
    self.jumpFrames = love.graphics.newImage("images/Animation/jump_1.png")
    self.jumpFramesDown = love.graphics.newImage("images/Animation/jump_2.png")
    self.walkTime = 1
    self.walking = false
    self.speed = 650
    self.grounded = false
    self.jumpStr = 640
    self.limitX = 200
    self.limitY = 420

    self.heart = love.graphics.newImage("images/Heart.png")
    self.heartGrey = love.graphics.newImage("images/Heartgrey.png")
    self.maxHealth = 3
    self.health = self.maxHealth

    self.score = 0

    self.walkSpeed = 5
    self.attackSpeed = 15
    self.slashSpeed = 10

    self.rect.body:setX(self.limitX)
    self.rect.body:setY(self.limitY)

    self.rotation = 0
    self.backflip = false

    self.tiny = false

    self.joint = 0

    self.grappleOnce = true
end

function Player:update(dt)
    -- print(self.dash)
    if numJoysticks < 1 then
        if love.keyboard.isDown("left") then
            self:move("left")
        
        elseif love.keyboard.isDown("right") then
            self:move("right")
        else
            self.walking = false
        end
        if love.keyboard.isDown("space") then
            self:jump()
        end

        if love.keyboard.isDown("c") and not self.attack then
            self:strike()
        end
        if love.keyboard.isDown("b") then
            self.backflip = true
        end
        if love.keyboard.isDown("v") then
            self:switchSize()
        end
    else
        if joysticks[1]:isDown(1) and not self.attack then
            self:strike()
        end

        if joysticks[1]:isDown(2) then
            self:jump()
        end

        if joysticks[1]:isDown(4) and not self.attack then
            self.backflip = true
        end

        if joysticks[1]:isDown(5) or joysticks[1]:isDown(6) then
            if self.grappleOnce then
                self:grapple()
                self.grappleOnce = false
            end
        else
            self.grappleOnce = true
        end

        if joysticks[1]:getAxis(1) < -0.1 then
            self:move("left")
        
        elseif joysticks[1]:getAxis(1) > 0.1 then
            self:move("right")
        else
            self.walking = false
        end
        if joysticks[1]:isDown(3) then
            self:switchSize()
        end
    end

    xSpeed, ySpeed = self.rect.body:getLinearVelocity() 
    xSpeed = math.min(math.max(xSpeed ^ 2 / 100000, 1), 5)

    if self.walking then
        self.walkTime = self.walkTime + self.walkSpeed * xSpeed * dt
        if self.walkTime >= 5 then
            self.walkTime = 1
        end
    end

    if self.attack then
        if self.tomRight then
            self.swooshRect.body:setPosition(self.rect.body:getX() + self.width, self.rect.body:getY())
        else
            self.swooshRect.body:setPosition(self.rect.body:getX() - self.width, self.rect.body:getY())        
        end
        self.slashTime = self.slashTime + self.slashSpeed * dt
        if self.slashTime >= 4 then
            self.slashTime = 1
        end
        self.attackTime = self.attackTime + self.attackSpeed * dt
        if self.attackTime >= 5 then
            self.attackTime = 1
            self.attack = false
            self.swooshRect.fixture:destroy()
        end
    end

    if self.health <= 0 or self.rect.body:getY() > 2000 then
        deathSound:play()
        love.load() 
    end

    if self.backflip then
        self.rotation = self.rotation - 10 * dt
        if self.rotation < -6 then
            self.rotation = 0
            self.backflip = false
        end
    end
end

function Player:draw()
    if not self.attack then
        if self.grounded then
            if self.tomRight then
                if self.walking then
                    love.graphics.draw(self.walkFrames[math.floor(self.walkTime)], self.limitX, self.limitY, self.rotation, self.width / self.tom:getWidth(), self.height / self.tom:getHeight())
                else
                    love.graphics.draw(self.tom, self.limitX, self.limitY, self.rotation, self.width / self.tom:getWidth(), self.height / self.tom:getHeight())
                end
            else
                if self.walking then
                    love.graphics.draw(self.walkFrames[math.floor(self.walkTime)], self.limitX + self.width, self.limitY, self.rotation, -(self.width / self.tom:getWidth()), self.height / self.tom:getHeight())
                else
                love.graphics.draw(self.tom, self.limitX + self.width, self.limitY, self.rotation, -(self.width / self.tom:getWidth()), self.height / self.tom:getHeight())
                end
            end
        else
            local x, y = self.rect.body:getLinearVelocity()
            if y < 100 then
                if self.tomRight then
                    love.graphics.draw(self.jumpFrames, self.limitX, self.limitY, self.rotation, self.width / self.tom:getWidth(), self.height / self.tom:getHeight())
                else
                    love.graphics.draw(self.jumpFrames, self.limitX + self.width, self.limitY, self.rotation, -(self.width / self.tom:getWidth()), self.height / self.tom:getHeight())
                end
            else
                if self.tomRight then
                    love.graphics.draw(self.jumpFramesDown, self.limitX, self.limitY, self.rotation, self.width / self.tom:getWidth(), self.height / self.tom:getHeight())
                else
                    love.graphics.draw(self.jumpFramesDown, self.limitX + self.width, self.limitY, self.rotation, -(self.width / self.tom:getWidth()), self.height / self.tom:getHeight())
                end
            end
        end
    else
        if self.tomRight then
            love.graphics.draw(self.slashFrames[math.floor(self.slashTime)], self.limitX, self.limitY, self.rotation, self.width / self.tom:getWidth(), self.height / self.tom:getHeight())
        else
            love.graphics.draw(self.slashFrames[math.floor(self.slashTime)], self.limitX + self.width, self.limitY, self.rotation, -(self.width / self.tom:getWidth()), self.height / self.tom:getHeight())
        end
    end

    if self.attack then
        if self.tomRight then
            love.graphics.draw(self.attackFrames[math.floor(self.attackTime)], self.limitX + self.width, self.limitY, 0, self.width / self.swoosh:getWidth(), self.height / self.swoosh:getHeight())
        else
            love.graphics.draw(self.attackFrames[math.floor(self.attackTime)], self.limitX, self.limitY, 0, -(self.width / self.swoosh:getWidth()), self.height / self.swoosh:getHeight())
        end
    end

    love.graphics.setFont(font)
    love.graphics.print("Coins: " .. self.score, font)

    for i=1,self.maxHealth do
        if i <= self.health then
            love.graphics.draw(self.heart, 50 * i, 50, 0, 2, 2)
        else
            love.graphics.draw(self.heartGrey, 50 * i, 50, 0, 2, 2)
        end
    end

    if not (self.joint == 0) then
        love.graphics.setColor(0/255, 0/255, 0/255)
        love.graphics.line(self.limitX + self.rect.width / 2, self.limitY, 
        (self.grappled.body:getX()) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
        (self.grappled.body:getY()) - (player.rect.body:getY() - player.height / 2) + player.limitY)
    end
    -- love.graphics.rectangle("fill", self.limitX, self.limitY, self.width, self.height)
    -- love.graphics.setColor(255/255, 255/255, 200/255)
    -- love.graphics.polygon("fill", self.feet.body:getWorldPoints(self.feet.shape:getPoints()))
    love.graphics.setColor(255, 255, 255)
end

function Player:keypressed(key)
    if key == "x" then
        self:grapple()
    end
end

function Player:hurt()
    love.audio.play(painSound)
    self.health = self.health - 1
end

function Player:move(direction)
    if not self.attack then
        if direction == "left" then
            -- self.rect.body:setX(self.rect.body:getX() - self.speed * dt)
            self.rect.body:applyForce(-self.speed, 0)
            self.tomRight = false
            self.walking = true
        elseif direction == "right" then
            -- self.rect.body:setX(self.rect.body:getX() + self.speed * dt)
            self.rect.body:applyForce(self.speed, 0)
            self.tomRight = true
            self.walking = true
        end
    end
end

function Player:jump()
    if self.grounded or not (self.joint == 0) then
        if not (self.joint == 0) then
            self.joint:destroy()
            self.joint = 0
        end
        -- self.rect.body:applyLinearImpulse(0, -self.jumpStr)
        local x, y = self.rect.body:getLinearVelocity()
        self.rect.body:setLinearVelocity(x, -self.jumpStr)
        self.grounded = false
        love.audio.play(jumpSound)
    end
end

function Player:strike()
    self.attack = true
    if self.tomRight then
        self.swooshRect = createRect(self.rect.body:getX() + self.width, self.rect.body:getY(), self.width, self.height, "static", 1)
    else
        self.swooshRect = createRect(self.rect.body:getX() - self.width, self.rect.body:getY(), self.width, self.height, "static", 1)       
    end
    self.swooshRect.fixture:setUserData("sword")
    self.swooshRect.fixture:setCategory(2)
    swooshSound:play()
end

function Player:grapple()
    if self.joint == 0 then
        local closest = 300
        local closestIndex = 0
        for i,v in ipairs(anchors) do
            if v.body:getY() < self.rect.body:getY() then
                local distance = getDistance(v.body:getX(), v.body:getY(), self.rect.body:getX(), self.rect.body:getY())
                if distance < closest then
                    closest = distance
                    closestIndex = i
                end
            end
        end
        if not (closestIndex <= 0) then
            ropeSound:play()
            local rect1 = anchors[closestIndex]
            local rect2 = self.rect
            self.joint = love.physics.newRopeJoint( rect1.body, rect2.body, rect1.body:getX() + rect1.width / 2, rect1.body:getY() + rect1.height / 2, rect2.body:getX() + rect2.width / 2, rect2.body:getY(), closest)
            self.grappled = anchors[closestIndex]
        end
    else
        self.joint:destroy()
        self.joint = 0
    end
end

function Player:switchSize()
    sizeChangeSound:play()
    self.tiny = not self.tiny
    if self.tiny then
        deleteWorld()
        size = 100
        createWorld(size)
        love.timer.sleep(0.5)
        self.rect.body:setY(self.rect.body:getY() * 2)
        self.rect.body:setX(self.rect.body:getX() * 2)
    else
        deleteWorld()
        size = 50
        createWorld(size)
        love.timer.sleep(0.5)
        self.rect.body:setY(self.rect.body:getY() / 2)
        self.rect.body:setX(self.rect.body:getX() / 2)
    end
end
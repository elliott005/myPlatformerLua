Enemy = Object:extend()

function Enemy:new(x, y, static)
    self.width = 50
    self.height = 50
    self.rect = createRect(x, y, self.width, self.height, "dynamic", 1)
    self.rect.body:setFixedRotation(true)
    self.rect.fixture:setUserData("enemy")
    -- self.rect.fixture:setFriction(1.0)

    self.image = love.graphics.newImage("images/Animation/enemy_walk_1.png")

    self.speed = 200
    self.rect.body:setX(x)
    self.rect.body:setY(y)

    self.static = static
    self.moving = false

    self.right = false

    self.rotation = 0    
end

function Enemy:update(dt)
    -- self.rect.body:setX(self.rect.body:getX() - self.speed * dt)

    if player.rect.body:getX() < self.rect.body:getX() and self.rect.body:getX() < player.rect.body:getX() + 300 then
        self.moving = true
    end

    if not self.static and self.moving then
        if not self.right then
            self.rect.body:applyForce(-self.speed, 0)
        else
            self.rect.body:applyForce(self.speed, 0)
        end
    end
    self.destroyed = self.rect.fixture:isDestroyed( )

    if self.destroyed then
        self.rotation = self.rotation + 10 * dt
    end

    if love.math.random(0, 1 / dt) == 0 then
        self.right = not self.right
    end
end    

function Enemy:draw()
    if not self.destroyed then
        if not (self.rect.body:getY() > player.rect.body:getY() + love.graphics.getHeight()) then
            if not self.right then
                love.graphics.draw(self.image,
                (self.rect.body:getX() - self.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
                (self.rect.body:getY() - self.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY,
                0, self.width / self.image:getWidth(), self.height / self.image:getHeight())
            else
                love.graphics.draw(self.image,
                ((self.rect.body:getX() - self.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX) + self.width, 
                (self.rect.body:getY() - self.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY,
                0, -(self.width / self.image:getWidth()), self.height / self.image:getHeight())
            end
        -- love.graphics.setColor(255/255, 255/255, 200/255)
        -- love.graphics.polygon("fill", self.feet.body:getWorldPoints(self.feet.shape:getPoints()))
        end
    else
        if not (self.rect.body:getY() > player.rect.body:getY() + love.graphics.getHeight()) then
            love.graphics.draw(self.image,
            (self.rect.body:getX() - self.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
            (self.rect.body:getY() - self.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY,
            self.rotation, self.width / self.image:getWidth(), self.height / self.image:getHeight())
        end
    end
end
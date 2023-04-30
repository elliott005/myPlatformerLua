Heart = Object:extend()

function Heart:new(x, y)
    self.width = 50
    self.height = 50
    self.rect = createRect(x, y, self.width, self.height, "static", 1)
    self.rect.body:setFixedRotation(true)
    self.rect.fixture:setUserData("heart")
    self.rect.body:setX(x)
    self.rect.body:setY(y)

    self.image = love.graphics.newImage("images/Heart.png")
end

function Heart:draw()
    if not self.rect.fixture:isDestroyed() then
        love.graphics.draw(self.image,
            (self.rect.body:getX() - self.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
            (self.rect.body:getY() - self.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY,
            0, self.width / self.image:getWidth(), self.height / self.image:getHeight())
    end
end
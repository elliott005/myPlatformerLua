Coin = Object:extend()

function Coin:new(x, y)
    self.width = 50
    self.height = 50
    self.rect = createRect(x, y, self.width, self.height, "static", 1)
    self.rect.body:setFixedRotation(true)
    self.rect.fixture:setUserData("coin")
    self.rect.body:setX(x)
    self.rect.body:setY(y)
    self.coinFrames = {}
    for i = 1,9 do
        table.insert(self.coinFrames, love.graphics.newImage("images/Animation/goldCoin/goldCoin" .. i .. ".png"))
    end
    self.image = love.graphics.newImage("images/Animation/goldCoin/goldCoin1.png")

    self.coinTime = 1
end

function Coin:update(dt)
    self.coinTime = self.coinTime + 5 * dt
    if self.coinTime >= 10 then
        self.coinTime = 1
    end
end

function Coin:draw()
    if not self.rect.fixture:isDestroyed() then
        love.graphics.draw(self.coinFrames[math.floor(self.coinTime)],
            (self.rect.body:getX() - self.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
            (self.rect.body:getY() - self.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY,
            0, self.width / self.image:getWidth(), self.height / self.image:getHeight())
    end
end
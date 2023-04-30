Object = require "classic" -- import libraries
push = require "push"
lume = require "lume"
require "Player"
require "Enemy"
require "Finish"
require "Heart"
require "Coin"
require "Thorns"

local gameWidth, gameHeight = 1080, 720 --fixed game resolution
windowWidth, windowHeight = love.window.getDesktopDimensions()
windowWidth, windowHeight = windowWidth, windowHeight

push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true, stretched = true, pixelperfect = true})


-- import and play music
bgm = love.audio.newSource("music/bgm2.mp3", "stream")
bgm:setLooping(true)
love.audio.play(bgm)
jumpSound = love.audio.newSource("music/jump_sound.wav", "static")
deathSound = love.audio.newSource("music/Deathsound.mp3", "static")
finishSound = love.audio.newSource("music/chipquest.wav", "static")
painSound = love.audio.newSource("music/deathh.wav", "static")
swooshSound = love.audio.newSource("music/swishes/swishes/swish-1.wav", "static")
enemyDeathSound = love.audio.newSource("music/paind.wav", "static")
coinSound = love.audio.newSource("music/coin1.wav", "static")
saveSound = love.audio.newSource("music/coin2.wav", "static")
sizeChangeSound = love.audio.newSource("music/coin10.wav", "static")
ropeSound = love.audio.newSource("music/rope2.mp3", "static")
-- ropeSound:setVolume(0.4)

font = love.graphics.newFont("DejaVuSans.ttf", 30)

function love.load()
    wind = 0
    windSpeed = 0

    love.physics.setMeter(64)
    world = love.physics.newWorld(0 - windSpeed * 2, 20 * 64, true)
    -- world = love.physics.newWorld(15 * 64, 0, true)
    world:setCallbacks(beginContact, endContact, preSolve)

    groundtext = love.graphics.newImage("images/tileable2-50px.png")
    groundtextwidth  = groundtext:getWidth()
	groundtextheight = groundtext:getHeight()
    groundtext:setWrap( "repeat", "repeat")
        
    groundtext2 = love.graphics.newImage("images/tileable10-50px.png")
    groundtext2width  = groundtext:getWidth()
    groundtext2height = groundtext:getHeight()
    groundtext2:setWrap( "repeat", "repeat")

    backgroundImage = love.graphics.newImage("images/grass/background1.png")
    backgroundImagewidth  = backgroundImage:getWidth()
    backgroundImageheight = backgroundImage:getHeight()
    backgroundImage:setWrap( "repeat", "repeat")

    skyImage = love.graphics.newImage("images/sky7_seamless.jpg")
    skywidth  = skyImage:getWidth()
    skyheight = skyImage:getHeight()
    skyImage:setWrap( "repeat", "repeat")

    treeImage = love.graphics.newImage("images/tree.png")
    treewidth  = treeImage:getWidth()
    treeheight = treeImage:getHeight() - 10

    tree2Image = love.graphics.newImage("images/tree2.png")
    tree2width  = tree2Image:getWidth()
    tree2height = tree2Image:getHeight() - 10

    cherrytreeImage = love.graphics.newImage("images/cherry_tree.png")
    cherrytreewidth  = cherrytreeImage:getWidth()
    cherrytreeheight = cherrytreeImage:getHeight() - 10

    vineImage = love.graphics.newImage("images/Vines.png")
    vinewidth  = vineImage:getWidth()
    vineheight = vineImage:getHeight() - 10

    grapplePointImage = love.graphics.newImage("images/grapplePoint-50px.png")

    numJoysticks = love.joystick.getJoystickCount()
    joysticks = love.joystick.getJoysticks()

    player = Player()
    rects = {}
    rectsColor = {}
    enemies = {}
    finishes = {}
    hearts = {}
    coins = {}
    enemyCoins = {}
    thorns = {}
    anchors = {}
    anchorsNumbers = {}
    tilemaps = {}  -- 0:nothing 1:block, 2:enemy, 3:static enemy, 4:finish, 5:heart, 6:coin, 7:spike
    tilemaps[1] = {
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 1, 1, 0, 0, 0, 2, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 3, 3, 3, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    }

    tilemaps[2] = {
        {7, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    }

    tilemaps[3] = {
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    }


    savedata = "savedataElliott.txt"

    if love.filesystem.getInfo(savedata) then
        file = love.filesystem.read(savedata)
        data = lume.deserialize(file)
        level = data
    else
        level = 1
    end

    startLevel = 1

    maxLevel = #tilemaps

    finished = 0

    size = 50

    createWorld(size)

    -- rects[loops], ground[loops] = createRect(200, 50, 50, 100, "static", 1, true)
    -- rects[2], ground[2] = createRect(200, love.graphics.getHeight() - 100, 50, 100, "static", 1, true)
    -- rects[3], ground[3] = createRect(400, love.graphics.getHeight() - 100, 50, 100, "static", 1, true)
    -- rects[4], ground[4] = createRect(600, love.graphics.getHeight() - 200, 50, 100, "static", 1, true)

end

function love.update(dt)
    -- print(player.grounded)

    world:update(dt)
    player:update(dt)

    for i,v in ipairs(rects) do
        if v.fixture:testPoint(player.rect.body:getX()- player.width / 2 + 10, player.rect.body:getY() + player.height / 2 + 2)
        or v.fixture:testPoint(player.rect.body:getX()+ player.width / 2 - 10, player.rect.body:getY() + player.height / 2 + 2) then
            player.grounded = true
        end
    end

    for i,v in ipairs(enemies) do
        if not v.rect.fixture:isDestroyed() then
            if v.rect.fixture:testPoint(player.rect.body:getX()- player.width / 2 + 10, player.rect.body:getY() + player.height / 2 + 2)
            or v.rect.fixture:testPoint(player.rect.body:getX()+ player.width / 2 - 10, player.rect.body:getY() + player.height / 2 + 2) then
                player.grounded = true
            end
        end
    end

    for i,v in ipairs(thorns) do
        if v.rect.fixture:testPoint(player.rect.body:getX()- player.width / 2 + 10, player.rect.body:getY() + player.height / 2 + 2)
        or v.rect.fixture:testPoint(player.rect.body:getX()+ player.width / 2 - 10, player.rect.body:getY() + player.height / 2 + 2) then
            player.grounded = true
        end
    end

    numJoysticks = love.joystick.getJoystickCount()
    joysticks = love.joystick.getJoysticks()

    for i,v in ipairs(enemies) do
        v:update(dt)
    end

    for i,v in ipairs(coins) do
        v:update(dt)
    end

    wind = wind - windSpeed * dt

    if (wind < -skywidth) or (wind > skywidth) then
        wind = 0
    end

    for i=#enemyCoins, 1, -1 do
        table.insert(coins, Coin(enemyCoins[i][1], enemyCoins[i][2]))
        table.remove(enemyCoins, i)
    end

    if finished == 10 then
        finishSound:play()
        love.timer.sleep(2)
        player.rect.body:setX(player.limitX)
        player.rect.body:setY(player.limitY)
        if not (level == maxLevel) then
            level = level + 1
            player.health = player.maxHealth
        else
            level = startLevel
            player.health = player.maxHealth
        end
        finished = 0

        deleteWorld()

        size = 50

        createWorld(size)

        player.tiny = false

        saveGame()

        -- love.load()
    end

end

function love.draw()
    push:start()

    -- love.graphics.draw(backgroundImage, 0, 0)
    backgroundquad = love.graphics.newQuad(0,0, 10000,2000, backgroundImagewidth,backgroundImageheight)
    love.graphics.draw(backgroundImage, backgroundquad,
        -500 - (player.rect.body:getX() - player.width / 2) + player.limitX, 
        #tilemaps[level] * size - (player.rect.body:getY() - player.height / 2) + player.limitY)

    skyquad = love.graphics.newQuad(0,0, 10000,#tilemaps[level] * size + 1000, skywidth,skyheight)
    love.graphics.draw(skyImage, skyquad,
        -1000 + wind - (player.rect.body:getX() - player.width / 2) + player.limitX, 
        -1000 - (player.rect.body:getY() - player.height / 2) + player.limitY)

    for i,v in ipairs(anchors) do
        if (v.body:getY() / size - 3) > 0 then
            if (tilemaps[level][v.body:getY() / size - 1][v.body:getX() / size] == 0) and (tilemaps[level][v.body:getY() / size - 2][v.body:getX() / size] == 0) then
                if (anchorsNumbers[i][1] == 1) then
                    if (anchorsNumbers[i][2] > 1) then
                        love.graphics.draw(treeImage,
                            (v.body:getX() - v.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
                            (v.body:getY() - v.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY - treeheight)
                    elseif (tilemaps[level][v.body:getY() / size - 3][v.body:getX() / size] == 0) then
                        love.graphics.draw(treeImage,
                            (v.body:getX() - v.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX - 25, 
                            (v.body:getY() - v.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY - treeheight * 1.5,
                            0, 1.5, 1.5)
                    end
                elseif (anchorsNumbers[i][1] == 2) then
                    love.graphics.draw(cherrytreeImage,
                        (v.body:getX() - v.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
                        (v.body:getY() - v.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY - cherrytreeheight)
                elseif (anchorsNumbers[i][1] == 3) then
                    love.graphics.draw(tree2Image,
                        (v.body:getX() - v.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX - 20, 
                        (v.body:getY() - v.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY - tree2height + 10)
                end
            end
        end

        if (v.body:getY() / size + 1) < #tilemaps[level] and (anchorsNumbers[i][1] < 6) then
            if (tilemaps[level][v.body:getY() / size + 1][v.body:getX() / size] == 0) then
                love.graphics.draw(vineImage,
                    (v.body:getX() - vinewidth / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
                    (v.body:getY() + v.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY)
            end
        end
    end

    for i,v in ipairs(rects) do
        if rectsColor[i] == 1 then 
            groundtext2quad = love.graphics.newQuad(0,0, v.width,v.height, groundtext2width,groundtext2height)
            love.graphics.draw(groundtext2, groundtext2quad,
                (v.body:getX() - v.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
                (v.body:getY() - v.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY)
        else 
            groundtextquad = love.graphics.newQuad(0,0, v.width,v.height, groundtextwidth,groundtextheight)
            love.graphics.draw(groundtext, groundtextquad,
                (v.body:getX() - v.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
                (v.body:getY() - v.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY)
        end
    end

    for i,v in ipairs(enemies) do
        v:draw()
    end

    for i,v in ipairs(finishes) do
        v:draw()
    end

    for i,v in ipairs(hearts) do
        v:draw()
    end

    for i,v in ipairs(coins) do
        v:draw()
    end

    for i,v in ipairs(thorns) do
        v:draw()
    end

    -- for i,v in ipairs(anchors) do
    --     love.graphics.draw(grapplePointImage,
    --         (v.body:getX() - v.width / 2) - (player.rect.body:getX() - player.width / 2) + player.limitX, 
    --         (v.body:getY() - v.height / 2) - (player.rect.body:getY() - player.height / 2) + player.limitY)
    -- end

    player:draw()

    if finished > 0 then
        love.graphics.setFont(font)
        love.graphics.print("Congratulations!", font, 100, 100)
        if level == maxLevel then
            love.graphics.print("You finished the game!", font, 100, 200)
        end
        finished = finished + 1
    end

    -- love.graphics.setColor(100/255, 100/255, 100/255)
    -- for i,v in ipairs(ground) do
    --     love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
    -- end
    -- love.graphics.setColor(255, 255, 255)

    push:finish()

    -- love.graphics.setBackgroundColor((30 / 255), (178 / 255), (206 / 255))
end

function love.keypressed(key)
    if key == "q" then
        love.load()
    end
    if key == "escape" then
        saveGame()
        love.event.quit()
    end
    if key == "s" then
        saveGame()
    end
    if key == "r" then
        love.filesystem.remove(savedata)
        love.event.quit("restart")
    end

    player:keypressed(key)
end

function createRect(x, y, w, h, t, d, mask) -- x:Xpos, y:Ypos, w:Width, h:Height, t:Type("static", "dynamic"), d:Density, g:Ground mask:setMask
    local mask = mask or 16
    local rect = {
    body = love.physics.newBody( world, x, y, t ),
    shape = love.physics.newRectangleShape(w, h),
    }
    rect.width = w
    rect.height = h 
    rect.fixture = love.physics.newFixture( rect.body, rect.shape, d )
    rect.fixture:setMask(mask)
    return rect
end

function beginContact(a, b, coll)
    if (a:getUserData() == "player" or b:getUserData() == "player") and (a:getUserData() == "enemy" or b:getUserData() == "enemy") then
        player:hurt()
        -- love.load()
    end
    if (a:getUserData() == "player" or b:getUserData() == "player") and (a:getUserData() == "thorn" or b:getUserData() == "thorn") then
        player:hurt()
    end
    if (a:getUserData() == "enemy" or b:getUserData() == "enemy") and (a:getUserData() == "sword" or b:getUserData() == "sword") then
        if a:getUserData() == "enemy" then
            a:destroy()
            table.insert(enemyCoins, {a:getBody():getX(), a:getBody():getY()})
        else
            b:destroy()
            table.insert(enemyCoins, {b:getBody():getX(), b:getBody():getY()})
        end
        -- player.score = player.score + 1
        enemyDeathSound:play()
    end
    if (a:getUserData() == "player" or b:getUserData() == "player") and (a:getUserData() == "finish" or b:getUserData() == "finish") then
        finish()
    end
    if (a:getUserData() == "player" or b:getUserData() == "player") and (a:getUserData() == "heart" or b:getUserData() == "heart") then
        if player.health < player.maxHealth then
            player.health = player.health + 1
            if a:getUserData() == "health" then
                a:destroy()
            else
                b:destroy()
            end
        end
        coll:setEnabled(false)
    end
end

function endContact(a, b, coll)
    if (a:getUserData() == "ground" or b:getUserData() == "ground") and (a:getUserData() == "feet" or b:getUserData() == "feet") then
        player.grounded = false
        -- print(player.grounded)
    end
end

function preSolve(a, b, coll)
	if (a:getUserData() == "player" or b:getUserData() == "player") and (a:getUserData() == "coin" or b:getUserData() == "coin") then
        if a:getUserData() == "coin" then
            a:destroy()
        else
            b:destroy()
        end
        player.score = player.score + 1
        coinSound:play()
        coll:setEnabled(false)
    end
end

function finish()
    if finished == 0 then
        finished = 1
    end
end

function createWorld(size)
    local size = size
    local loops = 1
    local consecutiveX = 1
    local x = 1
    for y,v in ipairs(tilemaps[level]) do
        x = 1
        while x <= #v do
            if tilemaps[level][y][x] == 1 then
                while v[x+consecutiveX] == 1 do
                    consecutiveX =  consecutiveX + 1
                    table.insert(anchors, createRect((x + consecutiveX - 1) * size, y * size, size, size, "static", 1, 3))
                end
                if consecutiveX > 1 then
                    rects[loops] = createRect((x + consecutiveX / 2) * size - size / 2, y * size, size * consecutiveX, size, "static", 1)
                else
                    rects[loops] = createRect(x * size, y * size, size, size, "static", 1)
                end
                table.insert(anchors, createRect(x * size, y * size, size, size, "static", 1, 3))
                loops = loops + 1
                x = x + consecutiveX - 1
                consecutiveX = 1
            elseif tilemaps[level][y][x] == 2 then
                table.insert(enemies, Enemy(x * size, y * size, false))
            elseif tilemaps[level][y][x] == 3 then
                table.insert(enemies, Enemy(x * size, y * size, true))
            elseif tilemaps[level][y][x] == 4 then
                table.insert(finishes, Finish(x * size, y * size, true))
            elseif tilemaps[level][y][x] == 5 then
                table.insert(hearts, Heart(x * size, y * size, true))
            elseif tilemaps[level][y][x] == 6 then
                table.insert(coins, Coin(x * size, y * size, true))
            elseif tilemaps[level][y][x] == 7 then
                table.insert(thorns, Thorn(x * size, y * size, true))
            end
            x = x +1
        end
    end

    for i,v in ipairs(rects) do
        rectsColor[i] = love.math.random(3)
    end

    for i,v in ipairs(anchors) do
        anchorsNumbers[i] = {love.math.random(6), love.math.random(4)}
    end
end

function deleteWorld()
    loops = 1
    for i=#rects,1, -1 do
        rects[i].fixture:destroy()
        table.remove(rects, i)
    end
    for i=#enemies,1, -1 do
        if not enemies[i].rect.fixture:isDestroyed() then
            enemies[i].rect.fixture:destroy()
        end
        table.remove(enemies, i)
    end
    for i=#finishes,1, -1 do
        finishes[i].rect.fixture:destroy()
        table.remove(finishes, i)
    end
    for i=#thorns,1, -1 do
        thorns[i].rect.fixture:destroy()
        table.remove(thorns, i)
    end
    for i=#hearts,1, -1 do
        if not hearts[i].rect.fixture:isDestroyed() then
            hearts[i].rect.fixture:destroy()
            table.remove(hearts, i)
        end
    end
    for i=#coins,1, -1 do
        if not coins[i].rect.fixture:isDestroyed() then
            coins[i].rect.fixture:destroy()
            table.remove(coins, i)
        end
    end
    for i=#anchors,1, -1 do
        anchors[i].fixture:destroy()
        table.remove(anchors, i)
    end
    if not (player.joint == 0) then
        player.joint:destroy()
        player.joint = 0
    end
end

function saveGame()
    local data = level
    serialized = lume.serialize(data)
    love.filesystem.write(savedata, serialized)
    saveSound:play()
end

function getDistance(x1, y1, x2, y2)
    local horizontal_distance = x1 - x2
    local vertical_distance = y1 - y2
    --Both of these work
    local a = horizontal_distance * horizontal_distance
    local b = vertical_distance ^2

    local c = a + b
    local distance = math.sqrt(c)
    return distance
end
ball1 = {x = 153, y = 595, img = nil, body = nil, shape = nil, fixture = nil}
ball2 = {x = 178, y = 520, img = nil, body = nil, shape = nil, fixture = nil}
ball3 = {x = 191, y = 470, img = nil, body = nil, shape = nil, fixture = nil}
puck = {x = 195, y = 100, img = nil, body = nil, shape = nil, fixture = nil}

wallL = {body = nil, shape = nil, fixture = nil}
wallR = {body = nil, shape = nil, fixture = nil}
ceil = {body = nil, shape = nil, fixture = nil}
firstTurn = true

bounce = 1
minPuckSpeed = 100
minBallSpeed = 250

text       = ""
persisting = 0

score = 0
highScore = 0
lvlNum = 1
lvlIncrement = 50
lvlUp = 50

isAlive = true
isTurn = false

saveMade = love.filesystem.getInfo('high.txt')

if saveMade then
    scoreStr = love.filesystem.read('high.txt')
    highScore = tonumber(scoreStr)
else
    love.filesystem.newFile('high.txt')
    highScore = 0
    scoreStr = tostring(highScore)
    love.filesystem.write('high.txt', scoreStr)
end

scoreStr = love.filesystem.read('high.txt')
highScore = tonumber(scoreStr)

function love.load()
    love.physics.setMeter(30)
    world = love.physics.newWorld(0, 0, false)
        world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    backgroundImg = love.graphics.newImage('back.png')

    ball1.img = love.graphics.newImage('ball1.png')
    ball1.body = love.physics.newBody(world, ball1.x + 50, ball1.y + 50, 'kinematic')
    ball1.shape = love.physics.newCircleShape(51)
    ball1.fixture = love.physics.newFixture(ball1.body, ball1.shape, 1)
    ball1.fixture:setRestitution(bounce)
    ball1.fixture:setUserData("Ball 1")

    ball2.img = love.graphics.newImage('ball2.png')
    ball2.body = love.physics.newBody(world, ball2.x + 25, ball2.y + 25, 'kinematic')
    ball2.shape = love.physics.newCircleShape(26)
    ball2.fixture = love.physics.newFixture(ball2.body, ball2.shape, 1)
    ball2.fixture:setRestitution(bounce)
    ball2.fixture:setUserData("Ball 2")

    ball3.img = love.graphics.newImage('ball3.png')
    ball3.body = love.physics.newBody(world, ball3.x + 13, ball3.y + 13, 'kinematic')
    ball3.shape = love.physics.newCircleShape(14)
    ball3.fixture = love.physics.newFixture(ball3.body, ball3.shape, 1)
    ball3.fixture:setRestitution(bounce)
    ball3.fixture:setUserData("Ball 3")

    puck.img = love.graphics.newImage('puck.png')
    puck.body = love.physics.newBody(world, puck.x + 7.5, puck.y + 7.5, 'dynamic')
    puck.shape = love.physics.newCircleShape(7.5)
    puck.fixture = love.physics.newFixture(puck.body, puck.shape, 1)
    puck.fixture:setRestitution(bounce)
    puck.fixture:setUserData("Puck")
    puckB = love.graphics.newImage('bpuck.png')
    puckS = love.graphics.newImage('spuck.png')
    puckG = love.graphics.newImage('gpuck.png')

    wallL.body = love.physics.newBody(world, 10, 360, 'static')
    wallL.shape = love.physics.newRectangleShape(20, 720)
    wallL.fixture = love.physics.newFixture(wallL.body, wallL.shape, 1)
    wallL.fixture:setRestitution(bounce)
    wallL.fixture:setUserData("Wall Left")

    wallR.body = love.physics.newBody(world, 395, 360, 'static')
    wallR.shape = love.physics.newRectangleShape(20, 720)
    wallR.fixture = love.physics.newFixture(wallR.body, wallR.shape, 1)
    wallR.fixture:setRestitution(bounce)
    wallR.fixture:setUserData("Wall Right")

    ceil.body = love.physics.newBody(world, 0, 0, 'static')
    ceil.shape = love.physics.newChainShape(false, 20, 20, 56.5, 50, 93, 20, 129.5, 50, 166, 20, 202.5, 50, 239, 20, 275.6, 50, 312, 20, 348.5, 50, 385, 20)
    ceil.fixture = love.physics.newFixture(ceil.body, ceil.shape, 1)
    ceil.fixture:setRestitution(bounce)
    ceil.fixture:setUserData("Ceiling")

    clunk1 = love.audio.newSource("clunk1.mp3", "static")
    clunk2 = love.audio.newSource("clunk2.mp3", "static")
    clunk3 = love.audio.newSource("clunk3.mp3", "static")
    levelUp = love.audio.newSource("level.mp3", "static")
    theme = love.audio.newSource("theme.mp3", "stream")
    theme:setVolume(.25)
	theme:setLooping(true)
    love.audio.play(theme)

    clank = love.graphics.newImage("clank.png")
end

function love.update(dt)

    -- easy quit
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end

    world:update(dt)

    -- ball1 control
    if love.keyboard.isDown('z') then
        if ball1.x > 20 then -- map bounds
            ball1.x = ball1.x - (minBallSpeed*dt)
        end
    elseif love.keyboard.isDown('x') then
        if ball1.x < (love.graphics.getWidth() + ball1.img:getWidth() - 20) then
            ball1.x = ball1.x + (minBallSpeed*dt)
        end
    end

    ball1.body:setX(ball1.x + 50)

    -- ball2 control
    if love.keyboard.isDown('a') then
        if ball2.x > 20 then -- map bounds
            ball2.x = ball2.x - (minBallSpeed*dt)
        end
    elseif love.keyboard.isDown('s') then
        if ball2.x < (love.graphics.getWidth() + ball2.img:getWidth() - 20) then
            ball2.x = ball2.x + (minBallSpeed*dt)
        end
    end

    ball2.body:setX(ball2.x + 25)

    -- ball3 control
    if love.keyboard.isDown('q') then
        if ball3.x > 20 then -- map bounds
            ball3.x = ball3.x - (minBallSpeed*dt)
        end
    elseif love.keyboard.isDown('w') then
        if ball3.x < (love.graphics.getWidth() - ball3.img:getWidth() - 20) then
            ball3.x = ball3.x + (minBallSpeed*dt)
        end
    end

    ball3.body:setX(ball3.x + 13)

    -- initial boost if first turn
    if firstTurn and love.keyboard.isDown('space') then
        puck.body:applyForce(0, 800)
        firstTurn = false
    end

    -- Before turn starts
    if love.keyboard.isDown('space') then
        isTurn = true
    end

    -- velocity of puck
    puckVx, puckVy = puck.body:getLinearVelocity()

    if isTurn then
        -- keeps puck moving (y)
        if puckVy < 0 and puckVy > -minPuckSpeed*lvlNum then
            puck.body:applyForce(0, -200)
        elseif puckVy > 0 and puckVy < minPuckSpeed*lvlNum then
            puck.body:applyForce(0, 200)
        end

        -- keeps puck moving (x)
        if puckVx < 0 and puckVx > -minPuckSpeed*(1 + .25*lvlNum) then
            puck.body:applyForce(-200, 0)
        elseif puckVx > 0 and puckVx < minPuckSpeed*(1 + .25*lvlNum) then
            puck.body:applyForce(200, 0)
        end
    end

    -- figures out position
    puck.x = puck.body:getX() - 7.5
    puck.y = puck.body:getY() - 7.5

    -- dead if below
    if puck.y > 720 then
        isAlive = false
    end

    -- levels up
    if isAlive and score >= lvlUp then
        lvlUp = lvlUp + lvlIncrement
        lvlNum = lvlNum + 1
        levelUp:play()

        speedDt = 1
        if speedDt <= 50*lvlNum then
            puck.body:setLinearVelocity(puckVx + 1, puckVy + 1)
        end
    end

    -- dead but restart condition
    if not isAlive and love.keyboard.isDown('r') then
        puck.body:setX(193)
        puck.body:setY(100)
        puck.body:setLinearVelocity(0,0)

        ball1.x = 153
        ball2.x = 178
        ball3.x = 193

        firstTurn = true
        lvlNum = 1
        lvlUp = 50
        score = 0
        isAlive = true
        isTurn = false
    end

    if not isAlive then
        scoreStr = love.filesystem.read('high.txt')
        prevHigh = tonumber(scoreStr)
        if prevHigh < highScore then
            scoreStr = tostring(highScore)
            love.filesystem.write('high.txt', scoreStr)
        end
    end
end

function love.draw()

    -- Draw the background
    love.graphics.draw(backgroundImg, 0, 0)

    --Draw the balls
    love.graphics.draw(ball1.img, ball1.x, ball1.y)
    love.graphics.draw(ball2.img, ball2.x, ball2.y)
    love.graphics.draw(ball3.img, ball3.x, ball3.y)

    --Draw the puck
    if highScore >= 250 and highScore < 500 then
        puck.img = puckB
    elseif highScore >= 500 and highScore < 750 then
        puck.img = puckS
    elseif highScore >= 750 then
        puck.img = puckG
    end

    love.graphics.draw(puck.img, puck.x, puck.y)

    -- love.graphics.print(text, 10, 10)
    love.graphics.print('Score = ' .. score, 255, 73)
    love.graphics.print('High = ' .. highScore, 255, 103)
    love.graphics.print('Lvl ' .. lvlNum, 75, 73)

    -- start message

    if firstTurn then
        love.graphics.draw(clank, 45, 100)
        love.graphics.print("Press 'SPACE' to start", love.graphics:getWidth()/2 - 60, love.graphics:getHeight()/2 - 10)
        love.graphics.print("a game by scottmer", 250, 700)
    end
    -- dead message
    if not isAlive then
        love.graphics.print("a game by scottmer", 250, 700)
        love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2 - 50, love.graphics:getHeight()/2 - 10)
    end
end

-- function to handle collisions
function beginContact(a, b, coll)
    x,y = coll:getNormal()
    text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y

    if a:getUserData() == 'Ball 1' then
        score = score + 1
        clunk3:play()
    elseif a:getUserData() == 'Ball 2' then
        score = score + 5
        clunk2:play()
    elseif a:getUserData() == 'Ball 3' then
        score = score + 10
        clunk1:play()
    else
        clunk2:play()
    end

    if score > highScore then
        highScore = score
    end
end

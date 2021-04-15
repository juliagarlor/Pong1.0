--[[main function of pong. We pretend to create
 a screen with two paddles, a ball, score up to 10 and a comment bar]]

push=require 'push'
Class=require 'class'
require 'Paddle'
require 'Ball'

--let set the window size of the game
WINDOW_WIDTH=640
WINDOW_HEIGHT=600
--we take the real resolution of the window above and turn it into a virtual resolution
VIRTUAL_WIDTH=432
VIRTUAL_HEIGHT=405
--these last numbers are the resolution the screen will think it has
PADDLE_SPEED=200

--when the game opens:
function love.load()
love.graphics.setDefaultFilter('nearest','nearest')
love.window.setTitle('Pong')
math.randomseed(os.time())
--we set a retro front for the text
smallFont= love.graphics.newFont('font.ttf',8)
largeFont=love.graphics.newFont('font.ttf',16)
scoreFont=love.graphics.newFont('font.ttf',72)
love.graphics.setFont(smallFont)

sounds={
['paddle_Ball']=love.audio.newSource('sounds/Paddle-Ball.wav','static'),
['wall_Ball']=love.audio.newSource('sounds/Wall-Ball.wav','static'),
['point']=love.audio.newSource('sounds/Point.wav','static'),
['win']=love.audio.newSource('sounds/Win.wav','static')
}

push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
fullscreen=false,
resizable=false,
canvas=false,
vsync=true
})
--ininitializing the scores
player1Score=0
player2Score=0
--servingPlayer=1
--initial positions of paddles, we only take the variable y because they only move in that direction
player1=Paddle(10,95,5,30)
player2=Paddle(VIRTUAL_WIDTH-15, VIRTUAL_HEIGHT-40,5,30)
ball=Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 + 52, 4,4)

gameState='start'
end

function love.update(dt)

--updating the serve state
if gameState == 'serve' then
ball.dy = math.random(-50, 50)
	if servingPlayer == 1 then
	ball.dx = math.random(140, 200)
	else
	ball.dx = -math.random(140, 200)
	end
--updating the ball state in play
elseif gameState== 'play' then
	if ball:collides(player1) then
		ball.dx = -ball.dx * 1.05
		ball.x = player1.x + 5
			if ball.dy < 0 then
			ball.dy=-math.random(10,150)
			else
			ball.dy = math.random(10,150)
			end
		sounds.paddle_Ball:play()
	end
	if ball:collides(player2) then
		ball.dx = -ball.dx * 1.05
		ball.x = player2.x - 4
			if ball.dy < 0 then
			ball.dy=-math.random(10,150)
			else
			ball.dy = math.random(10,150)
			end
		sounds.paddle_Ball:play()
	end
	if ball.y <=90 then
	ball.y = 90
	ball.dy = -ball.dy
	sounds.wall_Ball:play()
	end
	if ball.y >= VIRTUAL_HEIGHT - 9 then
	ball.y = VIRTUAL_HEIGHT - 13
	ball.dy= -ball.dy
	sounds.wall_Ball:play()
	end
	
	if ball.x < 9 then
	servingPlayer = 1
	player2Score = player2Score + 1
		if player2Score == 10 then
		winningPlayer = 2
		gameState = 'done'
		sounds.win:play()
		else
		gameState = 'serve'
		ball:reset()
		sounds.point:play()
		end 
	end
	if ball.x > (VIRTUAL_WIDTH-9) then
	servingPlayer = 2
	player1Score = player1Score + 1
		if player1Score == 10 then
		winningPlayer = 1
		gameState = 'done'
		sounds.win:play()
		else
		gameState = 'serve'
		ball:reset()
		sounds.point:play()
		end
	end
end

--movement of the right paddle
	if love.keyboard.isDown("up") then
	player2.dy=-PADDLE_SPEED
	elseif love.keyboard.isDown("down") then
	player2.dy=PADDLE_SPEED
	else
	player2.dy=0
	end

--movement of the left paddle (self-driven one)
--sorry, I had to make it to start moving once the ball has passed to the left half of the screen because otherwise it was imposible to win
if gameState == 'play' then
ball:update(dt)
if ball.dx<0 and ball.x < VIRTUAL_WIDTH/2 then
	if ball.y > player1.y then
	player1.dy=PADDLE_SPEED
	elseif ball.y < player1.y then
	player1.dy=-PADDLE_SPEED
	end
elseif ball.dx>0 then
player1.dy=0
end
end

player1:update(dt)
player2:update(dt)
end

--lets define the key behaviour
function love.keypressed(key)
if key == 'escape' then
love.event.quit()

elseif key == 'enter' or key == 'return' then
	if gameState == 'start' then
	gameState='serve'
	elseif gameState == 'serve' then
	gameState='play'
	elseif gameState == 'done' then
	gameState = 'serve'
	ball:reset()
	player1Score=0
	player2Score=0
		if winningPlayer == 1 then
		servingPlayer=2
		else
		servingPlayer=1
		end
	end
end
end

--lets draw the scene:
function love.draw()
--begin rendering at virtual resolution
push:start()
love.graphics.clear(40/255,45/255,52/255,255/255)
--we've apply a gray colour to the background whose RGB code is 40,45,52. 
--255 is the transparence degree, so no transparence
love.graphics.rectangle('line',5,90,VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT-95)
displayScore()
drawLine()
love.graphics.setFont(scoreFont)
love.graphics.printf("PONG",0,0,VIRTUAL_WIDTH,'center')
love.graphics.setFont(smallFont)
if gameState == 'start' then
love.graphics.printf("Welcome to Pong!",0,60,VIRTUAL_WIDTH,'center')
love.graphics.printf("Press ENTER to start",0,70,VIRTUAL_WIDTH,'center')
elseif gameState == 'serve' then
love.graphics.printf("Player " .. tostring(servingPlayer) .. " serves",0,60,VIRTUAL_WIDTH,'center')
love.graphics.printf("Press ENTER to serve",0,70,VIRTUAL_WIDTH,'center')
elseif gameState == 'play' then
elseif gameState == 'done' then
love.graphics.setFont(largeFont)
love.graphics.printf('Player ' .. tostring(winningPlayer).. ' wins!',0,60,VIRTUAL_WIDTH,'center')
love.graphics.setFont(smallFont)
love.graphics.printf('Press ENTER to start',0,80, VIRTUAL_WIDTH,'center')
end

player1:render()
player2:render()
ball:render()

push:finish()
end
--we write the text 'bienvenidos a pong'
--everything fine till pong10

function displayScore()
love.graphics.setFont(scoreFont)
love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/3, 100)
love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/3 +110, 100)
end

function drawLine()
  love.graphics.setPointSize(2)

  local x, y = 0, VIRTUAL_HEIGHT-95
  local len = math.sqrt(x^2 + y^2)
  local stepx, stepy = 0, 4*y / len
  x1 = VIRTUAL_WIDTH/2
  y1 = 90

  for i = 1, len/4 do
    love.graphics.points(x1, y1)
    x1 = x1 + stepx
    y1 = y1 + stepy
  end
end

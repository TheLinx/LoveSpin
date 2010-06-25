require("ualove.init")
require("padding")

-- INITIAL FUNCTIONS

hook.add("initial", function ()
	love.graphics.print("Loading...", 500, 350)
end, "bootchange")

hook.add("load", function()
	love.graphics.setFont(50)
	game.images = {
		background = love.graphics.newImage("background.png"),
		spinner = love.graphics.newImage("spinner.png"),
		gauge = love.graphics.newImage("metre.png")
	}
	game.music = {
		bgm = love.audio.newSource("leekspin.ogg", "stream")
	}
	game.leekangle = 0
	game.oldangle = 0
	game.laps = 0
	game.lap = {false,false}
	game.lpm = 0
	game.state = "waiting"
end, "init")

-- DRAW FUNCTIONS

function drawGameField()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(game.images.background, 0, 30)
	love.graphics.draw(game.images.spinner, 512, 390, game.leekangle, 1, 1, 333, 333)
	local a = math.min(1, 1 - game.lpm / 400) * 692
	love.graphics.setScissor(0, 30 + a, 1024, 692 - a)
	love.graphics.draw(game.images.gauge, 0, 30)
	love.graphics.setScissor()
end

hook.add("draw", drawGameField, "a-game-w", "waiting")
hook.add("draw", drawGameField, "a-game-p", "playing")
hook.add("draw", drawGameField, "a-game-s", "scores")

hook.add("draw", function()
	love.graphics.setColor(255, 102, 51)
	love.graphics.rectangle("fill", 412, 130, 200, 100)
	love.graphics.printf("SPIN THE LEEK AS FAST AS YOU CAN", 0, 400, 1024, "center")
	love.graphics.setColor(255, 255, 255)
	love.graphics.printf("PLAY", 0, 195, 1024, "center")
end, "dinst", "waiting")

hook.add("draw", function()
	love.graphics.setColor(70, 101, 153)
	love.graphics.printf("YOU CAN STOP SPINNING NOW", 0, 350, 1024, "center")
	love.graphics.printf("YOUR SCORE: "..math.floor(game.lpm).." spins per minute", 0, 450, 1024, "center")
	love.graphics.printf("PRESS Q TO EXIT", 0, 550, 1024, "center")
end, "dscores", "scores")

hook.add("draw", function()
	love.graphics.setColor(255, 255, 255)
end, "z-clearcolour")

-- UPDATE FUNCTIONS

hook.add("update", function()
	if game.music.bgm:isStopped() then
		game.stop()
	else
		local ang = math.atan2(love.mouse.getY()-384, love.mouse.getX()-512)
		local fang = math.floor(ang/2)
		if fang == 0 and game.lap[1] and game.lap[2] then
			game.newLap()
		end
		if fang == 1 and not game.lap[1] then
			game.lap[1] = true
		end
		if fang == -1 and not game.lap[2] then
			game.lap[2] = true
		end
		game.leekangle = ang + (3.14 / 2)
		game.lpm = game.laps * (60 / game.getTime())
	end
end, "gameupdate", "playing")

hook.add("keypressed", function(key)
	if key == "q" or key == "escape" then
		game.quit = true
	end
end, "qcheck")

hook.add("mousepressed", function()
	local x,y = love.mouse.getPosition()
	if (x > 412 and x < 612) and
	   (y > 130 and y < 230) then
		game.start()
	end
end, "buttoncheck", "waiting")

-- GAME FUNCTIONS

function game.start()
	game.state = "playing"
	love.mouse.setGrab(true)
	love.audio.play(game.music.bgm)
	game.starttime = love.timer.getTime()
end

function game.stop()
	game.state = "scores"
	love.mouse.setGrab(false)
end

function game.newLap()
	game.lap = {false,false}
	game.laps = game.laps + 1
end

function game.getTime()
	return love.timer.getTime() - game.starttime
end

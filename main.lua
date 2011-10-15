-- initialisation
function love.load()
	love.graphics.setFont(50)
	images = {
		background = love.graphics.newImage("background.png"),
		spinner = love.graphics.newImage("spinner.png"),
		gauge = love.graphics.newImage("gauge.png")
	}
	bgm = love.audio.newSource("leekspin.ogg", "stream")
	leekangle = 0
	oldangle = 0
	laps = 0
	lap = {false, false}
	lpm = 0
	state = "menu"
end

-- output pretty pictures
function drawfield()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(images.background, 0, 30)
	love.graphics.draw(images.spinner, 512, 390, leekangle, 1, 1, 333, 333)
	local a = math.min(1, 1 - lpm / 400) * 692
	love.graphics.setScissor(0, 30 + a, 1024, 692 - a)
	love.graphics.draw(images.gauge, 0, 30)
	love.graphics.setScissor()
end

function love.draw()
	drawfield()
	if state == "menu" then
		love.graphics.setColor(255, 102, 51)
		love.graphics.rectangle("fill", 412, 130, 200, 100)
		love.graphics.printf("SPIN THE LEEK AS FAST AS YOU CAN", 0, 350, 1024, "center")
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf("PLAY", 0, 145, 1024, "center")
	elseif state == "end" then
		love.graphics.setColor(70, 101, 153)
		love.graphics.printf("YOU CAN STOP SPINNING NOW", 0, 300, 1024, "center")
		love.graphics.printf("YOUR SCORE: " .. math.floor(lpm) .. " spins per minute", 0, 400, 1024, "center")
		love.graphics.printf("PRESS Q TO EXIT", 0, 550, 1024, "center")
	end
end

-- logic
function start()
	state = "playing"
	love.mouse.setGrab(true)
	love.audio.play(bgm)
	starttime = love.timer.getTime()
end

function stop()
	state = "end"
	love.mouse.setGrab("false")
end

function newlap()
	lap = {false, false}
	laps = laps + 1
end

function gametime()
	return love.timer.getTime() - starttime
end

function love.update(dt)
	if state ~= "playing" then return end
	if bgm:isStopped() then
		stop()
	else
		local ang = math.atan2(love.mouse.getY() - 384, love.mouse.getX() - 512)
		local fang = math.floor(ang / 2)
		if fang == 0 and lap[1] and lap[2] then
			newlap()
		end
		if fang == 1 and not lap[1] then
			lap[1] = true
		end
		if fang == -1 and not lap[2] then
			lap[2] = true
		end
		leekangle = ang + (math.pi / 2)
		lpm = laps * (60 / gametime())
	end
end

function love.keypressed(key)
	if key == "q" or key == "escape" then
		love.event.push("q")
	end
end

function love.mousepressed(x, y)
	if state == "menu" and x > 412 and x < 612 and y > 130 and y < 230 then
		start()
	end
end
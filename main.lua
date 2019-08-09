Gamestate = require "libs.hump.gamestate"
Comandos = require "comandos"


function love.load()

	_G.version_juego = "Beta 1.0.3"
	_G.ip_direccion = "*"
	_G.lm=love.math
	_G.lm.setRandomSeed(love.timer.getTime())
	--_G.font = font
	_G.py=love.physics

  	Gamestate.registerEvents()

  	Gamestate.switch(Comandos)


end

--enviar imagenes de personajes del servidor al cliente

--colocar contraseña
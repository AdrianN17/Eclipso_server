local Class= require "libs.hump.class"
local Servidor = require "entidades.servidor"
local cmd = require "libs.lovecmd.lovecmd"



local comandos = Class{}

function comandos:init()
	
end

function comandos:enter()
	cmd.load()
	print("Escriba comando a elegir")
end

function comandos:update(dt)
	cmd.update()

	cmd:on("create", function(map,tiempo,revivir,max_players,max_enemies)--map,tiempo,revivir,max_players,max_enemies)
		local ok  = pcall(function() require ("entidades.mapas." .. map) end)

		if ok then
			local tiempo_n,revivir_n,max_players_n,max_enemies_n = tonumber(tiempo),tonumber(revivir), tonumber(max_players), tonumber(max_enemies)

			if not tiempo_n  and not revivir_n and not max_players_n and not max_enemies_n then
				print("numeros no validos")
			else
				if max_players_n<9 and max_players_n>=1 and max_enemies_n<51 and max_enemies_n>=0 and tiempo_n<20 and tiempo_n>=5 and revivir_n<10 and revivir_n>=0 then
					print("creando servidor")
					Gamestate.switch(Servidor,max_players_n,max_enemies_n,map,ip_direccion,tiempo_n,revivir_n)
				else
					print("cantidad no validas")
				end
			end
		else
			print("mapa desconocido")
		end
	end)

	cmd:on("createc", function(map)
		local ok  = pcall(function() require ("entidades.mapas." .. map) end)

		if ok then
			print("creando servidor")
			Gamestate.switch(Servidor,8,25,map,ip_direccion,5,0)
		end
	end)

	cmd:on("ping", function()

		print("pong")
	end)

	cmd:on("BYE", function()
    	love.event.quit()
  	end)

  	cmd:on(function(name) print(name .. "comando desconocido") end) 


  	cmd:on("help",function()
  		print("ping : saber conexion del servidor")
  		print("create [map tiempo revivir max_players max_enemies] : creacion de servidor")
  		print("createc [map] : creacion predeterminada de servidor")
  		print("BYE : salir de la consola")
  	end)

end

return comandos
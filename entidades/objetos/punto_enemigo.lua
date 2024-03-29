local Class= require "libs.hump.class"
local funciones = require "entidades.objetos.funciones_objetos"

local punto_enemigo = Class{}

function punto_enemigo:init(entidades,x,y)
	self.tipo="punto_enemigo"
	self.entidades=entidades

	self.radio=0
	self.ox,self.oy=x,y

	self.objetos_enemigos=entidades.objetos_enemigos

	self.max_enemigos=entidades.max_enemigos

	self.tiempo_invocacion=0

	self.tiempo_max_invocacion=lm.random(1,3)

	self.entidades:add_obj("inicios",self)
end

function punto_enemigo:update(dt)
	if self.entidades.server then
		if self.entidades.cantidad_actual_enemigos<self.max_enemigos then
			self.tiempo_invocacion=self.tiempo_invocacion+dt

			if self.tiempo_invocacion>self.tiempo_max_invocacion then

				local tipo = lm.random(1,#self.objetos_enemigos)
				self.objetos_enemigos[tipo](self.entidades,self.ox,self.oy)

				self.entidades.cantidad_actual_enemigos=self.entidades.cantidad_actual_enemigos+1

				self.tiempo_invocacion=0

				table.insert(self.entidades.respawn_enemigos_lista,{tipo=tipo,ox=self.ox,oy=self.oy})

			end
		end
	end
end

return punto_enemigo
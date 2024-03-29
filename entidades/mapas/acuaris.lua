local acuaris={}
acuaris.x,acuaris.y=3200,3200
acuaris.w_tile,acuaris.h_tile=32,32

acuaris.puntos						= require "entidades.mapa_puntos.acuaris"

acuaris.objetos_data={}
acuaris.objetos_data.arbol			= require "entidades.objetos.arbol"
acuaris.objetos_data.roca			= require "entidades.objetos.roca"
acuaris.objetos_data.estrella		= require "entidades.objetos.estrella"
acuaris.objetos_data.punto_enemigo	= require "entidades.objetos.punto_enemigo"
acuaris.objetos_data.punto_inicio	= require "entidades.objetos.punto_inicio"

acuaris.objetos_data.arrecife		= require "entidades.destruible.arrecife"

acuaris.objetos_enemigos={}
acuaris.objetos_enemigos[1]			= require "entidades.enemigos.muymuy"
acuaris.objetos_enemigos[2]			= require "entidades.enemigos.cangrejo"

acuaris.tipo_suelo={}
acuaris.tipo_suelo.agua= require "entidades.suelo.agua"

return acuaris
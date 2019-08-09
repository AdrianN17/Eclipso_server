local acuaris_volcan={}
acuaris_volcan.x,acuaris_volcan.y=3200,3200
acuaris_volcan.w_tile,acuaris_volcan.h_tile=32,32

acuaris_volcan.puntos						= require "entidades.mapa_puntos.acuaris_volcan"

acuaris_volcan.objetos_data={}
acuaris_volcan.objetos_data.arbol			= require "entidades.objetos.arbol"
acuaris_volcan.objetos_data.roca			= require "entidades.objetos.roca"
acuaris_volcan.objetos_data.estrella		= require "entidades.objetos.estrella"
acuaris_volcan.objetos_data.punto_enemigo	= require "entidades.objetos.punto_enemigo"
acuaris_volcan.objetos_data.punto_inicio	= require "entidades.objetos.punto_inicio"

acuaris_volcan.objetos_data.arrecife		= require "entidades.destruible.arrecife"
acuaris_volcan.objetos_data.obsidiana		= require "entidades.destruible.obsidiana"
acuaris_volcan.objetos_data.lava			= require "entidades.destruible.lava"

acuaris_volcan.objetos_enemigos={}
acuaris_volcan.objetos_enemigos[1]			= require "entidades.enemigos.muymuy"
acuaris_volcan.objetos_enemigos[2]			= require "entidades.enemigos.cangrejo"

acuaris_volcan.tipo_suelo={}
acuaris_volcan.tipo_suelo.agua= require "entidades.suelo.agua"

return acuaris_volcan
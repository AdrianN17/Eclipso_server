local Class= require "libs.hump.class"
local teclas = require "entidades.funciones.teclas"
local utf8 = require "utf8"
local extra = require "entidades.funciones.extra"

local entidad_servidor = Class{}

function entidad_servidor:init()

	self.id_creador=1
	self.enemigos_id_creador=100

  self.tipo_suelo = self.mapa_files.tipo_suelo

	self.objetos_enemigos=self.mapa_files.objetos_enemigos

	self.world = love.physics.newWorld(0, 0, false)
	self.world:setCallbacks(self:callbacks())

	self:close_map()

	self.gameobject={}

	self.gameobject.players={}
	self.gameobject.balas={}
	self.gameobject.efectos={}
	self.gameobject.destruible={}
	self.gameobject.enemigos={}
	self.gameobject.objetos={}
	self.gameobject.arboles={}
	self.gameobject.inicios={}
  self.gameobject.otros={}
  self.gameobject.suelos={}

  self:map_read(self.mapa_files.puntos)
	self:inicios_random()

	self.chat={}
	self.texto_escrito=""
	self.escribiendo=false

	self.tiempo_chat=0
	self.max_tiempo_chat=3

  self.index_enemigos=1

end


function entidad_servidor:callbacks()
	local beginContact =  function(a, b, coll)

		local obj1=nil
 		local obj2=nil

		local o1,o2=a:getUserData(),b:getUserData()

		if o1.pos<o2.pos then
			obj1=o1
			obj2=o2
		else
			obj1=o2
			obj2=o1
		end

 		local x,y=coll:getNormal()


    if obj1.data=="bala" and obj2.data=="objeto" then
      obj1.obj:remove()
    elseif obj1.data=="bala" and obj2.data=="destruible" then

      local x1, y1, x2, y2 = coll:getPositions( )
      if x1 and y1 then
        local poly = obj2.obj:poligono_recorte(x1,y1)
      end
      
      obj1.obj:remove()
    elseif obj1.data=="personaje" and obj2.data=="bala" then
      local esta_muerto = extra:dano(obj1.obj,obj2.obj.dano)

      if esta_muerto then
        local creador = obj2.obj.creador
        if creador == self.enemigos_id_creador then

        else
          self:aumentar_kill_personaje(creador)
        end
      end


      extra:efecto(obj1.obj,obj2.obj)
      obj2.obj:remove()
    elseif obj1.data=="escudo" and obj2.data=="bala" and obj1.obj.estados.protegido then
      obj2.obj:remove()
    elseif obj1.data=="personaje" and obj2.data=="melee" and obj2.obj.estados.atacando_melee then
      local esta_muerto = extra:dano(obj1.obj,obj2.obj.dano_melee)
      if esta_muerto then
        local creador = obj2.obj.creador
        self:aumentar_kill_personaje(creador)
      end

      extra:empujon(obj2.obj,obj1.obj,-1)

      obj2.obj.estados.atacando_melee=false
    elseif obj1.data=="bala" and obj2.data=="bala" then
      obj1.obj:remove()
      obj2.obj:remove()
    --callback de enemigos
    elseif obj1.data == "bala" and obj2.data == "enemigos" then
      obj2.obj:validar_estado_bala(obj1.obj)
      local esta_muerto = extra:dano(obj2.obj,obj1.obj.dano)

      if esta_muerto then
        local creador = obj1.obj.creador
        self:aumentar_kill_enemigo(creador)
      end

      extra:efecto(obj2.obj,obj1.obj)
      obj1.obj:remove()
    elseif obj1.data=="personaje" and obj2.data=="vision_enemigo" then
      obj2.obj:nueva_presas(obj1.obj)
    elseif obj1.data=="personaje" and obj2.data=="melee_enemigo" then
      local esta_muerto = extra:dano(obj1.obj,obj2.obj.dano_melee)

      if esta_muerto then

      end
      
      extra:empujon(obj2.obj,obj1.obj,1)
    elseif obj1.data=="enemigos" and obj2.data=="melee" and obj2.obj.estados.atacando_melee then
      local esta_muerto = extra:dano(obj1.obj,obj2.obj.dano_melee)

      if esta_muerto then
        local creador = obj2.obj.creador
        self:aumentar_kill_enemigo(creador)
      end

      extra:empujon(obj2.obj,obj1.obj,1)

      obj1.obj.radio=-obj2.obj.radio

      obj2.obj.estados.atacando_melee=false

    elseif obj1.data=="personaje" and obj2.data=="destruible" then
      if obj2.obj.efecto then
        obj2.obj:efecto(obj1.obj)
      end

    elseif obj1.data=="enemigos" and obj2.data=="destruible" then
      if obj2.obj.efecto then
        obj2.obj:efecto(obj1.obj)
      end
    elseif obj1.data=="personaje" and obj2.data=="efecto_suelo" then
      obj1.obj.friccion = obj2.friccion
      obj1.obj.tocando = obj2.tocando
    end

  end
  
  local endContact =  function(a, b, coll)
   	local obj1=nil
   	local obj2=nil

  	local o1,o2=a:getUserData(),b:getUserData()
      
    if o1.pos<o2.pos then
  		obj1=o1
  		obj2=o2
  	else
  		obj1=o2
  		obj2=o1
  	end
    
    local x,y=coll:getNormal()

    if obj1.data=="personaje" and obj2.data=="vision_enemigo" then
      obj2.obj:eliminar_presas(obj1.obj)
    elseif obj1.data=="personaje" and obj2.data=="efecto_suelo" then
      --obj1.obj.friccion = obj1.obj.friccion_original
    end
    
  end
  
  local preSolve =  function(a, b, coll)
	    
  end
  
  local postSolve =  function(a, b, coll, normalimpulse, tangentimpulse)

	end

	return beginContact,endContact,preSolve,postSolve
end

function entidad_servidor:update_server(dt)

  for _, obj_data in ipairs(self.gameobject.arboles) do
    obj_data:update(dt)
  end

  for _, obj_data in ipairs(self.gameobject.players) do
    if obj_data.obj then
      obj_data.obj:update(dt)
    end
  end

  for _, obj_data in ipairs(self.gameobject.enemigos) do
    obj_data:update(dt)
  end

  for _, obj_data in ipairs(self.gameobject.balas) do
    obj_data:update(dt)
  end

  for _, obj_data in pairs(self.gameobject.destruible) do
    if obj_data then
      obj_data:update(dt)
    end
  end

  for _, obj_data in ipairs(self.gameobject.objetos) do
    obj_data:update(dt)
  end

  for _, obj_data in ipairs(self.gameobject.inicios) do
    obj_data:update(dt)
  end
    
end

function entidad_servidor:add_obj(name,obj)
	table.insert(self.gameobject[name],obj)
end

function entidad_servidor:remove_obj(name,obj)
	for i, e in ipairs(self.gameobject[name]) do
		if e==obj then
			table.remove(self.gameobject[name],i)
			return
		end
	end
end


function entidad_servidor:map_read(data) 
  local obj_data = self.mapa_files.objetos_data

  for _, object in ipairs(data.object_layers) do
      if #object==2 then
        obj_data[object[1]](self,object[2])
      else
        obj_data[object[1]](self,object[2],object[3])
      end 
  end

  for _,tile in ipairs(data.tilelayers) do

    local objeto = self.tipo_suelo[tile[1]](self.world,tile[2])
    self.gameobject.suelos[tile[1]]=objeto
  end

end


function entidad_servidor:control_chat()
  if #self.chat> 11 then
      table.remove(self.chat,1)
  end
end

function entidad_servidor:aumentar_id_creador()
  self.id_creador=self.id_creador+1
end

function entidad_servidor:close_map()
  local w,h=self.mapa_files.x,self.mapa_files.y
  local fin_mapa={}
  fin_mapa.collider=py.newBody(self.world,0,0,"static")
  fin_mapa.shape=py.newChainShape(true,0,0,w,0,h,w,0,h)
  fin_mapa.fixture=py.newFixture(fin_mapa.collider,fin_mapa.shape)
  
  fin_mapa.fixture:setUserData( {data="objeto",obj=self, pos=5} )
  
  return fin_mapa
end

function entidad_servidor:dar_xy_personaje()
  for i, ini in ipairs(self.gameobject.inicios) do
    if not ini.creacion_players and ini.tipo=="punto_inicio" then
      ini.creacion_players=true
      return ini.ox,ini.oy,i
    end
  end
end

function entidad_servidor:inicios_random()

    local tbl=self.gameobject.inicios
    local len, random = #tbl, lm.random ;
    for i = len, 2, -1 do
        local j = random( 1, i );
        tbl[i], tbl[j] = tbl[j], tbl[i];
    end
    return tbl;

end

function entidad_servidor:reiniciar_punto_resureccion(i)
    self.gameobject.inicios[i].creacion_players=false
end

function entidad_servidor:finalizar_busqueda()
  self.estado_partida:empezando()
end

function entidad_servidor:remove_player(obj)
  for i,data in ipairs(self.gameobject.players) do
    if data.obj==obj then
      local id = data.index
      self.gameobject.players[i].obj=nil
      --crear nuevo personaje
      if self.gameobject.players[i].vidas>0 then

          self.timer_juego:after(0.5, function()
            local player = self.gameobject.players[i]
            if player then
              self:crear_personaje_principal_otravez(player,player.personaje,player.nickname,player.creador)
            end
          end)
      end


      return id
    end
  end
end

function entidad_servidor:remove_player_total(obj)
  for i,data in ipairs(self.gameobject.players) do
    if data.obj==obj then
      local id = data.index
      table.remove(self.gameobject.players,i)
      return id
    end
  end
end

function entidad_servidor:get_enemigo_id()
    return self.index_enemigos
end

function entidad_servidor:incrementar_enemigo_id()
  self.index_enemigos=self.index_enemigos+1
end

function entidad_servidor:volver_menu()
  self:clear()
  self.timer_juego:clear()
  self.server:destroy()
  Gamestate.switch(Menu)
end

return entidad_servidor
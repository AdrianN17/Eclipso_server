local Class= require "libs.hump.class"
local Sock = require "libs.sock.sock"
local bitser = require "libs.bitser.bitser"
local socket = require "socket"
local machine = require "libs.statemachine.statemachine"
local extra = require "entidades.funciones.extra"
local entidad_servidor = require "entidades.entidad_servidor"

local personajes = {}

personajes.aegis = require "entidades.personajes.aegis"
personajes.solange = require "entidades.personajes.solange"
personajes.xeon = require "entidades.personajes.xeon"
personajes.radian = require "entidades.personajes.radian"

local timer = require "libs.hump.timer"

local cmd = require "libs.lovecmd.lovecmd"

local servidor = Class{
	__includes={entidad_servidor}
}

function servidor:init()
	
end

function servidor:enter(gamestate,max_jugadores,max_enemigos,mapas,ip_direccion,tiempo,revivir)

  self.targetTime=0
  self.timestep = 1/60

  cmd.load()
  print("[SERVER] : Servidor creado correctamente")

  self.tiempo_partida=tiempo*60
  self.tiempo_partida_inicial=0
  self.max_revivir=revivir

  self.timer_juego=timer.new()

  self.estado_partida=machine.create({
    initial="espera",
    events = {
      {name = "empezando", from = "espera" , to = "inicio"},
      {name = "finalizando" , from = "inicio", to = "fin"}
  }
  })

	self.mapa_files=require ("entidades.mapas." .. mapas)
  self.w_tile,self.h_tile=self.mapa_files.w_tile,self.mapa_files.h_tile


	self.max_enemigos=max_enemigos
	self.cantidad_actual_enemigos=0

  self.respawn_enemigos_lista={}
  self.enemigos_eliminados={}


	--creacion de servidor

	entidad_servidor.init(self)

	

	--informacion de servidor
	self.tickRate = 1/60
	self.tick = 0

	self.server = Sock.newServer(ip_direccion,22122,max_jugadores)
	self.server:setSerialization(bitser.dumps, bitser.loads)

	self.server:enableCompression()

	self.server:setSchema("informacion_primaria",{
		"personaje",
		"nickname"
	})


  self.server:setSchema("recibir_cliente_servidor_1_1",
    {"tipo","data"})

  self.server:setSchema("recibir_mira_cliente_servidor_1_1",{"rx","ry"})

  self.server:setSchema("enviar_vista",{"cx","cy","cw","ch"})


  self.server:on("recibir_mira_cliente_servidor_1_1",function(data,client)
      local index =client:getIndex()
      local obj = self:verificar_existencia(index)

      if obj and obj.obj then
        obj.obj.rx,obj.obj.ry=data.rx,data.ry

        self.server:sendToAllBut(client,"recibir_mira_servidor_cliente_1_muchos",{index,data.rx,data.ry})
      end

    end)

  self.server:on("enviar_vista", function(data,client)
      local index =client:getIndex()
      local obj = self:verificar_existencia(index)

      if obj then
        obj.cx,obj.cy,obj.cw,obj.ch=data.cx,data.cy,data.cw,data.ch
      end
  end)


  self.server:on("recibir_cliente_servidor_1_1" ,function(data,client)
    local index=client:getIndex()

    local obj = self:verificar_existencia(index)

    if obj then

      if data.tipo=="keypressed" then
        obj.obj:keypressed(data.data[1])
      elseif data.tipo=="keyreleased" then
        obj.obj:keyreleased(data.data[1])
      elseif data.tipo=="mousepressed" then
        obj.obj:mousepressed(data.data[1],data.data[2],data.data[3])
      elseif data.tipo=="mousereleased" then
        obj.obj:mousereleased(data.data[1],data.data[2],data.data[3])
      end

      self.server:sendToAllBut(client,"recibir_servidor_cliente_1_muchos",{index,data.tipo,data.data})
    end

  end)




	self.server:on("informacion_primaria", function(data, client)
    if self.estado_partida.current=="espera" then
      	local index=client:getIndex()

        self:crear_personaje_principal(index,data.personaje,data.nickname)

        local index=client:getIndex()

        local actual_players={}

        for i,player in ipairs(self.gameobject.players) do
          local t = {}
          t.index = player.index 
          t.x=player.obj.x
          t.y=player.obj.y
          t.nickname=player.obj.nickname
          t.personaje=player.obj.tipo

          table.insert(actual_players,t)
        end

        local radios_objetos = self:enviar_radios_objetos()
        local radios_arboles = self:enviar_radios_arboles()


        client:send("player_init_data", {index,mapas,actual_players,self.max_enemigos,radios_objetos,radios_arboles}) 


        local obj = self:verificar_existencia(index)

        if obj then
        
          self.server:sendToAllBut(client,"nuevo_player", {index,obj.obj.tipo,obj.obj.nickname,obj.obj.x,obj.obj.y})

        end
      else
        client:disconnectNow()
      end

  	end)

  	self.server:on("disconnect", function(data, client)

    	local index =client:getIndex()

    	local obj = self:verificar_existencia(index)
    	if obj then
        if obj.obj then
    		  obj.obj:remove_final()
        else
          self:remove_desde_raiz(obj)
        end
    		self.server:sendToAll("desconexion_player", index)
    	end
    end)

    self.server:on("chat", function(chat,client)

      table.insert(self.chat,chat)

      self:control_chat()

      self.server:sendToAllBut(client,"chat_total",chat)

    end)

    self.jugadores_ganadores={}
    
end

function servidor:update(dt)
  self.targetTime = love.timer.getTime() + self.timestep
  --dt = math.min (dt, 1/30)

  --print(dt)

	self.tick = self.tick + dt

	if self.tick >= self.tickRate then
		self.tick = 0

    self.timer_juego:update(dt)
		self.server:update(dt)
    

		if self.estado_partida.current == "inicio" then
        self.tiempo_partida_inicial=self.tiempo_partida_inicial+dt

        self:update_server(dt)
        self.world:update(dt) 

        if self.tiempo_partida_inicial>self.tiempo_partida or self:contabilizar_jugadores() <= 1 then

            self:ver_jugadores_ultimos_vivos()
            self.server:sendToAll("partida_finalizada",self.jugadores_ganadores)
            self.estado_partida:finalizando()
            
          self.tiempo_partida_inicial=0
        end

        self:envio_masivo_validaciones() 
    end
  end

  cmd.update()

  self:lista_comandos()

  love.timer.sleep(self.targetTime - love.timer.getTime())
  self.targetTime = love.timer.getTime() + self.timestep

end


function servidor:crear_personaje_principal(id,personaje,nickname)
  local obj = personajes[personaje](self,self.id_creador,nickname)

	t={index=id, obj =obj ,personaje=personaje,nickname=nickname,vidas=self.max_revivir,creador = self.id_creador,kills_enemigos=0,kills_personajes=0}
    self:add_obj("players",t)
    self:aumentar_id_creador()
end

function servidor:crear_personaje_principal_otravez(player,personaje,nickname,creador)
  player.obj = personajes[personaje](self,creador,nickname)
  player.vidas=player.vidas-1

  local ox,oy = player.obj.ox,player.obj.oy
  local index = player.index

  self.server:sendToAll("revivir_usuarios",{index,personaje,nickname,creador,ox,oy})

end

function servidor:verificar_existencia(index)
	local obj = nil

	for i,data in ipairs(self.gameobject.players) do
		if data.index==index then
			obj=data
			break
		end
	end

	return obj
end

function servidor:envio_masivo_validaciones()
    local clientes = self.server:getClients()

    for _, cliente in ipairs(clientes) do
      local index = cliente:getIndex()
      local peer = self.server:getPeerByIndex(index)
      local obj = self:verificar_existencia(index)

      if obj and obj.cx and obj.cy and obj.cw and obj.ch then
        local aliados,enemigos = extra:enviar_data_primordiar_jugador(self,obj)
        self.server:sendToPeer( peer,"enviar_data_principal", {aliados,enemigos,self.respawn_enemigos_lista,self.enemigos_eliminados})
      end
    end

    self.respawn_enemigos_lista={}
    self.enemigos_eliminados={}
end

function servidor:enviar_radios_objetos()
    local obj_lista={}
    for _,obj in ipairs(self.gameobject.objetos) do
      local t={ox=obj.ox,oy=obj.oy,radio=obj.radio}
      table.insert(obj_lista,t)
    end

    return obj_lista
end

function servidor:enviar_radios_arboles()
    local obj_lista={}
    for _,obj in ipairs(self.gameobject.arboles) do
      local t={ox=obj.ox,oy=obj.oy,radio=obj.radio}
      table.insert(obj_lista,t)
    end

    return obj_lista
end

function servidor:volver_comando()
  self.timer_juego:clear()
  self:clear()
  self.server:destroy()
  Gamestate.switch(Comandos)
end

function servidor:quit()
  self.timer_juego:clear()
  self:clear()
  self.server:destroy()
end

function servidor:clear()
  self.world:destroy( )
  self.gameobject.players={}
  self.gameobject.balas={}
  self.gameobject.efectos={}
  self.gameobject.destruible={}
  self.gameobject.enemigos={}
  self.gameobject.objetos={}
  self.gameobject.arboles={}
  self.gameobject.inicios={}
end

function servidor:contabilizar_jugadores()
  local i = 0
  for _,player in ipairs(self.gameobject.players) do
    if player.obj  or player.vidas>0 then
      i=i+1
    end
  end
  return i
end

function servidor:ver_jugadores_ultimos_vivos()
    for i,player in ipairs(self.gameobject.players) do
      if player and player.obj then
        t={nickname = player.nickname, kills_personajes = player.kills_personajes, kills_enemigos = player.kills_enemigos}
        table.insert(self.jugadores_ganadores,t)
      end
    end
end

function servidor:buscar_personaje_creador(creador)
  local obj=nil
  for i,player in ipairs(self.gameobject.players) do
    if player and player.obj and player.obj.creador == creador then
      obj=player
    end
  end

  return obj
end

function servidor:aumentar_kill_personaje(creador)
  local obj = self:buscar_personaje_creador(creador)
  if obj then
    obj.kills_personajes=obj.kills_personajes+1
  end
end

function servidor:aumentar_kill_enemigo(creador)
  local obj = self:buscar_personaje_creador(creador)
  if obj then
    obj.kills_enemigos=obj.kills_enemigos+1
  end
end

function servidor:remove_desde_raiz(obj)
  for i,player in ipairs(self.gameobject.players) do
    if player == obj then
      table.remove(self.gameobject.players,i)
    end
  end
end

function servidor:lista_comandos()
  cmd:on("ping", function()
    print("[SERVER] : pong server")
  end)

  cmd:on("INIT_GAME", function()
    if  #self.gameobject.players>1 then
      self.estado_partida:empezando()
      self.server:sendToAll("iniciar_juego",true)
      self.server:sendToAll("chat_total","Iniciando partida")
    else
      print("[SERVER] : Players insuficientes. Min 2")
    end
  end)

  cmd:on("END_GAME", function()
    self:volver_comando()
  end)

  cmd:on("BYE", function()
    print("[SERVER] : Servidor finalizado")
    love.event.quit()
  end)

  cmd:on("STATUS", function()
    print(self.estado_partida.current)
  end)

  cmd:on(function(name) print(name .. "comando desconocido") end) 

  cmd:on("help",function()
      print("\t ping : saber conexion del servidor")
      print("\t INIT_GAME : iniciar juego")
      print("\t END_GAME : finalizar juego")
      print("\t STATUS : estado de partida")
      print("\t BYE : salir de la consola")
    end)
end

return servidor


local Class= require "libs.hump.class"
local polybool = require "libs.polygon.polybool"
local delete = require "entidades.funciones.delete"
local funciones = require "entidades.destruible.funciones_destruible"

local obsidiana = Class{
	__includes = {delete}
}

function obsidiana:init(entidades,poligono)
	self.tipo="obsidiana"
	self.entidades=entidades

	local ok, res = pcall(function () funciones:crear_destruible(self,poligono) end)
	
	self.entidades:add_obj("destruible",self)

	self.otro_poligono=nil

	delete.init(self,"destruible")

	if not ok  then
		print(res)
		self:remove()
	end
end

function obsidiana:update(dt)
	if self.otro_poligono then
    	self:recorte_figura(self.otro_poligono)
  	end
end

function obsidiana:recorte_figura(poligono_enemigo)
  
  local nuevo_poligono = polybool(self.poligono, poligono_enemigo, "not")

  if #nuevo_poligono<4 then
  		local lista_poligono={}

	    for i=1, #nuevo_poligono ,1 do

	    	if funciones:get_area_poligono(nuevo_poligono[i]) >100 then

	    		local poligono_validado = funciones:validar_poligono_box2d(nuevo_poligono[i])

	    		if #poligono_validado>=6 and #poligono_validado%2==0 then
		        	obsidiana(self.entidades,poligono_validado)
		        end
		    end
	    end
  end
	   
  self:remove() 

end

function obsidiana:poligono_recorte(x,y)
  local dis=3.5
  self.otro_poligono =  {-5*dis+x,-8.66*dis+y,
  5*dis+x,-8.66*dis+y,
  10*dis+x,0*dis+y,
  5*dis+x,8.66*dis+y,
  -5*dis+x,8.66*dis+y,
  -10*dis+x,0*dis+y}
end

return obsidiana
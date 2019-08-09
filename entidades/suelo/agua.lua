local Class= require "libs.hump.class"

local agua = Class()

function agua:init(world,lista)
	self.collider=py.newBody(world,0,0,"kinematic")

	for _,tile in ipairs(lista) do
		self:crear_tile(tile,self.collider)
	end
end

function agua:crear_tile(tile)
	local x,y,w,h=tile.x or tile[1] ,tile.y or tile[2] ,tile.w or tile[3],tile.h or tile[4]
	local shape=py.newRectangleShape(x+w/2,y+h/2,w,h)
	local fixture=py.newFixture(self.collider,shape)
	fixture:setUserData( {data="efecto_suelo", pos=12, friccion = 0.5, tocando="agua"} )
	fixture:setSensor(true)
end

return agua
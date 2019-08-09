# Eclipso_server

Server of eclipso multiplayer game, only comands (No gui)

Tested in ubuntu with vps

![alt text](https://img.shields.io/badge/Love-11.2-ff69b4.svg) ![alt text](https://img.shields.io/badge/Status-Beta%201.0-orange.svg)

## Comands lines:

* No game : 

  * create
    * arguments : map time lifes max_players max_enemies
    * descripcion : create game with custom parameters

  * createc
    * arguments : maps
    * descripcion : create game with default parameters ( 5 min , 0 lifes , 8 max_players, 25 max_enemies)

  * ping
    * descripcion : check if server stil alive
    * return : pong

  * VER
    * descripcion : get version of server
    * return : version

  * BYE
    * descripcion : close server
    
  * help
    * descripcion : get version of server
    * return : list with comands
    
* When your create game

  * ping
    * descripcion : check if server stil alive
    * return : pong server

  * INIT_GAME
    * descripcion : start game
    
  * END_GAME
    * descripcion : finish game
    
  * BYE
    * descripcion : close server
    
  * STATUS
    * descripcion : get status of game
    * return : espera|wait - inicio|start - fin|end
    
  * help
    * descripcion : get version of server
    * return : list with comands

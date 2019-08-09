# Eclipso_server


Comands lines:

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

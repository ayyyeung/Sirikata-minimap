
system.require('std/core/bind.em');

std.gameCreator = system.Class.extend(
   {
       init: function () {
       /*Initializes the game setting up the handlers for joining the game, quitting the game and moving your avatar." */
          system.print('Test');
          /*var acceptInvitePattern = new util.Pattern("game": "accept");
          var acceptHandler = std.core.bind(this.acceptHandler, this);
          acceptHandler << acceptInvitePattern;*/
          var quitPattern = new util.Pattern("game", "quit");
          var quitHandler = std.core.bind(this.quitHandler, this);
          quitHandler << quitPattern;
          this.inviteList = new Array();
          this.playerList = new Array();
          this.presenceCount = 0;
          var movePattern = new util.Pattern("game", "move");
          var motionHandler = std.core.bind(this.motionHandler, this);
          motionHandler << movePattern;
	  this.presStart = system.presences.length;
	  this.invite(system.presences[0].toString());
       },
       invite: function (player) {

       /*This invites a player to the game by sending them a script for handling connection messages from their 
	* avatar and also sets up key bindings for movement.  This is then just sent as a script 
	* request to the selected/invited player. */

   
          function gamePlayer () {
		  function askq () {
			  system.print("Do you want to join a game? (y/n)");
 		}
		  system.timeout(10, askq);
		system.print("Do you want to join a game? (y/n)");
		function connHandler (msg, sender) {
  			  avNum = msg.num;
			  gameContStr = sender;
  			  gameController = system.createVisible(sender);
		}

		var connPattern = new util.Pattern('avatar', 'connected');
		connHandler << connPattern;

		var avNum = -1;
		var gameController;
		var gameContStr = "none";
		function joinGame () {
		  system.print("Enjoy the game! \n");
   		
		  function moveLeftGame () {
   			var msg = new Object();
			msg.game = 'move';
			msg.dir = 'left';
			msg.avatar = avNum;
			msg >> gameController >> [];
		  }

		  simulator._binding.addAction('moveLeftR', moveLeftGame);
		  var moveLBinding =  [{ key: ['button-pressed', 'u' ], action: 'moveLeftR' } ];
		  simulator._binding.addBindings(moveLBinding);

 
                  function moveStopGame () {
   			var msg = new Object();
			msg.game = 'move';
			msg.dir = 'stop';
			msg.avatar = avNum;
			msg >> gameController >> [];
		  }

		  simulator._binding.addAction('moveStop', moveStopGame);
		  var stopBinding =  [{ key: ['button-pressed', 'o' ], action: 'moveStop' } ];
		  simulator._binding.addBindings(stopBinding);

		  function moveRightGame () {
		     var msg = new Object();
		     msg.game = 'move';
		     msg.dir = 'right';
		     msg.avatar = avNum;
		     msg >> gameController >> [];
		  }

		  simulator._binding.addAction('moveRightR', moveRightGame);
		  var moveRBinding =  [{ key: ['button-pressed', 'i' ], action: 'moveRightR' } ];
		  simulator._binding.addBindings(moveRBinding);

		  function moveForwardGame () {
		     var msg = new Object();
		     msg.game = 'move';
		     msg.dir = 'forward';
		     msg.avatar = avNum;
		     msg >> gameController >> [];
		  }

		  simulator._binding.addAction('moveForwardR', moveForwardGame);
		  var moveFBinding =  [{ key: ['button-pressed', '8' ], action: 'moveForwardR' } ];
		  simulator._binding.addBindings(moveFBinding);


		  function moveBackGame () {
		     var msg = new Object();
		     msg.game = 'move';
		     msg.dir = 'back';
		     msg.avatar = avNum;
		     msg >> gameController >> [];
		  }

		  simulator._binding.addAction('moveBackR', moveBackGame);
		  var moveBBinding =  [{ key: ['button-pressed', 'j' ], action: 'moveBackR' } ];
		  simulator._binding.addBindings(moveBBinding);


		  function moveUpGame () {
		     var msg = new Object();
		     msg.game = 'move';
		     msg.dir = 'up';
		     msg.avatar = avNum;
		     msg >> gameController >> [];
		  }

		  simulator._binding.addAction('moveUpR', moveUpGame);
		  var moveUBinding =  [{ key: ['button-pressed', '7' ], action: 'moveUpR' } ];
		  simulator._binding.addBindings(moveUBinding);

		  function moveDownGame () {
		     var msg = new Object();
		     msg.game = 'move';
		     msg.dir = 'down';
		     msg.avatar = avNum;
		     msg >> gameController >> [];
		  }

		  simulator._binding.addAction('moveDownR', moveDownGame);
		  var moveDBinding =  [{ key: ['button-pressed', 'h' ], action: 'moveDownR' } ];
		  simulator._binding.addBindings(moveDBinding);

		}

		simulator._binding.addAction('joinGame', joinGame);
		var joinBinding =  [{ key: ['button-pressed', 'y' ], action: 'joinGame' } ];
		simulator._binding.addBindings(joinBinding);


		function quitGame () {
		   var msg = new Object();
		   msg.game = 'quit';

		   msg.avatar = avNum;
		   //msg >> gameController >> [];
		}

		simulator._binding.addAction('quitGame', quitGame);
		var quitBinding =  [{ key: ['button-pressed', 'n' ], action: 'quitGame' } ];
		simulator._binding.addBindings(quitBinding);

	  }

          var val = gamePlayer.toString() + "\n gamePlayer();";
	  system.print(val);
          this.inviteList.push(player);
	  var request = {
                request : 'script',
                script : val
            };
          var target = system.createVisible(player);
          request >> target >> [];
	  this.acceptHandler(player);



	
       },
       uninvite: function (avatar) {
	  /*Uninviting a player removes the player form the player list and destroys their avatar presence.*/
          this.playerList.splice(avatar,1);
          system.presences[avatar].disconnect();
       },
       quitHandler: function (msg, sender) {
	  /*The handler for quitting is just a wrapper for uninviting a player.*/
          this.uninvite(msg.avatar);
       },
       motionHandler: function (msg, sender) {
	  /*Right now this is just a test version that interprets every motion request
	   * as a request to set velocity in a single direction. */
	  for (var i =0; i<system.presences.length;i++)
  	   {
             system.print("avatar checking presences to find self");
             if (system.presences[i].toString() == this.playerList[msg.avatar].pres.toString()) {
                if (this.playerList[msg.avatar].player == sender) {
		       if (msg.dir == 'left') {
                         system.presences[i].setVelocity(<0,0,5>); 
		       }  
		       if (msg.dir == 'right') {
		         system.presences[i].setVelocity(<0,0,-5>);
	               }
		       if (msg.dir == 'up') {
		         system.presences[i].setVelocity(<0,5,0>);
	               }
                       if (msg.dir == 'down') {
		         system.presences[i].setVelocity(<0,-5,0>);
	               }
                       if (msg.dir == 'forward') {
		         system.presences[i].setVelocity(<-5,0,0>);
	               }
                       if (msg.dir == 'back') {
		         system.presences[i].setVelocity(<5,0,0>);
	               }
		       if (msg.dir == 'stop') {
		         system.presences[i].setVelocity(<0,0,0>);
	               }
		}
	     }
           }
         
       },
       createAvatar: function (index, pres) {
	  /*This is called by the newly connected presence/avatar.  It just sends some information
	   * To the player it is associated with. */
          system.print("avatar connecting");

          var avatarMsg = new Object();
          avatarMsg.avatar = "connected";
          var avnum = index;
	  this.playerList[avnum].pres = pres.toString();
          var playerVis = system.createVisible(this.playerList[avnum].player);
          avatarMsg.num = avnum;
          avatarMsg >> playerVis >> [];
       },
       acceptHandler: function(sender) {
	  /*This handles an accepted invitation and sets up a presence avatar for the player to use in the game. */
          var invited = false;
          for (var i =0 ; i<this.inviteList.length;i++)
  	   {
             if (this.inviteList[i]==sender) {
                invited = true;
                this.inviteList.splice(i,1);
             }
           }
          if (invited == false) return;
          
          var player = new Object();
          player.player = sender;
          player.avatar = this.presenceCount;
	  
	  player.connected = false;
          this.playerList[this.presenceCount]=player;
	  var index = this.presenceCount;
	  this.presenceCount++;
	  system.createPresence("meerkat:///emily2e/models/earth.dae/optimized/0/earth.dae", std.core.bind(this.createAvatar,this,index));

       }
      
   }
);





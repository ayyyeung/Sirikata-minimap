//Citation: Kotaro (original test)
function initBD() {
var guiToSend = @
if (typeof(std) === "undefined") std = {};
if (typeof(std.eventPortalScript) === "undefined") std.eventPortalScript = {};
(function () {
	var Sumd = std.eventPortalScript;
	
	Sumd.Init = function(parent) {
		this._parent = parent;
		this._parent._simulator.addGUITextModule("eventPortalScript", \@
			sirikata.ui("eventPortalScript", function() {
			
			eventPortalScript = {};
			var window;
			
			var toggleVisible = function() {
				window.toggle();
			};
			eventPortalScript.toggleVisible = toggleVisible;


			var updateScore = function(newScore) {
				$('#bDScore').text(newScore);
			};
			eventPortalScript.updateScore = updateScore;


			var updateLives = function(numLives) {
				if (numLives < 0) {
					$('#bDLives').text('Game Over!');
					sirikata.event('bdGameOver');
				} else $('#bDLives').text(numLives);
			};
			eventPortalScript.updateLives = updateLives;


			 var updateTimer = function(newTime) {
				$('#bDTimer').text(newTime);
			 };
			 eventPortalScript.updateTimer = updateTimer;
			 
			
				$('<div id="balloon-defense" title="Balloon Defense">' +
				'<div><button id="bDStartGame">Start Game</button><button id="bDNewRound">NewRound</button></div>' +
				'<style>' + '.titleStyle {font-style:normal; font-family:Verdana; font-size:1.8em;}' + 
				'.timerStyle {font-style:normal; font-family:Verdana; font-size: 4em; font-color:red}' +
				'</style>' +
				
				 '<div id="scoreBoard">' +
					'Lives<div id="bDLives" class="titleStyle">10</div>' +
					'<br/>' +
					'Score: <div id="bDScore" class="titleStyle">50</div>' +
					'<br/>' +
					'<div id="bDTimer" class="timerStyle" style="position:absolute; left: 100px; top: 20px;"></div>' +

				 '</div>' +

			'<HR WIDTH="100%" COLOR="#6699FF" SIZE="6">' +

			'<font face="verdana" color="green">Purchase weapons</font>' +

			'<div id="store" title="Weapon store">' + 
					  '<div style="position: absolute; left: 10px; top: 190px; width: 80px; height: 100px"> <button id="bDTeddy" class="buyWeapon"><img src="http://open3dhub.com/download/95d8a444921c296d1829d9e3bc73f9ed340e2494712ccd659a96e7b7a785f0c7" width="70px" height="80px"></img>10</button></div>' +
					  '<div style="position: absolute; left: 110px; top: 190px; width: 80px; height: 100px"><button id="bDPorcupine" class="buyWeapon"><img src="http://open3dhub.com/download/9b82f92052cf460c62654caff09a3f8387cfed73710277570bf64be18b9edcc8" width="70px" height="80px"></img>20</button></div>' +
					  '<div style="position: absolute; left: 210px; top: 190px; width: 80px; height: 100px;"><button id="bDDog" class="buyWeapon"><img src="http://open3dhub.com/download/4000a4fd22d38f337e084d3a7534fb8d650a9c2c5439b01c7909e171f5893c1e" width="70px" height="80px"></img>30</button></div>' +

			 '</div>' +
				 '</div>').appendTo('body');
				   
				   
				window = new sirikata.ui.window(                    
					"#balloon-defense",
					{
						autoOpen: true,
						width: 310,
						height: 360,
						modal: false
					}
				);
				
		sirikata.ui.button('#bDStartGame').button().click(startGame);
		sirikata.ui.button('#bDNewRound').button().click(newRound);
		
		sirikata.ui.button('#bDTeddy').button();
		sirikata.ui.button('#bDPorcupine').button();
		sirikata.ui.button('#bDDog').button();
		
		sirikata.ui.button('.buyWeapon').click(function() {
			buyWeapon($(this).attr('id'));
		 });
		
		function buyWeapon(weaponType){
			sirikata.event('bdBuyWeapon', weaponType);
		}
		
		function startGame() {
			sirikata.event('bdStartGame');
		}
		
		function newRound() {
			sirikata.event('bdStartRound');
		}		
				
			});
		\@,

		
		std.core.bind(function(gui){
			this._ui = gui;

            this._ui.bind("bdStartGame", std.core.bind(Sumd.handleStartGame, this));
            this._ui.bind("bdBuyWeapon", std.core.bind(Sumd.handleBuyWeapon, this));

            this._ui.bind("bdStartRound", std.core.bind(Sumd.handleStartRound, this));
			this._ui.bind("bdGameOver", std.core.bind(Sumd.handleGameOver, this));
			this.firstRound = 0;
            this.currentScore = 0;			
			
		}, this));
	};
	
	Sumd.handleStartGame = function() {
		//system.import('test/sirikataBalloonTD.em');
		initmotion();
		initdefenseTowers();
		initweaponGenerator();
		initdefenseTowerGenerator();
		initlevels();
		initfoeGenerator();
		initgameBoardGenerator();
		initislandGenerator();
		initvertexGridGeneratortd();
		initsirikataBalloonTD();
		this._ui.call('eventPortalScript.updateScore', bdScore);
	};
	
	Sumd.handleBuyWeapon = function(weaponType) {
		var createPosition = (system.createVisible(bdPlaceholder)).getPosition();
		createPosition.y = createPosition.y - 2;
		createPosition.z = createPosition.z - 5;
		createPosition.x = createPosition.x - 5;
	    if (weaponType == "bDTeddy") {
			bdScore = bdScore - 10;
			this._ui.call('eventPortalScript.updateScore', bdScore); 
			createDefenseTower("dart", createPosition , 10);
		} else if (weaponType =="bDPorcupine") {
			bdScore = bdScore - 15;
			this._ui.call('eventPortalScript.updateScore', bdScore); 
			createDefenseTower("tack", createPosition, 10);
		}
	    

	};
	
	Sumd.handleStartRound = function() {
	if (this.firstRound == 0) {
		placeholderHandler << [{'placeholder'::}];
		function placeholderHandler(msg, sender) {
			system.__debugPrint('msg Sent');
			bdPlaceholder = sender.toString();
			system.__debugPrint(bdPlaceholder);


		}
		//system.import('test/weaponPlaceholder.em');	
		initweaponPlaceholder();
		simulator._binding.addAction('moveRightR', moveRightGame);
		var moveRBinding =  [{ key: ['button-pressed', 'i' ], action: 'moveRightR' } ];
		simulator._binding.addBindings(moveRBinding);
		
			  function moveRightGame () {
				 var msg = new Object();
				 msg.game = 'move';
				 msg.dir = 'right';
				 msg >> system.createVisible(bdPlaceholder) >> [];
			  }
			  
		  simulator._binding.addAction('moveStop', moveStopGame);
		  var stopBinding =  [{ key: ['button-pressed', 'o' ], action: 'moveStop' } ];
		  simulator._binding.addBindings(stopBinding);		
		  
          function moveStopGame () {
   			var msg = new Object();
			msg.game = 'move';
			msg.dir = 'stop';
			msg >> system.createVisible(bdPlaceholder) >> [];
		  }
		  
		  function moveLeftGame () {
   			var msg = new Object();
			msg.game = 'move';
			msg.dir = 'left';
			msg >> system.createVisible(bdPlaceholder) >> [];
		  }

		  simulator._binding.addAction('moveLeftR', moveLeftGame);
		  var moveLBinding =  [{ key: ['button-pressed', 'u' ], action: 'moveLeftR' } ];
		  simulator._binding.addBindings(moveLBinding);		  

		  function moveForwardGame () {
		     var msg = new Object();
		     msg.game = 'move';
		     msg.dir = 'forward';
		     msg >> system.createVisible(bdPlaceholder) >> [];
		  }

		  simulator._binding.addAction('moveForwardR', moveForwardGame);
		  var moveFBinding =  [{ key: ['button-pressed', '8' ], action: 'moveForwardR' } ];
		  simulator._binding.addBindings(moveFBinding);


		  function moveBackGame () {
		     var msg = new Object();
		     msg.game = 'move';
		     msg.dir = 'back';
		     msg >> system.createVisible(bdPlaceholder) >> [];
		  }

		  simulator._binding.addAction('moveBackR', moveBackGame);
		  var moveBBinding =  [{ key: ['button-pressed', 'j' ], action: 'moveBackR' } ];
		  simulator._binding.addBindings(moveBBinding);


		
	    
		var balloonDefense_gui = this._ui;
		system.require('std/core/repeatingTimer.em');
		var newTimer = new std.core.RepeatingTimer(1, cbTimer);
		function cbTimer() {
			system.__debugPrint('update score timer fired');
			balloonDefense_gui.call('eventPortalScript.updateScore', bdScore);
			balloonDefense_gui.call('eventPortalScript.updateLives', bdLives);
		}
		this.firstRound = 1;
	}
		startRound();

		
	};
	
	Sumd.handleGameOver = function() {
	};
	

	

	

	
	
})();

simulator._eventPortalScript = new std.eventPortalScript.Init(simulator);
@;

var msg = {
	request: 'script',
	script:guiToSend
};
msg >> system.self >> [];
}
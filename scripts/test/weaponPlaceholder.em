function initweaponPlaceholder() {
bdPlaceholder = '';
function importDefault(obj) {
	system.require('std/default.em');
	system.onPresenceConnected(onPresCb);
	function onPresCb(pres) {
		var msg = {placeholder: 'this is a placeholder'};
		msg >> system.createVisible(obj.id) >> [];
		system.__debugPrint('msg supposedly sent');
		
	}
		var movePattern = new util.Pattern("game", "move");
	  motionHandler << movePattern;
	  
	  function motionHandler(msg, sender) {
		system.__debugPrint('msg motion handler reached\n');
		       if (msg.dir == 'left') {
                         system.self.setVelocity(<0,0,5>); 
		       }  
		       if (msg.dir == 'right') {
		         system.self.setVelocity(<0,0,-5>);
	               }
                       if (msg.dir == 'forward') {
		         system.self.setVelocity(<-5,0,0>);
	               }
                       if (msg.dir == 'back') {
		         system.self.setVelocity(<5,0,0>);
	               }
		       if (msg.dir == 'stop') {
		         system.self.setVelocity(<0,0,0>);
	               }
		}
}

var initPos = system.self.getPosition();
//initPos.z = initPos.z + 2;
initPos.x = initPos.x - 8;
initPos.y = 2;
var meshurl = 'meerkat:///emily2e/models/Untitled.dae/optimized/0/Untitled.dae';

var objToSend = {id: system.self.toString()};

system.createEntityScript(initPos, importDefault, objToSend, 3, meshurl, 2);
}



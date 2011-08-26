//system.import('std/default.em');
system.require('std/graphics/graphics.em');
system.require('std/core/repeatingTimer.em');


isDraggedHandler << [{'request': 'movable':}];

var dragLimit = 0;
//var weaponAddr = '';

function isDraggedHandler(msg, sender)
{
	/*if (dragLimit == 0) {
		system.__debugPrint('was dragged \n\n');
	}*/
	system.__debugPrint(system.self.getPosition());

	weaponAddr = sender;
             
	if (dragLimit == 0) {
	     //system.__debugPrint('its 0');
             var delta = msg.position - system.self.position;
		delta.x = -delta.y;
 		delta.y = 0;
             system.self.position = system.self.position + delta;
	     //system.self.position.y = -10;

             msg.makeReply({}) >> [];	
	}
}


var dragTimer = new std.core.RepeatingTimer(6, dragTimerCallback);

function dragTimerCallback()
{
	dragLimit = 1;
	//var scriptToSend = "system.self.position.y = -10";
	//var msg = {request: 'script', script: scriptToSend};
	//msg >> weaponAddr.createVisible() >> [];
}

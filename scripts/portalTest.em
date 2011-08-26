//system.require('std/core/queryDistance.em');
//system.require('std/core/repeatingTimer.em');

system.self.setQueryAngle(.15);
var requestPortal = {portal: "access"};
var visiblePortals = new Array();

//var msgTimer = new std.core.RepeatingTimer(1.5, endMessaging);

/*var endMessaging() {
	system.self.setQueryAngle(100);
	msgTimer.suspend();
}*/



var testFunc = function userAddedCallback(nowImportantPresence)
{
	system.__debugPrint('\n\nIm sending a mesage now\n\n');		
							    
	requestPortal >> nowImportantPresence >> [printOnPortalResp, 3, printNoPortalResp];
}

/*function userRemovedCallback(nowImportantPresence)
{		
							    
	requestPortal >> nowImportantPresence >> [printOnPortalResp, 10, printNoPortalResp];
}*/

function printOnPortalResp(msgResp, msgRespSender)
{
	//var text = 'Portal with ID' + msgRespSender.toString() + 'responded.';
	addToPortalArray(msgRespSender.toString(), msgResp.name);
	//system.print(text);
	//system.print(msgResp.prompt);
}

function addToPortalArray(newPortal, name)
{
	var isAlreadyThere = 'false';
	
	for (var i = 0; i < visiblePortals.length; i++) {
		/* avoiding repeating entries in the array */
		if (visiblePortals[i][0] == newPortal || newPortal == system.self.toString()) isAlreadyThere = 'true';
	}
	if (isAlreadyThere == 'false') visiblePortals.push([newPortal, name]);
}

function printNoPortalResp()
{
	system.print('no portal is currently within the specified distance');
}

system.self.onProxAdded( testFunc, true);



//var dQuery = new std.core.QueryDistance();
//dquery.init(50, userAddedCallback, userRemovedCallback, system.self); 
//dquery.proxAddFunc(system.self);


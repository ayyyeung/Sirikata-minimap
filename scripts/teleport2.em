system.onPresenceConnected(moveFunc);

function moveFunc(newPres) {
	system.print('init');
}

function respToSender(msgResp, msgRespSender)
{
	system.print('sending response...');
	var scriptToSend = 'system.self.guiText = \'\''
	var response = {request: 'script', script: scriptToSend, prompt: 'ctrl u to respond', name: 'banana'};
	msgResp.makeReply(response) >> [];
}

respToSender << [{'portal'::}];

sendTransportInfo << [{'execute': 'true':}];

function sendTransportInfo(msgResp, msgRespSender)
{
	var meshUrl = 'meerkat:///ayyyeung/female.dae/optimized/0/female.dae';
	system.__debugPrint("\n\n\nThis is the msg RepsSender\n\n\n\n");
	system.__debugPrint(msgRespSender.toString());
	
	system.import("gameCreator.em");
	var gC = new std.gameCreator();
	gC.invite(msgRespSender.toString());
	var position = new util.Vec3(-5, -10, 10);
	var msgHandler = {newMesh: meshUrl, newPos: position};
	msgResp.makeReply(msgHandler) >> [];
}
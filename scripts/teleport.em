system.import('std/default.em');

system.print('init');

function respToSender(msgResp, msgRespSender)
{
	system.__debugPrint('sending response...');
	var scriptToSend = 'system.self.guiText = \'\''
	var response = {request: 'script', script: scriptToSend, prompt: 'ctrl u to respond', name: 'apple'};
	msgResp.makeReply(response) >> [];
}

respToSender << [{'portal'::}];

sendTransportInfo << [{'execute': 'true':}];

function sendTransportInfo(msgResp, msgRespSender)
{
	var meshUrl = 'meerkat:///elliotconte/models/Untitled.dae/optimized/0/Untitled.dae';
	var position = new util.Vec3(100, 100, 100);
	var msgHandler = {newMesh: meshUrl, newPos: position};
	msgResp.makeReply(msgHandler) >> [];
}
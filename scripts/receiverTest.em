system.print('init');

function echoOnRespFunc(msgResp, msgRespSender)
{
	//system.print(system.self.toString());
	//var newScript = 'system.print(\'the response was sent\')';
	//var newResp = {request: 'script', script: newScript};
	system.print('sending response...');
	system.print(msgResp.portal);
	var response = {portal: 'sideways'};
	msgResp.makeReply(response) >> [];
}

/*function echoOnRespFunc(msgResp,msgRespSender)
{
      	system.print('Ive sent a response');
	
	msgResp.makeReply(msgResp) >> [echoOnRespFunc, 10, printOnNoRespFunc];
}*/

function printOnNoRespFunc()
{
    system.print('\n\No response\n');
}

echoOnRespFunc << [{'portal'::}];
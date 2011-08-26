var scriptToSend = 'system.__debugPrint(\'I got a script request\')';
var msgHandler = {request: 'script', script: scriptToSend, portal: 'forward'};
//msgHandler >> simulator._selected >> [printOnRespFunc, 10, printOnNoRespFunc];

/*function printOnRespFunc(msgResp,msgRespSender)
{
    system.print(msgResp.action);
}*/


function echoOnRespFunc(msgResp,msgRespSender)
{

	system.print(msgResp.portal);
	var response = {portal: 'backward'};
      msgResp.makeReply(msgHandler) >> [echoOnRespFunc, 10, printOnNoRespFunc];
}

function printOnNoRespFunc()
{
    system.print('\n\No response\n');
}

msgHandler >> simulator._selected >> [echoOnRespFunc,10,printOnNoRespFunc];

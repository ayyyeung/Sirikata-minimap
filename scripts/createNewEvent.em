system.require('eventPortalScript.em');
system.require('test/sirikataBalloonTD.em');
system.require('test/weaponPlaceholder.em');
			
system.require('test/weaponGenerator.em'); 
system.require('test/foeGenerator.em');
system.require('test/defenseTowerGenerator.em');
system.require('test/defenseTowers.em');
system.require('test/levels.em');
system.require('test/vertexGridGenerator-td.em');
system.require('test/gameBoardGenerator.em');
system.require('test/islandGenerator.em');
system.require('test/motion.em');
var scriptToSend = initBD.toString() + "\ninitBD();\n" + initsirikataBalloonTD.toString() + "\n" + initweaponPlaceholder.toString() + "\n" + initweaponGenerator.toString() + "\n" + initfoeGenerator.toString() + "\n" + initdefenseTowerGenerator.toString() + "\n" + initdefenseTowers.toString() + "\n" + initlevels.toString() + "\n" + initvertexGridGeneratortd.toString() + "\n" + initgameBoardGenerator.toString() + "\n" + initislandGenerator.toString() + "\n" + initmotion.toString();

var msgToJoin = {request: 'script', script: scriptToSend};

sendScript <<[{'action': 'touch':}];

function sendScript(msg, sender) {
    msg.makeReply(msgToJoin) >> [];
}
var meshurl = 'meerkat:///elliotconte/models/Untitled.dae/optimized/0/Untitled.dae';



var pos = system.self.getPosition();
pos.x = pos.x - 3;
//system.createPresence(meshurl, callbackNew, pos);
system.createEntityScript(pos, importWrapper, null, 3, meshurl, 2);

function importWrapper() {
	system.import('teleport.em');
}
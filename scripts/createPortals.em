var meshurl = 'meerkat:///dannyatucb/Apple.dae/optimized/0/Apple.dae';


/* first direction portal */

var pos = system.self.getPosition();


pos.x = pos.x - 3;
system.createEntityScript(pos, importWrapper, null, 3, meshurl, 2);
pos.x = pos.x - 3;
pos.y = pos.y + 2;
system.createEntityScript(pos, importWrapper, null, 3, meshurl, 2);
pos.z = pos.z + 3;
system.createEntityScript(pos, importWrapper, null, 3, meshurl, 2);


function importWrapper() {
	system.import('teleport.em');
}


/* Snow land */
function importDefault() {
	system.import('defEntityScript.em');
}
var snowPos = new util.Vec3(100,100,101);
var snowurl = 'meerkat:///wmonroe4/snow_large_em.dae/optimized/0/snow_large_em.dae';

system.createEntityScript(snowPos, importDefault, null, 3, snowurl, 2);



/* back direction portal */

function importWrapper2() {
	system.import('teleport2.em');
}

var pos1 = new util.Vec3(100, 101, 103);
var pos2 = new util.Vec3(90, 110, 100);
var meshurl2 = 'meerkat:///dannyatucb/banana_chiquita.dae/optimized/0/banana_chiquita.dae';

system.createEntityScript(pos1, importWrapper2, null, 3, meshurl2, 2);
system.createEntityScript(pos2, importWrapper2, null, 3, meshurl2, 2);

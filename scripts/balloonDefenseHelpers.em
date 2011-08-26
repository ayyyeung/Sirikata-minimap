var initPosition = system.self.getPosition();
initPosition.x += 5;

function cloneEntity(weaponType) {
	var meshurl = "";
	if (weaponType == "bDTeddy") {
		meshurl = 'meerkat:///kittyvision/teddybear_white.dae/optimized/0/teddybear_white.dae';
	} else if (weaponType == "bDPorcupine") {
		meshurl = 'meerkat:///kittyvision/hedgehog.dae/optimized/0/hedgehog.dae';
	} else if (weaponType == "bDDog") {
		meshurl = 'meerkat:///kittyvision/dog.dae/optimized/0/dog.dae';
	}
	

	system.createEntityScript(initPosition, importWrapper, null, 3, meshurl, 2);
}

function importWrapper() {
	system.import('towerDragHandler.em');
}
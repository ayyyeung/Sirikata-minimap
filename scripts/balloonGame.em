/* Testing the dragging effect for defense towers */


/* Creating the vertex grid */

system.import('test/vertexGridGenerator-standalone.em');

createVertexGrid(5,5,10,function(vertexGrid, space) {
    var street = createStreet(vertexGrid);
    placeStreet(street, space);
		
});
system.self.vertexGrid = vertexGrid;


/* Create tower option entities */

var pos = system.self.getPosition();

pos.x = pos.x - 10;
pos.z = pos.z - 10;

var meshurl = 'meerkat:///kittyvision/teddybear_white.dae/optimized/0/teddybear_white.dae';

system.createEntityScript(pos, importWrapper, null, 3, meshurl, 2);

function importWrapper() {
	system.import('towerDragHandler.em');
}


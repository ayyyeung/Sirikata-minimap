//system.require("test/plantClusterGenerator.em");
//system.require("test/fishFlockGenerator.em");

function createRoadGridSegment(roads, coord, cols, rows) {
	var roadStrips = [];
	for(var col = coord.col; col < coord.col+cols; col++) {
		var roadStrip = [];
		for(var row = coord.row; row < coord.row+rows; row++) {
			roadStrip.push(roads[col][row]);
		}
		roadStrips.push(roadStrip);
	}
	return roadStrips;
}

function divideForest(coord, cols, rows, min, clusters, roads) {
	system.__debugPrint("\ndivideForest called: \n");
	system.__debugPrint("coord: (" + coord.col.toString() + ", " + coord.row.toString() + ")\n");
	system.__debugPrint("cols: " + cols.toString() + " rows: " + rows.toString() + "\n");
	
	if(cols*rows <= min) {
		system.__debugPrint(">> Creating cluster object...\n");
		var cluster = new Object();
		cluster.coord = coord;
		var roadGridSegment = createRoadGridSegment(roads, coord, cols, rows);
		cluster.plantCluster = createPlantCluster(roadGridSegment, cols, rows, Math.random());
		clusters.push(cluster);
		return;
	}
	
	var coord2 = new Object();
	if(rows > cols) {
		coord2.col = coord.col;
		coord2.row = coord.row + Math.floor(Math.random()*(rows-1)) + 1;
		divideForest(coord, cols, coord2.row - coord.row, min, clusters, roads);
		divideForest(coord2, cols, rows + coord.row - coord2.row, min, clusters, roads);
	} else {
		coord2.col = coord.col + Math.floor(Math.random()*(cols-1)) + 1;
		coord2.row = coord.row;
		divideForest(coord, coord2.col - coord.col, rows, min, clusters, roads);
		divideForest(coord2, cols + coord.col - coord2.col, rows, min, clusters, roads);
	}
}

function createForest(roads, cols, rows, min) {
	var clusters = [];
	var initialCoord = new Object();
	initialCoord.col = 0;
	initialCoord.row = 0;
	
	if(roads.length != cols || roads[0].length != rows) roads = blankGrid(cols, rows);
	divideForest(initialCoord, cols, rows, min, clusters, roads);

	system.__debugPrint("\nHave finished dividing forest!\n");
	return clusters;
}

function findCircle(cols, rows, location, space) {
	var circle = new Object();
	var x = location.x + space*cols/2;
	var z = location.z + space*rows/2;
	circle.center = <x,location.y,z>;
	circle.radius = (cols + rows)*space/2;
	circle.depth = 4;
	return circle;
}

function placeForest(clusters, cols, rows, location, space) {
	system.__debugPrint("\nplaceForest has been called!");
	system.__debugPrint("\nThere are " + clusters.length.toString() + " clusters of plants in the forest.\n\n");
	for(var cluster = 0; cluster < clusters.length; cluster++) {
		system.print("\n Displaying clusters["+cluster.toString()+"]...");
		var x = clusters[cluster].coord.col*space + location.x;
		var z = clusters[cluster].coord.row*space + location.z;
		var position = <x, location.y, z>;
		placePlantCluster(clusters[cluster].plantCluster, position, space);
	}
	
	//var circle = findCircle(cols, rows, location, space);
	//createFlock("meerkat:///gabrielle/models/Fish.dae/optimized/0/Fish.dae", 5, circle.center, circle.radius, circle.depth);
}
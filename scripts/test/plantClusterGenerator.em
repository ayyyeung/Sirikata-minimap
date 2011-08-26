system.require("test/treemeshes.em");
system.require("test/flowermeshes.em");
system.require("test/shrubmeshes.em");
system.require("test/rockmeshes.em");

function createPlantCluster(roads, cols, rows, percentTrees) {
	if(roads.length == cols && roads[0].length == rows) var grid = roads;
	else var grid = blankGrid(cols, rows);

	populatePlantCluster(grid, treemeshes, percentTrees, "plant", "tree");
	populatePlantCluster(grid, flowermeshes, 0.5, "grid", "flower");	
	populatePlantCluster(grid, shrubmeshes, 1, "grid", "shrub");

	return grid;
}

/*
 * Initializes a 2d array that contains all false
 */
function blankGrid(nCols, nRows) {
	var cols = [];
	for(var colNum = 0; colNum < nCols; colNum++) {
		var col = [];
		for(var rowNum = 0; rowNum < nRows; rowNum++) {
			col.push(false);
		}
		cols.push(col);
	}
	return cols;
}

function populatePlantCluster(grid, meshes, threshold, elemType, plantType) {
	for(var col = 0; col < grid.length; col++) {
		for(var row = 0; row < grid[col].length; row++) {
			if(grid[col][row] != false) continue;
			
			if(Math.random() < threshold) {			
				if(elemType == "plant") {
					var plant = new Object();
					plant.mesh = meshes[Math.floor(Math.random()*meshes.length)];
					plant.type = plantType;
					grid[col][row] = plant;
					
				} else {
					var smallPlantGrid = new Object();
					smallPlantGrid.grid = blankGrid(2,2);
					populatePlantCluster(smallPlantGrid.grid, meshes, 1, "plant", plantType);
					smallPlantGrid.type = elemType;
					grid[col][row] = smallPlantGrid;
				}
			}
		}
	}
}

function plantFactory(type, col, row, location, space) {
	return function(plant) {
		plant.position = <location.x + col*space, location.y, location.z + row*space>;
		if(type == "tree") plant.scale = 2.5;
	}
}

function placePlantCluster(grid, location, space) {
	system.print("\nplacePlantCluster has been called!");
	for(var col = 0; col < grid.length; col++) {
		for(var row = 0; row < grid[col].length; row++) {
		
			if(grid[col][row] == true) {
				var createRoad = plantFactory("road", col, row, location, space);
				var rockmesh = rockmeshes[Math.floor(Math.random()*rockmeshes.length)];
				system.print("\nUsing rock mesh " + rockmesh);
				system.createPresence(rockmesh, createRoad);
				
			} else if(grid[col][row].type == "grid") {
				var newLocation = <location.x+col*space, location.y, location.z+row*space>;
				placePlantCluster(grid[col][row].grid, newLocation, space/2);
				
			} else {
				var createPlant = plantFactory(grid[col][row].type, col, row, location, space);
				system.createPresence(grid[col][row].mesh, createPlant);
			}
		}
	}
}

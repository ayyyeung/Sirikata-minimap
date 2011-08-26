function initsirikataBalloonTD() {
//system.import("test/vertexGridGenerator-td.em");
//system.import("test/foeGenerator.em");
//system.import("test/gameBoardGenerator.em");
//system.import("test/defenseTowerGenerator.em");
//system.import("test/levels.em");

		
		
		

bdScore = 30;
bdLives = 10;

startRound = function() {
    var startMsg = {'start':true};
    startMsg >> system.self >> [];
}

function numFoes(typeArr) {
    var count = 0;
    for(var d = 0; d < typeArr.length; d++) {
        count += typeArr[d];
    }
    return count;
}

function foesAreGone(arr) {
    for(var f = 0; f < arr.length; f++) {
        if(arr[f].scale > 0) return false;
    }
    return true;
}

createVertexGrid(system.self, 6,6,10,function(controller, vertexGrid, space) {
    system.__debugPrint("\nIn callback for createVertexGrid:");
    var foes = null;
    var nextFoes;
    var round = 0;
    var board = createGameBoard(vertexGrid);
    
    function prepareForNextRound() {
        if(round >= levels.length) {
            nextFoes = null;
        } else {
            system.__debugPrint("\nPreparing for round "+round);
            nextFoes = initFoeGenerator(board, space, levels[round], board.nodes[board.nodes.length-1]);
        }
    }
    
    function startNextRound() {
        if(nextFoes == null) return; // no more rounds
        if(nextFoes.foes.length != numFoes(levels[round])) return; // Hasn't initialized all foes yet
        if(foes != null && !foesAreGone(foes.foes)) return; // Last round hasn't finished yet
        
        system.__debugPrint("\n\nStarting round "+round+"!!");
        round++;
        foes = nextFoes;
        animateFoes(foes, defenseTowerWeapons);
        prepareForNextRound();
    }
    
		placeGameBoard(board, space);
		createDefenseTower("dart",vertexGrid[0][0],space);
		system.__debugPrint("\n\n\n\nThis is the right location!");
		system.__debugPrint(vertexGrid[1][1]);
		system.__debugPrint(space);
		createDefenseTower("tack",vertexGrid[1][1],space);
		prepareForNextRound();
		startNextRound << [{'start'::}];
});

}
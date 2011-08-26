function initvertexGridGeneratortd() {
//system.import("test/islandGenerator.em");
system.require("std/shim/bbox.em");
system.require("std/shim/raytrace.em");

createVertexGrid = function(controller, cols, rows, space, callback) {
    function constructVertexGrid() {
        system.__debugPrint("\nislandPos: <"+islandPos.x+", "+islandPos.y+", "+islandPos.z+">");
        system.__debugPrint("\nislandBB: <"+islandBB.x+", "+islandBB.y+", "+islandBB.z+">\n");
    
        var offset = space*cols*multiplier/4;
        var x = islandPos.x - islandBB.x/2 + offset;
        var y = islandPos.y + islandBB.y/2;
        var z = islandPos.z - islandBB.z/2 + multiplier*offset;
        var anchor = <x,y,z>;
        
        var vertexGrid = [];
        for(var i = 0; i < cols; i++) {
            var col = [];
            for(var j = 0; j < rows; j++) {
                var pos = <anchor.x+space*i,anchor.y,anchor.z+space*j>;
                col.push(pos);
            }
            vertexGrid.push(col);
        }
        callback(controller, vertexGrid, space);
    }

    var multiplier = 4/3;
    var islandPos = <0,0,0>;
    var islandBB = <0,0,0>;
    createIsland(space*cols*multiplier, islandPos, islandBB, constructVertexGrid);
}
}
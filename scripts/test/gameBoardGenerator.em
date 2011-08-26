/*
 * File: streetGenerator.em
 * ----------------------
 * 
 *
 */
function initgameBoardGenerator() {
system.require("std/shim/quaternion.em");
var nodeMap = [];
nodeMap.push({col:0,row:0});
nodeMap.push({col:0,row:1});
nodeMap.push({col:1,row:1});
nodeMap.push({col:1,row:2});
nodeMap.push({col:2,row:2});
nodeMap.push({col:2,row:1});
nodeMap.push({col:3,row:1});
nodeMap.push({col:3,row:2});
nodeMap.push({col:3,row:3});
nodeMap.push({col:2,row:3});
nodeMap.push({col:1,row:3});
nodeMap.push({col:1,row:4});
nodeMap.push({col:2,row:4});
nodeMap.push({col:3,row:4});
nodeMap.push({col:4,row:4});
nodeMap.push({col:4,row:5});
nodeMap.push({col:5,row:5});

/*
 * var node = new pathNode(<0,0,0>);
 * ---------------------------------
 * Constructor for a path node.
 * @param position of the node
 */
function boardNode(position) {
    this.position = position;
    this.edges = [];
}

/*
 * var edge = new pathEdge(startNode, endNode);
 * --------------------------------------------
 * Constructor for a path edge.
 * @param startNode
 * @param endNode
 */
function boardEdge(startNode, endNode) {
    this.rendered = false;
    this.nodes = [startNode, endNode];
    this.types = [];
    
    this.directions = [];
    var x0 = startNode.position.x-endNode.position.x;
    var y0 = startNode.position.y-endNode.position.y;
    var z0 = startNode.position.z-endNode.position.z;
    this.directions.push(<x0,y0,z0>);
    
    var x1 = endNode.position.x-startNode.position.x;
    var y1 = endNode.position.y-startNode.position.y;
    var z1 = endNode.position.z-startNode.position.z;
    this.directions.push(<x1,y1,z1>);
}

createGameBoard = function(vertexGrid) {
    system.__debugPrint("\nIn createStreet...\n");
    var board = {nodes:[],edges:[]};
    
    for(var i = 0; i < nodeMap.length; i++) {
        board.nodes.push(new boardNode(vertexGrid[nodeMap[i].col][nodeMap[i].row]));
    }
    
    var prevNode = null
    var currNode;
    for(var i = 0; i < board.nodes.length; i++) {
        currNode = board.nodes[i];
        if(prevNode == null) prevNode = currNode;
        else {
            var edge = new boardEdge(prevNode, currNode);
            board.edges.push(edge);
            prevNode.edges.push(edge);
            currNode.edges.push(edge);
            prevNode = currNode;
        }
    }
    
    return board;
}

/*
 * var createEdge = edgeFactory(path, i);
 * --------------------------------------
 */
function edgeFactory(board, i, scale) {
    var edge = board.edges[i];
    return function(presence) {
        presence.loadMesh(function() {
            var bb = presence.meshBounds().across();
            var x = (edge.nodes[0].position.x + edge.nodes[1].position.x)/2;
            var y = (edge.nodes[0].position.y + edge.nodes[1].position.y + bb.y)/2;
            var z = (edge.nodes[0].position.z + edge.nodes[1].position.z)/2;
            presence.position = <x,y,z>;
            presence.scale = 30*scale;
            presence.orientation = util.Quaternion.fromLookAt(edge.directions[0]);
        });
    }
}

function nodeFactory(board, i, scale) {
    var node = board.nodes[i];
    return function(presence) {
        presence.loadMesh(function() {
            var bb = presence.meshBounds().across();
            presence.position = node.position + <0, bb.y/2, 0>;
            presence.scale = 7.5*scale;
            presence.orientation = util.Quaternion.fromLookAt(node.edges[0].directions[0]);
        });
    }
}


/*
 * function placePath(path)
 * ------------------------
 * Iterates through the edges and renders each edge in the world
 * @param path is the path graph object
 */
placeGameBoard = function(board, space) {
    for(var i = 0; i < board.edges.length; i++) {
        var displayEdge = edgeFactory(board, i, space/60);
        system.createPresence("meerkat:///kittyvision/street.dae/optimized/0/street.dae",displayEdge);
    }
    
    for(var i = 0; i < board.nodes.length; i++) {
        var displayNode = nodeFactory(board, i, space/60);
        system.createPresence("meerkat:///kittyvision/street/intersection.dae/optimized/0/intersection.dae", displayNode);
    }
}
}

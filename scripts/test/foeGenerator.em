/*
 * File: foeGenerator.em
 * created by G1
 * ---------------------
 * Given a graph object of a street system, lets a car loose on the road.
 * The car obeys appropriate traffic rules specific to a street block.
 * 
 * Usage:
 *      system.import(<streetGenerator.em file here>);
 *      var street = createStreet(<appropriate parameters here>);
 *      system.import(<carGenerator.em file here>);
 *      for(var i = 0; i < <# cars to be created>; i++) createCar(street);
 *
 */

function initfoeGenerator() {
system.require("std/shim/quaternion.em");
system.require("std/movement/units.em");
system.require("std/shim/bbox.em");


var meshForDegree = [];
meshForDegree.push("meerkat:///kittyvision/balloon/blue.dae/optimized/blue.dae");
meshForDegree.push("meerkat:///kittyvision/balloon/green.dae/optimized/green.dae");
meshForDegree.push("meerkat:///kittyvision/balloon/yellow.dae/optimized/yellow.dae");
meshForDegree.push("meerkat:///kittyvision/balloon/red.dae/optimized/red.dae");
meshForDegree.push("meerkat:///kittyvision/balloon/purple.dae/optimized/purple.dae");


/*
 * Given the current edge the car is traveling through and the index of the node
 * the car is traveling towards, selects the next edge and node for the car.
 */
function selectNextEdge(index, edge) {

    // If there is only one edge connected to the node the car is traveling to,
    // then it means that the road is not through. So by returning the current
    // edge as the next edge, the car takes a u-turn.
    if(edge.nodes[index].edges.length == 1) {
        return edge;   
    }
    
    // Else, creates an array of edges radiating from the target node that does not
    // include the current node, so that a new edge can be randomly selected.
    var viableEdges = [];
    for(var i = 0; i < edge.nodes[index].edges.length; i++) {
        if(edge.nodes[index].edges[i] == edge) continue;
        viableEdges.push(edge.nodes[index].edges[i]);
    }
    
    // If there is more than one edge connected to the node, but there are no viable
    // edges other than the current edge, that means the the only other edge is blocked.
    // Thus car makes a u-turn.
    if(viableEdges.length == 0) return edge;
    
    // Otherwise, selects randomly from the viable edges array
    else return viableEdges[Math.floor(Math.random()*viableEdges.length)];
}

/*
 * Given the current target node and the next edge the car will be traveling on,
 * returns the next target node by checking in with the current target node and
 * making sure that it isn't the one that is being returned.
 */
function selectNextIndex(index, currEdge, nextEdge) {
    if(nextEdge.nodes[0] == currEdge.nodes[index]) return 1;
    return 0;
}

function getSpeedMultiplier(degree) {
    switch(degree) {
        case 0: case 1: return 0.3;
        case 2: return 0.4;
        case 3: return 0.5;
        default: return 0.7;
    }
}

/*
 * Given the target node it is driving towards, this function sets the correct
 * velocity and orientation for the car. Then the next target node to travel
 * towards is selected and a recursive call is made so that the car would orient
 * itself correctly after it has finished traveling to the current target node.
 */
function recurseMove(foe, index, edge, lastNode, space) {
    if(foe.scale == 0) foe.disconnect();
    if(foe.mesh.length < 5 || !foe.getIsConnected()) return;
    foe.edge = edge;
    var speed = getSpeedMultiplier(foe.degree)*space;
    var dx = edge.nodes[index].position.x - foe.position.x;
    var dz = edge.nodes[index].position.z - foe.position.z;
    
    var diff = <dx, 0, dz>;
    var vel = diff.scale(speed/diff.length());
    vel = <vel.x, foe.velocity.y, vel.z>;
    foe.velocity = vel;

    var oldEdge = edge;
    var oldIndex = index;
    edge = selectNextEdge(index, edge);
    index = selectNextIndex(index, oldEdge, edge);
    
    system.timeout(diff.length()/vel.length(), function() {
        if(oldEdge.nodes[oldIndex] == lastNode) {
            foe.setScale(0);
            //foe.disconnect();
            system.__debugPrint("\n >> old lives: "+bdLives);
            bdLives--;
            system.__debugPrint("\n >> new lives: "+bdLives);
            return;
        }
        recurseMove(foe, index, edge, lastNode, space);
    });
}

function recurseBounce(foe, vy) {
    if(foe.scale == 0 || foe.mesh.length < 5 || !foe.getIsConnected()) return;
    var x = foe.velocity.x;
    var z = foe.velocity.z;
    foe.velocity = <x,vy,z>;
    system.timeout(Math.random(),function() {
        recurseBounce(foe, -vy);
    });
}

function foeActionFactory(foes, foe, edge, lastNode, scale, weapons, space) {
    return function() { 
        function isWeaponMesh(mesh) {
            system.__debugPrint("\n Trying to determine if prox is a weapon...");
            system.__debugPrint(" >> prox.mesh: "+mesh);
            for(var i = 0; i < weapons.length; i++) {
                if(weapons[i]==mesh) {
                    system.__debugPrint("\n >>>>>>>>>>>> PROX IS WEAPON <<<<<<<<<<<<<");
                    return true;
                    return true;
                }
            }
            system.__debugPrint("\n >> Prox is not weapon!");
            return false;
        }

        function killFoe() {
                system.__debugPrint("\n >> old score: "+system.self.bdScore);
                //system.self.bdScore = system.self.bdScore + foe.degree + 1;
				bdScore = bdScore + foe.degree + 1;
                system.__debugPrint("\n >> new score: "+system.self.bdScore);
                if(foe.degree==0) {
                    foe.setScale(0);
                    return;
                }
                foe.mesh = meshForDegree[foe.degree-1];
                foe.degree = foe.degree - 1;
        }

        function handleCollision(prox) {
            if(isWeaponMesh(prox.mesh)) {
                system.__debugPrint("\n\nFoe has been hit!");
                killFoe();
            }
        }
        
        function handleHit(msg, sender) {
            if(!foe.getIsConnected()) return;
            if(foe.scale == 0) return;
            system.__debugPrint("\n\n------------->This balloon has been hit!\n\n");
            killFoe();
        }
    
        foe.scale = scale;
        recurseBounce(foe, 0.5);
        recurseMove(foe, 1, edge, lastNode, space);
    
        foe.onProxAdded(handleCollision, true);
        foe.setQueryAngle(12);
        handleHit << [{'hit'::}];
        var proxSet = system.getProxSet(foe);
    }
}

animateFoes = function(foeObj, weapons) {
    system.__debugPrint("\nIn animate foes!");
    system.__debugPrint("\nThere are "+foeObj.foes.length+" foes to defeat");
    var foes = foeObj.foes;
    var space = foeObj.space;
    var graph = foeObj.graph;
    var lastNode = foeObj.lastNode;
    
    var timePast = 0;
    var nFoes = foes.length;
    for(var i = 0; i < nFoes; i++) {
        var foe = foes[i];
        var randTime = Math.random()*3;
        var moveFoe = foeActionFactory(foes, foe, graph.edges[0], lastNode, space*0.175, weapons, space);
        system.timeout(timePast+randTime, moveFoe);
        timePast += randTime;
    }
}

/*
 * Given a graph representation of a system of streets to travel on, this function
 * creates a car and lets it loose on the road. A random mesh for the car is picked
 * from the carmeshes array.
 */
createFoe = function(position, space, degree, foes, mesh){
    system.createPresence(mesh, function(presence) {
        presence.loadMesh(function() {
            var bb = presence.untransformedMeshBounds().across();
            presence.degree = degree;
            presence.scale = 0;
            presence.position = position + <0,space*0.02+space*0.2*bb.y/2,0>;
            foes.push(presence);
        });
    });
}

initFoeGenerator = function(graph, space, typeArr, lastNode) {
    if(graph.nodes.length == 0 || graph.edges.length == 0) {
        system.__debugPrint("\nError: street is an empty or malformed graph");
        return;
    }
    var foes = [];
    var position = graph.nodes[0].position;
    for(var i = 0; i < typeArr.length; i++) {
        for(var j = 0; j < typeArr[i]; j++) {
            system.__debugPrint("\nCreating foe of degree "+i);
            createFoe(position, space, i, foes, meshForDegree[i]);
        }
    }
    
    return {graph:graph, space:space, lastNode:lastNode, foes:foes};
}
}
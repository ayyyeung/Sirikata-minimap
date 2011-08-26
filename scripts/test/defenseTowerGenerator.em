function initdefenseTowerGenerator() {
//system.import("test/defenseTowers.em");
//system.import("test/weaponGenerator.em");




createDefenseTower = function(type, anchor, space) {
    system.__debugPrint("\nIn createDefenseTower:");
    system.__debugPrint("\n >> type: "+type+" anchor: "+anchor+" space: "+space);
    var weaponObj;
    
    system.createPresence(defenseTowers[type].mesh, function(presence) {
        var range = defenseTowers[type].range;
        var proxFoes = [];
        
        function proxAdded(prox) {
            if(prox.mesh.indexOf("balloon") != -1) {
                system.__debugPrint("\n-------Adding balloon to "+type+" tower's proxset!");
                proxFoes.push(prox);
            }
        }

        function getFoe() {
            for(var i = 0; i < proxFoes.length; i++) {
                var distance = (proxFoes[i].position-presence.position).length();
                if((distance < range) && (proxFoes[i].scale > 0) && (proxFoes[i].mesh.indexOf("balloon") > -1)) {
                    return proxFoes[i];
                }
            }
            return null;
        }
    
        function attackFoes() {
            if(type=="dart") {
                var foe = getFoe();
                if(foe != null) {
                    var time = (foe.position-presence.position).length()/weaponObj.weaponGroundSpeed;
                    var dx = foe.velocity.x*time;
                    var dz = foe.velocity.z*time;
                    var targetPos = foe.position + <dx,0,dz>;
                    orientation = util.Quaternion.fromLookAt(foe.position-presence.position);
                    var rotation = new util.Quaternion(<0,1,0>, defenseTowers[type].modelOrientation);
                    presence.orientation = rotation.mul(orientation);
                    throwWeapon(weaponObj, presence.position, [targetPos], defenseTowers[type].weaponOrientation);
                }
                
            } else if(type=="tack") {
                if(getFoe() != null) {
                    var targetPosArr = [];
                    var rotation = new util.Quaternion(<0,1,0>, Math.PI*2/defenseTowers[type].weaponNumber);
                    var temp = <defenseTowers[type].range, 0, 0>;
                    for(var i = 0; i < defenseTowers[type].weaponNumber; i++) {
                        targetPosArr.push(temp + presence.position);
                        temp = rotation.mul(temp);
                    }
                    
                    throwWeapon(weaponObj, presence.position, targetPosArr, defenseTowers[type].weaponOrientation);
                }
            }
            
            system.timeout(defenseTowers[type].weaponInterval, attackFoes);
        }
        
        weaponObj = initWeapons(defenseTowers[type].weaponMesh, defenseTowers[type].weaponScale*space, defenseTowers[type].weaponNumber);
        presence.loadMesh(function() {
            var bb = presence.untransformedMeshBounds().across();
            presence.scale = defenseTowers[type].scale*space;
            presence.position = anchor + <space/2,presence.scale*bb.y/2,space/2>;
            
            presence.onProxAdded(proxAdded,true);
            presence.setQueryAngle(0.07);
            attackFoes();
        });
    });
}
}
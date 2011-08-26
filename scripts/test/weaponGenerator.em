function initweaponGenerator() {
system.require("std/shim/quaternion.em");

loadWeapon = function(weaponObj, index, ipos, dir, orientation) {
    var weapon = weaponObj.weapons[index];
    weapon.mesh = weaponObj.weaponMesh;
    weapon.velocity = <0,0,0>;
    weapon.position = ipos;
    weapon.orientation = util.Quaternion.fromLookAt(dir);
    
    var rotation = new util.Quaternion(<0,1,0>, orientation);
    weapon.orientation = rotation.mul(weapon.orientation);
    
    return weapon;
}

throwWeapon = function(weaponObj, towerPos, targetPosArr, orientation) {
    var groundSpeed = weaponObj.weaponGroundSpeed;
    var weapons = weaponObj.weapons;
    if(weapons.length != targetPosArr.length) {
        system.__debugPrint("\n In throwWeapon:");
        system.__debugPrint("\n weapons.length != targetPosArr.length.");
        system.__debugPrint("\n weapons.length is "+weapons.length+", targetPosArr.length is "+targetPosArr.length +". Returning..");
        return;
    }
    
    for(var i = 0; i < weapons.length; i++) {
        var diff = targetPosArr[i] - towerPos;
        diff = diff.scale(0.9);
        var weapon = loadWeapon(weaponObj, i, towerPos, diff, orientation);
        if(weapon == null) return;
        
        var vel = diff.scale(groundSpeed/diff.length());
        vel.y += 0.5*motion.defaultGravity*diff.length()/vel.length();
        weapon.velocity = vel;
        weapon.controller.reset();
        
        system.timeout(diff.length()/groundSpeed, function() {
            weapon.position = weapon.position + <0, -50, 0>;
            weapon.velocity = <0,0,0>;
            weapon.mesh = "";
            weapon.controller.suspend();
        });
        
    }
}

initWeapons = function(mesh, scale, number) {
    var weapons = [];
    for(var i = 0; i < number; i++) {
        system.createPresence(mesh, function(presence) {
            function proxFunc(prox) {
                if(prox.mesh.indexOf("balloon") != -1) {
                   system.__debugPrint("\nWeapon has hit balloon");
                   {'hit':true} >> prox >> [];
                }
            }
            
            presence.scale = scale;
            presence.mesh = "";
            weapons.push(presence);
            presence.controller = new motion.Gravity(presence);
            presence.controller.suspend();
            
            presence.onProxAdded(proxFunc, true);
            presence.setQueryAngle(10);
        });
    }
    return {weapons: weapons, weaponGroundSpeed: 15, weaponMesh: mesh, weaponScale: scale, weaponNumber: number};
}
}
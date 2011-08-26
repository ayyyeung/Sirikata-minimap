function initdefenseTowers() {
defenseTower = function(mesh, scale, orientation, wmesh, wscale, worientation, wnumber, winterval, range) {
    this.mesh = mesh;
    this.scale = scale;
    this.modelOrientation = orientation;
    this.weaponMesh = wmesh;
    this.weaponScale = wscale;
    this.weaponOrientation = worientation;
    this.weaponNumber = wnumber;
    this.weaponInterval = winterval;
    this.range = range;
}

defenseTowers = {};
defenseTowers["dart"] = new defenseTower("meerkat:///kittyvision/teddybear_white.dae/optimized/0/teddybear_white.dae",
                                             0.3, Math.PI, "meerkat:///kittyvision/knife.dae/optimized/knife.dae",
                                             0.125, -0.5*Math.PI, 1, 2, 7); //7
                                             

defenseTowers["tack"] = new defenseTower("meerkat:///kittyvision/hedgehog.dae/optimized/hedgehog.dae",
                                             0.3, 0.5*Math.PI, "meerkat:///kittyvision/pencil_eraser_yellow.dae/optimized/pencil_eraser_yellow.dae",
                                             0.13, 1.5*Math.PI, 6, 5, 6); //6
                                             
                                             
defenseTowerWeapons = [];
for(key in defenseTowers) {
    defenseTowerWeapons.push(defenseTowers[key].weaponMesh);
}

system.__debugPrint("\n-----------The Weapons------------");
for(weaponmesh in defenseTowerWeapons) {
    system.__debugPrint("\nweaponmesh: "+defenseTowerWeapons[weaponmesh]);
}
}
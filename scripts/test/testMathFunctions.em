

system.print("\n\n********Testing math functions now.*******\n\n");

system.print("Test abs\n");
var x = util.abs(-3);
system.print("Should be -3: " + x.toString() + "\n\n");


system.print("Test power\n");
x = util.pow(2,2);
system.print("Should be 4: " + x.toString() + "\n");
x = util.pow(2,5);
system.print("Should be 32: " + x.toString() + "\n");
x = util.pow(3,.5);
system.print("Should be 1.732...: " + x.toString() + "\n");
x = util.pow(5.5,5.5);
system.print("Should be 11803.06...: " + x.toString() + "\n");




{

    // NOTE: These are just for documentation

  /** @class A visible represents some other presence, probably on
   *  another object host, that exists (or existed) in the
   *  space. Visibles track basic information like position,
   *  orientation, and mesh and also allow you to communicate with the
   *  other presence. You don't construct visibles directly: usually
   *  they are the result of a proximity query or are passed to you by
   *  other presences.
   */
  var visible = function()
  {
      /**
       @param Vec3.
       @return Number.

       @description Returns the distance from this visible object to the position
       specified by first argument vector.
       */
      visible.prototype.dist =  function()
      {
      };

      /**
       @return A string corresponding to the URI for your current mesh.  Can pass
       this uri to setMesh functions on your own presences, but cannot set mesh
       directly on a visible.
       */
      visible.prototype.getMesh = function(){
      };

      /** 
       @return An array of strings, where each string is the name of an animation that
       is supported by this visible's mesh.
      */
      visible.prototype.getAnimationList = function(){}



      /**
       @return Vec3 associated with the position of this visible object.

       @description Note: the returned value may be stale if the visible object is far away from you.
       */
      visible.prototype.getPosition = function(){
      };



      /** Returns all data associated with this visible for serialization.
       *  @private
       *  @return Object containing all data associated with this visible.  Fields or returned object: {string} sporef, {vec3} pos, {vec3} vel, {quaternion} orient, {quaternion} orientVel, {number} scale, {string} mesh, {string} posTime, {string} orientTime,
       */
      visible.prototype.getAllData = function()
      {
      };

      /**
       @return Number associated with the velocity at which this visible object is travelling.

       @description Note: the returned value may be stale if the visible object is far away from you.
       */
      visible.prototype.getVelocity = function(){
      };


      /** @function
       @return Returns the identifier for the space that the visible is in.
       @type String
       */
      visible.prototype.getSpaceID = function(){};

      /** @function
       @return Returns the identifier for the visible in the space that it's in.
       @type String
       */
      visible.prototype.getVisibleID = function(){};


      /**
       @return Quaternion associated with visible object's orientation.

       @description Note: the returned value may be stale if the visible object is far away from you.
       */
      visible.prototype.getOrientation = function(){
      };

      /**
       @return Angular velocity of visible object (rad/s).

       @description Note: the returned value may be stale if the visible object is far away from you.
       */
      visible.prototype.getOrientationVel = function (){
      };



      /**
       @return Number associated with how large the visible object is compared to the
       mesh it came from.
       */
      visible.prototype.getScale = function(){
      };

      /** Get a string representation of this visible -- a
       *  combination of the space and object identifiers which
       *  uniquely identify it.
       *  @returns {string} a unique string identifier for this
       *  visible.
       */
      visible.prototype.toString = function() {};


      /**
       @return Boolean.  If true, positions and velocities for this visible object
       are automatically being updated by the system.
       */
      visible.prototype.getStillVisible = function(){
      };

      /**
       @param Visible object.
       @return Returns true if the visible objects correspond to the same presence
       in the virtual world.
       */
      visible.prototype.checkEqual = function(){
      };
  };

}

// These are the real wrappers
(function() {

     // Hide visible but let rest of method override behavior.
     var visible = system.__visible_constructor__;
     // NOTE: Currently disabled so we can use it in raytrace
     // delete system.__visible_constructor__;

     Object.defineProperty(visible.prototype, "position",
                           {
                               get: function() { return this.getPosition(); },
                               enumerable: true
                           }
                          );

     Object.defineProperty(visible.prototype, "velocity",
                           {
                               get: function() { return this.getVelocity(); },
                               enumerable: true
                           }
                          );

     Object.defineProperty(visible.prototype, "orientation",
                           {
                               get: function() { return this.getOrientation(); },
                               enumerable: true
                           }
                          );


     Object.defineProperty(visible.prototype, "orientationVel",
                           {
                               get: function() { return this.getOrientationVel(); },
                               enumerable: true
                           }
                          );


     Object.defineProperty(visible.prototype, "scale",
                           {
                               get: function() { return this.getScale(); },
                               enumerable: true
                           }
                          );


     Object.defineProperty(visible.prototype, "mesh",
                           {
                               get: function() { return this.getMesh(); },
                               enumerable: true
                           }
                          );



      var decodePhysics = function(phy) {
          if (phy.length == 0) return {};
          return JSON.parse(phy);
      };

     Object.defineProperty(visible.prototype, "physics",
                           {
                               get: function() { return decodePhysics(this.getPhysics()); },
                               enumerable: true
                           }
                          );

     visible.prototype.__origLoadMesh = visible.prototype.loadMesh;
     visible.prototype.loadMesh = function(cb) {
         system.__loadVisibleMesh(this, cb);
     };
     var __origMeshBounds = visible.prototype.meshBounds;
     var __origUntransformedMeshBounds = visible.prototype.untransformedMeshBounds;
     var decodeBBox = function(raw) {
         return new util.BBox(raw[0], raw[1]);
     };
     visible.prototype.meshBounds = function() {
         return decodeBBox(__origMeshBounds.apply(this));
     };
     visible.prototype.untransformedMeshBounds = function() {
         return decodeBBox(__origUntransformedMeshBounds.apply(this));
     };

     // The basic raytrace is in *completely untransformed* mesh space, meaning
     // not even the translate/rotate/scale of the presence/visible is
     // included. Wrappers provide those types of raytracing.
     var __origRaytrace = visible.prototype.raytrace;
     visible.prototype.__raytrace = function(start, dir) {
         return __origRaytrace.apply(this, arguments);
     };


     visible.prototype.__prettyPrintFieldsData__ = [
         "position", "velocity",
         "orientation", "orientationVel",
         "scale", "mesh", "physics"
     ];
     visible.prototype.__prettyPrintFields__ = function() {
         return this.__prettyPrintFieldsData__;
     };

     /** @function
      @return {string} type of this object ("visible");
      */
     visible.prototype.__getType = function()
     {
         return  'visible';
     };


})();

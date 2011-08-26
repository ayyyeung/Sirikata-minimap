/*  Sirikata
 *  quaternion.em
 *
 *  Copyright (c) 2011, Ewen Cheslack-Postava
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *  * Neither the name of Sirikata nor the names of its contributors may
 *    be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


/* Quaternion should be assumed to only have .x, .y, .z, and .w. */


/** @constant
 *  Identity quaternion representing no rotation.
 */
util.Quaternion.identity = <0, 0, 0, 1>;

/** Make a copy of this quaternion.
 *  @returns a copy of this Quaternion.
 */
util.Quaternion.prototype.clone = function() {
    return < this.x, this.y, this.z, this.w>;
};

/** @function
@return quaternion sum of the two quaternions*/
util.Quaternion.prototype.add = function(rhs) {
    return <this.x + rhs.x, this.y + rhs.y, this.z + rhs.z, this.w + rhs.w>;
};

/** @function
 @return {string} type of this object ("quat");
 */
util.Quaternion.prototype.__getType = function()
{
    return 'quat';
};

/** @function 
@return quaternion difference of the two quaternions
*/
util.Quaternion.prototype.sub = function(rhs) {
    return <this.x - rhs.x, this.y - rhs.y, this.z - rhs.z, this.w - rhs.w>;
};

/** 
  @function
  @return Returns the negation of the quaternion
*/
util.Quaternion.prototype.neg = function() {
    return <-this.x, -this.y, -this.z, -this.w>;
};

/**
  @function
  @return Dot product of the two quaternions
*/

util.Quaternion.prototype.dot = function(rhs) {
    return this.x * rhs.x + this.y * rhs.y + this.z * rhs.z + this.w * rhs.w;
};


/**
 @param rhs any type
 @return {bool} True if rhs is not a quaternion and x,y,z,and w fields
 of this and rhs are identical.  False otherwise.
 */
util.Quaternion.prototype.equal = function(rhs){
    if (rhs == null)
        return false;

    
    return ((this.x === rhs.x) && (this.y === rhs.y) && (this.z === rhs.z) && (this.w === rhs.w));
};


/**
  @function
  @return The quaternion product of two quaternions
*/
util.Quaternion.prototype.mul = function(rhs) {
    if (typeof(rhs) === "number") // scalar
        return this.scale(rhs);
    else if (
        typeof(rhs.x) === 'number' &&
            typeof(rhs.y) === 'number' &&
            typeof(rhs.z) === 'number')
    {
        if (typeof(rhs.w) === 'number') {
            // Quaternion
            return <
                this.w*rhs.x + this.x*rhs.w + this.y*rhs.z - this.z*rhs.y,
                this.w*rhs.y + this.y*rhs.w + this.z*rhs.x - this.x*rhs.z,
                this.w*rhs.z + this.z*rhs.w + this.x*rhs.y - this.y*rhs.x,
                this.w*rhs.w - this.x*rhs.x - this.y*rhs.y - this.z*rhs.z
            >;
        }
        else { // Vec3
            var quat_axis = new util.Vec3(this.x, this.y, this.z);
            var uv = quat_axis.cross(rhs);
            var uuv= quat_axis.cross(uv);
            uv = uv.scale(2.0 * this.w);
            uuv = uuv.scale(2.0);
            return rhs.add(uv).add(uuv);
        }
    }
    else
        throw new TypeError('Quaternion.mul parameter must be numeric, Vec3, or Quaternion.');
};

/** @function 
  @param scalar by which to scale
  @return A quaternion scaled by the scalar parameter
*/
util.Quaternion.prototype.scale = function(rhs) {
    return <this.x*rhs, this.y*rhs, this.z*rhs, this.w*rhs>;
};

/**
  @function
  @return The length of the quaternion  
*/
util.Quaternion.prototype.length = function() {
    return util.sqrt( this.dot(this) );
};

/**
  @function
  @return the length-squared of the quaternion
*/
util.Quaternion.prototype.lengthSquared = function() {
    return this.dot(this);
};

/**
  @function
  @return The quaternion normal to this quaternion
*/
util.Quaternion.prototype.normal = function() {
    var len = this.length();
    if (len>1e-08)
        return this.scale(1.0/len);
    return this;
};

/**
  @function
  @return The inverse of this quaternion
*/
util.Quaternion.prototype.inverse = function() {
    var len = this.lengthSquared();
    if (len>1e-8)
        return <-this.x/len,-this.y/len,-this.z/len,this.w/len>;
    return <0.0, 0.0, 0.0, 0.0>;
};
util.Quaternion.prototype.inv = util.Quaternion.prototype.inverse;

/**
  @function
  @return true if the quaternion is (near) zero/identity, i.e. that it represents no rotation, false otherwise
*/
util.Quaternion.prototype.isZero = function() {
    return (this.x*this.x+this.y*this.y+this.z*this.z < 1e-08);
};

/**
@function
@return The x-axis of the quaternion as a Vec3
*/
util.Quaternion.prototype.xAxis = function() {
    var fTy  = 2.0*this.y;
    var fTz  = 2.0*this.z;
    var fTwy = fTy*this.w;
    var fTwz = fTz*this.w;
    var fTxy = fTy*this.x;
    var fTxz = fTz*this.x;
    var fTyy = fTy*this.y;
    var fTzz = fTz*this.z;

    return new util.Vec3(1.0-(fTyy+fTzz), fTxy+fTwz, fTxz-fTwy);
};

/**
  @function
  @return The y-axis of the quaternion as a Vec3
*/
util.Quaternion.prototype.yAxis = function() {
    var fTx  = 2.0*this.x;
    var fTy  = 2.0*this.y;
    var fTz  = 2.0*this.z;
    var fTwx = fTx*this.w;
    var fTwz = fTz*this.w;
    var fTxx = fTx*this.x;
    var fTxy = fTy*this.x;
    var fTyz = fTz*this.y;
    var fTzz = fTz*this.z;

    return new util.Vec3(fTxy-fTwz, 1.0-(fTxx+fTzz), fTyz+fTwx);
};

/**
  @function
  @return The z-axis of the quaternion as a Vec3
*/
util.Quaternion.prototype.zAxis = function() {
    var fTx  = 2.0*this.x;
    var fTy  = 2.0*this.y;
    var fTz  = 2.0*this.z;
    var fTwx = fTx*this.w;
    var fTwy = fTy*this.w;
    var fTxx = fTx*this.x;
    var fTxz = fTz*this.x;
    var fTyy = fTy*this.y;
    var fTyz = fTz*this.y;
    return new util.Vec3(fTxz+fTwy, fTyz-fTwx, 1.0-(fTxx+fTyy));
};

/**
  @function
  @return The axis of rotation represented by this quaternion.
*/
util.Quaternion.prototype.axis = function() {
    var axis = new util.Vec3(this.x, this.y, this.z);
    axis = axis.normal();
    return axis;
};

/**
  @function
  @return The angle of rotation represented by this quaternion.
*/
util.Quaternion.prototype.angle = function() {
    var quat = this.normal();
    return 2 * Math.acos(quat.w);
};

/**
  @function
  @param direction Vector that represents direction to look at.
  @param up Up direction of the quaternion.
  @return A quaternion constructed so that the -z axis (lookat direction) points
          in the same direction as the direction vector, with the up vector
          as close as possible to the given up vector.
*/
util.Quaternion.fromLookAt = function(direction, up) {
    up = up || <0, 1, 0>;
    
    if (direction.lengthSquared() < 1e-08)
        return <0, 0, 0, 1>;
    direction = direction.normal();

    // Orient the -z axis to be along direction.
    var defaultForward = <0, 0, -1>;
    var quatAxis = defaultForward.cross(direction);
	if(quatAxis.lengthSquared() > 0.001 || direction.dot(defaultForward) > 0) {
        // defaultForward and direction are either not colinear, or are colinear
        // but are pointing in the same direction.
		var firstQuat = <quatAxis.x, quatAxis.y, quatAxis.z,
											1 + direction.dot(defaultForward)>;
	} else {
        // defaultForward and direction are pointing in opposite directions.
		var firstQuat = <0, 1, 0; Math.PI>;
	}
    firstQuat = firstQuat.normal();

    // Compute new up vector and orient the y axis to be along that direction.
    var secondQuat;
    var left = direction.cross(up);
    var newUp = left.cross(direction);
    if (newUp.lengthSquared() > 0.001) {
        newUp = newUp.normal();
        var yAxis = firstQuat.yAxis();
        var quatAxis = yAxis.cross(newUp);
        if (quatAxis.lengthSquared() > 0.01 || yAxis.dot(newUp) > 0) {
            secondQuat = <quatAxis.x, quatAxis.y, quatAxis.z,
                                             1 + yAxis.dot(newUp)>;
        } else {
            secondQuat = <direction; Math.PI>;
        }
    } else {
        secondQuat = <0, 0, 0, 1>;
    }
    secondQuat = secondQuat.normal();

    return secondQuat.mul(firstQuat);
}


util.Quaternion.prototype.__prettyPrintFieldsData__ = ["x", "y", "z", "w"];
util.Quaternion.prototype.__prettyPrintFields__ = function() {
    return this.__prettyPrintFieldsData__;
};

function initmotion() {
/* motion.em
 *
 * An object motion controller library
 *
 * Author: Will Monroe
 *
 * Defines a set of classes that continuously monitor a presence's state and
 * change its position or velocity when necessary.  To assign a motion
 * controller to a presence, simply create a controller with the presence as
 * the first parameter to the constructor:
 *		var controller = new motion.SomeType(presence, options...);
 */

system.require('std/core/repeatingTimer.em');
system.require('std/core/pretty.em');

if(typeof(motion) === 'undefined')
	motion = {};
if(typeof(motion.util) === 'undefined')
	motion.util = {};

motion.util._default = function(arg, defaultVal) {
	if(typeof(arg) === 'undefined')
		return defaultVal;
	else
		return arg;
}

/**
 * Motion controllers operate on repeating timers.  The last (optional)
 * argument to every class of controller specifies the repeat period at
 * which the timer operates; assigning longer periods means less network
 * traffic but a slower update rate.  defaultPeriod is the period for all
 * controllers whose last argument is not given.
 * @constant
 */
motion.defaultPeriod = 0.06;


/**
 * @class Base class for all motion controllers.  This sets up the basic
 * repeating timer code, with a callback specified by base classes.  Generally
 * intended as an abstract base class, but could be useful on its own with a
 * specialized callback.  The core methods available for all controllers are
 * also defined here.
 *
 * @param presence The presence to control.  This may be changed later by
 *		assigning to <code>controller.presence</code>.
 * @param fn The callback function to call repeatedly, with a presence as a
 * @param period (optional =defaultPeriod) The period at which the callback is
 *		called
 */
motion.Motion = system.Class.extend({
	init: function(presence, fn, period) {
		if(typeof(period) === 'undefined')
			period = motion.defaultPeriod;

		var self = this; // so callbacks can refer to instance variables
		
		self.period = period;
		self.presence = presence;
		self.timer = new std.core.RepeatingTimer(self.period, function() {
			fn(self.presence);
		});
	},
	
	/**
	 * Pauses the operation of the controller.  The controller can be resumed
	 * at any time by calling <code>reset</code>.
	 */
	suspend: function() {
		this.timer.suspend();
	},
	
	/**
	 * Restarts the controller, resuming if suspended.
	 */
	reset: function() {
		this.timer.reset();
	},
	
	/**
	 * @return <code>true</code> if the controller is currently suspended,
	 *		<code>false</code> otherwise.
	 */
	isSuspended: function () {
		return this.timer.isSuspended();
	}
});

/**
 * @class A controller for applying accelerations to an object.
 *
 * @param presence The presence to control
 * @param accelFn A function that should return the acceleration on a
 *		presence at any point in time
 * @param period (optional =defaultPeriod) The period at which the
 *		acceleration is updated
 */
motion.Acceleration = motion.Motion.extend({
	init: function(presence, accelFn, period) {
		var self = this;
		var callback = function(p) {
			p.velocity = p.velocity + accelFn(p).scale(self.period);
		};
		this._super(presence, callback, period);
	}
});

/**
 * @class A controller for manipulating the velocity of a presence.
 */
motion.Velocity = motion.Motion.extend({
	init: function(presence, velFn, period) {
		var callback = function(p) {
			p.velocity = velFn(p);
		};
		this._super(presence, callback, period);
	}
});

/**
 * @class A controller for manipulating the position of a presence directly.
 * Note that if this is used for constant updates, the position changes will
 * appear abrupt and jittery -- this type of controller is best used for
 * sudden, infrequent changes (such as teleportation).
 *
 * @param presence The presence to control
 * @param posFn A function that should return the new position of an object
 * 		at any point in time
 * @param period (optional =defaultPeriod) The period at which the object's position is
 *		updated
 */
motion.Position = motion.Motion.extend({
	init: function(presence, posFn, period) {
		var callback = function(p) {
			p.position = posFn(p);
		};
		this._super(presence, callback, period);
	}
});

/**
 * The default acceleration of an object under a Gravity controller.
 * @constant
 */
motion.defaultGravity = 9.80665;

/**
 * Accelerates a presence downward under a constant gravitational force.
 *
 * @param presence The presence to accelerate
 * @param accel (optional =<0, -defaultGravity, 0>) The acceleration of
 *		gravity (as either a scalar quantity or a vector).  This may be
 *		changed later through <code>controller.accel</code>, but only as a
 *		vector.
 * @param period (optional =defaultPerid) The period at which the presence's
 *		velocity is updated
 */
motion.Gravity = motion.Acceleration.extend({
	init: function(presence, accel, period) {
		var self = this;
		
		if(typeof(accel) === 'number')
			self.accel = <0, -accel, 0>;
		else
			self.accel = motion.util._default(accel,
					<0, -motion.defaultGravity, 0>);
		
		this._super(presence, function() { return self.accel; }, period);
	}
});

/**
 * Accelerates a presence under a harmonic spring force.
 *
 * @param presence The presence to control
 * @param anchor The anchor point around which the presence oscillates.  This
 *		can be a vector (point in space) or another presence or visible (which
 * 		will be examined as its position changes).  It can be changed later 
 *		through <code>controller.anchor</code>.
 * @param stiffness The stiffness or "spring constant" of the spring force --
 *		the greater the stiffness, the greater the force at the same distance
 * @param damping (optional =0) The damping or "friction" of the spring motion
 * @param eqLength (optional =0) The equilibrium length of the spring; if
 *		positive, the presence will be accelerated *away* from the anchor
 *		point if it gets too close
 * @param period (optional =defaultPeriod) The period at which the presence's
 *		velocity is updated
 */
motion.Spring = motion.Acceleration.extend({
	init: function(presence, anchor, stiffness, damping, eqLength, period) {
		var self = this;
		
		self.stiffness = stiffness;
		self.eqLength = motion.util._default(eqLength, 0);
		self.damping = motion.util._default(damping, 0);
		
		self.anchor = anchor;
		var anchorFn;
		if(typeof(self.anchor) === 'object' && 'x' in self.anchor)
			anchorFn = function() {	return self.anchor; };
		else if(typeof(anchor) === 'object' && 'position' in self.anchor)
			anchorFn = function() { return self.anchor.position; };
		else
			throw("Second argument 'anchor' to motion.Spring constructor ('" +
					std.core.pretty(anchor) +
					"') is not a vector or presence");
		
		var accelFn = function(p) {
			var mass = ('mass' in p ? p.mass : 1);
		
			var disp = (p.position - anchorFn());
			var len = disp.length();
			if(len < 1e-08)
				// even if eqLength is nonzero, we don't know which way to push
				// the object if it's directly on top of the anchor.
				return <0, 0, 0>;
			
			return disp.scale((self.stiffness * (self.eqLength - len) -
					self.damping * p.velocity.dot(disp)) / (len * mass));
		};
		
		this._super(presence, accelFn, period);
	}
});

/**
 * The default number of collisions the Collision controller attempts to
 * detect before giving up.  After a collision, the Collision controller will
 * call the response function and check for collisions again.  This could
 * result in an infinite loop if a presence is tightly confined, so the
 * controller requires a limit to the number of iterations through which this
 * loop is sustained.
 * @constant
 */
motion.defaultMaxCollisions = 4;

/**
 * @class A generic controller to detect and respond to collisions.
 * 		All arguments except <code>period</code> can be modified later through
 *		fields of the same name (e.g. controller.testFn).
 *
 * @param presence The presence whose collisions are to be detected (the
 *		"colliding presence")
 * @param testFn A function that should detect any collisions when called
 *		repeatedly and return one in the form of a "collision object"
 * @param responseFn A function to be called when a collision happens; should
 *		return true to request further collision detection or false to stop.
 * @param maxCollisions (optional =defaultMaxCollisions) The number of
 *		successive collisions to detect for each tick of the repeating timer
 * @param period (optional =defaultPeriod) The period at which to check for
 *		collisions
 *
 * @see collision.em
 */
motion.Collision = motion.Motion.extend({
	init: function(presence, testFn, responseFn, maxCollisions, period) {
		var self = this;
		
		self.testFn = testFn;
		self.responseFn = responseFn;
		self.maxCollisions = motion.util._default(maxCollisions, 
				motion.defaultMaxCollisions);
		
		var testCollision = function(p) {
			for(var collNum = 0; collNum < self.maxCollisions; collNum++)
			{
				var collision = self.testFn(p);
				if(!collision || !self.responseFn(collision)) {
					break;
				}
			}
		};
		
		this._super(presence, testCollision, period);
	}
});
}


/*  Sirikata
 *  movable.em
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

if (typeof(std) === "undefined") std = {};
if (typeof(std.movement) === "undefined") /** @namespace*/ std.movement = {};

system.require('std/core/bind.em');
system.require('std/movement/movement.em');

(
function() {

    var ns = std.movement;

    /** @namespace
     *  A Movable listens for requests from other objects to move and
     *  applies them to itself. This allows objects to control each
     *  other, e.g. for a client to move objects in the world.
     *
     *  An optional parameter, only_self, allows you to restrict
     *  requests to only yourself. This is useful to let you unify
     *  controls via this interface (for others and yourself), but not
     *  expose this interface to others -- for example on your own
     *  avatar.
     */
    std.movement.Movable = function(only_self) {
        var moveRequestHandler = std.core.bind(this._handleRequest, this, only_self);
        moveRequestHandler << [{"request"::}];

        // Set up a bunch of handlers based on request name so we can
        // easily dispatch them
        this._handlers = {
            stop : std.core.bind(this._handleStop, this),
            position : std.core.bind(this._handleSetPos, this),
            velocity : std.core.bind(this._handleSetVel, this),
            orient : std.core.bind(this._handleSetRot, this),
            orientvel : std.core.bind(this._handleSetRotVel, this),
            scale : std.core.bind(this._handleSetScale, this),
            physics : std.core.bind(this._handleSetPhysics, this),
            mesh : std.core.bind(this._handleSetMesh, this)
        };
    };

    std.movement.Movable.prototype._handleRequest = function(only_self, msg, sender) {
        if (only_self && !sender.checkEqual(system.self))
            return;

        var handled = false;
        for(var f in msg) {
            var handler = this._handlers[f];
            if (handler) {
                handler(msg, sender);
                handled = true;
            }
        }
        if (handled) msg.makeReply({}) >> [];
    };

    std.movement.Movable.prototype._handleStop = function(msg, sender) {
        std.movement.stopMove(system.self);
        std.movement.stopRotate(system.self);
        system.self.physics = { treatment : 'ignore' };
    };

    std.movement.Movable.prototype._handleSetPos = function(msg, sender) {
        std.movement.position(system.self, msg.position);
    };

    std.movement.Movable.prototype._handleSetVel = function(msg, sender) {
        std.movement.move(system.self, msg.velocity);
    };

    std.movement.Movable.prototype._handleSetRot = function(msg, sender) {
        std.movement.orientation(system.self, msg.orient);
    };

    std.movement.Movable.prototype._handleSetRotVel = function(msg, sender) {
        std.movement.rotate(system.self, msg.orientvel);
    };

    std.movement.Movable.prototype._handleSetScale = function(msg, sender) {
        std.movement.scaleTo(system.self, msg.scale);
    };

    std.movement.Movable.prototype._handleSetPhysics = function(msg, sender) {
        system.self.physics = msg.physics;
    };

    std.movement.Movable.prototype._handleSetMesh = function(msg, sender) {
        system.self.mesh = msg.mesh;
    };

})();

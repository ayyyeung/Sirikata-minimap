/*  Sirikata
 *  move.em
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

system.require('std/movement/movableremote.em');
system.require('std/graphics/drag/handler.em');
system.require('std/graphics/axes.em');

/** @namespace
    MoveDragHandler responds to drag events by moving a selected object.
 */
std.graphics.MoveDragHandler = std.graphics.DragHandler.extend(
    {
        /** @memberOf std.graphics.MoveDragHandler */
        init: function(gfx) {
            this._super(gfx);
        },

        /** @memberOf std.graphics.MoveDragHandler */
        selected: function(obj, hitpoint, evt) {
            if (obj) {
                this._obj = obj;
                this._dragging = new std.movement.MovableRemote(obj);
                this._dragPoint = hitpoint;
            }
            else {
                this._obj = null;
                this._dragging = null;
                this._dragPoint = null;
            }
            this._localConstraints = null;
            this._globalConstraints = null;
        },

        /** @memberOf std.graphics.MoveDragHandler */
        onMouseDrag: function(evt) {
            if (!this._dragging) return;

            if (!this._dragging.dragPosition) {
                this._dragging.dragPosition = this._dragging.getPosition();
                this._startPosition = this._dragging.dragPosition;
            }

            var centerAxis = this._graphics.cameraDirection();
            var clickAxis = this._graphics.cameraDirection(evt.x, evt.y);

            var lastClickAxis = this._lastClickAxis;
            this._lastClickAxis = clickAxis;

            if (!lastClickAxis) return;

            var moveVector = this._dragPoint.sub( this._graphics.cameraPosition() );
            var moveDistance = moveVector.dot(centerAxis);
            var start = lastClickAxis.scale(moveDistance);
            var end = clickAxis.scale(moveDistance);
            var toMove = end.sub(start);
            moveDistance = toMove.length();
            
          
            if (this._localConstraints === null) {
                this._localConstraints = [];
                this._globalConstraints = [];
                if (!std.graphics.axes.getAxes(this._obj)) {
                    std.graphics.axes.setVisibleAll(this._obj, true);
                }
                var axes = std.graphics.axes.getAxes(this._obj);
                var state = axes.state();
                var inheritOrient = axes.inheritOrient();
                for (var i = 0; i < 3; i++) {
                    if (!state[i]) {
                        if (inheritOrient[i]) {
                            for (var j = 0; j < 3; j++) {
                                if (j === i) {
                                    this._localConstraints.push(0);
                                } else {
                                    this._localConstraints.push(1);
                                }
                            }
                        } else {
                            for (var j = 0; j < 3; j++) {
                                if (j === i) {
                                    this._globalConstraints.push(0);
                                } else {
                                    this._globalConstraints.push(1);
                                }
                            }
                        }
                    }
                }
            }
            
            if (this._localConstraints.length > 2) {
                toMove = this._obj.orientation.inverse().mul(toMove);
                for (var i = 0; i < this._localConstraints.length - 2; i += 3) {
                    toMove = <toMove.x * this._localConstraints[i],
                              toMove.y * this._localConstraints[i+1],
                              toMove.z * this._localConstraints[i+2]>;
                }
                toMove = this._obj.orientation.mul(toMove);
            }
            
            if (this._globalConstraints.length > 2) {
                for (var i = 0; i < this._globalConstraints.length - 2; i += 3) {
                    toMove = <toMove.x * this._globalConstraints[i],
                              toMove.y * this._globalConstraints[i+1],
                              toMove.z * this._globalConstraints[i+2]>;
                }
            }
            
            toMove = toMove.normal().scale(moveDistance);

            this._dragging.dragPosition = this._dragging.dragPosition.add(toMove);
            this._dragPoint = this._dragPoint.add(toMove);
            this._dragging.setPosition(this._dragging.dragPosition);
        },

        /** @memberOf std.graphics.MoveDragHandler */
        onMouseRelease: function(evt) {
            if (this._dragging) {
                if (this._startPosition && 'addUndoAction' in this._graphics) {
                    this._graphics.addUndoAction({
                        movable: this._dragging,
                        start: this._startPosition,
                        end: this._dragging.getPosition()
                    }, this);
                }
                this._dragging.dragPosition = null;
            }
            this._lastClickAxis = null;
            this._localConstraints = null;
            this._globalConstraints = null;
        },

        undo: function(action) {
            action.movable.setPosition(action.start);
        },

        redo: function(action) {
            action.movable.setPosition(action.end);
        }
    }
);

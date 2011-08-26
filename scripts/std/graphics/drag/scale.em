/*  Sirikata
 *  scale.em
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

/** @namespace 
  ScaleDragHandler responds to drag events by scaling the selected object.
 */
std.graphics.ScaleDragHandler = std.graphics.DragHandler.extend(
    {
        /** @memberOf std.graphics.ScaleDragHandler */
        init: function(gfx) {
            this._super(gfx);
        },

        /** @memberOf std.graphics.ScaleDragHandler */
        selected: function(obj) {
            this._dragging = obj ?
                new std.movement.MovableRemote(obj) : null;
        },

        /** @memberOf std.graphics.ScaleDragHandler */
        onMouseDrag: function(evt) {
            if (!this._dragging) return;

            if (!this._dragging.dragScale) {
                this._dragging.dragScale = this._dragging.getScale();
                this._startScale = this._dragging.dragScale;
            }

            var cameraAxis = this._graphics.cameraDirection();

            var sensitivity = 5.0;
            var scale_amt = util.exp( sensitivity * evt.dy);
            this._dragging.setScale( scale_amt * this._dragging.dragScale );
        },

        /** @memberOf std.graphics.ScaleDragHandler */
        onMouseRelease: function(evt) {
            if (this._dragging) {
                if (this._startScale && 'addUndoAction' in this._graphics) {
                    this._graphics.addUndoAction({
                        movable: this._dragging,
                        start: this._startScale,
                        end: this._dragging.getScale()
                    }, this);
                }
                this._startScale = null;
                this._dragging.dragScale = null;
            }

            this._lastClickAxis = null;
        },

        undo: function(action) {
            action.movable.setScale(action.start);
        },

        redo: function(action) {
            action.movable.setScale(action.end);
        }
    }
);

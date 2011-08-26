/*  Sirikata
 *  graphics.em
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

system.require('std/escape.em');

if (typeof(std) === "undefined") std = {};
if (typeof(std.graphics) === "undefined") std.graphics = {};

(
function() {

    var ns = std.graphics;

    /** @namespace
     *  The GUI class wraps the underlying GUI Invokable
     *  objects. These present 2D user interface widgets to the user,
     *  which are coded as HTML + Javascript pages.
     *
     *  The callback is passed this GUI as a parameter.
     */
    std.graphics.GUI = function(name, me, onready) {
        this._name = name;
        this._gui = me;
        if (onready)
            this.bind('__ready', std.core.bind(onready, undefined, this));
    };

    var dispatchBindCallback = function(cb) {
        // Any additional arguments after cb are arguments. They're JSON encoded, so we need to decode before passing them along.
        var args = [];
        for(var i = 1; i < arguments.length; i++) {
            var parsed = JSON.parse(arguments[i]);
            args.push(parsed);
        }

        cb.apply(undefined, args);
    };

    /** Bind a listener for events from this GUI. */
    std.graphics.GUI.prototype.bind = function(type, cb) {
        this._gui.invoke("bind", this._name + '-' + type, std.core.bind(dispatchBindCallback, undefined, cb));
    };

    /** Evaluate the Javascript string inside the GUI context. */
    std.graphics.GUI.prototype.guiEval = function(js) {
        this._gui.invoke("eval", js);
    };

    var getGUIJSValue = function(arg) {
        if (typeof(arg) === 'string')
            return Escape.escapeString(arg, '"');
        else if (typeof(arg) === 'undefined' ||
                 (typeof(arg) === 'object' && arg === null) ||
                 typeof(arg) === 'number' ||
                 typeof(arg) === 'boolean')
            return arg.toString();
        else if (typeof(arg) === 'object' && typeof(arg.__var) === 'string' )
            return arg.__var; // Variables, see GUI.variable
        else {
            // Non-trivial type. Try to JSONify it.
            try {
                var arg_json = JSON.stringify(arg);
                // And wrap in decoding call
                return 'JSON.parse(' + Escape.escapeString(arg_json) + ')';
            } catch (x) {
                throw new TypeError("Invalid object type passed to GUI.call. Must be basic type (undefined, null, boolean, number, string) or JSON-encodable.");
            }
        }
    };

    /** Create an object which can be used to specify a variable name
     *  to GUI.call and GUI.set. Since strings are converted to string
     *  literals, it isn't possible to specify variable names in these
     *  calls without this method.
     *
     *  @param {string} name the name of the variable
     *  @returns {object} a placeholder object which gets converted to
     *  the variable name when passed to GUI.call or GUI.set.
     */
    std.graphics.GUI.prototype.variable = function(name) {
        // Just a special object, see getGUIJSValue for how it is used.
        return {
            '__var' : name
        };
    };

    /** Call a method in the GUI context. This is just a convenience
     *  wrapper around eval which will build the string to eval
     *  automatically from the method arguments.
     *
     *  Example:
     *   var x = 7;
     *   var st = 'hello "Bob"';
     *   gui.call('myfunc', x, st);
     *  is equivalent to
     *   gui.guiEval( "myfunc(7, 'hello \"Bob\"');" );
     */
    std.graphics.GUI.prototype.call = function() {
        if (arguments.length < 1) return;
        var methodname = arguments[0];

        var ev_str = methodname + '(';

        for(var i = 1; i < arguments.length; i++) {
            if (i > 1) ev_str += ', ';

            var arg = arguments[i];
            ev_str += getGUIJSValue(arg);
        }

        ev_str += ')';

        this.guiEval(ev_str);
    };

    /** Set the value of a variable in the GUI context. This is just a
     *  convenience wrapper around eval which will build the string to
     *  eval automatically from the arguments.
     *
     *  Example:
     *   gui.set('myvar', 17)
     *  is equivalent to
     *   gui.eval('var myvar = 17;');
     *
     */
    std.graphics.GUI.prototype.set = function(varname, value) {
        var ev_str = varname + ' = ' + getGUIJSValue(value) + ';';
        this.guiEval(ev_str);
    };

    /** Hides the GUI window. */
    std.graphics.GUI.prototype.hide = function() {
        this._gui.invoke("hide");
    };

    /** Shows the GUI window. */
    std.graphics.GUI.prototype.show = function() {
        this._gui.invoke("show");
    };

    /** Shows the GUI window. */
    std.graphics.GUI.prototype.focus = function() {
        this._gui.invoke("focus");
    };

    /** Bind a listener for exception events. Listener should have the form fn(message, file, linenum). */
    std.graphics.GUI.prototype.onException = function(cb) {
        this._gui.invoke("onException", cb);
    };
})();

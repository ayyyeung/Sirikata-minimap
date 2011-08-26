/*  Sirikata
 *  scripter.em
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

system.require('std/core/bind.em');
system.require('std/core/pretty.em');

if (typeof(std) === "undefined") std = {};
if (typeof(std.script) === "undefined") std.script = {};

(
function() {

    var ns = std.script;

    /** A Scripter is an object which will display a scripting window
     *  for operating on other objects.
     */
    ns.Scripter = function(parent, init_cb) {
        this._parent = parent;
        this._scriptedObjects = {};

	try {
            this._parent._simulator.addGUIModule(
                "Scripter", "scripting/prompt.js",
                std.core.bind(function(scripting_gui) {
                    scripting_gui.bind("event", std.core.bind(this._handleScriptEvent, this));
                    scripting_gui.onException( function(msg, file, line) { system.print('Scripting GUI Exception: ' + msg + ' at ' + file + ':' + line); } );
                    this._scriptingWindow = scripting_gui;
                    //this._scriptingWindow.hide();
                    if (init_cb) init_cb();
                }, this));
        } catch (ex) {
	    system.print(ex);
        }
        // Listen for replies
        var scriptReplyPattern = new util.Pattern("reply", "script");
        var scriptReplyHandler = std.core.bind(this._handleScriptReply, this);
        scriptReplyHandler << scriptReplyPattern;

        // Listen for print events
        var printPattern = new util.Pattern("request", "print");
        var printHandler = std.core.bind(this._handlePrint, this);
        printHandler << printPattern;
    };

    ns.Scripter.prototype.onReset = function(reset_cb) {
        this._parent._simulator.addGUIModule(
            "Scripter", "scripting/prompt.js",
            std.core.bind(function(scripting_gui) {
                              if (reset_cb) reset_cb();
                          }, this));
    };

    ns.Scripter.prototype.script = function(target) {
        if (!target) return;

        this._scriptingWindow.call('Scripter.addObject', target.toString());
        //this._scriptingWindow.show();
        system.timeout(.1, std.core.bind(this._scriptingWindow.focus, this._scriptingWindow));
        this._scriptedObjects[target.toString()] = target;
    };

    ns.Scripter.prototype._handleScriptEvent = function(evt, objid, val) {
        if (evt == 'Close') {
            system.print('Close\n'); // FIXME
        }
        else if (evt == 'ExecScript') {
            // ExecScript Command Value
            var target = this._scriptedObjects[objid];
            if (!target) {
                system.prettyprint('Received ExecScript UI event for unknown object:' + objid);
                return;
            }

            var request = {
                request : 'script',
                script : val
            };

            request >> target >> [ std.core.bind(this._handleScriptReply, this) ];
        }
    };

    ns.Scripter.prototype._handleScriptReply = function(msg, sender) {
        // We potentially get two reply messages, but we might need to
        // actually use either one of them (if the Scriptable only
        // supports old messages, we *must* use the old message,
        // otherwise we should use the new message). We prefer using
        // the new messages, and can safely ignore the old messages if
        // they contain a deprecated field, since that means the new
        // version of the reply should also arrive.
        if (msg.deprecated) return;

        var win = this._scriptingWindow;

        if (msg.value !== undefined)
            win.call('Scripter.addMessage', sender.toString(), std.core.pretty(msg.value));
        if (msg.exception !== undefined)
            win.call('Scripter.addMessage', sender.toString(), 'Exception: ' + std.core.pretty(msg.exception));
    };

    ns.Scripter.prototype._handlePrint = function(msg, sender) {
        var win = this._scriptingWindow;

        if (msg.print) {
            var to_print = msg.print;
            win.call('Scripter.addMessage', sender.toString(), std.core.pretty(to_print));
        }
    };

})();

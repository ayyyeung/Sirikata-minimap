/*  Sirikata
 *  miniMap.em
 *
 *  Copyright (c) 2011, Stanford University
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


/** The SetMesh class allows the user to change the mesh of any presence in the world or create a new presence 
 * with a chosen mesh.  The list of meshes automatically adds any meshes added to open3dhub.com.
 */

system.require('std/core/repeatingTimer.em');

std.graphics.MiniMap = system.Class.extend(
    {
        init: function(sim, init_cb) {
            this._sim = sim;

            this._selected = undefined;
		


            this._sim.addGUIModule(
                "MiniMap", 'scripting/miniMap.js',
                std.core.bind(function(miniMap_gui) {
                                  this._ui = miniMap_gui;
                                  this._ui.bind("mmQuerySurrounding", std.core.bind(this.handleInitPresences, this));
                                  this._ui.bind("mmTeleport", std.core.bind(this.handleTeleport, this));
                                  this._ui.bind("mmCreateEvent", std.core.bind(this.handleCreateEvent, this));
                              	  this._ui.bind("mmJoinEvent", std.core.bind(this.handleJoinEvent, this));
                              	  this._ui.bind("mmCreateBoundary", std.core.bind(this.handleCreateBoundary, this));
                              	  this._ui.bind("mmTouchBoundary", std.core.bind(this.handleTouchBoundary, this));
                              	  this._ui.bind("printAlert", std.core.bind(this.printAlert, this));
                              	  this.mmAutoUpateTimer;
								  this.mmMapTypeTimer;
								  this.mmBlacklist;
                              	  if (init_cb) init_cb();
				}, this)
            );
        },

        onReset : function(reset_cb) {
            this._sim.addGUIModule(
                "MiniMap", "scripting/miniMap.js",
                std.core.bind(function(chat_gui) {
                                  if (reset_cb) reset_cb();
                              }, this));
        },

        toggle: function() {
		this._ui.call('MiniMap.toggleVisible');
        },
	
	        
        handleInitPresences : function() {
			this.mmBlacklist = new Array();
            this.mmAutoUpdateTimer = new std.core.RepeatingTimer(0.8, autoUpdateCallback);
			this.mmMapTypeTimer = new std.core.RepeatingTimer(5, mapTypeTimerCallback);
            this.handleSurrounding();
            var miniMap_gui = this._ui;
			var blacklist = this.mmBlacklist;
            function autoUpdateCallback() {
                var presArray = new Array();
		        var obj = system.getProxSet(system.self);
		        for (var s in obj) {
			        if (blacklist.indexOf(obj[s].toString()) == -1) {
						presArray.push([((obj[s].getPosition()).x), ((obj[s].getPosition()).y), ((obj[s].getPosition()).z), obj[s].mesh, obj[s].toString()]); 
					} else {

					}
				}
				miniMap_gui.call('MiniMap.createPresMarkers', presArray);    
            }
			
			function mapTypeTimerCallback() {
				var queryForSpecialType = {'map': 'myMapName'};
				var obj = system.getProxSet(system.self);
				for (var s in obj) {
					queryForSpecialType >> obj[s] >> [onEventResponse];
			    }
				function onEventResponse(msg, msgSender) {
					
					if (blacklist.indexOf(msgSender.toString()) == -1) {
						var specialTypeArray = new Array();	
						blacklist.push(msgSender.toString());
						
						/* Determine what 'special type' message was received */
						
						if (msg.mapType == 'event') {
						    specialTypeArray.push([((msgSender.getPosition()).x), ((msgSender.getPosition()).y), ((msgSender.getPosition()).z), msgSender.mesh, msgSender.toString()]); 
						    miniMap_gui.call('MiniMap.createEventMarkers', specialTypeArray);
						} else if (msg.mapType == 'bound') {
						    var containedPresenceList = msg.containedPresences.split(',');
						    for (var i = 0; i < containedPresenceList.length; i++) {
						        blacklist.push(containedPresenceList[i]);
						    }
						    specialTypeArray.push([((msgSender.getPosition()).x), ((msgSender.getPosition()).y), ((msgSender.getPosition()).z), msgSender.mesh, msgSender.toString(), msg.radius, msg.regionName]); 
						    miniMap_gui.call('MiniMap.createBoundMarkers', specialTypeArray, containedPresenceList);
						}
					}
				}
			}
        },

	handleSurrounding: function() {

		var presArray = new Array();
		var obj = system.getProxSet(system.self);
		for (var s in obj)
			presArray.push([((obj[s].getPosition()).x), ((obj[s].getPosition()).y), ((obj[s].getPosition()).z), obj[s].mesh, obj[s].toString(), obj[s].mapType]);
		this._ui.call('MiniMap.createPresMarkers', presArray);
	},
	
	handleTeleport: function(x, y, z) {
	    var xPos = parseInt(x);
	    var yPos = parseInt(y);
	    var zPos = parseInt(z);
	    system.self.setPosition(<xPos, yPos, zPos>);
	},
	
	handleCreateEvent: function(eventInfoObj) {
	    var eventPos = <parseInt(eventInfoObj.xPos), parseInt(eventInfoObj.yPos), parseInt(eventInfoObj.zPos)>;
	    var meshurl = 'meerkat:///dannyatucb/Apple.dae/optimized/0/Apple.dae';
	    var scriptObj = {'script': eventInfoObj.script};
	    system.createEntityScript(eventPos, initWrapper, scriptObj, 3, meshurl, 2);
	    
	    function initWrapper(scriptToLoad) {
	        system.import(scriptToLoad.script);
	        system.__debugPrint('\ncreateing intity');
	        system.onPresenceConnected(onPresCb);
	        function onPresCb(pres) {
				sendEventInfo << [{'map'::}];
				function sendEventInfo(msg, msgSender) {
					var response = {'mapType': 'event'};
					msg.makeReply(response) >> [];
				}
	        }
	    }
	},
	
	handleJoinEvent: function(spaceID) {
	    var msg = {action: 'touch'};
	    msg >> system.createVisible(spaceID) >> [];
	},
	
	handleCreateBoundary: function(boundInfoObj, containedPresences) {
	    var boundPos = <parseInt(boundInfoObj.xPos), parseInt(boundInfoObj.yPos), parseInt(boundInfoObj.zPos)>;
	    var meshurl = 'meerkat:///dannyatucb/Apple.dae/optimized/0/Apple.dae';
	    var infoObj = {'radius': boundInfoObj.radius, 
	        'containedPresences': containedPresences.toString(),
	        'regionName': boundInfoObj.regionName
	    };
	    system.createEntityScript(boundPos, initWrapper, infoObj, 3, meshurl, 2);
	    function initWrapper(infoObj) {
	        system.onPresenceConnected(onPresCb);
	        function onPresCb(pres) {
	            var containedPresences = containedPresences;
	            sendBoundInfo << [{'map'::}];
	            sendContainedPresences << [{'action': 'touch':}];
	            function sendContainedPresences(msg, msgSender) {
	                var response = {'containedPresences': infoObj.containedPresences};
	                msg.makeReply(response) >> [];
	            }
	            
	            function sendBoundInfo(msg, msgSender) {
	                var response = {'mapType': 'bound', 
	                    'radius': infoObj.radius,
	                    'containedPresences': infoObj.containedPresences,
	                    'regionName': infoObj.regionName
	                    
	                };
	                msg.makeReply(response) >> [];
	            }
	        }
	    }
	},
	
	handleTouchBoundary: function(spaceID) {
	    var msg = {action: 'touch'};
	    msg >> system.createVisible(spaceID) >> [trackContainedPresences];
	    var miniMap_gui = this._ui;
	    function trackContainedPresences(returned, msgSender) {
	        miniMap_gui.call('MiniMap.displayListInfo', returned.containedPresences.split(','));
	    }
	},
	
	printAlert: function(string) {
	    system.__debugPrint("\n************************************\n");
	    system.__debugPrint(string);
	    system.__debugPrint("\n*************************************\n");
	}
	

/**************************************************************************************/        
    }
);

/* 
 **********************************************************************
 * TODO:
 * Use OpenLayers filter to make clustered markers reappear at high zoom levels
 * Improve the sidebar content seen when a boundary or event is selected
 * Query angle adjustments for sensing stuff further away
 **********************************************************************
 */


sirikata.ui(
    "MiniMap",
    function() {


MiniMap = {}; // External interface
var window; // Our UI window
var $dialog;


        /**** Variables ******************************/
        var markers;
        var presences;
        var boundaries;
        
            var drawPolygon;
            var dragPolygon;
            var currentBoundaryOutline;
        
        var map;
        var existingPresMarkers = [];
        var existingEventMarkers = [];
        var existingBoundMarkers = [];
        var currentDisplayedInfo;
        var indexSelected = 0;


/* Function: toggleVisible
 *************************
 * toggles the visibility of the gui window
 */
var toggleVisible = function() {
    window.toggle();
    toggleInfoPanel(0);
    
};
MiniMap.toggleVisible = toggleVisible;

/* Function: createPresMarkers
 *****************************
 * creates markers on the presence layer by matching the meshurl with the corresponding source
 * image
 * presArray[][0] is x-position
 * presArray[][1] is y-position
 * presArray[][2] is z-position
 * presArray[][3] is meshUrl
 * presArray[][4] is spaceID
 */
 var createPresMarkers = function(presArray) {
            for (var i = 0; i < presArray.length; i++) {
                var uniqueString = presArray[i][0] + presArray[i][1] + presArray[i][2] + presArray[i][3] + presArray[i][4]; //NOTE MESHURL USED possible bug if xyz position is in a special case
                 iconUrl = findPresenceImage(presArray[i][3]);
                    presenceInfoObj = {'xPos': presArray[i][0], 
                        'yPos': presArray[i][1],
                        'zPos': presArray[i][2],
                        'iconUrl': iconUrl,
                        'spaceID': presArray[i][4],
                        'uniqueString': uniqueString
                    }
                var existing = 0;
                
                    for (var s = 0; s < existingPresMarkers.length; s++) {
                        if (existingPresMarkers[s].attributes.spaceID.indexOf(presArray[i][4]) >= 0) {
                            if (existingPresMarkers[s].attributes.uniqueString != uniqueString) {
                                tBFunc(presenceInfoObj, s);
                            } else {
                                existing = 1;
                            }
                            break;
                        }
                    }
                    if (existing == 0) {
                        addPresMarker(presenceInfoObj);
                    }

           } 
           presences.redraw();  
 
 };
 MiniMap.createPresMarkers = createPresMarkers;
 
 /* Function: createEventMarkers
  ******************************
  * Stores info for new event markers, checks if they're already existing (just being updated) or new.  Removes the presence
  * from the regular presence array
  */
  var createEventMarkers = function(eventArray) {
    for (var i = 0; i < eventArray.length; i++) {
    
    
        var uniqueString = eventArray[i][0] + eventArray[i][1] + eventArray[i][2] + eventArray[i][3] + eventArray[i][4]; 
            iconUrl = findPresenceImage(eventArray[i][3]);
            presenceInfoObj = {'xPos': eventArray[i][0], 
                'yPos': eventArray[i][1],
                'zPos': eventArray[i][2],
                'iconUrl': iconUrl,
                'spaceID': eventArray[i][4],
                'uniqueString': uniqueString
            }
       var existing = 0;
       for (var s = 0; s < existingEventMarkers.length; s++) {
            if (existingEventMarkers[s].attributes.spaceID.indexOf(eventArray[i][4]) >= 0) {
                existingEventMarkers[s].destroy();
                existingEventMarkers.splice(s, 1);
                existing = 1;
                break;
            }
       }
       if (existing == 0) {
           /* DELETE FROM PRESENCE ARRAY */
            for (var j = existingPresMarkers.length - 1; j >= 0; j--) {
                if (existingPresMarkers[j].attributes.spaceID.indexOf(eventArray[i][4]) >= 0) {
                tBFunc(presenceInfoObj, j);
                break;
                }        
            }
       }
       addMarker(presenceInfoObj);
    }
    markers.redraw();
  };
  MiniMap.createEventMarkers = createEventMarkers;
  
 /* Function: createBoundMarkers
  ******************************
  * stores info for boundary polygons, deletes all involved presences from the regular presence array.
  * boundArray[i][5] is the radius
  * boundArray[i][6] is the regionName
  */
  var createBoundMarkers = function(boundArray, containedPresences) {
    for (var i = 0; i < boundArray.length; i++) {
    
        var uniqueString = boundArray[i][0] + boundArray[0][1] + boundArray[0][2] + boundArray[0][3] + boundArray[0][4]; //make more specific??
        iconUrl = findPresenceImage(boundArray[i][3]);
        presenceInfoObj = {'xPos': boundArray[i][0],
            'yPos': boundArray[i][1],
            'zPos': boundArray[i][2],
            'iconUrl': iconUrl,
            'spaceID': boundArray[i][4],
            'uniqueString': uniqueString,
            'radius': boundArray[i][5],
            'regionName': boundArray[i][6]
        }
        var existing = 0;
        for (var s = 0; s < existingBoundMarkers.length; s++) {
            if (existingBoundMarkers[s].attributes.spaceID.indexOf(boundArray[i][4]) >= 0) {
                existingBoundMarkers[s].destroy();
                existingBoundMarkers.splice(s, 1);
                existing = 1;
                break;
            }
        }
        if (existing == 0) {
           /* DELETE FROM PRESENCE ARRAY */
            for (var j = existingPresMarkers.length - 1; j >= 0; j--) {
                if (existingPresMarkers[j].attributes.spaceID.indexOf(boundArray[i][4]) >= 0) {
                    tBFunc(presenceInfoObj, j);
                    break;
                }        
            }
            /* ALSO DELETE PRESENCE LIST CONTENTS FROM PRESENCE ARRAY */
            for (var k = 0; k < containedPresences.length; k++) {
                for (var m = 0; m < existingPresMarkers.length; m++) {
                    if (existingPresMarkers[m].attributes.spaceID.indexOf(containedPresences[k]) >= 0) {
                        tBFunc(presenceInfoObj, m); //FIX : we dont actually need presenceinfoobj for this.
                        break;
                    }
                }
            }
            
            
       }
       addBoundMarker(presenceInfoObj);
    }
    boundaries.redraw();
  };
  MiniMap.createBoundMarkers = createBoundMarkers;
  
  /* Function: displayListInfo
   ***************************
   * displays sidebar info for boundary presences (a list of all presences in the boundary)
   */
   var displayListInfo = function(containedPresences) {
    sirikata.log('fatal', containedPresences.toString());
   };
   MiniMap.displayListInfo = displayListInfo;


/*******************************************************************************/


/*******************************************************************************/
      
      /* Elements on window */
       $('<div id="mini-map" title="Map">'  +

      
        '<div id="mm-map-panel">' + 
            '<div style="position: absolute; left: 10px; top: 10px;" id="mouseLocation"><div id="mouseLocLon">Lon</div>' + '<div id="mouseLocLat">Lat</div>' + '</div>' +
            '<div style="position: absolute; left: 10px; top: 40px; width: 330px; height: 330px;" id="map_box"><script src="../scripting/OpenLayers.js"></script></div>' + 
            '<div style="position: absolute; left: 10px; top: 370px;" id="layerswitcher"></div>' +
            '<div style="position: absolute; left: 100px; top: 100px;"><button id="query">Search for map</button></div>' +
            '<div style="position: absolute; left: 360px; top: 410px;"><button id="register">Register new event</button></div>' +
            '<div style="position: absolute; left: 200px; top: 410px;"><button id="new-boundary">Register new boundary</button></div>' +
            //'<div style="position: absolute; left: 400px; top: 590px;"><button id="showPresences">Show Presences</button></div>' +
        '</div>' + 
        
        '<div id="mm-info-panel" style="position: absolute; left: 360px; width: 190px; height: 400px; border: 3px solid black"><h1 class="ui-widget-header">Info</h1><br/>' +
            '<div id="displayPresenceInfo">' + 
                '<div id="mmPresenceID">Presence ID</div></br>' +
                '<img style="width: 130px" src=""></img></br>' +
                '<button id="mmTeleport">Teleport</button>' +
            '</div>' + //end displayPresenceInfo
            
            /* Register New Event html */
         '<div id="register-event">' +
		    '<div id="mmRegStepOne">' +
		        '<form><fieldset>' +
                    '<legend>Event Information</legend>' +
                    'Location: <br/><input value="x-position" id="mmRegPosLat" type="text" size="10" />' +
                    '<br/><input value="z-position" id="mmRegPosLon" type="text" size="10" /><br />' +
                    'Description: <pre><textarea id="mmRegDescription"></textarea></pre><br />' +                    
                '</fieldset></form>' + 
                '<button id="mmRegNext">Next</button>' + 
            '</div>' /* end mmRegStepOne */ + 
                
            '<div id="mmRegStepTwo">' + 
                '<form><fieldset>' +
                    '<legend>Portal Setup</legend>' +
                    'Script to load: <pre><textarea id="mmRegScript"></textarea></pre><br />' +        
                '</fieldset></form>' + 
                '<button id="mmRegSave">Save</button>' +
            '</div>' /* end mmReggStepTwo */ +                 
          '</div>' /* end register-event */ +
          
          /* Register New Boundary html */
          '<div id="register-boundary">' +
            '<form><fieldset>' +
                '<legend>Boundary Information</legend>' +
                'Draw the desired boundary on the map.' +
                '<br/>Boundary name: <input value="" id="mmRegBoundName" type="text" size="10" /><br />' +
                'Description: <pre><textarea id="mmRegBoundDescription"></textarea></pre><br />' +
            '</fieldset></form>' +
            '<button id="mmRegBoundSave">Save</button>' + '<button id="mmRegBoundCancel">Cancel</button>' +
          '</div>' /*end register-boundary */ +
            
            
        '</div>' +//end mm-info-panel
      
        '</div>'/*end mini-map*/).appendTo('body');
		

       
       window = new sirikata.ui.window( 
        "#mini-map",        
           {
               autoOpen: false,
               width: 570,
               height: 510,
               modal: false
           }
        )
        
        /* Function: toggleInfoPanel
         ***************************
         * Adjusts which divs of the info panel are showing
         */
        function toggleInfoPanel(setting) {
            if (setting == 0) { //default
                $('#displayPresenceInfo').show();
                $('#register-event').hide();
                $('#register-boundary').hide();
                $('#new-boundary').show();
                $('#register').show();
            } else if (setting == 1) { //first step of event registration
                $('#displayPresenceInfo').hide();
                $('#register-event').show();
                $('#mmRegStepOne').show();
                $('#mmRegStepTwo').hide();
                $('#register').hide();
                $('#new-boundary').hide();
            } else if (setting == 2) { //second step of event registration
                $('#mmRegStepTwo').show();
                $('#mmRegStepOne').hide();
                $('#register').hide();
                $('#new-boundary').hide();
            } else if (setting == 3) { //boundary registration
                $('#displayPresenceInfo').hide();
                $('#register-boundary').show();
                $('#register').hide();
                $('#new-boundary').hide();      
            }         
        }

        
        
        /* left panel map buttons */
        sirikata.ui.button('#query').button().click(initMap);
        sirikata.ui.button('#register').button().click(registerNewEvent);
        sirikata.ui.button('#new-boundary').button().click(registerNewBoundary);
        
        
        /* right panel buttons */
        sirikata.ui.button('#mmTeleport').button().click(teleportToPresence);
        
        /* $dialog buttons */
        sirikata.ui.button('#mmRegNext').button().click(mmRegNextFunc);//completeRegister);
        sirikata.ui.button('#mmRegSave').button().click(mmRegSaveFunc);
        sirikata.ui.button('#mmRegBoundSave').button().click(mmRegBoundSaveFunc);
        sirikata.ui.button('#mmRegBoundCancel').button().click(mmRegBoundCancelFunc);
        
             
        
        /* For displaying presence icons */
        var allMeshes = [];
        var nextStart = '';      

/*********************************************************/
/************ Map Operation Functions ********************/
/*********************************************************/
        
        /* Function: initMap
         *******************
         * Initializes the OpenLayers map with controls and base layer. Initializes the overlays.
         */
        function initMap() {
            $('#query').hide();
            map = new OpenLayers.Map("map_box", {
            controls: [
                new OpenLayers.Control.Navigation(),
                new OpenLayers.Control.PanZoomBar(),
                new OpenLayers.Control.LayerSwitcher(),
                new OpenLayers.Control.MousePosition()
                ]
            });
            
            var osmrail = new OpenLayers.Layer.XYZ("Sirikata map",
            "http://images.kaneva.com/filestore9/5172405/6374413/lightUblue.jpg", 
               {
                    sphericalMercator: true,
                    minResolution: 0.1
                }
            );
	       map.addLayer(osmrail);

	       displayCurrCenter(0,0);


/**********************************************************************************************/
/*************************** INITIALIZE LAYERS ************************************************/
/**********************************************************************************************/
	
	       markers = new OpenLayers.Layer.Vector( "Markers" , {
	        styleMap: new OpenLayers.StyleMap({
	            "default": new OpenLayers.Style({
	                externalGraphic: 'http://www.openlayers.org/dev/img/marker-green.png',
	                graphicWidth: 21,
	                graphicHeight: 24
	            }),
	            "select": new OpenLayers.Style({
	                externalGraphic: "http://www.openlayers.org/dev/img/marker.png"
	            })
	        })
	       });
	       map.addLayer(markers);
           markers.id = "Markers";
           
           markers.events.on({
                "featureselected": function(e) {
                    displaySidebarInfo(e.feature, 0);
                },
                "featureunselected": function(e) {
                }
           });
           
           
           presences = new OpenLayers.Layer.Vector( "Presences" , {
            styleMap: new OpenLayers.StyleMap({
                "default": new OpenLayers.Style({
                    externalGraphic: "${thisIcon}",
                    graphicWidth: 24,
                    graphicHeight: 24
                }),
                "select": new OpenLayers.Style({
                    externalGraphic: "http://freetransform.net/wp-content/uploads/2007/10/star.jpg"
                })
            })      
           });
           map.addLayer(presences);
           presences.id = "Presences";
           
           
           presences.events.on({
            "featureselected": function(e) {
                displaySidebarInfo(e.feature, 1);
            },
            "featureunselected": function(e) {
            }
           });
           
           boundaries = new OpenLayers.Layer.Vector( "Boundaries" , {
	        styleMap: new OpenLayers.StyleMap({
	            "default": new OpenLayers.Style({
	                label: "${getLabel}",
	                strokeColor: "#800000",
                    strokeOpacity: 1,
                    strokeWidth: 2,
                    fillColor: "${getFillColor}",
                    fillOpacity: 0.7
	            }, {context: {
	                getLabel: function(feature) {
	                    if (map.getZoom() > 12) {
	                        return feature.attributes.regionName;
	                    } else return "";
	                }, //end getLabel function 
	                getFillColor: function(feature) {
	                    if (feature.attributes.color == "") {
	                        var randomNum = Math.random();
	                        if (randomNum < .25) {
	                            feature.attributes.color = "#FF0000";
	                        } else if (randomNum < .5) {
	                            feature.attributes.color = "#00FFFF";
	                        } else if (randomNum < .75) {
	                            feature.attributes.color = "#FFA500";
	                        } else {
	                            feature.attributes.color = "#008000";
	                        }
	                    }
	                    return feature.attributes.color;
	                }
	               } //end context object
	            }),
	            "select": new OpenLayers.Style({
	                strokeColor: "#000080",
                    strokeOpacity: 1,
                    strokeWidth: 2,
                    fillColor: "#0000FF",
                    fillOpacity: 0.7
	            }),
	            "temporary": new OpenLayers.Style({
	                strokeColor: "##800000",
                    strokeOpacity: 1,
                    strokeWidth: 2,
                    fillColor: "#FF0000",
                    label: "",
                    fillOpacity: 0.7
	            })
	        })
	       });
           map.addLayer(boundaries);
           boundaries.id = "Boundaries";
           drawPolygon = new OpenLayers.Control.DrawFeature(boundaries, OpenLayers.Handler.Polygon, {handlerOptions: {freehand: true}, eventListeners: {"featureadded": finishDrawingPolygon}});
           dragPolygon = new OpenLayers.Control.DragFeature(boundaries);
           map.addControl(drawPolygon);
           map.addControl(dragPolygon);

           
           
           boundaries.events.on({
            "featureselected": function(e) {
                displaySidebarInfo(e.feature, 2);
                sirikata.event('printAlert', 'feature selected');
            },
            "featureunselected": function(e) {
                sirikata.event('printAlert', 'boundary unselected');
            }
           });
           
           
           var selectControl = new OpenLayers.Control.SelectFeature([presences, markers, boundaries]);
           map.addControl(selectControl);
           selectControl.activate();
           


         map.events.register("click", map, function(e) {
                var temp = $('#mmRegPosLon').val();
                var position = map.getLonLatFromPixel(e.xy);
                $('#mouseLocLon').text("Lon: " + position.lon);
                $('#mouseLocLat').text("Lat: " + position.lat);
                
                //update register
                $('#mmRegPosLon').val(position.lon);
                $('#mmRegPosLat').val(position.lat);


         });
         
         
        getSourceUrls();
	    initPresenceLayer();  
	        
      } //end initMap();
      
      /* Function: finishDrawingPolygon
       ********************************
       */
       function finishDrawingPolygon(event) {
        drawPolygon.deactivate();
        currentBoundaryOutline = event.feature;
       }
      
      /* Function: newBoundaryAdded 
       ****************************
       * After user defines a new boundary on the map,  this function calls a function in emerson to
       * create a presence associated with the boundary so that other maps will receive the same information
       */
       function newBoundaryAdded() {
            var center = currentBoundaryOutline.geometry.getCentroid(); 
            var containedPresences = new Array();
            var radius = 0;
            
            /* FIX: narrow down the number of points that need to be checked with bounds */
            for (var i = 0; i < existingPresMarkers.length; i++) {
                var presencePoint = existingPresMarkers[i].geometry.getCentroid();
                if (currentBoundaryOutline.geometry.containsPoint(presencePoint)){
                    containedPresences.push(existingPresMarkers[i].attributes.spaceID); //FIX: what if a presence is deleted????
                    var distance = currentBoundaryOutline.geometry.distanceTo(presencePoint);
                    if (distance > radius) radius = distance;                   
                }
            }
            
            boundaryInfoObj = {'xPos': center.y,  
                'yPos': 30,
                'zPos': center.x,
                'description': 'new boundary',
                'radius': radius,
                'regionName': $('#mmRegBoundName').val()
            }
            sirikata.event('mmCreateBoundary', boundaryInfoObj, containedPresences);
            currentBoundaryOutline.destroy();
       }
      
      
      /* Function: displaySidebarInfo
       ******************************
       * Displays information according to the presence icon selected
       */
       function displaySidebarInfo(feature, type) {
        currentDisplayedInfo = feature.attributes;
        $('#mmPresenceID').text(currentDisplayedInfo.spaceID.substring(0,8));
        //var position = '<' + feature.attributes.xPos + ',' + feature.attributes.yPos + ',' + feature.attributes.zPos + '>';
        $('#mm-info-panel').find('img').attr('src', currentDisplayedInfo.thisIcon);
        if (type == 0) { //event
            $('#mmTeleport').html('Join Event');
        } else if (type == 1) { //regular presence
            $('#mmTeleport').html('Teleport');
        } else if (type == 2) {
            $('#mmTeleport').html('Teleport');
            sirikata.event('mmTouchBoundary', currentDisplayedInfo.spaceID);
        }
       }
      
        /* Function: tBFunc
         ******************
         * action to replace a changed presence
         */
         function tBFunc(newPresInfo, index) {
          existingPresMarkers[index].destroy();
          existingPresMarkers.splice(index, 1);  
         }
         
         /* Function: teleportToPresence
          ******************************
          * teleports to the currently displayed position
          */
          function teleportToPresence() {
            var type = $('#mmTeleport').html();
            sirikata.event("mmTeleport", currentDisplayedInfo.xPos, currentDisplayedInfo.yPos, currentDisplayedInfo.zPos);
            if (type == 'Join Event') {
                sirikata.event("mmJoinEvent", currentDisplayedInfo.spaceID);
            }
          }


/*************************************************************/

        
        /* Function: registerNewBoundary
         *******************************
         * toggles side panel to register new boundary gui
         */
         function registerNewBoundary() {
            toggleInfoPanel(3);
            drawPolygon.activate();
         }
         
         /* Function: mmRegBoundSaveFunc
          ******************************
          * saves boundary info and calls function to create the corresponding entity
          */
          function mmRegBoundSaveFunc() {
            newBoundaryAdded();
            toggleInfoPanel(0);
          }
          
          /* Function mmRegBoundCancelFunc
           *******************************
           * Cancels the boundary that has been drawn
           */
           function mmRegBoundCancelFunc() {
            toggleInfoPanel(0);
           }
         
        /* Function: mmRegNextFunc
         *************************
         * temp function
         */
         function mmRegNextFunc() {
            toggleInfoPanel(2);
         }
         
         /* Function: mmRegSaveFunc
          *************************
          * save function
          */
          function mmRegSaveFunc() {
            toggleInfoPanel(0);
            AutoSizeAnchored = OpenLayers.Class(OpenLayers.Popup.Anchored, {
                'autoSize': true
            });
            
            eventInfoObj = {'xPos': $('#mmRegPosLat').val(), 
                'yPos': 30,
                'zPos': $('#mmRegPosLon').val(),
                'description': $('#mmRegDescription').val(),
                'script': $('#mmRegScript').val()
            }
            sirikata.event('mmCreateEvent', eventInfoObj);
          }

        /* Function: initPresenceLayer
         *****************************
         * Initializes the layer that shows where other presences are located
         */
         function initPresenceLayer() {
            sirikata.event("mmQuerySurrounding");
         }

        /* Function: displayCurrCenter
         *****************************
         * Sets the map display center to the lon/lat specified
         */
         function displayCurrCenter(lon, lat) {
            var center = new OpenLayers.LonLat(lon, lat);
	        map.setCenter(center, 14);   
         }
        


         
          /* Function: getSourceUrls
           *************************
           * Quick fix for nonexistent paths (img/[name.png]) from openlayers library 
           */
          function getSourceUrls() {              	           
            $('img').each( function(self) {
	            var name = $(this).attr('src');
	            if (name.substring(0,3) == 'img' || name.substring(0,3) == 'the') {
	               var newSrc = '../scripting/' + name;
	                    $(this).attr('src', newSrc);
	                }
	            });         
          } //end getSourceUrls 
          
          /* Function: registerNewEvent
           ****************************
           * retrieves information for a new 'event' and calls addMarker to create a marker on 
           * the appropriate place in the map
           */
           function registerNewEvent() {
                toggleInfoPanel(1);              
           }
        //var for tracking the current popup info
        var presContent = "";
            
            /* Function: addMarker
             *********************
             * adds a marker to the marker layer in the desired location, and a popup box with desired text
             * marker is added as an openlayer Feature, popup is an associated property of the marker (cannot be directly accessed)
             */
            function addMarker(eventInfoObj) {
                var feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(eventInfoObj.zPos, eventInfoObj.xPos), {
                    xPos: eventInfoObj.xPos,
                    yPos: eventInfoObj.yPos,
                    zPos: eventInfoObj.zPos,
                    thisIcon: eventInfoObj.iconUrl,
                    spaceID: eventInfoObj.spaceID,
                    uniqueString: eventInfoObj.uniqueString
                    }); 
                markers.addFeatures(feature);
                existingEventMarkers.push(feature);
               
            } // end addMarker()
            
            /* Function: addBoundMarker
             *********************
             * adds a circular polygon boundary to the desired location and adds the feature to the boundary array
             */
            function addBoundMarker(boundInfoObj) {
                var feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Polygon.createRegularPolygon(new OpenLayers.Geometry.Point(boundInfoObj.zPos, boundInfoObj.xPos), boundInfoObj.radius, 30, 0 ), {
                    xPos: boundInfoObj.xPos,
                    yPos: boundInfoObj.yPos,
                    zPos: boundInfoObj.zPos,
                    thisIcon: boundInfoObj.iconUrl,
                    spaceID: boundInfoObj.spaceID,
                    uniqueString: boundInfoObj.uniqueString,
                    regionName: boundInfoObj.regionName,
                    color: ""
                    }); 
                boundaries.addFeatures(feature);
                existingBoundMarkers.push(feature);
               
            } // end addBoundMarker()
                        
            
          
            
            /* Function: addPresMarker
             *************************
             * adds markers to represent the appearance of the presences. presenceInfoObj 
             * records the location info that will be passed to sirikata.event
             */
            function addPresMarker(presenceInfoObj) {     
                if (presenceInfoObj.iconUrl === undefined) presenceInfoObj.iconUrl = 'http://www.clker.com/cliparts/2/b/3/8/1197149700505366957Gerald_G_Parchment_Background_or_Border_1.svg.med.png';             
                var feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(presenceInfoObj.zPos, presenceInfoObj.xPos), {
                    xPos: presenceInfoObj.xPos,
                    yPos: presenceInfoObj.yPos,
                    zPos: presenceInfoObj.zPos,
                    thisIcon: presenceInfoObj.iconUrl,
                    spaceID: presenceInfoObj.spaceID,
                    uniqueString: presenceInfoObj.uniqueString
                    }); 
                presences.addFeatures(feature);
                existingPresMarkers.push(feature);
            } // end addPresMarker()   
            

            
            
/************************************************************************************/
        /* retrieving model information from open3dhub */
        while (true) {
            $.ajax({
                url: 'http://open3dhub.com/api/browse/' + nextStart, 
                type: 'GET',
                dataType: 'json',
                async: false,
                success: allMeshesFunc,
                crossDomain: true
            });

            if (nextStart == null) break;
        }


        /* Function: allMeshesFunc
         *************************
         * Callback function for ajax request, pushes each thumbnail, base name, and title into a 2-dimensional array
         */
        function allMeshesFunc(dataGotten, status, xhr) {
            nextStart = dataGotten.next_start;
            for (var s in dataGotten.content_items) {
                if (typeof (dataGotten.content_items[s].metadata.types.original.thumbnail) != 'undefined') {
                    allMeshes.push([dataGotten.content_items[s].metadata.types.original.thumbnail, dataGotten.content_items[s].base_name, dataGotten.content_items[s].metadata.title]);
                }
            }
        }
        
        
        //Takes a string like this:
        // "d3308661de134382afafce26376c84c9d29a6bd319d9c3f3ac501d17f75f0e60"
        //turns it into this:
        //  http://open3dhub.com/download/d3308661de134382afafce26376c84c9d29a6bd319d9c3f3ac501d17f75f0e60
        function formSource(str) {
            return 'http://open3dhub.com/download/' + str;
        }
        
        
        function findPresenceImage(string) {
            var cutIndex = string.lastIndexOf('/');
            string = string.substring(cutIndex + 1);
            for (var elem in allMeshes) {
                if (allMeshes[elem][1] == string) {
                    return formSource(allMeshes[elem][0]);
                }
            }
        
        }

        
        
             
 /********************* Ending ***********************/       
    }
    


);
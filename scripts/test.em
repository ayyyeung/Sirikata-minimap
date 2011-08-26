/*
Event stuff now operating with select, prior to converting dialog to same window
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
        var map;
        var existingPresMarkers = [];
        var existingEventMarkers = [];
        var currentDisplayedInfo;
        var indexSelected = 0;


/* Function: toggleVisible
 *************************
 * toggles the visibility of the gui window
 */
var toggleVisible = function() {
    window.toggle();
    
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
                //var abbrSpaceID = presArray[i][4].substring(0,8);
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
                
                if (presArray[i][3] == 'meerkat:///dannyatucb/Apple.dae/optimized/0/Apple.dae') { //FIX
                    for (var s = 0; s < existingEventMarkers.length; s++) {
                        if (existingEventMarkers[s].attributes.spaceID.indexOf(presArray[i][4]) >= 0) {
                            existing = 1;
                            break;
                        }    
                    }
                    if (existing == 0) {
                        
                        addMarker(presenceInfoObj);
                    }
                } else {
                
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
                } //end else (for pres markers)

           } 
           presences.redraw(); 
           markers.redraw();   
 
 };
 MiniMap.createPresMarkers = createPresMarkers;


/*******************************************************************************/


/*******************************************************************************/
      
      /* Elements on window */
       $('<div id="mini-map" title="Map">'  +

      
        '<div id="mm-map-panel">' + 
            '<div style="position: absolute; left: 10px; top: 10px;" id="mouseLocation"><div id="mouseLocLon">Lon</div>' + '<div id="mouseLocLat">Lat</div>' + '</div>' +
            '<div style="position: absolute; left: 10px; top: 40px; width: 330px; height: 330px;" id="map_box"><script src="../scripting/OpenLayers.js"></script></div>' + 
            '<div style="position: absolute; left: 10px; top: 380px;" id="layerswitcher"></div>' +
            '<div style="position: absolute; left: 10px; top: 590px;"><button id="query">Search for map</button></div>' +
            '<div style="position: absolute; left: 200px; top: 590px;"><button id="register">Register new event</button></div>' +
            //'<div style="position: absolute; left: 400px; top: 590px;"><button id="showPresences">Show Presences</button></div>' +
        '</div>' + 
        
        '<div id="mm-info-panel" style="position: absolute; left: 360px; width: 190px; height: 500px; border: 3px solid blue"><h1 class="ui-widget-header">Info</h1><br/>' +
            '<div id="mmPresenceID">Presence ID</div></br>' +
            '<img style="width: 130px" src=""></img></br>' +
            '<button id="mmTeleport">Teleport</button>' +
            
        '</div>' +
      
        '</div>'/*end mini-map*/).appendTo('body');
		


//Add new event to map
		
		$dialog = $('<div id="register-event" title="Register New Event">' +
		    '<div id="mmRegStepOne"><form><fieldset>' +
                    '<legend>Event Information</legend>' +
                   'Location: <input value="x-position" id="mmRegPosLat" type="text" size="10" />' +
                    '<input value="z-position" id="mmRegPosLon" type="text" size="10" /><br />' +
                    'Description: <pre><textarea id="mmRegDescription"></textarea></pre><br />' +
                    
                '</fieldset></form></div>' + 
                
            '<div id="mmRegStepTwo"><form><fieldset>' +
                    '<legend>Portal Setup</legend>' +
                    'Script to load: <pre><textarea id="mmRegScript"></textarea></pre><br />' +
                    
                '</fieldset></form></div>' +
                '<button id="mmRegNext">Next</button>' + '<button id="mmRegSave">Save</button>' +
                
          '</div>')
		.dialog({
			autoOpen: false,
			title: 'Register New Event',
			width: 300,
			height: 300,
			modal: false
		});

       
       window = new sirikata.ui.window( 
        "#mini-map",        
           {
               autoOpen: false,
               width: 560,
               height: 500,
               modal: false
           }
        )

        
        
        /* left panel map buttons */
        sirikata.ui.button('#query').button().click(initMap);
        sirikata.ui.button('#register').button().click(registerNewEvent);
        //sirikata.ui.button('#showPresences').button().click(initPresenceLayer);
        
        
        /* right panel buttons */
        sirikata.ui.button('#mmTeleport').button().click(teleportToPresence);
        
        /* $dialog buttons */
        sirikata.ui.button('#mmRegNext').button().click(mmRegNextFunc);//completeRegister);
        sirikata.ui.button('#mmRegSave').button().click(mmRegSaveFunc);
             
        
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
                new OpenLayers.Control.LayerSwitcher({'div':OpenLayers.Util.getElement('layerswitcher'),activeColor:'green'})
                ]
            });
            
            var osmrail = new OpenLayers.Layer.XYZ("Sirikata map",
            "http://images.kaneva.com/filestore9/5172405/6374413/lightUblue.jpg", // http://www.biorust.com/tutorials/ps-sinedots/step1.jpg//http://i279.photobucket.com/albums/kk151/lilmiss_tajalove/800px-F1_light_blue_flag_svg.png
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
                    sirikata.event("printAlert", "something was selected");
                    displaySidebarInfo(e.feature, 0);
                },
                "featureunselected": function(e) {
                }
           });
           
           //CLUSTER STRATEGY: var presenceClusterStrategy = new OpenLayers.Strategy.Cluster({distance: 2, threshold: 2});
           
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
            //strategies: [presenceClusterStrategy]          
           });
           map.addLayer(presences);
           //presenceClusterStrategy.activate();
           presences.id = "Presences";
           
           
           presences.events.on({
            "featureselected": function(e) {
                sirikata.event("printAlert", "something was selected");
                displaySidebarInfo(e.feature, 1);
            },
            "featureunselected": function(e) {
            }
           });
           
           var selectControl = new OpenLayers.Control.SelectFeature([presences, markers]);
           map.addControl(selectControl);
           selectControl.activate();
           


         map.events.register("click", map, function(e) {
                var temp = $('#mmRegPosLon').val();
                var position = map.getLonLatFromPixel(e.xy);
                $('#mouseLocLon').text("Lon: " + position.lon);
                $('#mouseLocLat').text("Lat: " + position.lat);
                
                //update register
                $('#mmRegPosLon').value(position.lon);
                $('#mmRegPosLat').value(position.lat);


         });
         
         
        getSourceUrls();
	    initPresenceLayer();  
	        
      } //end initMap();	
      
      
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
        }
       }
      
        /* Function: tBFunc
         ******************
         * action to replace a changed presence
         */
         function tBFunc(newPresInfo, index) {
          existingPresMarkers[index].destroy();
          existingPresMarkers.splice(index, 1);
         //presences.eraseFeatures(existingPresMarkers[index]);
          //existingPresMarkers[index].move(new OpenLayers.LonLat(newPresInfo.zPos, newPresInfo.xPos));
          //existingPresMarkers[index].attributes.thisIcon = newPresInfo.iconUrl;        
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
        /* Function: mmRegNextFunc
         *************************
         * temp function
         */
         function mmRegNextFunc() {
            $('#mmRegStepOne').hide();
            $('#mmRegStepTwo').show();
            $('#mmRegNext').hide();
            $('#mmRegSave').show();
         }
         
         /* Function: mmRegSaveFunc
          *************************
          * save function
          */
          function mmRegSaveFunc() {
            $dialog.dialog('close');
            AutoSizeAnchored = OpenLayers.Class(OpenLayers.Popup.Anchored, {
                'autoSize': true
            });
            
            eventInfoObj = {'xPos': $('#mmRegPosLon').val(), 
                'yPos': 30,
                'zPos': $('#mmRegPosLat').val(),
                'description': $('#mmRegDescription').val(),
                'script': $('#mmRegScript').val()
            }
            sirikata.event('mmCreateEvent', eventInfoObj);
            //popupClass = AutoSizeAnchored;
            //addMarker(popupClass, eventInfoObj);
            //getSourceUrls();
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
	        map.setCenter(center, 5);   
         }
        


         
          /* Function: getSourceUrls
           *************************
           * Quick fix for nonexistent paths (img/[name.png]) from openlayers library 
           */
          function getSourceUrls() {              	           
            $('img').each( function(self) {
	            //sirikata.log('fatal', $(this).attr('src'));
	            var name = $(this).attr('src');
	            if (name.substring(0,3) == 'img' || name.substring(0,3) == 'the') {
	               // var newSrc = 'http://openlayers.org/api/' + name;//img/zoom-minus-mini.png
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
                $('#mmRegStepOne').show();
                $('#mmRegStepTwo').hide();
                $('#mmRegNext').show();
                $('#mmRegSave').hide();
                $dialog.dialog('open');
                
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
                sirikata.event('printAlert', 'eventDetected');
               
            } // end addMarker()
            
          
            
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
                    return formSource(allMeshes[elem][0]);//allMeshes[elem]
                }
            }
        
        }

        
        
             
 /********************* Ending ***********************/       
    }
    


);
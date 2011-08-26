var a = @
if (typeof(std) === "undefined") std = {};
if (typeof(std.test) === "undefined") std.test = {};
(function () {
	var Sum = std.test;
	
	Sum.Init = function(parent) {
		this._parent = parent;
		this._parent._simulator.addGUITextModule("test", \@
			sirikata.ui("test", function() {
				$('<div id="test-Main" title="Main Window">' + 
				  '  <div id="testtext">blaaaaaaaaah</div>' +
				  '  <iframe id="iframetest" src="https://graph.facebook.com/oauth/access_token?client_id=154379104633134&redirect_uri=file%3A///C%3A/Users/perceptual/Desktop/sirikata/sirikata-0.0.11-win32/sirikata_win32/share/ogre/data/chrome/blank.html&client_secret=bf6f271ab05f0919c6a3a788c47ad3b5&code=lUrqSr8n7ybCrisv1mn_COeujkDBilpiT8hpn-rsAPA.eyJpdiI6ImNsVTRDUnF6QVp5WjJuM01DS3BYQVEifQ.oQ9UJiLb5fFEYv3wghbByMSRaQa62kgkMmhLkLncOoZeUDdfy5GbLGJPhfCD7lCTz7tznKXsvJJLmbghYO3PwVMn7djhmdoQZi0A30Wv9HMOy91OPH7buY6LpwcaboEy"></iframe>' + 
				  '  <input id="testbutton" type="button" value="PUSH"/>' +
				  '  <div id="testtext2"></div>' +
				  '  <div id="testtext3"></div>' +
				  '  <div id="testtext4"></div>' +
				  '</div>').appendTo('body');
				$("#test-Main").dialog({
					width:430,
					height:'auto',
					modal:false,
					autoOpen:true
				});
				$("#testbutton").click(function () {getInterior();});
				function getInterior() {
					$("#testtext").text("");
					var iframe = document.getElementById("iframetest"); 
					var cw = iframe.contentWindow;
					var doc = cw.document;
					for (i in iframe.contentWindow.document)
						$("#testtext").append(i + " ");
					$("#testtext2").text("<br>1: " + doc);
					$("#testtext3").text("<br>2: " + doc.documentMode);
					$("#testtext4").text("<br>3: " + doc.toString());
				}
			});
		\@, std.core.bind(function(gui){
			this._testModule = gui;
		}, this));
	};
})();

simulator._test = new std.test.Init(simulator);
@;

var msg = {
	request: 'script',
	script:a
};
msg >> system.self >> [];

function checkJre(){

var agt=navigator.userAgent.toLowerCase();
var is_major = parseInt(navigator.appVersion);


var is_nav = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')== -1)
&& (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')== -1)
&& (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')== -1));
var is_nav4up = (is_nav && (is_major >= 4)); 

var pluginDetected = false;

// we can check for plugin existence only when browser is 'is_ie5up' or 'is_nav4up'
if(is_nav4up) {

  // Refresh 'navigator.plugins' to get newly installed plugins.
  // Use 'navigator.plugins.refresh(false)' to refresh plugins 
  // without refreshing open documents (browser windows)
  if(navigator.plugins) { 
    navigator.plugins.refresh(false);
  }

  // check for Java plugin in installed plugins
  if(navigator.mimeTypes) {
    // window.alert( navigator.mimeTypes.length); 
    for (i=0; i <  navigator.mimeTypes.length; i++) {
      // window.alert( navigator.mimeTypes[i].type); 
      if( (navigator.mimeTypes[ i].type != null)
        &&(navigator.mimeTypes[ i].type.indexOf(
        "application/x-java-applet;jpi-version=1.4") != -1) ) {
        //window.alert("Found"); 
        pluginDetected = true; 
       break;
      }

    }
  }

} 

if (pluginDetected) {
  // show applet page
  document.location.href="appletref.htm";

} else if (confirm("Java Plugin 1.4+ not found, Do you want to download it?\n" + 
                   "if you choose not to install the plugin  the reports graphical applets will not be available.")) {
  document.location.href=XilinxD;
} else {
  document.location.href="appletref.htm";
}

}


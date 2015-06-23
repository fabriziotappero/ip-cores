
function checkJre(){

var agt=navigator.userAgent.toLowerCase();
var is_major = parseInt(navigator.appVersion);


var is_nav = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')== -1)
&& (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')== -1)
&& (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')== -1));
var is_nav4up = (is_nav && (is_major >= 4)); 

var is_ie = ((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1)); 
var is_ie5 = (is_ie && (is_major == 4) && (agt.indexOf("msie 5.0")!= -1) );
var is_ie5_5 = (is_ie && (is_major == 4) && (agt.indexOf("msie 5.5") != -1));
var is_ie6 = (is_ie && (is_major == 4) && (agt.indexOf("msie 6.0") != -1));

var is_ie5up = (is_ie && (is_major == 4) && ( (agt.indexOf("msie 5.0")!=-1) || (agt.indexOf("msie 5.5")!=-1) || (agt.indexOf("msie 6.0")!=-1) ) );

var pluginDetected = false;
var activeXDisabled = false;

// we can check for plugin existence only when browser is 'is_ie5up' or 'is_nav4up'
if(is_nav4up) {

  // Refresh 'navigator.mimeTypes' to get newly installed mimeTypes.
  // Use 'navigator.mimeTypes.refresh(false)' to refresh mimeTypes 
  // without refreshing open documents (browser windows)

  // check for Java plugin in installed mimeTypes
  if(navigator.mimeTypes ) {
    //window.alert( "length");
    //window.alert( navigator.mimeTypes.length);
    for (i=0; i <  navigator.mimeTypes.length; i++) {
      //window.alert(navigator.mimeTypes[i].type);
      if( (navigator.mimeTypes[ i].type != null)
        &&(navigator.mimeTypes[ i].type.indexOf(
        "application/x-java-applet;jpi-version=1.4") != -1) ) {

        pluginDetected = true; 
       break;
      }

    }
  }

} else if (is_ie5up) {
  var javaVersion;
  var shell;
  try {
    // Create WSH(WindowsScriptHost) shell, available on Windows only
    shell = new ActiveXObject("WScript.Shell");

    if (shell != null) {
    // Read JRE version from Window Registry
      try {
        javaVersion = shell.regRead
        ("HKEY_LOCAL_MACHINE\\Software\\JavaSoft\\Java Runtime Environment\\CurrentVersion");
      } catch(e) {
      // handle exceptions raised by 'shell.regRead(...)' here
      // so that the outer try-catch block would receive only
      // exceptions raised by 'shell = new ActiveXObject(...)'
      }
    } 
  } catch(e) {
   window.alert(" Creating ActiveX controls thru script is disabled \n in InternetExplorer security options \n To enable it: \n a. Go to the 'Tools -->; Internet Options' menu\n b. Select the 'Security' tab\n c. Select zone (Internet/Intranet)\n d. Click the 'Custom Level..' button which will display the\n 'Security Settings' window.\n e. Enable the option 'Initialize and script ActiveX controls\n not marked as safe' ");

    activeXDisabled = true;
  } 

  // Check whether we got required (1.4+) Java Plugin
  if ( (javaVersion != null) && (javaVersion.indexOf("1.4") != -1) ) {
    pluginDetected = true;
  }

}


if (pluginDetected) {

  // show applet page
  document.location.href="newappletref.htm";

} else if (confirm("Java Plugin 1.4+ not found, Do you want to download it?\n" +
                   "if you choose not to install the plugin  the reports graphical applets will not be available.")) {

  // show install page
  document.location.href=XilinxD;

} else {
  // show error page
  document.location.href="newappletref.htm";
}

}


    var tmpStr = "";
    var waitWin;

    function openWait() {
     waitWin = window.open("wait.htm", "wait",
                          "toolbar=no,location=no,"+
                             "directories=no,status=no,menubar=no,scrollbars=no,"+
                             "resizable=no,width=300,height=50" );
    }

    function closeWait() { if (waitWin) waitWin.close(); }

    function setMsg(msg){

       parent.leftnav.setAppletMsg( msg );
       // now send it reload forces
       // call to applet paint
        location.reload();
    }

    function getMsg(){

        return( parent.leftnav.getAppletMsg() );
    }

    function resetMsg(){ parent.leftnav.setAppletMsg(""); }

    function printAppletPkg() {
        if( isNS() ){
             setMsg("cmd printPkg ");
         }
         else{
             document.ChipViewerApplet.PrintPkg();
         }
    }

    function showAppletGraphicMC(mc) {
        if( isNS() ){
             setMsg("cmd showMac " + mc);
         }
         else{
             document.ChipViewerApplet.ShowMac(mc);
         }
    }

    function ShowMC() { showAppletGraphicMC(tmpStr); }

    function showAppletGraphicFB(fb) {
         if( isNS() ){
            setMsg("cmd showFB " + fb);
         }
         else{
             document.ChipViewerApplet.ShowFB(fb);
         }
    }

    function showAppletGraphicPin(pin) { 
         if( isNS() ){ 
            setMsg("cmd showPin " + pin); 
         } 
         else{ 
             document.ChipViewerApplet.ShowPin(pin); 
         } 
    } 

    function ShowFB() { showAppletGraphicFB(tmpStr); }

    function isNS() {
      return ((navigator.appName.indexOf("Netscape") >= 0) && (parseFloat(navigator.appVersion) < 5) ) ? true : false;
    }

    function isIE(){
        var agt=navigator.userAgent.toLowerCase();
        return( ( (agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1) ) ? true: false );
    }

    function waitUntilOK() {
      if (!waitWin) openWait();
      if (isNS()) {
        if (document.ChipViewerApplet.isActive()) closeWait();
        else  settimeout("waitUntilOK()",100);
      }
      else {
        if (document.ChipViewerApplet.readyState == 4) closeWait();
        else  settimeout("waitUntilOK()",100);
      }
    }


    // check that the applet if file has been generated
    // this can only be done if the applets been loaded.
    function fileExists(fileName){

        if( document.ChipViewerApplet.readyState != 4 ) {
            window.alert("Navigation disabled until the applet is loaded." );
        }
        if( isIE() ){
            if( parent.leftnav.getAppletPermission() == 1 ){
                if( document.ChipViewerApplet.TestFileExists(fileName) == 1 ){
                    window.alert("file exist tests true" );
                    return( true );
                }
            }
            else{
                window.alert("file exist returns true no permission" );
                return( true );
            }
        }
        else{
            return( true );
        }
        window.alert("file exist returns false" );
        return( false );
    }



    function setPermission(){

        if( isIE() ){
            if( document.ChipViewerApplet.granted() ){
                parent.leftnav.setAppletPermission();     
            }
        } 
        else{ 
            return( true );
        }
    }

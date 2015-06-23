var noAppletOnClicked = 1;
var appletMsg = "";
var waitWin;
var oldIn =  oldOut = oldGbl = oldIsp = oldVcc = oldGnd = oldProhibit = oldUnuse = oldNc = 1;
var oldInfo = oldWarn = oldError = 1;
var verbose = 0;
var dispPage, mapLogPage, mapInPage, unLogPage, unInPage;
var javaPermission = 0;
var abelEqn = vhdlEqn = verEqn = "";

function IsNS() {
  return ((navigator.appName.indexOf("Netscape") >= 0) &&
          (parseFloat(navigator.appVersion) >= 4)) ? true : false;
}

function openWait() {
  waitWin = window.open("wait.htm", "wait",
                        "toolbar=no,location=no,"+
                        "directories=no,status=no,menubar=no,scrollbars=no,"+
                        "resizable=no,width=300,height=50" );
}

function closeWait() { if (waitWin) waitWin.close(); }

function popHTML(name, str) {
  document.options.htmlStr.value = str;
  if (name.indexOf(":") > -1)
    name = name.substring(0,name.indexOf(":")) + "_COLON_" +
           name.substring(name.indexOf(":")+1,name.length);
  if (name.indexOf(".") > -1)
    name = name.substring(0,name.indexOf(".")) + "_DOT_" +
           name.substring(name.indexOf(".")+1,name.length);
  var win = window.open("result.htm", "win_"+name,
                        "toolbar=no,location=no,"+
                        "directories=no,status=no,menubar=no,scrollbars=yes,"+
                        "resizable=yes,width=300,height=200" );
  win.focus();
}

function setAppletPermission() { appletPermission = 1; }
function getAppletPermission() { return( appletPermission); }
function getAppletMsg() { return(appletMsg); }
function setAppletMsg(msg) { appletMsg = msg; }


function showHTML(page, html) {

      dispPage = html;
      document.options.currPage.value = page;
      parent.content.location.href = html;
}

function showTop() { showHTML(document.options.currPage.value, dispPage); }

function setVerbose(value) { verbose = value; }

function showLegend(url, w, h) {
  if (verbose == 1) {
    url = url.substring(0,name.indexOf(".htm")) + "V.htm";
  }
  var win = window.open(url, 'win',
              'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width='+w+',height='+h);
  win.focus();
}

function showSummary()    { showHTML("summary", "summary.htm"); }
function showOptions()    { showHTML("options", "options.htm"); }
function showFBSum()      { showHTML("fbs", "fbs.htm"); }
function showFB(fb)       { showHTML("fbs_FB", "fbs_"+fb+".htm"); }
function showPinOut()     { showHTML("pins", "pins.htm"); }
function showError()      { showHTML("errors", "errs.htm"); }
function showFailTable()  { showHTML("failtable", "failtable.htm"); }

function showEqnAll()     {
  openWait();
  parent.eqns.setOper(currEqnType);
  if (currEqnType == defEqnType) showHTML("equations", "defeqns.htm");
  else if (currEqnType == 0) {
    if (abelEqn == "") abelEqn = parent.eqns.getEqnList();
    document.options.htmlStr.value = abelEqn;
    showHTML("equations", "equations.htm");
  }
  else if (currEqnType == 1) {
      if (vhdlEqn == "") vhdlEqn = parent.eqns.getEqnList();
      document.options.htmlStr.value = vhdlEqn;
      showHTML("equations", "equations.htm");
  }
  else {
      if (verEqn == "") verEqn = parent.eqns.getEqnList();
      document.options.htmlStr.value = verEqn;
      showHTML("equations", "equations.htm");
  }
  closeWait();
}

function showEqn(sig)     {
  popHTML(sig, parent.eqns.getEqn(sig));
}

function showPterm(pterm, type) {
  popHTML(pterm, parent.eqns.getPterm(pterm, type));
}

function showAscii() { showHTML("ascii", "ascii.htm"); }

function showHelp() { 
  var helpDoc = document.options.currPage.value + "doc.htm";
  popWin(helpDoc);
}

function getMapParam(type) {
  var paramStr = "";
  switch(type) {
    case 1: paramStr  += "10"; break;
    case 2: paramStr  += "01"; break;
    case 3: paramStr  += "11"; break;
    case 4: paramStr  += "02"; break;
    case 5: paramStr  += "12"; break;
    default: paramStr += "00";
  }

  return paramStr;
}

function showMappedLogics(type) {
  showHTML("maplogic", "maplogic_" + getMapParam(type) + ".htm");
}

function showMappedInputs(type) {
  showHTML("mapinput", "mapinput_" + getMapParam(type) + ".htm");
}

function showUnMappedLogics(type) {
  showHTML("unmaplogic", "unmaplogic_" + getMapParam(type) + ".htm");
}

function showLogicLeft()  { showHTML("logicleft", "logicleft.htm"); }

function showUnMappedInputs(type) {
  showHTML("unmapinput", "unmapinput_" + getMapParam(type) + ".htm");
}

function showInputLeft()  { showHTML("inputleft", "inputleft.htm"); }

function doEqnFormat() {
  var type = document.options.eqnType.options[document.options.eqnType.options.selectedIndex].value;
  currEqnType = type;
  parent.eqns.setOper(currEqnType);
  if (document.options.currPage.value == "equations") showEqnAll();
}

function showNoAppletAlert() {
  window.alert("No Applet supported for this session!!!");
}

function showAppletMC(mc) {
  if (parent.applets) parent.applets.showAppletGraphicMC(mc);
  else showNoAppletAlert();
}

function showAppletFB(fb) {
  if (parent.applets) parent.applets.showAppletGraphicFB(fb);
  else showNoAppletAlert();
}

function showAppletPin(pin)  {
  if (parent.applets) parent.applets.showAppletGraphicPin(pin);
  else showNoAppletAlert();
}

function printAppletPkg() {
  if (parent.applets) parent.applets.printAppletPkg();
  else showNoAppletAlert();
}

function popWin(url) {
  var win = window.open(url, 'win',
              'location=yes,directories=yes,menubar=yes,toolbar=yes,status=yes,scrollbars=yes,resizable=yes,width=800,height=600');
  win.focus();
}

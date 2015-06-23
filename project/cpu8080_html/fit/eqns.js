var eqnType = 0;
var spcStr = "&nbsp;";
var nlStr = "<br>";
var tabStr = spcStr + spcStr + spcStr + spcStr + spcStr; 
var nlTabStr = nlStr + tabStr;
var rClrS = "<font color='blue'>";
var rClrE = "</font>";
var cClrS = "<font color='green'>";
var cClrE = "</font>";

var abelOper = new Array();
abelOper["GND"] = new Array("Gnd");
abelOper["VCC"] = new Array("Vcc");
abelOper["NOT"] = new Array(rClrS + "!" + rClrE);
abelOper["AND"] = new Array(rClrS + "&" + rClrE);
abelOper["OR"]  = new Array(rClrS + "#" + rClrE);
abelOper["XOR"] = new Array(rClrS + "$" + rClrE);
abelOper["EQUAL_COLON"] = new Array(":= ");
abelOper["EQUAL"] = new Array("= ");
abelOper["ASSIGN"] = new Array("");
abelOper["OPEN_NEGATE"] = new Array("(");
abelOper["CLOSE_NEGATE"] = new Array(")");
abelOper["OPEN_PTERM"] = new Array("");
abelOper["CLOSE_PTERM"] = new Array("");
abelOper["OPEN_BRACE"] = new Array("<");
abelOper["CLOSE_BRACE"] = new Array(">");
abelOper["INVALID_OPEN_BRACE"] = new Array("<");
abelOper["INVALID_CLOSE_BRACE"] = new Array(">");

abelOper["ENDLN"] = new Array(";");
abelOper["COMMENT"] = new Array("//");
abelOper["IMPORT"] = new Array(";Imported pterms ");
abelOper["GCK_COM"] = new Array("GCK");
abelOper["GTS_COM"] = new Array("GTS");
abelOper["GSR_COM"] = new Array("GSR");
abelOper["START_EQN"] = new Array("");
abelOper["END_EQN"] = new Array("");

abelOper["_I"] = new Array(".I");
abelOper["_T"] = new Array(".T");
abelOper["_D"] = new Array(".D");
abelOper["_C"] = new Array(".CLK");
abelOper["_DEC"] = new Array(".DEC");
abelOper["_LH"] = new Array(".LH");
abelOper["_CLR"] = new Array(".AR");
abelOper["_PRE"] = new Array(".AP");
abelOper["_CE"] = new Array(".CE");
abelOper["_OE"] = new Array(".OE");

abelOper["OE_START"] = new Array(" <= ");
abelOper["OE_WHEN"] = new Array(" when ");
abelOper["OE_EQUAL"] = new Array(" = ");
abelOper["OE_ELSE"] = new Array(" else ");
abelOper["B0"] = new Array("'0'");
abelOper["B1"] = new Array("'1'");
abelOper["BZ"] = new Array("'Z'");

abelOper["FD"] = new Array(".D");
abelOper["FT"] = new Array(".T");
abelOper["FDD"] = new Array(".DEC");
abelOper["FTD"] = new Array(".T");
abelOper["LD"] = new Array(".LH");
abelOper["Q"] = new Array(".Q");

var vhdlOper = new Array();
vhdlOper["GND"] = new Array("'0'");
vhdlOper["VCC"] = new Array("'1'");
vhdlOper["NOT"] = new Array(rClrS + "NOT " + rClrE);
vhdlOper["AND"] = new Array(rClrS + "AND" + rClrE);
vhdlOper["OR"]  = new Array(rClrS + "OR" + rClrE);
vhdlOper["XOR"] = new Array(rClrS + "XOR" + rClrE);
vhdlOper["EQUAL_COLON"] = new Array("<= ");
vhdlOper["EQUAL"] = new Array("<= ");
vhdlOper["ASSIGN"] = new Array("");
vhdlOper["OPEN_NEGATE"] = new Array("(");
vhdlOper["CLOSE_NEGATE"] = new Array(")");
vhdlOper["OPEN_PTERM"] = new Array("(");
vhdlOper["CLOSE_PTERM"] = new Array(")");
vhdlOper["OPEN_BRACE"] = new Array("(");
vhdlOper["CLOSE_BRACE"] = new Array(")");
vhdlOper["INVALID_OPEN_BRACE"] = new Array("<");
vhdlOper["INVALID_CLOSE_BRACE"] = new Array(">");

vhdlOper["ENDLN"] = new Array(";");
vhdlOper["COMMENT"] = new Array("--");
vhdlOper["IMPORT"] = new Array("");
vhdlOper["GCK_COM"] = new Array("GCK");
vhdlOper["GTS_COM"] = new Array("GTS");
vhdlOper["GSR_COM"] = new Array("GSR");
vhdlOper["START_EQN"] = new Array(rClrS + "port map" + rClrE + " (");
vhdlOper["END_EQN"] = new Array(")");

vhdlOper["_I"] = new Array("_I");
vhdlOper["_T"] = new Array("_T");
vhdlOper["_D"] = new Array("_D");
vhdlOper["_C"] = new Array("_C");
vhdlOper["_DEC"] = new Array("_C");
vhdlOper["_LH"] = new Array("_C");
vhdlOper["_CLR"] = new Array("_CLR");
vhdlOper["_PRE"] = new Array("_PRE");
vhdlOper["_CE"] = new Array("_CE");
vhdlOper["_OE"] = new Array("_OE");

vhdlOper["OE_START"] = new Array(" <= ");
vhdlOper["OE_WHEN"] = new Array(" when ");
vhdlOper["OE_EQUAL"] = new Array(" = ");
vhdlOper["OE_ELSE"] = new Array(" else ");
vhdlOper["B0"] = new Array("'0'");
vhdlOper["B1"] = new Array("'1'");
vhdlOper["BZ"] = new Array("'Z'");

vhdlOper["FD"] = new Array("FDCPE");
vhdlOper["FT"] = new Array("FTCPE");
vhdlOper["FDD"] = new Array("FDDCPE");
vhdlOper["FTD"] = new Array("FTDCPE");
vhdlOper["LD"] = new Array("LDCP");
vhdlOper["Q"] = new Array("");

var verOper = new Array();
verOper["GND"] = new Array("1'b0");
verOper["VCC"] = new Array("1'b1");
verOper["NOT"] = new Array(rClrS + "!" + rClrE);
verOper["AND"] = new Array(rClrS + "&&" + rClrE);
verOper["OR"]  = new Array(rClrS + "||" + rClrE);
verOper["XOR"] = new Array(rClrS + "XOR" + rClrE);
verOper["EQUAL_COLON"] = new Array("= ");
verOper["EQUAL"] = new Array("= ");
verOper["ASSIGN"] = new Array("assign ");
verOper["OPEN_NEGATE"] = new Array("(");
verOper["CLOSE_NEGATE"] = new Array(")");
verOper["OPEN_PTERM"] = new Array("(");
verOper["CLOSE_PTERM"] = new Array(")");
verOper["OPEN_BRACE"] = new Array("[");
verOper["CLOSE_BRACE"] = new Array("]");
verOper["INVALID_OPEN_BRACE"] = new Array("<");
verOper["INVALID_CLOSE_BRACE"] = new Array(">");

verOper["ENDLN"] = new Array(";");
verOper["COMMENT"] = new Array("//");
verOper["IMPORT"] = new Array("");
verOper["GCK_COM"] = new Array("GCK");
verOper["GTS_COM"] = new Array("GTS");
verOper["GSR_COM"] = new Array("GSR");
verOper["START_EQN"] = new Array(" (");
verOper["END_EQN"] = new Array(")");

verOper["_I"] = new Array("_I");
verOper["_T"] = new Array("_T");
verOper["_D"] = new Array("_D");
verOper["_C"] = new Array("_C");
verOper["_DEC"] = new Array("_C");
verOper["_LH"] = new Array("_C");
verOper["_CLR"] = new Array("_CLR");
verOper["_PRE"] = new Array("_PRE");
verOper["_CE"] = new Array("_CE");
verOper["_OE"] = new Array("_OE");

verOper["OE_START"] = new Array(" = ");
verOper["OE_WHEN"] = new Array(" ? ");
verOper["OE_EQUAL"] = new Array("");
verOper["OE_ELSE"] = new Array(" : ");
verOper["B0"] = new Array("1'b0");
verOper["B1"] = new Array("1'b1");
verOper["BZ"] = new Array("1'bz");

verOper["FD"] = new Array("FDCPE");
verOper["FT"] = new Array("FTCPE");
verOper["FDD"] = new Array("FDDCPE");
verOper["FTD"] = new Array("FTDCPE");
verOper["LD"] = new Array("LDCP");
verOper["Q"] = new Array("");

var operator = abelOper;

var pterms = new Array();
var d1 = new Array();
var d2 = new Array();
var clk = new Array();
var set = new Array();
var rst = new Array();
var trst = new Array();
var d1imp = new Array();
var d2imp = new Array();
var clkimp = new Array();
var setimp = new Array();
var rstimp = new Array();
var trstimp = new Array();
var gblclk = new Array();
var gblset = new Array();
var gblrst = new Array();
var gbltrst = new Array();
var ce = new Array();
var ceimp = new Array();
var prld = new Array();
var specSig = new Array();
var clkNegs = new Array();
var setNegs = new Array();
var rstNegs = new Array();
var trstNegs = new Array();
var ceNegs = new Array();
var fbnand = new Array();
var inreg = new Array();

var dOneLit = true;

function setOper(type) {
  if      (type == "1") { operator = vhdlOper; eqnType = 1; }
  else if (type == "2") { operator = verOper;  eqnType = 2; }
  else                  { operator = abelOper; eqnType = 0; }
}

function isXC95() {
  if (device.indexOf("95") != -1) return true;
  return false;
}

function is9500() {
  if ((device.indexOf("95") != -1) &&
      (device.indexOf("XL") == -1) &&
      (device.indexOf("XV") == -1)) return true;
  return false;
}

function retSigType(s) {
  var sigType = sigTypes[s];
  var str = operator["Q"];
  if (sigType == "D") str = operator["FD"];
  else if (sigType == "T") str = operator["FT"];
  else if (sigType.indexOf("LATCH") != -1) str = operator["LD"];
  else if (sigType.indexOf("DDEFF") != -1) str = operator["FDD"];
  else if (sigType.indexOf("DEFF") != -1) str =  operator["FD"];
  else if (sigType.indexOf("DDFF") != -1) str =  operator["FDD"];
  else if (sigType.indexOf("TDFF") != -1) str =  operator["FTD"];
  else if (sigType.indexOf("DFF") != -1) str =   operator["FD"];
  else if (sigType.indexOf("TFF") != -1) str =   operator["FT"];
  return str;
}

function retSigIndex(signal) {
  for (s=0; s<signals.length; s++) { if (signals[s] == signal) return s; }
  return -1;
}

function retSigName(signal) {
  var str = "";
  if (specSig[signal]) str += specSig[signal];
  else str += signal;

  var idx1 = str.indexOf(operator["INVALID_OPEN_BRACE"]);
  var idx2 = str.indexOf(operator["INVALID_CLOSE_BRACE"]);
  if ((idx1 != -1) && (idx2 != -1))
    str = str.substring(0,idx1) + operator["OPEN_BRACE"] +
          str.substring(idx1+1,idx2) + operator["CLOSE_BRACE"] + 
          str.substring(idx2+1,str.length);
  return str;
}

function removePar(signal) {
  var str = signal;

  var idx = str.indexOf(operator["OPEN_BRACE"]);
  if (idx != -1)
    str = str.substring(0,idx) +
          str.substring(idx+1,str.indexOf(operator["CLOSE_BRACE"]));

  return str;
}


function isOneLiteral(str) {
  if ((str.indexOf(operator["AND"]) != -1) ||
      (str.indexOf(operator["OR"]) != -1) ||
      (str.indexOf(operator["XOR"]) != -1)) return false;
  return true;
}

function updateName(signal, index) {
  var str;

  var idx = signal.indexOf(operator["OPEN_BRACE"]);
  if (idx != -1)
    str = signal.substring(0,idx) +
          index + signal.substring(idx);
  else str = signal + index;

  return str;
}

function retPterm(pt) {
  var str = "";
  if (!pterms[pt]) {
    if (specSig[pt]) pt = specSig[pt];
    return pt;
  }

  if (pterms[pt].length > 1) str += operator["OPEN_PTERM"];
  for (p=0; p<pterms[pt].length; p++) {
    var sig = pterms[pt][p];
    if (sig.indexOf("xPUP_0") != -1) continue;
    if (p>0) str += " " + operator["AND"] + " ";
    var neg = 0;
    if (sig.indexOf("/") != -1) {
      sig = sig.substring(1, sig.length);
      str += operator["NOT"];
      neg = 1;
    }

    str += retSigName(sig);
  }
  if (pterms[pt].length > 1) str += operator["CLOSE_PTERM"];

  return str;
}

function retFBMC(str) {
  return str.substring(0,str.length-2);
}

function retD1D2(signal) {
  var str = "";

  dOneLit = true;
  if (d1[signal]) {
    var currImp = "";
    for (i=0; i<d1[signal].length; i++) {
      if (!eqnType && d1imp[signal] && (d1imp[signal][i] == "1")) {
        if (currImp != retFBMC(d1[signal][i]))  {
          currImp = retFBMC(d1[signal][i]);
          str += nlStr + operator["IMPORT"] + currImp;
        }
      }
      if (i>0) str += nlTabStr + operator["OR"] + spcStr;
      str += retPterm(d1[signal][i]);
    }

    if (d2[signal]) str += nlTabStr + operator["XOR"]+ spcStr;
  }

  if (d2[signal]) {
    var currImp = "";
    for (i=0; i<d2[signal].length; i++) {
      if (!eqnType && d2imp[signal] && (d2imp[signal][i] == "1")) {
        if (currImp != retFBMC(d2[signal][i]))  {
          currImp = retFBMC(d2[signal][i]);
          str += nlStr + operator["IMPORT"] + currImp;
        }
      }
      if (i>0) str += nlTabStr + operator["OR"] + spcStr;
      str += retPterm(d2[signal][i]);
    }
  }

  if (str == "GND") str = operator["GND"];
  else if (str == "VCC") str = operator["VCC"];
  else if (!isOneLiteral(str)) {
    dOneLit = false;

    var type = retSigType(retSigIndex(signal));
    if ((type == operator["FD"]) ||
        (type == operator["FDD"])) type = operator["_D"];
    else if ((type == operator["FT"]) ||
             (type == operator["FTD"])) type = operator["_T"];
    else if (type == operator["LD"] && eqnType) type = "_D";

    var tmpStr = updateName(retSigName(signal), type);
    tmpStr += spcStr + operator["EQUAL_COLON"];
    var idx = retSigIndex(signal);
    if (eqnType && sigNegs[idx] == "ON") tmpStr += operator["NOT"] + operator["OPEN_NEGATE"];
    str = tmpStr + str;
    if (eqnType && sigNegs[idx] == "ON") str += operator["CLOSE_NEGATE"];
    str += operator["ENDLN"];

  }

  return str;
}

function retClk(signal) {
  var str = "";

  if (clk[signal]) {
    if (clk[signal].length == 1) {
      var pterm = retPterm(clk[signal][0]);
      if (clkNegs[signal]) {
        str += operator["NOT"];
        if (!isOneLiteral(pterm)) str += operator["OPEN_NEGATE"];
      }
      str += pterm;
      if (clkNegs[signal] && !isOneLiteral(pterm)) str += operator["CLOSE_NEGATE"];
    }
    else {
      if (clkNegs[signal]) str += operator["NOT"] + operator["OPEN_NEGATE"];
      var currImp = "";
      for (i=0; i<clk[signal].length; i++) {
        if (!eqnType && clkimp[signal] && (clkimp[signal][i] == "1")) {
          if (currImp != retFBMC(clk[signal][i]))  {
            currImp = retFBMC(clk[signal][i]);
            str += nlStr + operator["IMPORT"] + currImp;
          }
        }
        if (i>0) str += nlTabStr + operator["OR"] + spcStr;
        str += retPterm(clk[signal][i]);
      }
      if (clkNegs[signal]) str += operator["CLOSE_NEGATE"];
      str += operator["ENDLN"];
    }
  }
  else if (gblclk[signal]) {
    if (gblclk[signal].length == 1) {
      var pterm = retPterm(gblclk[signal][0]);
      if (clkNegs[signal]) {
        str += operator["NOT"];
        if (!isOneLiteral(pterm)) str += operator["OPEN_NEGATE"];
      }
      str += pterm;
      if (clkNegs[signal] && !isOneLiteral(pterm)) str += operator["CLOSE_NEGATE"];
    }
    else {
      if (clkNegs[signal]) str += operator["NOT"] + operator["OPEN_NEGATE"];
      for (i=0; i<gblclk[signal].length; i++) {
        if (i>0) str += nlTabStr + operator["OR"] + spcStr;
        str += retPterm(gblclk[signal][i]);
      }
      if (clkNegs[signal]) str += operator["CLOSE_NEGATE"];
      str += operator["ENDLN"] + tabStr + cClrS +
             operator["COMMENT"] + spcStr + operator["GCK_COM"] + cClrE;
    }
  }
  else if (eqnType) str += operator["B0"];

  return str;
}

function retRst(signal) {
  var str = "";

  if (rst[signal]) {
    if (rst[signal].length == 1) {
      var currImp;
      if (!eqnType && rstimp[signal] && (rstimp[signal][0] == "1")) {
        if (currImp != retFBMC(rst[signal][0]))  {
          currImp = retFBMC(rst[signal][0]);
          str += nlStr + operator["IMPORT"] + currImp;
        }
      }
      if (rstNegs[signal]) str += operator["NOT"];
      str += retPterm(rst[signal][0]);
    }
    else {
      var currImp = "";
      if (rstNegs[signal]) str += operator["NOT"] + operator["OPEN_NEGATE"];
      for (i=0; i<rst[signal].length; i++) {
        if (!eqnType && rstimp[signal] && (rstimp[signal][i] == "1")) {
          if (currImp != retFBMC(rst[signal][i]))  {
            currImp = retFBMC(rst[signal][i]);
            str += nlStr + operator["IMPORT"] + currImp;
          }
        }
        if (i>0) str += nlTabStr + operator["OR"] + spcStr;
        str += retPterm(rst[signal][i]);
      }
      if (rstNegs[signal]) str += operator["CLOSE_NEGATE"];
      str += operator["ENDLN"];
    }
  }
  else if (gblrst[signal]) {
    if (gblrst[signal].length == 1) {
      if (rstNegs[signal]) str += operator["NOT"];
      str += retPterm(gblrst[signal][0]);
    }
    else {
      if (rstNegs[signal]) str += operator["NOT"] + operator["OPEN_NEGATE"];
      for (i=0; i<gblrst[signal].length; i++) {
        if (i>0) str += nlTabStr + operator["OR"] + spcStr;
        str += retPterm(gblrst[signal][i]);
      }
      if (rstNegs[signal]) str += operator["CLOSE_NEGATE"];
      str += operator["ENDLN"] + tabStr + cClrS +
             operator["COMMENT"] + spcStr + operator["GSR_COM"] + cClrE;
    }
  }
  else if (eqnType) str += operator["B0"];

  return str;
}

function retSet(signal) {
  var str = "";

  if (set[signal]) {
    if (set[signal].length == 1) {
      var currImp = "";
      if (!eqnType && setimp[signal] && (setimp[signal][0] == "1")) {
        if (currImp != retFBMC(set[signal][0]))  {
          currImp = retFBMC(set[signal][0]);
          str += nlStr + operator["IMPORT"] + currImp;
        }
      }
      if (setNegs[signal]) str += operator["NOT"];
      str += retPterm(set[signal][0]);
    }
    else {
      var currImp = "";
      if (setNegs[signal]) str += operator["NOT"] + operator["OPEN_NEGATE"];
      for (i=0; i<set[signal].length; i++) {
        if (!eqnType && setimp[signal] && (setimp[signal][i] == "1")) {
          if (currImp != retFBMC(set[signal][i]))  {
            currImp = retFBMC(set[signal][i]);
            str += nlStr + operator["IMPORT"] + currImp;
          }
        }
        if (i>0) str += nlTabStr + operator["OR"] + spcStr;
        str += retPterm(set[signal][i]);
      }
      if (setNegs[signal]) str += operator["CLOSE_NEGATE"];
      str += operator["ENDLN"];
    }
  }
  else if (gblset[signal]) {
    if (gblset[signal].length == 1) {
      if (setNegs[signal]) str += operator["NOT"];
      str += retPterm(gblset[signal][0]);
    }
    else {
      if (setNegs[signal]) str += operator["NOT"] + operator["OPEN_NEGATE"];
      for (i=0; i<gblset[signal].length; i++) {
        if (i>0) str += nlTabStr + operator["OR"] + spcStr;
        str += retPterm(gblset[signal][i]);
      }
      if (setNegs[signal]) str += operator["CLOSE_NEGATE"];
      str += operator["ENDLN"] + tabStr + cClrS +
             operator["COMMENT"] + spcStr + operator["GSR_COM"] + cClrE;
    }
  }
  else if (eqnType) str += operator["B0"];

  return str;
}

function retCE(signal) {
  var str = "";

  if (ce[signal]) {
    if (ce[signal].length == 1) {
      var currImp = "";
      if (!eqnType && ceimp[signal] && (ceimp[signal][0] == "1")) {
        if (currImp != retFBMC(ce[signal][0]))  {
          currImp = retFBMC(ce[signal][0]);
          str += nlStr + operator["IMPORT"] + currImp;
        }
      }
      if (ceNegs[signal]) str += operator["NOT"];
      str += retPterm(ce[signal][0]);
    }
    else {
      var currImp = "";
      if (ceNegs[signal]) str += operator["NOT"] + operator["OPEN_NEGATE"];
      for (i=0; i<ce[signal].length; i++) {
        if (!eqnType && ceimp[signal] && (ceimp[signal][i] == "1")) {
          if (currImp != retFBMC(ce[signal][i]))  {
            currImp = retFBMC(ce[signal][i]);
            str += nlStr + operator["IMPORT"] + currImp;
          }
        }
        if (i>0) str += nlTabStr + operator["OR"] + spcStr;
        str += retPterm(ce[signal][i]);
      }
      if (ceNegs[signal]) str += operator["CLOSE_NEGATE"];
      str += operator["ENDLN"];
    }
  }
  else if (eqnType) str += operator["B1"];

  return str;
}

function retTrst(signal) {
  var str = "";
  if (trst[signal]) {
    if (trstNegs[signal])
      str += operator["NOT"] + operator["OPEN_NEGATE"];
    for (i=0; i<trst[signal].length; i++) {
      var currImp = "";
      if (!eqnType && trstimp[signal] && (trstimp[signal][0] == "1")) {
        if (currImp != retFBMC(trst[signal][0]))  {
          currImp = retFBMC(trst[signal][0]);
          str += nlStr + operator["IMPORT"] + currImp;
        }
      }
      if (i>0) str += nlTabStr + operator["OR"] + spcStr;
      str += retPterm(trst[signal][i]);
    }
    if (trstNegs[signal]) str += operator["CLOSE_NEGATE"]; 
  }
  else if (gbltrst[signal]) {
    if (trstNegs[signal])
      str += operator["NOT"] + operator["OPEN_NEGATE"];
    for (i=0; i<gbltrst[signal].length; i++) {
      if (i>0) str += nlTabStr + operator["OR"] + spcStr;
      str += retPterm(gbltrst[signal][i]);
    }
    if (trstNegs[signal]) str += operator["CLOSE_NEGATE"]; 
  }

  str += operator["ENDLN"];
  return str;
}

function retEqn(signal) {
  var str = inregStr = "";
  var iStr = qStr = "";
  var dStr = dEqn = "";
  var cStr = cEqn = "";
  var clrStr = clrEqn = "";
  var preStr = preEqn = "";
  var ceStr = ceEqn = "";
  var oeStr = oeEqn = "";
  var sigName = retSigName(signal);

  var type = retSigType(retSigIndex(signal));

  if (gbltrst[signal] || trst[signal]) iStr = operator["_I"];
  if (eqnType) qStr = updateName(sigName, iStr);

  if (inreg[signal]) {
    if (!eqnType)
      inregStr = operator["COMMENT"] + " Direct Input Register" + nlStr;
    dStr = retSigName(inreg[signal][0]);
  }
  else dStr = retD1D2(signal);
  if (eqnType && !dOneLit) {
    dEqn = dStr;
    dStr = dStr.substring(0,dStr.indexOf(operator["EQUAL_COLON"]));
  }
  else if (!eqnType) {
    if (!dOneLit) dStr = dStr.substring(dStr.indexOf(operator["EQUAL_COLON"])+2);
    if (sigNegs[retSigIndex(signal)] == "ON") dEqn += operator["NOT"];
    dEqn += sigName;
    if ((type == operator["FT"]) ||
        (type == operator["FTD"])) dEqn += operator["_T"];
    else if ((type == operator["FD"]) ||
             (type == operator["FTD"])||
             (type == operator["LD"])) dEqn += operator["_D"];
    dEqn += " ";
    if ((type != operator["Q"]) && (type != operator["LD"]))
      dEqn += operator["EQUAL_COLON"];
    else  dEqn += operator["EQUAL"];
    dEqn += dStr;
    if (dOneLit) dEqn += operator["ENDLN"];
  }

  cStr = retClk(signal);
  if (eqnType && !isOneLiteral(cStr)){
    cEqn = cStr;
    if (cEqn.indexOf(operator["ENDLN"]) == -1)
      cEqn += operator["ENDLN"];
    cStr = updateName(sigName, operator["_C"]);
  }
  else if (!eqnType && cStr) {
    cEqn += cStr;
    cStr = tabStr + sigName;
    if (type == operator["LD"]) cStr += operator["_LH"];
    else if (type == operator["FDD"]) cStr += operator["_DEC"];
    else                        cStr += operator["_C"];
    if (cEqn.indexOf(operator["ENDLN"]) == -1)
      cEqn += operator["ENDLN"];
    if (gblclk[signal]) cEqn += tabStr + operator["COMMENT"] + " " + operator["GCK_COM"];
  }

  clrStr = retRst(signal);
  if (eqnType && !isOneLiteral(clrStr)){
    clrEqn = clrStr;
    if (cEqn.indexOf(operator["ENDLN"]) == -1)
      clrEqn += operator["ENDLN"];
    clrStr = updateName(sigName, operator["_CLR"]);
  }
  else if (!eqnType && clrStr) {
    clrEqn += clrStr;
    clrStr = tabStr + sigName + operator["_CLR"];
    if (clrEqn.indexOf(operator["ENDLN"]) == -1)
      clrEqn += operator["ENDLN"];
    if (gblrst[signal]) clrEqn += tabStr + operator["COMMENT"] + " " + operator["GSR_COM"];
  }

  preStr = retSet(signal);
  if (eqnType && !isOneLiteral(preStr)){
    preEqn = preStr;
    if (cEqn.indexOf(operator["ENDLN"]) == -1)
      preEqn += operator["ENDLN"];
    preStr = updateName(sigName, operator["_PRE"]);
  }
  else if (!eqnType && preStr) {
    preEqn += preStr;
    preStr = tabStr + sigName + operator["_PRE"];
    if (preEqn.indexOf(operator["ENDLN"]) == -1)
      preEqn += operator["ENDLN"];
    if (gblset[signal]) preEqn += tabStr + operator["COMMENT"] + " " + operator["GSR_COM"];
  }

  if (!is9500()) {
    ceStr = retCE(signal); 
    if (eqnType && !isOneLiteral(ceStr)){
      ceEqn = ceStr;
      if (cEqn.indexOf(operator["ENDLN"]) == -1)
        ceEqn += operator["ENDLN"];
      ceStr = updateName(sigName, operator["_CE"]);
    }
    else if (!eqnType && ceStr) {
      ceEqn += ceStr;
      ceStr = tabStr + sigName + operator["_CE"];
      if (ceEqn.indexOf(operator["ENDLN"]) == -1)
        ceEqn += operator["ENDLN"];
    }
  }

  if (eqnType && trst[signal]) oeEqn = retTrst(signal)
  else if (!eqnType && (trst[signal] || gbltrst[signal])) oeEqn = retTrst(signal);


  var newline = false;
  if (type == "") {
    str += operator["ASSIGN"] + qStr + " " + operator["EQUAL"];
    if (dOneLit) str += dStr;
    else         str += dEqn.substring(dEqn.indexOf(operator["EQUAL"])+2);
    if (oeEqn != "") {
      var oeStr = updateName(sigName, operator["_OE"]);
      if (eqnType == 1) {
        str += nlStr + sigName + operator["OE_START"] + qStr + operator["OE_WHEN"] + oeStr +
               operator["OE_EQUAL"] + operator["B1"] + operator["OE_ELSE"] +
               operator["OE_EQUAL"] + operator["BZ"] + operator["ENDLN"];
      }
      else if (eqnType == 2) {
        str += nlStr + operator["ASSIGN"] + sigName + operator["OE_START"] +
               oeStr + operator["OE_WHEN"] + qStr +
               operator["OE_ELSE"] + operator["BZ"] + operator["ENDLN"];
      }
      str += nlStr + operator["ASSIGN"] + oeStr + " " + operator["EQUAL"] + " " + oeEqn;
    }
  }
  else {
    if (eqnType == 1) {
      str += type + "_" + removePar(retSigName(signal)) +
             ": " + type + " " + operator["START_EQN"] +
             qStr + ", " + dStr + ", " + cStr + ", " +
             clrStr + ", " + preStr;
      if (!is9500() && (type != operator["LD"])) str += ", " + ceStr;
      str += operator["END_EQN"] + operator["ENDLN"];
      newline = true;
    }
    else if (eqnType == 2) {
      str += type + " " +
             type + "_" + removePar(retSigName(signal)) +
             operator["START_EQN"] +
             qStr + ", " + dStr + ", " + cStr + ", " +
             clrStr + ", " + preStr;
      if (!is9500() && (type != operator["LD"])) str += ", " + ceStr;
      str += operator["END_EQN"] + operator["ENDLN"];
      newline = true;
    }

    if (dEqn != "") {
      if (newline) str += nlStr;
      if (inregStr) str += inregStr;
      str += operator["ASSIGN"] + dEqn;
    }

    if (cEqn != "") {
      if (newline || !eqnType) str += nlStr;
      str += operator["ASSIGN"] + cStr + " " + operator["EQUAL"] + " " + cEqn;
    }

    if (clrEqn != "")  {
      if (newline || !eqnType) str += nlStr;
      str += operator["ASSIGN"] + clrStr + " " + operator["EQUAL"] + " " + clrEqn;
    }


    if (preEqn != "")  {
      if (newline || !eqnType) str += nlStr;
      str += operator["ASSIGN"] + preStr + " " + operator["EQUAL"] + " " + preEqn;
    }

    if (ceEqn != "")  {
      if (newline || !eqnType) str += nlStr;
      str += operator["ASSIGN"] + ceStr + " " + operator["EQUAL"] + " " + ceEqn;
    }

    if (oeEqn != "") {
      if (eqnType == 1) {
        var oeStr = updateName(sigName, operator["_OE"]);
        str += nlStr + sigName + operator["OE_START"] + qStr + operator["OE_WHEN"] + oeStr +
               operator["OE_EQUAL"] + operator["B1"] + operator["OE_ELSE"] +
               operator["OE_EQUAL"] + operator["BZ"] + operator["ENDLN"];
        str += nlStr + oeStr + " " + operator["EQUAL"] + " " + oeEqn;
      }
      else if (eqnType == 2) {
        var oeStr = updateName(sigName, operator["_OE"]);
        str += nlStr + operator["ASSIGN"] + sigName + operator["OE_START"] + oeStr + operator["OE_WHEN"] + qStr +
               operator["OE_ELSE"] + operator["BZ"] + operator["ENDLN"];
        str += nlStr + operator["ASSIGN"] + oeStr + " " + operator["EQUAL"] + " " + oeEqn;
      }
      else {
        var oeStr = sigName + operator["_OE"];
        if (gbltrst[signal])
          oeEqn += tabStr + operator["COMMENT"] + " " + operator["GTS_COM"];
        str += nlStr + tabStr + oeStr + " " + operator["EQUAL"] + " " + oeEqn;
      }
    }
  }

  return str;
}

function retFamily() {
  var family = "xc9500";
  if (device.indexOf("XC2C") != -1) {
    if (device.indexOf("S") != -1)  family = "cr2s";
    else                            family = "xbr";
  }
  else if (device.indexOf("XCR3") != -1) family = "xpla3";
  else {
    if (device.indexOf("XL") != -1)  family = "xc9500xl";
    if (device.indexOf("XV") != -1)  family = "xc9500xv";
  }

  return family;
}

function retDesign() { return design; }

function getPterm(pt, type) { 
  if (type) return type + " = " + retPterm(pt);
  return "PT" + pt.substring(pt.indexOf('_')+1,pt.length) + " = " + retPterm(pt);
}

function getPRLDName(prld) {
  if (eqnType != 0) return prld;
  else if (prld == "VCC") return "S";
  return "R";
}

function retFbnand(signal) {
  var str = operator["COMMENT"] + spcStr + "Foldback NAND";
  str += nlStr + retSigName(signal) + spcStr + operator["EQUAL"] + spcStr;
  for (i=0; i<fbnand[signal].length; i++) {
    if (i>0) str += nlTabStr + operator["OR"] + spcStr;
    str += retPterm(fbnand[signal][i]);
  }

  return str;
}

function getEqn(signal) { return retEqn(signal); }

function retUimPterm(pt) {
  var str = "";
  if (!uimPterms[pt]) return pt;
  for (p=0; p<uimPterms[pt].length; p++) {
    if (p>0) str += spcStr + operator["AND"] + spcStr;
    var sig = uimPterms[pt][p];
    if (sig.indexOf("/") != -1) sig = sig.substring(1, sig.length);

    str += retSigName(sig);
  }
  return str;
}

function retUimEqn(signal) {
  var str = operator["COMMENT"] + spcStr + "FC Node" + nlStr;
  var neg = 0;
  if (uimSigNegs[s] == "ON") str += operator["NOT"];
  str += retSigName(signal) + spcStr + operator["EQUAL"];
  str += retUimPterm(signal) + ";";

  return str;
}

function retLegend(url) {
  var str = "";
  if (!eqnType && !isXC95()) {
    str = "Legend: " + "&lt;" + "signame" + "&gt;" + ".COMB = combinational node mapped to ";
    str += "the same physical macrocell as the FastInput \"signal\" (not logically related)";
  }
  else if (eqnType) {
    str = "Register Legend:";
    if (is9500()) {
      str += nlTabStr + "FDCPE (Q,D,C,CLR,PRE);";
      str += nlTabStr + "FTCPE (Q,D,C,CLR,PRE);";
      str += nlTabStr + "LDCP  (Q,D,G,CLR,PRE);";
    }
    else if (retFamily() == "xbr") {
      str += nlTabStr + "FDCPE (Q,D,C,CLR,PRE,CE);";
      str += nlTabStr + "FDDCPE (Q,D,C,CLR,PRE,CE);";
      str += nlTabStr + "FTCPE (Q,D,C,CLR,PRE,CE);";
      str += nlTabStr + "FTDCPE (Q,D,C,CLR,PRE,CE);";
      str += nlTabStr + "LDCP  (Q,D,G,CLR,PRE);";
    }
    else {
      str += nlTabStr + "FDCPE (Q,D,C,CLR,PRE,CE);";
      str += nlTabStr + "FTCPE (Q,D,C,CLR,PRE,CE);";
      str += nlTabStr + "LDCP  (Q,D,G,CLR,PRE);";
    }
  }
  return str;
}


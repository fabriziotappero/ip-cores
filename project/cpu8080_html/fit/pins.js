var specSig = new Array();
var pins = new Array();
var pinsAssign = new Array();
var prohibit = new Array();
var unusedStr = "WPU";
var gndStr = "GND";
var vccStr = "VCC";
var tdiStr = "TDI";
var tdoStr = "TDO";
var tmsStr = "TMS";
var tckStr = "TCK";

function showPin(pin) { parent.leftnav.showAppletPin(pin); }

function printPage() { window.print();  parent.leftnav.printAppletPkg(); }

function showEqn(signal) { parent.leftnav.showEqn(signal); }

function updatePin(type) {
  with (document.options) {
    switch (type) {
    case 0:
      if (inp.checked) parent.leftnav.document.options.inOn.value = 1;
      else             parent.leftnav.document.options.inOn.value = 0;
      break;

    case 1:
      if (out.checked) parent.leftnav.document.options.outOn.value = 1;
      else             parent.leftnav.document.options.outOn.value = 0;
      break;

    case 2:
      if (glb.checked) parent.leftnav.document.options.glbOn.value = 1;
      else             parent.leftnav.document.options.glbOn.value = 0;
      break;

    case 3:
      if (isp.checked) parent.leftnav.document.options.ispOn.value = 1;
      else             parent.leftnav.document.options.ispOn.value = 0;
      break;

    case 4:
      if (vcc.checked) parent.leftnav.document.options.vccOn.value = 1;
      else             parent.leftnav.document.options.vccOn.value = 0;
      break;

    case 5:
      if (gnd.checked) parent.leftnav.document.options.gndOn.value = 1;
      else             parent.leftnav.document.options.gndOn.value = 0;
      break;

    case 6:
      if (unuse.checked) parent.leftnav.document.options.unuseOn.value = 1;
      else               parent.leftnav.document.options.unuseOn.value = 0;
      break;
    }
  }

  parent.leftnav.showPinOut();
}

function showLegend(url) { parent.leftnav.showLegend(url, 650, 350); }

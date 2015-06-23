function popWin(url, w, h) {
  var win = window.open(url, 'win',
              'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width='+w+',height='+h);
  win.focus();
}

function showTop() { parent.leftnav.showTop(); }

function showDoc(device) {
  var url = docURL;
  
  if ((device.indexOf("XC2") != -1) && (device.indexOf("S") != -1))
    url = docCr2sURL;
  else if (device.indexOf("XC2") != -1) url = docXbrURL;
  else if (device.indexOf("XA2") != -1) url = docAcr2URL;
  else if (device.indexOf("XCR3") != -1) url = docXpla3URL;
  else if (device.indexOf("XV") != -1) url = doc95xvURL;
  else if (device.indexOf("XL") != -1) url = doc95xlURL;
  else if (device.indexOf("XA") != -1) url = doc95xaURL;
  else url = doc95URL;

  popWin(url);
}

function priceDev(device) {
  var url = "http://toolbox.xilinx.com/cgi-bin/xilinx.storefront/1816638537/Catalog";
  popWin(url);
}

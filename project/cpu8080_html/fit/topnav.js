function popWin(url) {
  var win = window.open(url, 'win',
              'location=yes,directories=yes,menubar=yes,toolbar=yes,status=yes,scrollbars=yes,resizable=yes,width=800,height=600');
  win.focus();
}

function openTab(type, device) {
  var url = rootURL;
  switch (type) {
    case 0: url = rootURL; break;
    case 1:
      if (device.indexOf('XC2') != -1) url += prodURL + xbrURL;
      else if (device.indexOf('XA2') != -1) url += prodURL + acr2URL;
      else if (device.indexOf('XCR3') != -1) url += prodURL + xpla3URL;
      else if (device.indexOf('XV') != -1) url += prodURL + xc9500xvURL;
      else if (device.indexOf('XL') != -1) url += prodURL + xc9500xlURL;
      else if (device.indexOf('XA') != -1) url += prodURL + xa9500xlURL;
      else url += prodURL + xc9500URL;
      break;
    case 2: url += marketURL; break;
    case 3: url = supportURL; break;
    case 4: url += educationURL; break;
    case 5: url = buyURL; break;
    case 6: url += contactURL; break;
    case 7: url += searchURL; break;
    default: url = rootURL;
  }

  popWin(url);
}

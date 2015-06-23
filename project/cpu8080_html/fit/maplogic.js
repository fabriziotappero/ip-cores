function showFB(fb) { parent.leftnav.showFB(fb); }
function showMC(mc) { parent.leftnav.showAppletMC(mc); }
function showEqn(sig) { parent.leftnav.showEqn(sig); }
function showPin(pin) { parent.leftnav.showAppletPin(pin); }
function showLegend(url) { parent.leftnav.showLegend(url, 650, 350); }
function showTop() { parent.leftnav.showTop(); }

function Sort(x) {
  switch (x) {
    case 0: parent.leftnav.showMappedLogics(0); break;
    case 1: parent.leftnav.showMappedLogics(2); break;
    case 2: parent.leftnav.showMappedLogics(4); break;
    case 10: parent.leftnav.showMappedInputs(0); break;
    case 11: parent.leftnav.showMappedInputs(2); break;
    case 12: parent.leftnav.showMappedInputs(4); break;
    case 20: parent.leftnav.showUnMappedLogics(0); break;
    case 21: parent.leftnav.showUnMappedLogics(2); break;
    case 22: parent.leftnav.showUnMappedLogics(4); break;
    case 30: parent.leftnav.showUnMappedInputs(0); break;
    case 31: parent.leftnav.showUnMappedInputs(2); break;
    case 32: parent.leftnav.showUnMappedInputs(4); break;
  }
}

var infoList = new Array();
var warnList = new Array();
var errorList = new Array();

function updateError(type) {
  with (document.options) {
    switch (type) {
    case 0:
      if (info.checked) parent.leftnav.document.options.info.value = 1;
      else              parent.leftnav.document.options.info.value = 0;
      break;

    case 1:
      if (warn.checked) parent.leftnav.document.options.warn.value = 1;
      else              parent.leftnav.document.options.warn.value = 0;
      break;

    case 2:
      if (error.checked) parent.leftnav.document.options.error.value = 1;
      else               parent.leftnav.document.options.error.value = 0;
      break;
    }
  }

  parent.leftnav.showError();
}

function init() {
  if (!document.options) return;
  with (document.options) {
    if (parent.leftnav.document.options.info.value == 1)  info.checked = 1;
    else                                                  info.checked = 0;
    if (parent.leftnav.document.options.warn.value == 1)  warn.checked = 1;
    else                                                  warn.checked = 0;
    if (parent.leftnav.document.options.error.value == 1) error.checked = 1;
    else                                                  error.checked = 0;

  }
}

function showError(url) { parent.leftnav.showErrorLink(url); }

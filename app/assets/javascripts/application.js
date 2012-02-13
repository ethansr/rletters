//= require jquery
//= require jquery_ujs
//= require jquery_mobile
//= require_tree .

// Configure defaults for jQuery Mobile on all pages
//$(document).bind("mobileinit", function(){
//});

// Don't hide the toolbars on a tap
$('div[data-role=page]').live('pageinit', function (event){ 
  $.mobile.fixedToolbars.setTouchToggleEnabled(false);
});

// Load up the Google Visualization API
google.load('visualization', '1.0', {'packages':['corechart']});

// Call the given function only if it's defined, designed
// to be used in window.setTimeout handlers when we may have
// closed/removed from the DOM the page that contains the
// function referenced in window.setTimeout.
function callIfDefined(funcName) {
  // If it's not defined, just do nothing
  if (eval("typeof " + funcName) == 'function') {
    eval(funcName + '()');
  }
}
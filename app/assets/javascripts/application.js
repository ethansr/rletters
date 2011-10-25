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


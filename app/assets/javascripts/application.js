//= require jquery
//= require jquery_ujs
//= require jquery_mobile
//= require_tree .

// Configure defaults for jQuery Mobile on all pages
$(document).bind("mobileinit", function(){
  // Don't hide the toolbars on a tap
  $.mobile.fixedToolbars.setTouchToggleEnabled(false);
});


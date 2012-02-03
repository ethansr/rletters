//= require jquery
//= require jquery_ujs
//= require jquery_mobile

// The JS files here have to be loaded in a certain order, so make sure
// to use 'require' manually instead of 'require_tree'.
//= require raphael
//= require g.raphael
//= require g.line

//= require search
//= require user

// Configure defaults for jQuery Mobile on all pages
//$(document).bind("mobileinit", function(){
//});

// Don't hide the toolbars on a tap
$('div[data-role=page]').live('pageinit', function (event){ 
  $.mobile.fixedToolbars.setTouchToggleEnabled(false);
});


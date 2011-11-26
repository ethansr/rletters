// ---------------------------------------------------------------------------
// Patch in Google Analytics for jQuery Mobile

// We have to put the loading code in the <head>, as it's got to reference
// the APP_CONFIG variables (FIXME: can we use CoffeeScript, or something 
// else, to compile in some Ruby code in our JS?)

// Add a page view on every jQM page load
$( document ).bind( "pageload", function(event, data){
  url = '/';
  if (data.dataUrl) { url = data.dataUrl; }
  _gaq.push(['_trackPageview', url]);
});

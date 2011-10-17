// ---------------------------------------------------------------------------
// Collapsible list for facets, <= 768px

function createCollapsibleList() {
  var leftColumn = $('div.ui-page-active').find('div.leftcolumn');
  var facetList = $('div.ui-page-active').find('ul.facetlist');
  
  if (leftColumn.length && facetList.length) {
    var facetButtonText = $('li.filterheader').text();
    var facetCollapse = $(document.createElement('div')).attr('class', 'facetcollapse').append($(document.createElement('h3')).text(facetButtonText))
    facetList.clone().appendTo(facetCollapse);
    facetCollapse.appendTo(leftColumn);
    facetCollapse.collapsible({theme:'c',refresh:true,collapsed:true});
  }
}
function destroyCollapsibleList() {
  $('div.ui-page-active').find('div.facetcollapse').remove();
}

function checkCollapsibleList() {
  var width = $(window).width();
  var facetCollapsible = $('div.ui-page-active').find('div.facetcollapse');
  
  if (width <= 768 && facetCollapsible.length == 0)
    createCollapsibleList();
  else if (width > 768 && facetCollapsible.length != 0)
    destroyCollapsibleList();
}

// We need to look for page resizes on both window-resize, and on any time
// a new page is shown
$(window).resize( function() { checkCollapsibleList(); });
$('[data-role=page]').live('pageshow', function (event, ui) { checkCollapsibleList(); });
$(window).load( function() { checkCollapsibleList(); });
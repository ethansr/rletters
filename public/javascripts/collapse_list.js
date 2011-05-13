
function createCollapsibleList() {
  var rightColumn = $('div.ui-page-active').find('div.rightcolumn');
  var facetList = $('div.ui-page-active').find('ul.facet-list');
  
  if (rightColumn.length && facetList.length) {
    $(document.createElement('div')).attr('class', 'facet-collapse').append($(document.createElement('h3')).text('Filter and Search...')).append(facetList).appendTo(rightColumn).collapsible({theme:'c',refresh:true,collapsed:true});
  }
}
function destroyCollapsibleList() {
  var facetList = $('div.ui-page-active').find('ul.facet-list');
  
  if (facetList.length) {
    $('div.rightcolumn').append(facetList);
    $('div.ui-page-active').find('div.facet-collapse').remove();
  }
}

function checkCollapsibleList() {
  var width = $(window).width();
  var facetCollapsible = $('div.ui-page-active').find('div.facet-collapse');
  
  if (width <= 480 && facetCollapsible.length == 0)
    createCollapsibleList();
  else if (width > 480 && facetCollapsible.length != 0)
    destroyCollapsibleList();
}

// We need to look for page resizes on both window-resize, and on any time
// a new page is shown
$(window).resize( function() { checkCollapsibleList(); });
$('[data-role=page]').live('pageshow', function (event, ui) { checkCollapsibleList(); });
checkCollapsibleList();

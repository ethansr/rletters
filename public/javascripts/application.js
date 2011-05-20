
// ---------------------------------------------------------------------------
// Google Bookmark Bubble

window.addEventListener('load', function() {
  window.setTimeout(function() {
    var bubble = new google.bookmarkbubble.Bubble();

    bubble.hasHashParameter = function() {
      if (!window.localStorage.bookmarkBubble)
        return false;
      return window.localStorage.bookmarkBubble > 0;
    };

    bubble.setHashParameter = function() {
      if (!this.hasHashParameter()) {
        window.localStorage.bookmarkBubble = 1;
      }
    };
    
    bubble.showIfAllowed();
  }, 1000);
}, false);

// ---------------------------------------------------------------------------
// Locale form on options page

function localeRedirect() {
  var form = $('#localeform');
  if (form.length) {
    var idx = form.locale.selectedIndex;
    var page = '/' + form.locale.options[idx].value;
    $.mobile.changePage(page);
  }
}

// ---------------------------------------------------------------------------
// Collapsible list on iPhone for index page sidebar

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

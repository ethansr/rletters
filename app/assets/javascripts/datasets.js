// ---------------------------------------------------------------------------
// AJAX support for datasets#index and #show

function killDatasetTimer() {
  var datasetList = $.mobile.activePage.find('div.dataset_list');
  if (datasetList.length == 0)
    return;
  
  timer = datasetList.data('timeout')
  if (typeof(timer) != 'undefined') {
    window.clearTimeout(timer);
  }
}

function updateDatasetList() {
  var datasetList = $.mobile.activePage.find('div.dataset_list');
  if (datasetList.length == 0)
    return;
  
  var ajax_url = datasetList.attr('data-fetch-url');
  
  datasetList.load(ajax_url,
    function() {
      $(this).data('timeout', window.setTimeout(updateDatasetList, 4000));
      $(this).find('ul').listview().trigger('updatelayout');
    });
}

function killTaskTimer() {
  var datasetList = $.mobile.activePage.find('div.dataset_list');
  if (datasetList.length == 0)
    return;
  
  timer = datasetList.data('timeout')
  if (typeof(timer) != 'undefined') {
    window.clearTimeout(timer);
  }
}

function updateTaskList() {
  var taskList = $.mobile.activePage.find('div.dataset_task_list');
  if (taskList.length == 0)
    return;
  
  var ajax_url = taskList.attr('data-fetch-url');
  
  taskList.load(ajax_url,
    function() {
      window.setTimeout(updateTaskList, 4000);
      $(this).find('ul').listview().trigger('updatelayout');
    });
}

$('div[data-role=page]').live('pageshow', function (event, data) { updateDatasetList(); });
$('div[data-role=page]').live('pageshow', function (event, data) { updateTaskList(); });

$('div[data-role=page]').live('pagehide', function (event, data) { killDatasetTimer(); });
$('div[data-role=page]').live('pagehide', function (event, data) { killTaskTimer(); });

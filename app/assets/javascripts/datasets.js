// ---------------------------------------------------------------------------
// AJAX support for datasets#index and #show

function updateDatasetList() {
  var datasetList = $.mobile.activePage.find('div.dataset_list');
  if (datasetList.length == 0)
    return;
  
  var ajax_url = datasetList.attr('data-fetch-url');
  
  datasetList.load('').load(ajax_url,
    function() {
      window.setTimeout(updateDatasetList, 4000);
      $(this).find('ul').listview();
    });
}

function updateTaskList() {
  var taskList = $.mobile.activePage.find('div.dataset_task_list');
  if (taskList.length == 0)
    return;
  
  var ajax_url = taskList.attr('data-fetch-url');
  
  taskList.load('').load(ajax_url,
    function() {
      window.setTimeout(updateTaskList, 4000);
      $(this).find('ul').listview();
    });
}

$('div[data-role=page]').live('pageinit', function (event, ui) { updateDatasetList(); });
$('div[data-role=page]').live('pageinit', function (event, ui) { updateTaskList(); });

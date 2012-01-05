# -*- encoding : utf-8 -*-
require 'minitest_helper'

class DatasetsControllerTest < ActionController::TestCase
  tests DatasetsController
  fixtures :datasets, :dataset_entries, :users
  
  setup do
    @user = users(:john)
    session[:user_id] = @user.to_param
  end

  test "should redirect to users if not logged in" do
    session[:user_id] = nil
    get :index
    assert_redirected_to user_path
  end

  test "should get index" do
    get :index
    assert_response :success
    refute_nil assigns(:datasets)
  end
  
  test "index should list the one dataset" do
    get :index
    assert_select 'ul li a', "Test Dataset\n10"
  end
  
  test "index should list pending analysis tasks" do
    task = AnalysisTask.new({ :name => 'test', :dataset => datasets(:one) })
    task.save
    
    get :index
    assert_select "li[data-theme=e]", 'You have one analysis task pending...'
  end
  
  test "index should not show completed analysis tasks" do
    task = AnalysisTask.new({ :name => 'test', :dataset => datasets(:one) })
    task.finished_at = Time.zone.now
    task.save
    
    get :index
    assert_select "li[data-theme=e]", false
  end
  
  test "should get the new dataset form" do
    get :new
    assert_response :success
  end
  
  test "new form should have field for name, solr query" do
    get :new, { :q => '*:*', :fq => nil, :qt => 'precise' }
    assert_select "input[name='dataset[name]']"
    assert_select "input[name=q][value='*:*']"
    assert_select "input[name='fq[]']", 0
    assert_select "input[name=qt][value=precise]"
  end
  
  test "should create dataset (DJ)" do
    SolrExamples.stub :dataset_precise_all
    
    expected_job = Jobs::CreateDataset.new(users(:john).to_param,
      'Test Dataset', '*:*', nil, 'precise')
    Delayed::Job.expects(:enqueue).with(expected_job).once
    
    post :create, { :dataset => { :name => 'Test Dataset' }, 
      :q => '*:*', :fq => nil, :qt => 'precise' }
    assert_redirected_to datasets_path
  end
    
  test "should show dataset" do
    get :show, :id => datasets(:one).to_param
    assert_response :success
  end
  
  test "should show correct number of entries" do
    get :show, :id => datasets(:one).to_param
    assert_select "ul li p:first-of-type", 'Number of documents: 10'
  end
  
  test "should show pending analysis tasks" do
    task = AnalysisTask.new({ :name => 'test', :dataset => datasets(:one) })
    task.save
    
    get :show, :id => datasets(:one).to_param
    assert_select "li[data-theme=e]", '1 analysis task pending for this dataset...'
  end
  
  test "should show completed analysis tasks" do
    task = AnalysisTask.new({ :name => 'test', :dataset => datasets(:one) })
    task.finished_at = Time.zone.now
    task.save
    
    get :show, :id => datasets(:one).to_param
    assert_select "li:nth-of-type(4)" do
      assert_select "a[href='#{download_dataset_path(datasets(:one), :task_id => task.to_param)}']", 'test'
    end
  end
  
  test "should get delete form" do
    get :delete, :id => datasets(:one).to_param
    assert_response :success
  end
  
  test "destroy cancel button should work" do
    Delayed::Job.expects(:enqueue).never
    delete :destroy, :id => datasets(:one).to_param, :cancel => true
    
    assert_redirected_to dataset_path(datasets(:one))
  end

  test "should destroy dataset (DJ)" do
    expected_job = Jobs::DestroyDataset.new(users(:john).to_param, datasets(:one).to_param)
    Delayed::Job.expects(:enqueue).with(expected_job).once
    
    delete :destroy, :id => datasets(:one).to_param
    assert_redirected_to datasets_path
  end
  
  test "should download result files" do
    # Execute the export job, which should create an AnalysisTask
    SolrExamples.stub :precise_one_doc
    Jobs::ExportCitations.new(users(:john).to_param,
      datasets(:one).to_param, :bibtex).perform
    
    # Double-check that the task is created
    assert_equal 1, datasets(:one).analysis_tasks.count
    task = datasets(:one).analysis_tasks[0]
    refute_nil task
    
    # Get the download page
    get :download, :id => datasets(:one).to_param, :task_id => task.to_param
    assert_response :success
    assert_equal 'application/zip', @response.content_type
    refute_equal 0, @response.body.length
  end
end

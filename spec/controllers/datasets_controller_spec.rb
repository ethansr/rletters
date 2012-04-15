# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DatasetsController do
  
  fixtures :datasets, :dataset_entries, :users
  login_user(:john)
  
  describe '#index' do
    context "when not logged in" do
      logout_user

      it "redirects to the users page" do
        get :index
        response.should redirect_to(user_path)
      end
    end
    
    context "when logged in" do
      it "loads successfully" do
        get :index
        response.should be_success
      end
    end
  end
  
  describe '#dataset_list' do
    context "when logged in" do
      it "loads successfully" do
        get :dataset_list
        response.should be_success
      end
      
      it "assigns the list of datsets" do
        get :dataset_list
        assigns(:datasets).should eq(users(:john).datasets)
      end
    end
  end
  
  describe '#new' do
    it 'loads successfully' do
      get :new
      response.should be_success
    end
    
    it 'assigns dataset' do
      get :new
      assigns(:dataset).should be_new_record
    end
  end
  
  describe '#create' do
    it 'creates a delayed job' do
      Examples.stub_with(/localhost\/solr\/.*/, :dataset_precise_all)

      expected_job = Jobs::CreateDataset.new(
        :user_id => users(:john).to_param,
        :name => 'Test Dataset',
        :q => '*:*',
        :fq => nil,
        :qt => 'precise')
      Delayed::Job.should_receive(:enqueue).with(expected_job).once
      
      post :create, { :dataset => { :name => 'Test Dataset' }, 
        :q => '*:*', :fq => nil, :qt => 'precise' }
    end
    
    it 'redirects to index when done' do
      post :create, { :dataset => { :name => 'Test Dataset' }, 
        :q => '*:*', :fq => nil, :qt => 'precise' }
      response.should redirect_to(datasets_path)
    end
  end
  
  describe '#show' do
    context 'without clear_failed' do
      it 'loads successfully' do
        get :show, :id => datasets(:one).to_param
        response.should be_success
      end
    
      it 'assigns dataset' do
        get :show, :id => datasets(:one).to_param
        assigns(:dataset).should eq(datasets(:one))
      end
    end
    
    context 'with clear_failed' do
      before(:each) do
        task = datasets(:one).analysis_tasks.create(:name => 'failure')
        task.failed = true
      end
      
      it 'loads successfully' do
        get :show, :id => datasets(:one).to_param, :clear_failed => true
        response.should be_success
      end
      
      it 'deletes the failed task' do
        get :show, :id => datasets(:one).to_param, :clear_failed => true
        datasets(:one).analysis_tasks.failed.count.should eq(0)
      end
      
      it 'sets the flash' do
        get :show, :id => datasets(:one).to_param, :clear_failed => true
        flash[:notice].should_not be_nil
      end
    end
  end
  
  describe '#delete' do
    it 'loads successfully' do
      get :delete, :id => datasets(:one).to_param
      response.should be_success
    end
    
    it 'assigns dataset' do
      get :delete, :id => datasets(:one).to_param
      assigns(:dataset).should eq(datasets(:one))
    end
  end
  
  describe '#destroy' do
    context 'when cancel is not passed' do
      it 'creates a delayed job' do
        expected_job = Jobs::DestroyDataset.new(
          :user_id => users(:john).to_param,
          :dataset_id => datasets(:one).to_param)
        Delayed::Job.should_receive(:enqueue).with(expected_job).once

        delete :destroy, :id => datasets(:one).to_param
      end
      
      it 'redirects to index when done' do
        delete :destroy, :id => datasets(:one).to_param
        response.should redirect_to(datasets_path)
      end
    end
    
    context 'when cancel is passed' do
      it 'does not create a delayed job' do
        Delayed::Job.should_not_receive(:enqueue)
        delete :destroy, :id => datasets(:one).to_param, :cancel => true
      end
      
      it 'redirects to the dataset page' do
        delete :destroy, :id => datasets(:one).to_param, :cancel => true
        response.should redirect_to(datasets(:one))
      end
    end
  end

  describe '#add' do
    context 'when an invalid document is passed' do
      it 'raises an exception' do
        Examples.stub_with(/localhost\/solr\/.*/, :standard_empty_search)
        
        expect {
          get :add, :dataset_id => datasets(:one).to_param, :shasum => 'fail'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when all parameters are valid' do
      before(:each) do
        Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
      end
      
      it 'adds to the dataset' do
        expect {
          get :add, :dataset_id => datasets(:one).to_param, :shasum => '00972c5123877961056b21aea4177d0dc69c7318'
        }.to change{datasets(:one).entries.count}.by(1)
      end

      it 'redirects to the dataset page' do
        get :add, :dataset_id => datasets(:one).to_param, :shasum => '00972c5123877961056b21aea4177d0dc69c7318'
        response.should redirect_to(dataset_path(datasets(:one)))
      end
    end
  end
  
  describe '#task_start' do
    context 'when an invalid class is passed' do
      it 'raises an exception' do
        expect {
          get :task_start, :id => datasets(:one).to_param, :class => 'ThisIsNoClass'
        }.to raise_error
      end
    end
    
    context 'when Base is passed' do
      it 'raises an exception' do
        expect {
          get :task_start, :id => datasets(:one).to_param, :class => 'Base'
        }.to raise_error
      end
    end
    
    context 'when a valid class is passed' do
      it 'does not raise an exception' do
        expect {
          get :task_start, :id => datasets(:one).to_param, :class => 'ExportCitations', :job_params => { :format => 'bibtex' }
        }.to_not raise_error
      end
      
      it 'enqueues a job' do
        expected_job = Jobs::Analysis::ExportCitations.new(
          :user_id => users(:john).to_param,
          :dataset_id => datasets(:one).to_param,
          :format => 'bibtex')
        Delayed::Job.should_receive(:enqueue).with(expected_job).once
        
        get :task_start, :id => datasets(:one).to_param, :class => 'ExportCitations', :job_params => { :format => 'bibtex' }
      end
      
      it 'redirects to the dataset page' do
        get :task_start, :id => datasets(:one).to_param, :class => 'ExportCitations', :job_params => { :format => 'bibtex' }
        response.should redirect_to(dataset_path(datasets(:one)))
      end
    end
  end
  
  describe '#task_view' do
    context 'when an invalid task ID is passed' do
      it 'raises an exception' do
        expect {
          get :task_view, :id => datasets(:one).to_param, :task_id => '12312312312312', :view => 'test'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context 'when a valid task ID is passed' do
      before(:each) do
        @task = datasets(:one).analysis_tasks.create(:name => 'test', :job_type => 'ExportCitations')
      end
      
      after(:each) do
        @task.destroy
      end
      
      it 'does not raise an exception' do
        expect {
          get :task_view, :id => datasets(:one).to_param, :task_id => @task.to_param, :view => 'start'
        }.to_not raise_error
      end
    end
  end
  
  describe '#task_download' do
    before(:each) do
      # Execute an export job, which should create an AnalysisTask
      Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
      Jobs::Analysis::ExportCitations.new(
        :user_id => users(:john).to_param,
        :dataset_id => datasets(:one).to_param,
        :format => :bibtex).perform

      # Double-check that the task is created
      datasets(:one).analysis_tasks.should have(1).item
      datasets(:one).analysis_tasks[0].should be
      
      @task = datasets(:one).analysis_tasks[0]
    end
    
    after(:each) do
      @task.destroy
    end
    
    it 'loads successfully' do
      get :task_download, :id => datasets(:one).to_param, :task_id => @task.to_param
      response.should be_success
    end
    
    it 'has the right MIME type' do
      get :task_download, :id => datasets(:one).to_param, :task_id => @task.to_param
      response.content_type.should eq('application/zip')
    end
    
    it 'sends some data' do
      get :task_download, :id => datasets(:one).to_param, :task_id => @task.to_param
      response.body.length.should be > 0
    end
  end
  
  describe "#task_destroy" do
    context 'when an invalid task ID is passed' do
      it 'raises an exception' do
        expect {
          get :task_destroy, :id => datasets(:one).to_param, :task_id => '12312312312312'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context 'when cancel is pressed' do
      before(:each) do
        @task = datasets(:one).analysis_tasks.create(:name => 'test', :job_type => 'ExportCitations')
      end
      
      after(:each) do
        @task.destroy
      end
      
      it "doesn't delete the task" do
        expect {
          get :task_destroy, :id => datasets(:one).to_param, :task_id => @task.to_param, :cancel => true
        }.to_not change{datasets(:one).analysis_tasks.count}
      end
      
      it 'redirects to the dataset page' do
        get :task_destroy, :id => datasets(:one).to_param, :task_id => @task.to_param, :cancel => true
        response.should redirect_to(dataset_path(datasets(:one)))
      end
    end
    
    context "when cancel is not pressed" do
      before(:each) do
        @task = datasets(:one).analysis_tasks.create(:name => 'test', :job_type => 'ExportCitations')
      end
      
      it "deletes the task" do
        expect {
          get :task_destroy, :id => datasets(:one).to_param, :task_id => @task.to_param
        }.to change{datasets(:one).analysis_tasks.count}.by(-1)
      end
      
      it 'redirects to the dataset page' do
        get :task_destroy, :id => datasets(:one).to_param, :task_id => @task.to_param
        response.should redirect_to(dataset_path(datasets(:one)))
      end
    end
  end
  
end

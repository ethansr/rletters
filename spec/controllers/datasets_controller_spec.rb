# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DatasetsController do
  
  fixtures :datasets, :dataset_entries, :users
  
  before(:each) do
    @user = users(:john)
    session[:user_id] = @user.to_param
  end
  
  describe '#index' do
    context "when not logged in" do
      before(:each) do
        @user = nil
        session[:user_id] = nil
      end

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
      
      it "assigns the list of datsets" do
        get :index
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
      SolrExamples.stub :dataset_precise_all

      expected_job = Jobs::CreateDataset.new(users(:john).to_param,
        'Test Dataset', '*:*', nil, 'precise')
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
    it 'loads successfully' do
      get :show, :id => datasets(:one).to_param
      response.should be_success
    end
    
    it 'assigns dataset' do
      get :show, :id => datasets(:one).to_param
      assigns(:dataset).should eq(datasets(:one))
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
        expected_job = Jobs::DestroyDataset.new(users(:john).to_param,
          datasets(:one).to_param)
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
  
  describe '#start_job' do
    context 'when an invalid job name is passed' do
      it 'raises an exception' do
        expect {
          get :start_job, :id => datasets(:one).to_param, :job_name => 'start_ThisIsNoClass'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context 'when a valid job name is passed' do
      it 'does not raise an exception' do
        expect {
          get :start_job, :id => datasets(:one).to_param, :job_name => 'start_ExportCitations', :job_params => { :format => 'bibtex' }
        }.to_not raise_error
      end
      
      it 'enqueues a job' do
        expected_job = Jobs::ExportCitations.new(users(:john).to_param,
          datasets(:one).to_param, 'bibtex')
        Delayed::Job.should_receive(:enqueue).with(expected_job).once
        
        get :start_job, :id => datasets(:one).to_param, :job_name => 'start_ExportCitations', :job_params => { :format => 'bibtex' }
      end
      
      it 'redirects to the dataset page' do
        get :start_job, :id => datasets(:one).to_param, :job_name => 'start_ExportCitations', :job_params => { :format => 'bibtex' }
        response.should redirect_to(dataset_path(datasets(:one)))
      end
    end
  end
  
  describe '#download' do
    before(:each) do
      # Execute an export job, which should create an AnalysisTask
      SolrExamples.stub :precise_one_doc
      Jobs::ExportCitations.new(users(:john).to_param,
        datasets(:one).to_param, :bibtex).perform

      # Double-check that the task is created
      datasets(:one).analysis_tasks.should have(1).item
      datasets(:one).analysis_tasks[0].should be
      
      @task = datasets(:one).analysis_tasks[0]
    end
    
    after(:each) do
      @task.destroy
    end
    
    it 'loads successfully' do
      get :download, :id => datasets(:one).to_param, :task_id => @task.to_param
      response.should be_success
    end
    
    it 'has the right MIME type' do
      get :download, :id => datasets(:one).to_param, :task_id => @task.to_param
      response.content_type.should eq('application/zip')
    end
    
    it 'sends some data' do
      get :download, :id => datasets(:one).to_param, :task_id => @task.to_param
      response.body.length.should be > 0
    end
  end
  
end

# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Dataset do
  
  fixtures :datasets, :users
  
  describe '#valid?' do
    context 'when empty' do
      before(:each) do
        @dataset = Dataset.new
      end
      
      it "isn't valid" do 
        @dataset.should_not be_valid
      end
    end
    
    context 'when name is not specified' do
      before(:each) do
        @dataset = Dataset.new
        @dataset.user = users(:john)
      end
      
      it "isn't valid" do
        @dataset.should_not be_valid
      end
    end
    
    context 'when user is not specified' do
      before(:each) do
        @dataset = Dataset.new({ :name => 'Test Dataset' })
      end
      
      it "isn't valid" do
        @dataset.should_not be_valid
      end
    end
    
    context 'when user and name are specified' do
      before (:each) do
        @dataset = Dataset.new({ :name => 'Test Dataset' })
        @dataset.user = users(:john)
      end
      
      it "is valid" do
        @dataset.should be_valid
      end
    end
  end
  
  describe '#analysis_tasks' do
    context 'when an analysis task is created' do
      before(:each) do
        @dataset = Dataset.new({ :name => 'The Dataset'})
        @dataset.user = users(:john)
        @dataset.save.should be_true
        
        @task = AnalysisTask.new({ :name => 'test', :dataset => @dataset })
        @task.save.should be_true
      end
      
      after(:each) do
        @task.destroy
        @dataset.destroy
      end
      
      it "has one analysis task" do
        @dataset.analysis_tasks.should have(1).items
      end
      
      it "points to the right analysis task" do
        @dataset.analysis_tasks[0].name.should eq('test')
      end
    end
  end
  
  describe '#entries' do
    context 'when creating a new dataset' do
      before(:each) do
        @dataset = users(:alice).datasets.build({ :name => 'Alices Dataset' })
        @dataset.entries.build({ :shasum => '00cdb0f945c1e1d7b7789cd8178f3232a57fee34' })
        @dataset.entries.build({ :shasum => '00dbffbfff2d18a74ed5f8895fa9f515bf38bf5f' })
        @dataset.save.should be_true
      end
      
      it "is connected to the user" do
        users(:alice).datasets.should have(1).items
      end
      
      it "has the right number of entries" do
        @dataset.entries.should have(2).items
      end
    end
  end
end

# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::PlotDates do
  
  fixtures :datasets, :users
  
  it_should_behave_like 'an analysis job'
  
  context "when all parameters are valid" do
    before(:each) do
      Examples.stub_with(/localhost/, :precise_one_doc)
      @dataset = users(:alice).datasets.build({ :name => 'Test' })
      @dataset.entries.build({ :shasum => '00972c5123877961056b21aea4177d0dc69c7318' })
      @dataset.save.should be_true
      
      Jobs::Analysis::PlotDates.new(:user_id => users(:alice).to_param,
        :dataset_id => @dataset.to_param).perform
    end
    
    after(:each) do
      @dataset.analysis_tasks[0].destroy
    end
    
    it_should_behave_like 'an analysis job with a file'
    
    it 'names the task correctly' do
      @dataset.analysis_tasks[0].name.should eq("Plot dataset by date")
    end
    
    it 'creates good YAML' do
      arr = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      arr.should be_an(Array)
    end
    
    it 'fills in the right values' do
      arr = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      arr[0][0].should eq('2008')
      arr[0][1].should eq(1)
    end
  end
  
end
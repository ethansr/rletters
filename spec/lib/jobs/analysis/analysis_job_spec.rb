# -*- encoding : utf-8 -*-
require 'spec_helper'

shared_examples_for 'an analysis job' do
  context "when the wrong user is specified" do
    it "raises an exception" do
      params ||= {}
      
      expect {
        described_class.new(params.merge({ :user_id => users(:alice).to_param, 
          :dataset_id => datasets(:one).to_param })).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when an invalid user is specified" do
    it "raises an exception" do
      params ||= {}
      
      expect {
        described_class.new(params.merge({ :user_id => '123123123123123', 
          :dataset_id => datasets(:one).to_param })).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when an invalid dataset is specified" do
    it "raises an exception" do
      params ||= {}
      
      expect {
        described_class.new(params.merge({ :user_id => users(:john).to_param, 
          :dataset_id => '123123123123' })).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

shared_examples_for 'an analysis job without a file' do
  it "creates an analysis task" do
    @dataset.analysis_tasks.should have(1).items
    @dataset.analysis_tasks[0].should be
  end
end

shared_examples_for 'an analysis job with a file' do
  it_should_behave_like 'an analysis job without a file'
  
  it "makes a file for the task" do
    @dataset.analysis_tasks[0].result_file.should be
  end
    
  it "creates the file on disk" do
    File.exists?(@dataset.analysis_tasks[0].result_file.filename).should be_true
  end
end

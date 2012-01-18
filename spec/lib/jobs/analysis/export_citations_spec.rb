# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'zip/zip'

describe Jobs::Analysis::ExportCitations do
  
  fixtures :datasets, :users
  
  context "when the wrong user is specified" do
    it "raises an exception" do
      expect {
        Jobs::Analysis::ExportCitations.new(users(:alice).to_param, 
          datasets(:one).to_param, :bibtex).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when an invalid user is specified" do
    it "raises an exception" do
      expect {
        Jobs::Analysis::ExportCitations.new('123123123123123', 
          datasets(:one).to_param, :bibtex).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when an invalid dataset is specified" do
    it "raises an exception" do
      expect {
        Jobs::Analysis::ExportCitations.new(users(:john).to_param, 
          '123123123123', :bibtex).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when an invalid format is specified" do
    it "raises an exception" do
      expect {
        Jobs::Analysis::ExportCitations.new(users(:john).to_param,
          datasets(:one).to_param, :notaformat).perform
      }.to raise_error(ArgumentError)
    end
  end
  
  context "when the format is a string" do
    it "works anyway" do
      expect {
        SolrExamples.stub :precise_one_doc
        @dataset = users(:alice).datasets.build({ :name => 'Test' })
        @dataset.entries.build({ :shasum => '00972c5123877961056b21aea4177d0dc69c7318' })
        @dataset.save.should be_true

        Jobs::Analysis::ExportCitations.new(users(:alice).to_param,
          @dataset.to_param, 'bibtex').perform
      }.to_not raise_error
    end
  end
  
  context "when all parameters are valid" do
    before(:each) do
      SolrExamples.stub :precise_one_doc
      @dataset = users(:alice).datasets.build({ :name => 'Test' })
      @dataset.entries.build({ :shasum => '00972c5123877961056b21aea4177d0dc69c7318' })
      @dataset.save.should be_true
      
      Jobs::Analysis::ExportCitations.new(users(:alice).to_param,
        @dataset.to_param, :bibtex).perform
    end
    
    after(:each) do
      @dataset.analysis_tasks[0].destroy
    end
    
    it "creates an analysis task" do
      @dataset.analysis_tasks.should have(1).items
      @dataset.analysis_tasks[0].should be
    end
    
    it "names the task correctly" do
      @dataset.analysis_tasks[0].name.should eq("Export as BIBTEX")
    end
    
    it "makes a file for the task" do
      @dataset.analysis_tasks[0].result_file.should be
    end
    
    it "creates the file on disk" do
      File.exists?(@dataset.analysis_tasks[0].result_file.filename).should be_true
    end
    
    it "creates a proper ZIP file" do
      Zip::ZipFile.open(@dataset.analysis_tasks[0].result_file.filename) do |zf|
        zf.should have(1).entry
      end
    end
  end
  
end

# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'zip/zip'

describe Jobs::Analysis::ExportCitations do
  
  fixtures :datasets, :users
  
  it_should_behave_like 'an analysis job' do
    let(:params) { { :format => :bibtex } }
  end
  
  context "when an invalid format is specified" do
    it "raises an exception" do
      expect {
        Jobs::Analysis::ExportCitations.new(:user_id => users(:john).to_param,
          :dataset_id => datasets(:one).to_param,
          :format => :notaformat).perform
      }.to raise_error(ArgumentError)
    end
  end
  
  context "when the format is a string" do
    it "works anyway" do
      expect {
        Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
        @dataset = users(:alice).datasets.build({ :name => 'Test' })
        @dataset.entries.build({ :shasum => '00972c5123877961056b21aea4177d0dc69c7318' })
        @dataset.save.should be_true

        Jobs::Analysis::ExportCitations.new(:user_id => users(:alice).to_param,
          :dataset_id => @dataset.to_param, :format => 'bibtex').perform
      }.to_not raise_error
    end
  end
  
  context "when all parameters are valid" do
    before(:each) do
      Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
      @dataset = users(:alice).datasets.build({ :name => 'Test' })
      @dataset.entries.build({ :shasum => '00972c5123877961056b21aea4177d0dc69c7318' })
      @dataset.save.should be_true
      
      Jobs::Analysis::ExportCitations.new(:user_id => users(:alice).to_param,
        :dataset_id => @dataset.to_param, :format => :bibtex).perform
    end
    
    after(:each) do
      @dataset.analysis_tasks[0].destroy
    end
    
    it_should_behave_like 'an analysis job with a file'
    
    it "names the task correctly" do
      @dataset.analysis_tasks[0].name.should eq("Export as BibTeX")
    end
    
    it "creates a proper ZIP file" do
      Zip::ZipFile.open(@dataset.analysis_tasks[0].result_file.filename) do |zf|
        zf.should have(1).entry
      end
    end
  end
  
end

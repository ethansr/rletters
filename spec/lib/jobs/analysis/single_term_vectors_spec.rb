# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::SingleTermVectors do
  
  fixtures :datasets, :users
  
  it_should_behave_like 'an analysis job'
  
  context "with a multi-document dataset" do
    before(:each) do
      Examples.stub_with(/localhost\/solr\/.*/, :precise_all_docs)
    end
    
    it "raises an exception" do
      expect {
        Jobs::Analysis::SingleTermVectors.new(:user_id => users(:john).to_param,
          :dataset_id => datasets(:one).to_param).perform
      }.to raise_error(ArgumentError)
    end
  end

  context "when all parameters are valid" do
    before(:each) do
      Examples.stub_with(/localhost\/solr\/.*/, :fulltext_one_doc)
      @dataset = users(:alice).datasets.build({ :name => 'Test' })
      @dataset.entries.build({ :shasum => '00972c5123877961056b21aea4177d0dc69c7318' })
      @dataset.save.should be_true
      
      Jobs::Analysis::SingleTermVectors.new(:user_id => users(:alice).to_param,
        :dataset_id => @dataset.to_param).perform
    end
    
    after(:each) do
      @dataset.analysis_tasks[0].destroy
    end
    
    it_should_behave_like 'an analysis job with a file'
    
    it 'names the task correctly' do
      @dataset.analysis_tasks[0].name.should eq("Term frequency information")
    end
    
    it 'creates good YAML' do
      tv = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      tv.should be_a(Hash)
    end
    
    it 'fills in the right values' do
      tv = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      tv["cornell"][:tf].should eq(3)
      tv["laboratory"][:df].should eq(2)
      tv["humboldt"][:tfidf].should eq(1.0)
    end
  end
end

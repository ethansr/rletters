# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::CreateDataset do
  
  fixtures :users
  
  context "when user is invalid" do
    it "raises an exception" do
      expect {
        Jobs::CreateDataset.new(:user_id => '123123123123', 
          :name => 'Test Dataset', :q => '*:*', :fq => nil,
          :qt => 'precise').perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when Solr fails" do
    before(:each) do
      Examples.stub_with(/localhost/, :error)
    end
    
    it "raises an exception" do
      expect {
        Jobs::CreateDataset.new(:user_id => users(:alice).to_param,
          :name => 'Test Dataset', :q => '*:*', :fq => nil,
          :qt => 'precise').perform
      }.to raise_error
      
      users(:alice).datasets.should have(0).items
    end
  end
  
  context "given precise_all Solr results" do
    before(:each) do
      Examples.stub_with(/localhost/, :dataset_precise_all)
      Jobs::CreateDataset.new(:user_id => users(:alice).to_param,
        :name => 'Test Dataset', :q => '*:*', :fq => nil,
        :qt => 'precise').perform
    end
    
    it "creates a dataset" do
      users(:alice).datasets.should have(1).items
      users(:alice).datasets[0].should be
    end
    
    it "puts the right number of items in the dataset" do
      users(:alice).datasets[0].entries.should have(10).items
    end
  end
  
  context "given precise_with_facet_koltz Solr results" do
    before(:each) do
      Examples.stub_with(/localhost/, :dataset_precise_with_facet_koltz)
      Jobs::CreateDataset.new(:user_id => users(:alice).to_param,
        :name => 'Test Dataset', :q => '*:*',
        :fq => ['authors_facet:"Amanda M. Koltz"'], 
        :qt => 'precise').perform
    end
    
    it "creates a dataset" do
      users(:alice).datasets.should have(1).items
      users(:alice).datasets[0].should be
    end
    
    it "puts the right number of items in the dataset" do
      users(:alice).datasets[0].entries.should have(1).items
    end
  end
  
  context "given search_diversity Solr results" do
    before(:each) do
      Examples.stub_with(/localhost/, :dataset_search_diversity)
      Jobs::CreateDataset.new(:user_id => users(:alice).to_param,
        :name => 'Test Dataset', :q => 'diversity', :fq => nil,
        :qt => 'standard').perform
    end
    
    it "creates a dataset" do
      users(:alice).datasets.should have(1).items
      users(:alice).datasets[0].should be
    end
    
    it "puts the right number of items in the dataset" do
      users(:alice).datasets[0].entries.should have(1).items
    end
  end
  
  context "given large Solr dataset" do
    before(:each) do
      Examples.stub_with(/localhost/, [ :long_query_one, :long_query_two, :long_query_three ])
      Jobs::CreateDataset.new(:user_id => users(:alice).to_param,
        :name => 'Long Dataset', :q => '*:*', :fq => nil,
        :qt => 'precise').perform
    end
    
    it "creates a dataset" do
      users(:alice).datasets.should have(1).items
      users(:alice).datasets[0].should be
    end
    
    it "puts the right number of items in the dataset" do
      users(:alice).datasets[0].entries.should have(2300).items
    end
  end
  
end

# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::AddToDataset do
  
  fixtures :datasets, :users

  before(:each) do
    Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
  end
  
  context "when the wrong user is specified" do
    it "raises an exception and does nothing" do      
      expect {
        expect {
          Jobs::AddToDataset.new(:user_id => users(:alice).to_param, 
                                 :dataset_id => datasets(:one).to_param,
                                 :shasum => '00972c5123877961056b21aea4177d0dc69c7318').perform
        }.to raise_error(ActiveRecord::RecordNotFound)
      }.to_not change{datasets(:one).entries.count}
    end
  end
  
  context "when an invalid user is specified" do
    it "raises an exception" do
      expect {
        Jobs::AddToDataset.new(:user_id => '123123123123123', 
                               :dataset_id => datasets(:one).to_param,
                               :shasum => '00972c5123877961056b21aea4177d0dc69c7318').perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when an invalid dataset is specified" do
    it "raises an exception" do
      expect {
        Jobs::AddToDataset.new(:user_id => users(:john).to_param, 
                               :dataset_id => '123123123123',
                               :shasum => '00972c5123877961056b21aea4177d0dc69c7318').perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when an invalid document is specified" do
    it "raises an exception" do
      # Override the stub and stub empty, because the server would return
      # no result for this
      Examples.stub_with(/localhost\/solr\/.*/, :standard_empty_search)
      
      expect {
        Jobs::AddToDataset.new(:user_id => users(:john).to_param,
                               :dataset_id => datasets(:one).to_param,
                               :shasum => 'fail').perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when the parameters are valid" do
    it "adds to the dataset" do
      expect {
        Jobs::AddToDataset.new(:user_id => users(:john).to_param, 
                               :dataset_id => datasets(:one).to_param,
                               :shasum => '00972c5123877961056b21aea4177d0dc69c7318').perform
      }.to change{datasets(:one).entries.count}.by(1)
    end
  end
  
end

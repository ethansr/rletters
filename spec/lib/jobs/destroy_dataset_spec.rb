# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::DestroyDataset do
  
  fixtures :datasets, :users
  
  context "when the wrong user is specified" do
    it "raises an exception and does not destroy a dataset" do      
      expect {
        expect {
          Jobs::DestroyDataset.new(users(:alice).to_param, 
            datasets(:one).to_param).perform
        }.to raise_error(ActiveRecord::RecordNotFound)
      }.to_not change{users(:john).datasets.count}
    end
  end
  
  context "when an invalid user is specified" do
    it "raises an exception" do
      expect {
        Jobs::DestroyDataset.new('123123123123123', 
          datasets(:one).to_param).perform        
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when an invalid dataset is specified" do
    it "raises an exception and does not destroy a dataset" do
      expect {
        expect {
          Jobs::DestroyDataset.new(users(:john).to_param, 
            '123123123123').perform
        }.to raise_error(ActiveRecord::RecordNotFound)
      }.to_not change{users(:john).datasets.count}
    end
  end
  
  context "when the parameters are valid" do
    it "destroys a dataset" do
      expect {
        Jobs::DestroyDataset.new(users(:john).to_param, 
          datasets(:one).to_param).perform        
      }.to change{users(:john).datasets.count}.by(-1)
    end
  end
  
end

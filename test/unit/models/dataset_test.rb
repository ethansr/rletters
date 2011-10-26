# -*- encoding : utf-8 -*-
require 'test_helper'

class DatasetTest < ActiveSupport::TestCase  
  test "empty dataset should be invalid" do
    dataset = Dataset.new
    assert !dataset.valid?
  end
  
  test "dataset with no name should be invalid" do
    dataset = datasets(:one)
    dataset.name = ''
    assert !dataset.valid?
  end
  
  test "dataset with no user should be invalid" do
    dataset = datasets(:one)
    dataset.user = nil
    assert !dataset.valid?
  end
  
  test "minimal dataset should be valid" do
    dataset = datasets(:one)
    assert dataset.valid?
  end
  
  test "should be able to build a dataset from scratch" do
    dataset = users(:alice).datasets.build({ :name => 'Alices Dataset' })
    dataset.entries.build({ :shasum => '00cdb0f945c1e1d7b7789cd8178f3232a57fee34' })
    dataset.entries.build({ :shasum => '00dbffbfff2d18a74ed5f8895fa9f515bf38bf5f' })
    
    assert_difference 'users(:alice).datasets.count' do
      assert dataset.save
    end
    assert_equal 2, dataset.entries.count
  end
end

# -*- encoding : utf-8 -*-
require 'minitest_helper'

class DestroyDatasetTest < ActiveSupport::TestCase
  fixtures :datasets, :users
  
  test "should not be able to destroy dataset for another user" do
    assert_no_difference('users(:john).datasets.count') do
      assert_raises ActiveRecord::RecordNotFound do
        Jobs::DestroyDataset.new(users(:alice).to_param, 
          datasets(:one).to_param).perform
      end
    end
  end
  
  test "should not be able to destroy dataset for invalid user" do
    assert_raises ActiveRecord::RecordNotFound do
      Jobs::DestroyDataset.new('123123123123123', 
        datasets(:one).to_param).perform
    end
  end
  
  test "destroying invalid dataset should not work" do
    assert_no_difference('users(:john).datasets.count') do
      assert_raises ActiveRecord::RecordNotFound do
        Jobs::DestroyDataset.new(users(:john).to_param, 
          '123123123123').perform
      end
    end
  end
  
  test "should destroy dataset" do
    assert_difference('users(:john).datasets.count', -1) do
      Jobs::DestroyDataset.new(users(:john).to_param, 
        datasets(:one).to_param).perform
    end
  end
end

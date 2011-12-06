# -*- encoding : utf-8 -*-
require 'minitest_helper'

class DestroyDatasetTest < ActiveSupport::TestCase
  fixtures :datasets, :users
  
  test "should destroy dataset" do
    assert_difference('users(:john).datasets.count', -1) do
      Jobs::DestroyDataset.new(users(:john).to_param, 
        datasets(:one).to_param).perform
    end
  end
end

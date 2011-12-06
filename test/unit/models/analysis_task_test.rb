# -*- encoding : utf-8 -*-
require 'test_helper'

class AnalysisTaskTest < ActiveSupport::TestCase
  test "analysis task without name is invalid" do
    task = AnalysisTask.new({ :dataset => datasets(:one) })
  end
  
  test "analysis task without dataset is invalid" do
    task = AnalysisTask.new({ :name => 'test' })
    assert !task.valid?
  end
  
  test "minimal analysis task is valid" do
    task = AnalysisTask.new({ :name => 'test', :dataset => datasets(:one) })
    assert task.valid?
  end
end

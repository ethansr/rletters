# -*- encoding : utf-8 -*-
require 'minitest_helper'

class AnalysisTaskTest < ActiveRecord::TestCase
  fixtures :datasets
  
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
  
  test "destroying analysis task with files deletes them" do
    task = AnalysisTask.new({ :name => 'test', :dataset => datasets(:one) })
    assert task.valid?
    
    task.result_file = Download.create_file('test.txt') do |file|
      file.write 'test'
    end
    task.save
    
    filename = task.result_file.filename
    assert File.exists?(filename)
    
    task.destroy
    
    refute File.exists?(filename)
  end
end

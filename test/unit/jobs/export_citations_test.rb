# -*- encoding : utf-8 -*-
require 'minitest_helper'
require 'zip/zip'

class ExportCitationsTest < ActiveSupport::TestCase
  fixtures :datasets, :users
  
  test "should not be able to export citations for another user" do
    assert_raises ActiveRecord::RecordNotFound do
      Jobs::ExportCitations.new(users(:alice).to_param, 
        datasets(:one).to_param, :bibtex).perform
    end
  end
  
  test "should not be able to export citations for invalid user" do
    assert_raises ActiveRecord::RecordNotFound do
      Jobs::ExportCitations.new('123123123123123', 
        datasets(:one).to_param, :bibtex).perform
    end
  end
  
  test "exporting invalid dataset should not work" do
    assert_raises ActiveRecord::RecordNotFound do
      Jobs::ExportCitations.new(users(:john).to_param, 
        '123123123123', :bibtex).perform
    end
  end
  
  test "exporting in an invalid format should not work" do
    assert_raises ArgumentError do
      Jobs::ExportCitations.new(users(:john).to_param,
        datasets(:one).to_param, :notaformat).perform
    end
  end
  
  test "should create export file" do
    # Execute the export job, which should create an AnalysisTask
    SolrExamples.stub :precise_one_doc
    assert_difference 'datasets(:one).analysis_tasks.count' do
      Jobs::ExportCitations.new(users(:john).to_param,
        datasets(:one).to_param, :bibtex).perform
    end
    
    # Check the task
    task = datasets(:one).analysis_tasks[0]
    refute_nil task
    
    # Check the attributes
    assert_equal task.name, "Export as BIBTEX"
    refute_nil task.result_file
    
    # Make sure the file exists and is a zip file with one entry
    assert File.exists?(task.result_file.filename)
    Zip::ZipFile.open(task.result_file.filename) do |zf|
      assert_equal 1, zf.size
    end
    
    task.destroy
  end
end

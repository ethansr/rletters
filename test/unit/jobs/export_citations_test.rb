# -*- encoding : utf-8 -*-
require 'minitest_helper'
require 'zip/zip'

class ExportCitationsTest < ActiveSupport::TestCase
  fixtures :datasets, :users
  
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

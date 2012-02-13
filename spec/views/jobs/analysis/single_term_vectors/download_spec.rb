# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "jobs/single_term_vectors/download" do
  
  before(:each) do
    @dataset = mock_model(Dataset)
    
    @task = AnalysisTask.new(:name => "Term frequency information", :job_type => 'SingleTermVectors')
    @task.dataset = @dataset
    @task.result_file = Download.create_file('temp.yml') do |file|
      file.write({ "test" => { :tf => 3, :df => 1, :tfidf => 2.5 }}.to_yaml)
      file.close
    end
    @task.save
  end
  
  after(:each) do
    @task.destroy
  end
  
  it "shows a header column" do
    render
    rendered.should contain("Term,tf,df,tf*idf")
  end
  
  it 'shows the data in a CSV row' do
    render
    rendered.should contain("test,3,1,2.5")
  end
end

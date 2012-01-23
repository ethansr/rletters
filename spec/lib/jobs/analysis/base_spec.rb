# -*- encoding : utf-8 -*-
require 'spec_helper'

module Jobs
  module Analysis
    class MockJob < Jobs::Analysis::Base
    end
  end
end

describe Jobs::Analysis::Base do
  
  describe '.job_view_path' do
    it 'returns the right value' do
      expected = Rails.root.join('lib', 'jobs', 'analysis', 'views', 'mock_job', 'test.html.haml')
      Jobs::Analysis::MockJob.job_view_path('test').should eq(expected)
    end
  end
  
  describe '.render_job_view' do
    before(:each) do
      Dir.mkdir Rails.root.join('lib', 'jobs', 'analysis', 'views', 'mock_job')
      File.open(Rails.root.join('lib', 'jobs', 'analysis', 'views', 'mock_job', 'test.html.haml'), 'w') do |f|
        f.write('This is a test')
      end
    end
    
    after(:each) do
      File.delete Rails.root.join('lib', 'jobs', 'analysis', 'views', 'mock_job', 'test.html.haml')
      Dir.rmdir Rails.root.join('lib', 'jobs', 'analysis', 'views', 'mock_job')
    end
    
    it 'calls render on the right file' do
      expected_filename = Rails.root.join('lib', 'jobs', 'analysis', 'views', 'mock_job', 'test.html.haml')
      dataset = Dataset.new
      
      controller = double
      controller.should_receive(:render_to_string).with(:file => expected_filename, :layout => false, :locals => { :dataset => dataset })
      Jobs::Analysis::MockJob.render_job_view(controller, dataset, 'test')
    end
    
    it 'properly renders the contents of job views' do
      Jobs::Analysis::MockJob.render_job_view(DatasetsController.new, Dataset.new, 'test').should include('This is a test')
    end
  end
  
end

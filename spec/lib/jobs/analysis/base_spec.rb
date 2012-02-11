# -*- encoding : utf-8 -*-
require 'spec_helper'

module Jobs
  module Analysis
    class MockJob < Jobs::Analysis::Base
    end
  end
end

describe Jobs::Analysis::Base do
  
  describe '.view_path' do
    it 'returns the right value' do
      expected = Rails.root.join('lib', 'jobs', 'analysis', 'views', 'mock_job', 'test')
      Jobs::Analysis::MockJob.view_path('test').should eq(expected)
    end
  end
  
end

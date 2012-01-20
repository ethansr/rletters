# -*- encoding : utf-8 -*-

# Markup generators for the datasets controller
module DatasetsHelper
  # Include markup that each analysis task provides for creating jobs
  def create_jobs_markup
    output = ''
    Jobs::Analysis::Base.job_list.each do |c|
      output << c.render_job_view(controller, 'start')
    end
    
    output.html_safe
  end
end

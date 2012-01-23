# -*- encoding : utf-8 -*-

module JobViewSpecHelper
  def init_job_view_spec(job, view)
    @dataset = mock_model(Dataset)
    
    controller.controller_path = 'datasets'
    controller.request.path_parameters[:controller] = 'datasets'
    controller.request.path_parameters[:action] = 'job_view'
    controller.request.path_parameters[:id] = @dataset.to_param
    controller.request.path_parameters[:job_name] = job
    controller.request.path_parameters[:job_view] = view
  end
  
  def render_job_view(job, view)
    render :file => "lib/jobs/analysis/views/#{job.underscore}/#{view}.html.haml",
      :locals => { :dataset => @dataset }
  end
end
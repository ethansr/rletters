# -*- encoding : utf-8 -*-

module JobViewSpecHelper
  def init_job_view_spec(job, view, format = 'html')
    @dataset ||= mock_model(Dataset)
    @task ||= mock_model(AnalysisTask)
    
    controller.controller_path = 'datasets'
    controller.request.path_parameters[:controller] = 'datasets'
    controller.request.path_parameters[:action] = 'job_view'
    controller.request.path_parameters[:id] = @dataset.to_param
    controller.request.path_parameters[:task_id] = @task.to_param
    controller.request.path_parameters[:job_view] = view
    controller.request.path_parameters[:format] = format || 'html'
  end
  
  def render_job_view(job, view, format = 'html')
    render :file => "lib/jobs/analysis/views/#{job.underscore}/#{view}",
      :formats => [ format.to_s ], :locals => { :dataset => @dataset, :task => @task }
  end
end

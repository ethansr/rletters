# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    
    # Base class for all analysis jobs
    #
    # All jobs act on a dataset with a user ID, so those are common to all
    # analysis jobs.  Also, we include some error handling code (via Airbrake).
    class Base < Jobs::Base
      # @return [String] the user that created this dataset
      attr_accessor :user_id
      # @return [String] the dataset to export
      attr_accessor :dataset_id
      
      # Does this job produce a download?
      #
      # If true (default), then links to results of tasks will produce links to
      # download the result_file from that task.  If not, then the link to the
      # task results will point to the 'results' view for this job.  Override
      # this method to return false if you want to use the 'results' view.
      #
      # @api public
      # @return [Boolean] true if task produces a download, false otherwise
      # @example Get a link to the results of a task
      #   if task.job_class.download?
      #     link_to '', :controller => 'datasets', :action => 'task_download',
      #       :id => dataset.to_param, :task_id => task.to_param
      #   else
      #     link_to '', :controller => 'datasets', :action => 'task_view',
      #       :id => dataset.to_param, :task_id => task.to_param, 
      #       :view => 'results'
      def self.download?
        true
      end
      
      # Get a list of all classes that are analysis jobs
      def self.job_list
        # Get all the classes defined in the Jobs::Analysis module
        begin
          classes = Dir[Rails.root.join('lib', 'jobs', 'analysis', '*.rb')].map { |f|
            next if File.basename(f) == 'base.rb'
            ('Jobs::Analysis::' + File.basename(f, '.*').camelize).constantize
          }.compact
        rescue NameError
          return []
        end
    
        # Make sure that worked
        classes.each do |c|
          return [] unless c.is_a?(Class)
        end
        
        classes
      end
    
      # Get the path to a job-view template for this job
      #
      # We let analysis jobs ship their own job view templates in
      # lib/jobs/analysis/views/<job>/*.html.haml.  This function takes a view 
      # name and returns its template's full disk path.
      #
      # @api public
      # @param [String] view the view to fetch the path to
      # @return [String] the path to the template
      # @example Get the path to the ExportCitations 'start' view
      #   Jobs::Analysis::ExportCitations.view_path 'start'
      #   => 'RAILS_ROOT/lib/jobs/analysis/views/export_citations/start.html.haml'
      def self.view_path(view)
        # This will return something like 'jobs/analysis/export_citations', so we
        # need to add '/views' in there
        class_path = self.name.underscore.sub('/analysis/', '/analysis/views/')
        Rails.root.join('lib', class_path, "#{view}.html.haml")
      end
      
      # Set the analysis task fail bit on error
      def error(job, exception)
        if instance_variable_defined?(:@task)
          @task.failed = true
          @task.save!
        end
        super
      end
    end
  
  end
end

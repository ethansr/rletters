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
    
      # Return markup that lets the user start this job
      #
      # This markup will be placed into a <ul> tag.  The way that jQuery
      # Mobile works (at least currently), you can:
      # * Return a single <li> that points to an analysis_job_view
      # * Return more than one <li>
      # * Return a <li> that contains a <ul> to use jQM's 'nested lists'
      #
      # @api public
      # @return [String] some markup for starting this job
      # @example Get the start markup for an analysis job
      #   %ul= Jobs::Analysis::ExportCitations.start_markup
      def self.start_markup
        return ''
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
      #   Jobs::Analysis::ExportCitations.job_view_path 'start'
      #   => 'RAILS_ROOT/lib/jobs/analysis/views/export_citations/start.html.haml'
      def self.job_view_path(view)
        # This will return something like 'jobs/analysis/export_citations', so we
        # need to add '/views' in there
        class_path = self.name.underscore.sub('/analysis/', '/analysis/views/')
        Rails.root.join('lib', class_path, "#{view}.html.haml")
      end
    
      # Get the results of rendering a job view template as a string
      #
      # Render the template specified by +self.job_view_path+ and return the
      # results as a string.
      #
      # @api public
      # @param [ActionController] controller the controller to do the rendering
      # @param [String] view the view to render
      # @return [String] the results of rendering this view
      # @example Display the 'start' view from the ExportCitations job
      #   <%= Jobs::Analysis::ExportCitations.render_job_view @controller, 
      #         @dataset, 'start' =>
      def self.render_job_view(controller, dataset, view)
        controller.render_to_string :file => job_view_path(view), 
          :layout => false, :locals => { :dataset => dataset }
      end
    end
  
  end
end

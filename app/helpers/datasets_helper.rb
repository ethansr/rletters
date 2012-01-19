# -*- encoding : utf-8 -*-

# Markup generators for the datasets controller
module DatasetsHelper
  # Include markup that each analysis task provides for creating jobs
  def create_jobs_markup
    # Get all the classes defined in the Jobs::Analysis module
    begin
      classes = Dir[Rails.root.join('lib', 'jobs', 'analysis', '*.rb')].map do |f|
        ('Jobs::Analysis::' + File.basename(f, '.*').camelize).constantize
      end
    rescue NameError
      return ''
    end
    
    # Make sure that worked
    classes.each do |c|
      return '' unless c.is_a?(Class)
    end
    
    "WE HAVE #{classes.size} CLASSES"
  end
end

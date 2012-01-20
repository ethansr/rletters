# -*- encoding : utf-8 -*-

# Code that runs as delayed jobs
#
# This namespace contains classes for all code that runs as a delayed job.
#
# Some guidelines for RLetters delayed jobs:
# - These jobs should, except in rare cases (like +DestroyDataset+) only
#   query Solr or the SQL database for something like 1,000 rows at a time.
#   Forgetting to put bounds on queries could result in fetching hundreds of
#   thousands of records from the database, possibly freezing up the DJ
#   worker for a period of days.
# - All of these jobs should derive from +Jobs::Base+ to enable error handling
#   and easy attribute setting and comparison.
# - Analysis jobs should derive from +Jobs::AnalysisJob+ to get some common
#   attributes.
module Jobs
  
  # Base class for all delayed jobs
  class Base
    
    # Initialize the job from a hash of attributes in a generic way
    def initialize(args = { })
      @state_vars = args.keys
      
      args.each_pair do |key, value|
        self.send("#{key}=", value) if self.respond_to?("#{key}=")
      end
    end
    
    # Get a hash of attributes from the state variables
    def attributes
      ret = {}
      @state_vars.each { |k| ret[k] = instance_variable_get("@#{k.to_s}") }      
      ret
    end
    
    # Compare objects for equality based on their attributes
    def <=>(other)
      attributes <=> other.attributes
    end
    
    # Use the <=> function to implement all the other operators
    include Comparable
    
    
    # Report any exceptions to Airbrake, if it's enabled
    #
    # This method is a callback that is invoked by Delayed::Job.  No tests, as
    # it's merely a wrapper on the Airbrake gem.
    #
    # @param [Delayed::Job] job The job currently being run
    # @param [StandardError] exception The exception raised to cause the error
    # @api private
    # @return [undefined]
    # :nocov:
    def error(job, exception)
      unless APP_CONFIG['airbrake_key'].blank?
        Airbrake.notify(exception)
      end
    end
    # :nocov:
    
  end
  
end

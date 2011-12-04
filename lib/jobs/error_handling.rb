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
# - All of these jobs should +include ErrorHandling+ to enable the reporting
#   of DJ errors to Airbrake (if enabled by the user).
module Jobs
  
  # Mixin for job classes to gain Airbrake exception handling
  module ErrorHandling
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

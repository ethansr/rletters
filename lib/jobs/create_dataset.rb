# -*- encoding : utf-8 -*-

module Jobs
  
  # Create a dataset from a Solr query for a given user
  #
  # This job fetches results from the Solr server and spools them into the
  # database, creating a dataset for a user.
  #
  # @attr [String] user_id The user that created this dataset
  # @attr [String] name The name of the dataset to create
  # @attr [String] q The Solr query for this search
  # @attr [Array<String>] fq Faceted browsing parameters for this search
  # @attr [String] qt Query type of this search
  class CreateDataset < Struct.new(:user_id, :name, :q, :fq, :qt)
    include Jobs::ErrorHandling
    
    # We're connecting to Solr, get the connection mechanisms
    extend SolrHelpers
    
    # Check the response from Solr for a host of common errors
    #
    # This method will throw if the Solr response is not valid.
    #
    # @api private
    # @return [undefined]
    # @example Check that we have a good Solr response
    #   solr_response = SolrHandlers.get_solr_response(...)
    #   # Will have thrown if the response is not valid
    def check_solr_response(solr_response)
      raise StandardError, 'Unknown error in Solr response' unless solr_response["response"]
      raise StandardError, 'Unknown error in Solr response' unless solr_response["response"]["numFound"]
      raise StandardError, 'Attempted to save empty query' unless solr_response["response"]["numFound"] > 0
      raise StandardError, 'Unknown error in Solr response' unless solr_response["response"]["docs"]
    end
    
    # Create a dataset for the user
    #
    # @api public
    # @return [undefined]
    # @example Start a job for creating a dataset
    #   Delayed::Job.enqueue Jobs::CreateDataset.new(users(:john).to_param, 
    #     'Test Dataset', '*:*', ['authors_facet:"Shatner"'], 'precise')
    def perform
      # Fetch the user based on ID
      user = User.find(user_id)
      raise ArgumentError, 'User ID is not valid' unless user
      
      # Create a dataset and save it, to fix its ID
      dataset = user.datasets.build(:name => name)
      raise StandardError, 'Cannot create dataset for user' unless dataset
      raise StandardError, 'Cannot save dataset' unless dataset.save
      
      # Build a Solr query to fetch the results, 1000 at a time
      solr_query = {}
      solr_query[:start] = 0
      solr_query[:rows] = 1000
      solr_query[:q] = q
      solr_query[:fq] = fq
      
      if qt == 'precise'
        solr_query[:qt] = 'dataset_precise'
      else
        solr_query[:qt] = 'dataset'
      end
      
      # We trap all of this so that if we get exceptions we can clean them
      # up and delete any and all fledgling dataset parts
      begin
        # Get the first Solr response
        solr_response = CreateDataset.get_solr_response(solr_query)
        check_solr_response solr_response
      
        # Get our parameters
        docs_to_fetch = solr_response["response"]["numFound"]
      
        now = DateTime.current.to_formatted_s(:db)
        dataset_id = dataset.to_param
        sql_tail = "'#{dataset_id}', '#{now}', '#{now}'"
      
        while docs_to_fetch > 0
          # What did we get this time?
          docs_fetched = solr_response["response"]["docs"].count
        
          # Formulate a SQL query for all these results
          sql = 'INSERT INTO dataset_entries (`shasum`, `dataset_id`, `created_at`, `updated_at`) VALUES '
          solr_response["response"]["docs"].each do |doc|
            # We need to force this into UTF-8 on Ruby 1.9, or we may well
            # get concatenation errors and suchlike
            str = doc["shasum"]
            str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
            
            sql << "('#{str}', #{sql_tail}),"
          end
        
          # Send it (deleting the trailing comma)
          ActiveRecord::Base.connection.execute(sql.chop!())
        
          # Update counters and execute another query if required
          docs_to_fetch = docs_to_fetch - docs_fetched
          if docs_to_fetch > 0
            solr_query[:start] = solr_query[:start] + docs_fetched
            solr_response = CreateDataset.get_solr_response(solr_query)
            check_solr_response solr_response
          end
        end
      rescue StandardError => e
        # Destroy the dataset to clean up
        dataset.destroy
        raise
      end
    end
  end  
end

# -*- encoding : utf-8 -*-

module Jobs
  
  # Add a document to an already extant dataset
  class AddToDataset < Jobs::Base    
    # @return [String] the user that owns the dataset
    attr_accessor :user_id
    # @return [String] the dataset to add to
    attr_accessor :dataset_id
    # @return [String] the document shasum to add
    attr_accessor :shasum

    # Add a document to a dataset
    #
    # @api public
    # @return [undefined]
    # @example Add a new document to a dataset
    #   Delayed::Job.enqueue Jobs::AddToDataset.new(
    #     :user_id => users(:john).to_param, 
    #     :name => datasets(:one).to_param, 
    #     :shasum => '12341234...')
    def perform
      # Fetch the user based on ID
      user = User.find(user_id)
      raise ArgumentError, 'User ID is not valid' unless user

      # Get the dataset
      dataset = user.datasets.find(dataset_id)
      raise ArgumentError, 'Dataset ID is not valid' unless dataset

      # Check the document (raises if not found)
      document = Document.find(shasum)

      # Okay, all good, add it
      dataset.entries.create({ :shasum => shasum })
    end
  end
  
end

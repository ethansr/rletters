# -*- encoding : utf-8 -*-

module Jobs

  # Destroy a user's datset
  #
  # This job destroys a given dataset.  This SQL call can be quite expensive,
  # so we perform it in the background
  class DestroyDataset < Jobs::Base
    # @return [String] the user that owns this dataset
    attr_accessor :user_id
    # @return [String] the id of the dataset to be destroyed
    attr_accessor :dataset_id
    
    # Destroy a dataset
    #
    # @api public
    # @return [undefined]
    # @example Start a job for destroying a dataset
    #   Delayed::Job.enqueue Jobs::DestroyDataset.new(
    #     :user_id => users(:john).to_param, 
    #     :dataset_id => dataset.to_param)
    def perform
      # Fetch the user based on ID
      user = User.find(user_id)
      raise ArgumentError, 'User ID is not valid' unless user
      
      dataset = user.datasets.find(dataset_id)
      raise ArgumentError, 'Dataset ID is not valid' unless dataset

      dataset.destroy
    end
  end
end

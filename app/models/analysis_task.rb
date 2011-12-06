# -*- encoding : utf-8 -*-

# An analysis task run on a dataset
#
# While the processing is actually occurring in a delayed job, we need a way
# for those delayed jobs to readily communicate with users via the web
# front-end.  This model is how they do so.
#
# @attr [String] name The name of this task
# @attr [DateTime] created_at The time at which this task was started
# @attr [DateTime] finished_at The time at which this task was finished
# @attr [Dataset] dataset The dataset to which this task
#   belongs (+belongs_to+)
# @attr [Download] result_file The results of this analysis task, if
#   completed and returned as a file download
class AnalysisTask < ActiveRecord::Base
  validates :name, :presence => true
  validates :dataset_id, :presence => true

  belongs_to :dataset
  has_one :result_file, :class_name => 'Download'
  
  attr_accessible :name, :dataset
end

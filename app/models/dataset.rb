# -*- encoding : utf-8 -*-

# The saved results of a given search, for analysis
#
# A dataset is the result set from a given search, persisted in the database
# so that we can run digital humanities analyses on a collection of documents.
class Dataset < ActiveRecord::Base
  belongs_to :user
end

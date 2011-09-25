# -*- encoding : utf-8 -*-

module SearchHelper
  # Return a formatted version of the number of documents in the last search
  # @return [String] number of documents in the last search
  def num_results_string
    if params[:precise] or params[:q]
      ret = "#{pluralize(Document.num_results, 'document')} found"
    else
      ret = "#{pluralize(Document.num_results, 'document')} in database"
    end
    ret
  end
end

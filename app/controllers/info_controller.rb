# -*- encoding : utf-8 -*-

# Display static information pages about RLetters
#
# This controller displays static information, such as the RLetters help, FAQ,
# and privacy policy.
class InfoController < ApplicationController
  # We run a Solr query to get information to put on the index page
  extend SolrHelpers
  
  # Query some Solr parameters for the index page
  #
  # This action will query the Solr database to get some nice statistics
  # for our index page.
  #
  # @api public
  # @return [undefined]
  def index
    solr_query = {}
    solr_query[:q] = '*:*'
    solr_query[:qt] = 'precise'
    solr_query[:rows] = 5
    solr_query[:start] = 0
    
    solr_response = InfoController.get_solr_response(solr_query)
    
    if (solr_response["response"] && solr_response["response"]["numFound"])
      @database_size = solr_response["response"]["numFound"]
    else
      @database_size = 0
    end
  end
  
  # Show the about page
  #
  # @api public
  # @return [undefined]
  def about; end
  
  # Show the FAQ
  #
  # @api public
  # @return [undefined]
  def faq; end
  
  # Show the privacy policy
  #
  # @api public
  # @return [undefined]
  def privacy; end
  
  # Show the tutorial
  #
  # @api public
  # @return [undefined]
  def tutorial; end
end


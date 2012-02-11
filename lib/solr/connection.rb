# -*- encoding : utf-8 -*-

module Solr
  
  module Connection
    
    # Get a response from Solr
    #
    # This method breaks out the retrieval of a Solr response in order to
    # provide for easier testing.
    #
    # @api private
    # @param [Hash] params
    # @return [RSolr::Ext.response] Solr search result
    def self.find(params)
      begin
        solr = RSolr::Ext.connect :url => APP_CONFIG['solr_server_url']
        ret = solr.find params
      rescue Exception => e
        RSolr::Ext::Response::Base.new({ 'response' => { 'docs' => [] } }, 'select', params)
      end
    end
    
  end
  
end

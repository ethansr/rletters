# -*- encoding : utf-8 -*-
require 'citeproc'

# Serialization code for +Document+ objects
#
# This module contains helpers intended to be included by the +Document+
# model, which allow the document to be converted to any one of a number of
# export formats.
module Serializers
  
  # Serialization code to Citation Style Language
  #
  # The Citation Style Language (http://citationstyles.org) is a language
  # designed for the processing of citations and bibliographic entries. In
  # RLetters, we use CSL to allow users to format the list of search results
  # in whatever bibliography-entry format they choose.
  module CSL
    # Returns a hash representing the article in CSL format
    #
    # @api public
    # @return [Hash] article as a CSL record
    # @example Get the CSL entry for a given document
    #   doc = Document.new(...)
    #   doc.to_csl
    #   # { 'type' => 'article-journal', 'author' => ... }
    def to_csl
      ret = {}
      ret['type'] = 'article-journal'

      if self.formatted_author_list && self.formatted_author_list.count
        ret['author'] = []
     
        self.formatted_author_list.each do |a|
          h = {}
          h['given'] = a[:first]
          h['family'] = a[:last]
          h['suffix'] = a[:suffix]
          h['non-dropping-particle'] = a[:von]

          ret['author'] << h
        end
      end
      
      ret['title'] = self.title if self.title
      ret['container-title'] = self.journal if self.journal
      ret['issued'] = { 'date-parts' => [[ Integer(self.year) ]] } if self.year
      ret['volume'] = self.volume if self.volume
      ret['issue'] = self.number if self.number
      ret['page'] = self.pages if self.pages

      ret
    end

    # Convert the document to CSL, and format it with the given style
    #
    # Takes a document and converts it to a bibliographic entry in the
    # specified style using CSL.
    #
    # @api public
    # @param [String] style CSL style to use (see +vendor/csl+)
    # @return [String] bibliographic entry in the given style
    # @example Convert a given document to Chicago author-date format
    #   doc.to_csl_entry('chicago-author-date.csl')
    #   # "Doe, John. 2000. ..."
    def to_csl_entry(style = '')
      style = 'chicago-author-date.csl' if style.blank?
      style = Rails.root.join('vendor', 'csl', style) unless style.match(/\Ahttps?:/)

      CiteProc.process(to_csl, :format => :html, :style => style).strip.html_safe
    end
  end
end

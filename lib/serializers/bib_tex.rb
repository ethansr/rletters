# -*- encoding : utf-8 -*-

module Serializers
  
  # Convert a document to a BibTeX record
  module BibTex
    # Returns this document as a BibTeX record
    #
    # @api public
    # @return [String] document in BibTeX format
    # @example Download this document as a bib file
    #   controller.send_data doc.to_bibtex, :filename => 'export.bib', :disposition => 'attachment'
    def to_bibtex
      # We don't have a concept of cite keys, so we're forced to just use
      # AuthorYear and hope it doesn't collide
      if formatted_author_list.count > 0
        first_author = formatted_author_list[0][:last].gsub(' ','').gsub(/\P{ASCII}/, '')
      else
        first_author = Anon
      end
      cite_key = "#{first_author}#{year}"
      
      ret  = "@article{#{cite_key},\n"
      ret << "    author = {#{author_list.join(' and ')}},\n" unless authors.blank?
      ret << "    title = {#{title}},\n" unless title.blank?
      ret << "    journal = {#{journal}},\n" unless journal.blank?
      ret << "    volume = {#{volume}},\n" unless volume.blank?
      ret << "    number = {#{number}},\n" unless number.blank?
      ret << "    pages = {#{pages}},\n" unless pages.blank?
      ret << "    doi = {#{doi}},\n" unless doi.blank?
      ret << "    year = {#{year}}\n" unless year.blank?
      ret << "}\n"
      
      ret
    end
  end
end

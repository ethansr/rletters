# coding: UTF-8

class ExportController < ApplicationController
  EXPORT_FORMATS = [
    { :action => "ris", :class => "RISCollection" },
    { :action => "bibtex", :class => "BIBCollection" },
    { :action => "endnote", :class => "EndNoteCollection" },
    { :action => "rdf", :class => "RDFCollection" },
    { :action => "turtle", :class => "TurtleCollection" },
    { :action => "marc", :class => "MARCCollection" },
    { :action => "marcxml", :class => "MARCXMLCollection" },
    { :action => "mods", :class => "MODSCollection" }
  ]
  
  # This may be my favorite bit of Ruby meta-programming I've done yet.
  EXPORT_FORMATS.each do |f|
    class_eval <<-RUBY
    def #{f[:action]}
      headers["Cache-Control"] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers["Expires"] = "0"
      
      Kernel.const_get("#{f[:class]}").new(get_documents).send(self)
    end
    RUBY
  end
  
  def get_documents
    ids = params[:id]
    raise ActiveRecord::RecordNotFound if ids.blank?
    ids = [ ids ] unless ids.is_a? Array
    
    ids.map { |i| Document.find(i)[:document] }
  end
  private :get_documents
end

class UnapiController < ApplicationController
  def index
    if params[:id]
      hash_to_instance_variables Document.find(params[:id], true, nil)
      
      if params[:format]
        get_item params[:id], params[:format]
      else
        render :template => 'unapi/formats.xml.builder', :layout => false, :status => 300, :locals => { :id => params[:id] }
      end
    else
      render :template => 'unapi/formats.xml.builder', :layout => false, :locals => { :id => nil }
    end
  end
  
  FORMAT_TO_ACTION = {
    'bibtex' => 'bib',
    'ris' => 'ris',
    'endnote' => 'enw',
    'rdf' => 'rdf',
    'turtle' => 'ttl',
    'marcxml' => 'xml_marc',
    'marc' => 'marc',
    'mods' => 'xml_mods'
  }
  
  def get_item(id, format)
    if not FORMAT_TO_ACTION.has_key? format
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 406
    else
      redirect_to :controller => 'documents', :action => FORMAT_TO_ACTION[format], :id => id
    end
  end
end

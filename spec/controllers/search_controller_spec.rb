# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchController do

  fixtures :users, :datasets, :dataset_entries
  
  describe '#index' do
    context 'with empty search results' do
      before(:each) do
        Examples.stub_with(/localhost\/solr\/.*/, :standard_empty_search)
        get :index
      end

      it 'loads successfully' do
        response.should be_success
      end
    end

    context 'with precise search results' do
      before(:each) do
        Examples.stub_with(/localhost\/solr\/.*/, :precise_all_docs)
        get :index
      end

      it 'assigns the documents variable' do
        assigns(:documents).should be
      end

      it 'assigns the right number of documents' do
        assigns(:documents).should have(10).items
      end

      it 'assigns solr_q' do
        assigns(:solr_q).should eq('*:*')
      end

      it 'assigns solr_qt' do
        assigns(:solr_qt).should eq('precise')
      end

      it 'does not assign solr_fq' do
        assigns(:solr_fq).should be_nil
      end

      it 'sorts by year, descending' do
        assigns(:sort).should eq('year_sort desc')
      end
    end

    context 'with faceted search results' do
      before(:each) do
        Examples.stub_with(/localhost\/solr\/.*/, :precise_facet_author_and_journal)
        get :index, { :fq => [ 'authors_facet:"Amanda M. Koltz"', 'journal_facet:"Ethology"' ] }
      end

      it 'assigns solr_fq' do
        assigns(:solr_fq).should be
      end

      it 'sorts by year, descending' do
        assigns(:sort).should eq('year_sort desc')
      end
    end

    context 'with a dismax search' do
      before(:each) do
        Examples.stub_with(/localhost\/solr\/.*/, :standard_search_diversity)
        get :index, { :q => 'diversity' }
      end

      it 'assigns solr_q' do
        assigns(:solr_q).should eq('diversity')
      end

      it 'assigns solr_qt' do
        assigns(:solr_qt).should eq('standard')
      end

      it 'does not assign solr_fq' do
        assigns(:solr_fq).should be_nil
      end

      it 'sorts by score, descending' do
        assigns(:sort).should eq('score desc')
      end
    end

    context 'with offset and limit parameters' do
      before(:each) do
        default_sq = { :q => "*:*", :qt => "precise" }
        options = { :sort => "year_sort desc", :offset => 20, :limit => 20 }
        Document.should_receive(:find_all_by_solr_query).with(default_sq, options).and_return([])

        get :index, { :page => "1", :per_page => "20" }
      end

      it 'successfully parses those parameters' do
        assigns(:documents).should have(0).items
      end
    end
  end
  
  describe '#show' do
    before(:each) do
      Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
    end
    
    context 'when displaying as HTML' do
      it 'loads successfully' do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
        response.should be_success
      end
    
      it 'assigns document' do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
        assigns(:document).should be
      end
    end
    
    context 'when exporting in other formats' do
      it "exports in MARC format" do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'marc' }
        response.should be_valid_download('application/marc')
      end

      it "exports in MARC-JSON format" do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'json' }
        response.should be_valid_download('application/json')
      end

      it "exports in MARC-XML format" do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'marcxml' }
        response.should be_valid_download('application/marcxml+xml')
      end

      it "exports in BibTeX format" do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'bibtex' }
        response.should be_valid_download('application/x-bibtex')
      end

      it "exports in EndNote format" do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'endnote' }
        response.should be_valid_download('application/x-endnote-refer')
      end

      it "exports in RIS format" do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'ris' }
        response.should be_valid_download('application/x-research-info-systems')
      end

      it "exports in MODS format" do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'mods' }
        response.should be_valid_download('application/mods+xml')
      end

      it "exports in RDF/XML format", :jruby => false do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'rdf' }
        response.should be_valid_download('application/rdf+xml')
      end

      it "exports in RDF/N3 format" do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'n3' }
        response.should be_valid_download('text/rdf+n3')
      end

      it "fails to export an invalid format" do
        get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'csv' }
        controller.should respond_with(406)
      end
    end
  end

  describe '#add' do
    before(:each) do
      Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
      
      @user = users(:john)
      session[:user_id] = @user.to_param
    end

    it 'loads successfully' do
      get :add, { :id => datasets(:one).to_param, :shasum => '00972c5123877961056b21aea4177d0dc69c7318' }
      response.should be_success
    end
  end
  
  describe '#to_mendeley' do
    context 'when request succeeds' do
      before(:all) do
        APP_CONFIG['mendeley_key'] = 'asdf'
      end
      
      after(:all) do
        APP_CONFIG['mendeley_key'] = ''
      end
      
      before(:each) do
        Examples.stub_with(/api\.mendeley\.com\/oapi\/documents\/search\/title.*/, :mendeley_response_p1d)
        Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
      end
            
      it 'redirects to Mendeley' do
        get :to_mendeley, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
        response.should redirect_to('http://www.mendeley.com/research/how-reliable-are-the-methods-for-estimating-repertoire-size-1/')
      end
    end
    
    context 'when request times out' do
      before(:all) do
        APP_CONFIG['mendeley_key'] = 'asdf'
      end
      
      after(:all) do
        APP_CONFIG['mendeley_key'] = ''
      end
      
      before(:each) do
        stub_request(:any, /api\.mendeley\.com\/oapi\/documents\/search\/title.*/).to_timeout
        Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
      end
      
      it 'raises an exception' do
        expect {
          get :to_mendeley, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  describe '#to_citeulike' do
    context 'when request succeeds' do
      before(:each) do
        Examples.stub_with(/www\.citeulike\.org\/json\/search\/all\?.*/, :citeulike_response_p1d)
        Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
      end
      
      it 'redirects to citeulike' do
        get :to_citeulike, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
        response.should redirect_to('http://www.citeulike.org/article/3509563')
      end
    end
    
    context 'when request times out' do
      before(:each) do
        stub_request(:any, /www\.citeulike\.org\/json\/search\/all\?.*/).to_timeout
        Examples.stub_with(/localhost\/solr\/.*/, :precise_one_doc)
      end
      
      it 'raises an exception' do
        expect {
          get :to_citeulike, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  describe '#advanced' do
    it 'loads successfully' do
      get :advanced
      response.should be_success
    end
  end
  
end

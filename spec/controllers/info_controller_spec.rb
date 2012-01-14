# -*- encoding : utf-8 -*-
require 'spec_helper'

describe InfoController do
  
  describe '#index' do
    context 'given Solr results' do
      before(:each) do
        SolrExamples.stub :precise_one_doc
      end
      
      it 'loads successfully' do
        get :index
        response.should be_success
      end
    end
    
    context 'when Solr fails' do
      before(:each) do
        SolrExamples.stub :error
      end
      
      it 'loads successfully' do
        get :index
        response.should be_success
      end
    end
  end
  
  describe '#faq' do
    it 'loads successfully' do
      get :faq
      response.should be_success
    end
  end

  describe '#about' do
    it 'loads successfully' do
      get :about
      response.should be_success
    end
  end

  describe '#privacy' do
    it 'loads successfully' do
      get :privacy
      response.should be_success
    end
  end

  describe '#tutorial' do
    it 'loads successfully' do
      get :tutorial
      response.should be_success
    end
  end
  
end
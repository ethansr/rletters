# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UsersHelper do
  
  #describe '#options_from_locales' do
  #end
  
  describe '#get_user_language' do
    context 'when ACCEPT_LANGUAGE has a country code' do
      it 'parses correctly' do
        controller.request.stub(:env) { { 'HTTP_ACCEPT_LANGUAGE' => 'es-mx,es;q=0.5' } }
        helper.get_user_language.should eq('es-MX')
      end
    end
    
    context 'when ACCEPT_LANGUAGE does not have a country code' do
      it 'parses correctly' do
        controller.request.stub(:env) { { 'HTTP_ACCEPT_LANGUAGE' => 'es' } }
        helper.get_user_language.should eq('es')        
      end
    end
  end
  
  #describe '#options_from_csl_styles' do
  #end
  
  #describe '#options_from_timezones' do
  #end
  
end

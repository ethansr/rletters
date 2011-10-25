# -*- encoding : utf-8 -*-
require 'test_helper'

# Tests for SearchController#show
class SearchControllerAdvancedTest < ActionController::TestCase
  tests SearchController
  
  test "should render show-document page" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select 'li', 'Document details'
    assert_select 'ul li:nth-child(2) h3', 'How Reliable are the Methods for Estimating Repertoire Size?'
  end
  
  test "should have DOI link" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select 'ul[data-inset=true]' do
      assert_select 'li' do
        assert_select "a[href='http://dx.doi.org/10.1111/j.1439-0310.2008.01576.x']"
      end
    end
  end
  
  test "should have local library links if logged in" do
    stub_solr_response :precise_one_doc
    session[:user] = users(:john)
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    assert_select "a[href='#{CGI::escapeHTML('http://sfx.hul.harvard.edu/sfx_local?ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.genre=article&rft_id=info:doi%2F10.1111%2Fj.1439-0310.2008.01576.x&rft.atitle=How+Reliable+are+the+Methods+for+Estimating+Repertoire+Size%3F&rft.title=Ethology&rft.date=2008&rft.volume=114&rft.spage=1227&rft.epage=1238&rft.aufirst=Carlos+A.&rft.aulast=Botero&rft.au=Andrew+E.+Mudge&rft.au=Amanda+M.+Koltz&rft.au=Wesley+M.+Hochachka&rft.au=Sandra+L.+Vehrencamp')}']"
  end
  
  test "should have redirect links" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    unless APP_CONFIG['mendeley_key'].blank?
      assert_select "ul[data-inset=true] li:nth-last-child(2)" do
        assert_select "a[href='#{mendeley_redirect_path(:id => '00972c5123877961056b21aea4177d0dc69c7318')}']"
      end
    end
    assert_select "ul[data-inset=true] li:nth-last-child(1)" do
      assert_select "a[href='#{citeulike_redirect_path(:id => '00972c5123877961056b21aea4177d0dc69c7318')}']"
    end
  end
  
  test "should have unAPI link in the page" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    assert_select "link[href='#{unapi_url}'][rel=unapi-server][type=application/xml]"
  end
  
  test "should have some element with class unapi-id" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    assert_select ".unapi-id"
  end
end

# -*- encoding : utf-8 -*-
require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  #test "should properly render footer bar" do
  #  FIXME: Do we want to test ApplicationHelper#render_footer_list? 
  #end
  
  test "should render default content in static partials" do
    dist_filename = Rails.root.join('app', 'views', 'static', '_testing.markdown.dist')
    f = File.new(dist_filename, 'w')
    f.write('# Testing #')
    f.close
    
    render_static_partial :testing
    assert_template dist_filename
    
    File.delete(dist_filename)
  end
  
  test "should render customized content in static partials" do
    dist_filename = Rails.root.join('app', 'views', 'static', '_testing.markdown.dist')
    cust_filename = Rails.root.join('app', 'views', 'static', '_testing.markdown')
    
    f = File.new(dist_filename, 'w')
    f.write('# Testing #')
    f.close
    
    f = File.new(cust_filename, 'w')
    f.write('# This is a Test #')
    f.close
    
    render_static_partial :testing
    assert_template cust_filename
    
    File.delete(dist_filename)
    File.delete(cust_filename)
  end
  
  test "should render markdown in translations" do
    I18n.backend.store_translations :en, :test_markdown => '# Testing #'
    assert_equal "<h1 id=\"testing\">Testing</h1>\n", t_md(:test_markdown)
  end
end

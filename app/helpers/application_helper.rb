module ApplicationHelper

  def render_footer_list
    footer_buttons = [
      { :controller => 'mockup', :action => 'index', :text => 'Datasets', :icon => 'grid' },
      { :controller => 'mockup', :action => 'search', :text => 'Search/Browse', :icon => 'search' },
      { :controller => 'mockup', :action => 'account', :text => 'Account', :icon => 'home' }
    ]
    
    ret = ''.html_safe
    
    current = footer_buttons.index { |b| params[:controller] == b[:controller] and params[:action] == b[:action] }
    
    footer_buttons.each_with_index do |b, i|
      style = { :'data-icon' => b[:icon], :'data-transition' => 'slide' }
      unless current.nil?
        style[:class] = 'ui-btn-active' if i == current
        style[:'data-direction'] = 'reverse' if i < current
      end
      
      ret << content_tag(:li, link_to(b[:text], { :controller => b[:controller], :action => b[:action] }, style))
    end
    
    ret
  end

end

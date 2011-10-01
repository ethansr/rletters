# -*- encoding : utf-8 -*-
module ApplicationHelper

  def render_footer_list
    footer_buttons = [
      { :controller => 'search', :text => I18n.t('all.search_button'), :icon => 'search' },
      { :controller => 'datasets', :text => I18n.t('all.datasets_button'), :icon => 'grid' },
    ]
    
    ret = ''.html_safe
    
    current = footer_buttons.index { |b| params[:controller] == b[:controller] }
    
    footer_buttons.each_with_index do |b, i|
      style = { :'data-icon' => b[:icon], :'data-transition' => 'slide' }
      unless current.nil?
        style[:class] = 'ui-btn-active' if i == current
        style[:'data-direction'] = 'reverse' if i < current
      end
      
      ret << content_tag(:li, link_to(b[:text], { :controller => b[:controller], :action => 'index' }, style))
    end
    
    ret
  end

end

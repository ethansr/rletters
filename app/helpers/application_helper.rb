# -*- encoding : utf-8 -*-

# Markup generators common to all of RLetters
module ApplicationHelper

  # Create the list of nagivation buttons at the bottom of the screen
  #
  # This function primarily makes sure that the transitions between the
  # different modes of RLetters move in the "right" direction depending on
  # the currently-selected item.  It also makes it easy for us to add more
  # "major modes" to RLetters.
  #
  # @api public
  # @return [String] the navigation footer at the bottom of every page
  # @example Show the footer list
  #   <ul id='footer'><%= render_footer_list %></ul>
  def render_footer_list
    footer_buttons = [
      { :controller => 'info', :text => I18n.t('all.home_button'), :icon => 'home' },
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
  
  # Render a partial from the 'static' folder
  #
  # This helper either renders a partial from the 'static' folder (if it
  # exists), or renders the '.dist' version of that partial (otherwise).
  #
  # @api public
  # @return [undefined]
  # @example Render the 'about' partial
  #   <%= render_static_partial 'about' %>
  def render_static_partial(partial)
    if File.exists?(Rails.root.join('app', 'views', 'static', "_#{partial}.markdown"))
      render :file => Rails.root.join('app', 'views', 'static', "_#{partial}.markdown")
    else
      render :file => Rails.root.join('app', 'views', 'static', "_#{partial}.markdown.dist")
    end
  end
end

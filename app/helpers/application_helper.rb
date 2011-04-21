# coding: UTF-8

module ApplicationHelper
  
  # Thanks to Peter Gumeson's HTML5 Boilerplate gem for this
  def add_class(name, attrs)
    classes = attrs[:class] || ''
    classes.strip!
    classes = ' ' + classes if !classes.blank?
    classes = name + classes
    attrs.merge(:class => classes)
  end

  def ie_html(attrs={}, &block)
    attrs.symbolize_keys!
    haml_concat("<!--[if lt IE 7]> #{ tag(:html, add_class('ie6', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 7]>    #{ tag(:html, add_class('ie7', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 8]>    #{ tag(:html, add_class('ie8', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if gt IE 8]><!-->".html_safe)
    haml_tag :html, attrs do
      haml_concat("<!--<![endif]-->".html_safe)
      block.call
    end
  end
  
  def title(page_title)
    content_for(:title) { page_title }
  end
  
  def tooltip(id, string, width = 200)
    content_for :javascripts do
      javascript_tag "$(document).ready(function() {$(\"#{id}\").qtip({
        content: '#{string}',
        style: {
          tip: 'bottomLeft',
          background: '#222222',
          color: '#cacaca',
          textAlign: 'left',
          border: {
            width: 1,
            radius: 8,
            color: '#222222'
          },
          width: #{width},
          name: 'dark'
        },
        position: {
          corner: {
            target: 'topRight',
            tooltip: 'bottomLeft'
          }
        },
      })});"
    end
  end
  
  def help_image(width = 200, &block)
    id = UUID.generate
    
    # Have to strip newlines for JS
    html = capture(&block)
    html.gsub!(/\r/, " ")
    html.gsub!(/\n/, " ")
    
    tooltip("#" + "#{id}", html, width)
    image_tag "/images/questionmark.jpg", { :alt => "Help?", :size => "16x16", :id => id, :class => "helptip" }
  end
end

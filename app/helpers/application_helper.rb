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
  
  def add_jquery_page(id, &block)
    content_for :pages do
      content_tag :div, :id => id, 'data-role' => 'page', 'data-theme' => 'd' do
        block.call
      end
    end
  end
  
  def add_help_page(id, &block)
    add_jquery_page(id) do
      content_tag :div, 'data-role' => 'header', 'data-theme' => 'd', 'data-position' => 'inline', 'data-backbtn' => 'false' do
        content_tag :h1, "Help"
      end
      content_tag :div, 'data-role' => 'content' do
        block.call
        link_to request.request_uri, 'Close', 'data-role' => 'button', 'data-rel' => 'back', 'data-theme' => 'b'
      end
    end
  end
end

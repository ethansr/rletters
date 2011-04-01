# coding: UTF-8

module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end
  
  def tooltip(id, string, width = 200)
    content_for :javascripts do
      javascript_tag "$(document).ready(function() {$(\"#{id}\").qtip({
        content: '#{string}',
        style: {
          name: 'light',
          tip: 'bottomLeft',
          border: {
            width: 1,
            radius: 8,
            color: '#f5f5f5'
          },
          width: #{width}
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

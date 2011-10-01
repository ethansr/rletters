
# Run Markdown templates through ERB before Maruku
class MarkdownTemplate
  def self.erb_handler
    @@erb_handler ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.call(template)
    compiled_source = erb_handler.call(template)
    "erb_source = #{compiled_source}; Maruku::new(erb_source).to_html.html_safe"
  end
end

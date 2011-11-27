# -*- encoding : utf-8 -*-

# A template handler for Markdown templates that include ERB
class MarkdownTemplate
  # Save a copy of the ERB template handler
  #
  # @api private
  # @return [ActionView::Template::Handler] the template handler for ERB
  def self.erb_handler
    @@erb_handler ||= ActionView::Template.registered_template_handler(:erb)
  end

  # Run the provided view source through ERB and then Kramdown
  #
  # @api private
  # @param [ActionView::Template] template the template to render
  # @return [String] the code to call to create a Markdown template
  def self.call(template)
    compiled_source = erb_handler.call(template)
    "erb_source = #{compiled_source}; Kramdown::Document.new(erb_source).to_html.html_safe"
  end
end

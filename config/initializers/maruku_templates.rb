
# A nice one-liner to enable markdown-based templates with Maruku
ActionView::Template.register_template_handler :markdown,
  lambda { |template| "Maruku::new(#{template.source.inspect}).to_html" }


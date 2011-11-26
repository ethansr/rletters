# -*- encoding : utf-8 -*-

# We add the '.dist' extension so we can render our static user-generated
# content pages (.markdown.dist) in testing/CI
ActionView::Template.register_template_handler('markdown', MarkdownTemplate)
ActionView::Template.register_template_handler('dist', MarkdownTemplate)

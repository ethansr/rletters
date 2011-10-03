# -*- encoding : utf-8 -*-

APP_CONFIG['csl_style_names'] = {}

APP_CONFIG['available_csl_styles'].each do |st|
  File.open(Rails.root.join('vendor', 'csl', st)) do |f|
    doc = REXML::Document.new(f)
    title = ''
    elt = doc.elements.each('style/info/title') do |elt|
      title = elt.get_text.value
      break
    end
    APP_CONFIG['csl_style_names'][st] = title
  end
end

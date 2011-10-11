# -*- encoding : utf-8 -*-

module UsersHelper
  # Create a localized list of languages
  def options_from_locales(current = I18n.locale)
    list = []

    APP_CONFIG['available_locales'].each do |loc|
      parts = loc.split('-')
      entry = ''

      if parts.count == 1
        # Just a language, translate
        entry = I18n.t("languages.#{loc}")
      elsif parts.count == 2
        # A language and a territory
        entry = I18n.t("languages.#{parts[0]}")
        entry += " ("
        entry += I18n.t("territories.#{parts[1]}")
        entry += ")"
      end

      list << [entry, loc]
    end

    list.sort! { |a, b| a[0] <=> b[0] }
    options_for_select(list, current)
  end

  # Get the user's preferred language from the Accept-Language header
  def get_user_language
    acc_language = request.env['HTTP_ACCEPT_LANGUAGE']
    if acc_language
      lang = acc_language.scan(/^([a-z]{2,3}(-[A-Za-z]{2})?)/).first[0]
      if lang.include? '-'
        # Capitalize the country portion (many browsers send it lowercase)
        lang[-2, 2] = lang[-2, 2].upcase
        lang
      else
        lang
      end
    else
      I18n.default_locale.to_s
    end
  end

  # Create a list of all available CSL styles
  def options_from_csl_styles(current = '')
    list = [ [ I18n.t('users.index.default_style'), '' ] ]

    APP_CONFIG['available_csl_styles'].each do |loc|
      list << [ APP_CONFIG['csl_style_names'][loc], loc ]
    end

    options_for_select(list, current)
  end
end


require "i18n/backend/fallbacks" 
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
I18n::Backend::Simple.include(I18n::Backend::Pluralization)

# Set the list of available locales ('en' ships with Rails)
APP_CONFIG['available_locales'] = ['en']

# This exact line is taken from the README file of the rails-i18n gem, which
# supplies localizations for all our Rails defaults.
#
# Note: When you update this list from rails-i18n, you *must* copy over the
# appropriate CLDR files into vendor/locales/cldr.
"ar, bg, bs, ca, cs, cy, da, de, de-AT, de-CH, el, en-AU, en-GB, en-US, eo, " \
"es, es-AR, es-CL, es-CO, es-MX, et, eu, fa, fi, fr, fr-CA, fr-CH, gsw-CH, " \
"he, hi, hi-IN, hu, id, is, it, ja, kn, ko, lv, nb, nl, pl, pt-BR, pt-PT, " \
"ro, ru, sk, sv-SE, sw, th, uk, zh-CN, zh-TW".split(',').each do |loc|
  APP_CONFIG['available_locales'] << loc.strip
end

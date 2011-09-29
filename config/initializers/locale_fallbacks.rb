require "i18n/backend/fallbacks" 
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

# Set the list of available locales
APP_CONFIG['available_locales'] = []

# This exact line is taken from the README file of the rails-i18n gem, which
# supplies localizations for all our Rails defaults.
"ar, bg, bs, ca, cs, cy, da, de, de-AT, de-CH, el, en-AU, en-GB, en-US, eo, " \
"es, es-AR, es-CL, es-CO, es-MX, et, eu, fa, fi, fr, fr-CA, fr-CH, gsw-CH, " \
"he, hi, hi-IN, hu, id, is, it, ja, kn, ko, lv, nb, nl, pl, pt-BR, pt-PT, " \
"ro, ru, sk, sv-SE, sw, th, uk, zh-CN, zh-TW".split(',') do |loc|
  APP_CONFIG['available_locales'] << loc.strip
end

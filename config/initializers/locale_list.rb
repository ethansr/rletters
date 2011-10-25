# -*- encoding : utf-8 -*-

# Set the list of available locales ('en' ships with Rails)
APP_CONFIG['available_locales'] = ['en']

# This exact line is taken from the README file of the rails-i18n gem, which
# supplies localizations for all our Rails defaults.
#
# Note: When you update this list from rails-i18n, you *must* copy over the
# appropriate CLDR files into vendor/locales/cldr.
#
# Exclude any languages that have a Rails translation but are not recognized
# by the CLDR, as we *require* the CLDR data files.  Currently this excludes
# the following languages:
# - csb (Kashubian)
"ar, az, bg, bs, ca, cs, cy, da, de, de-AT, de-CH, el, en-AU, en-GB, " \
"en-US, eo, es, es-AR, es-CL, es-CO, es-MX, et, eu, fa, fi, fr, fr-CA, " \
"fr-CH, gsw-CH, he, hi, hi-IN, hu, id, is, it, ja, kn, ko, lv, nb, nl, pl, " \
"pt-BR, pt-PT, ro, ru, sk, sv-SE, sw, th, uk, zh-CN, zh-TW".split(',').each do |loc|
  APP_CONFIG['available_locales'] << loc.strip
end

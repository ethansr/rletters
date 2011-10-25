# -*- encoding : utf-8 -*-
require "i18n/backend/fallbacks" 
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
I18n::Backend::Simple.include(I18n::Backend::Pluralization)


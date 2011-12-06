# -*- encoding : utf-8 -*-

# Validate an e-mail address
#
# This class provides (relatively good) validation for e-mail addresses, less
# strict than the precise RFC that governs address format.  The specific
# regular expression used is taken from 
# https://github.com/balexand/email_validator, based on work from
# http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3.
class EmailValidator < ActiveModel::EachValidator
  # Validate an e-mail address (from +ActiveModel::EachValidator+)
  #
  # @api private
  # @param [ActiveRecord::Base] record the record being validated
  # @param [Symbol] attribute the attribute being validated
  # @param [String] value the value of the attribute
  # @return [undefined] adds to +record.errors+ if invalid
  def validate_each(record, attribute, value)
    unless value =~ /^\s*([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\s*$/iu
      record.errors.add(attribute, options[:message] || :invalid)
    end
  end
end

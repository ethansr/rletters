# -*- encoding : utf-8 -*-

# The CSV module on Ruby 1.8 has a completely different interface than the
# one on Ruby 1.9.  If we're on 1.8, load the FasterCSV gem, and replace the
# original CSV code with it.
require 'csv'

if CSV.const_defined? :Reader
  CSV = FasterCSV
end

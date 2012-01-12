# -*- encoding : utf-8 -*-
RSpec::Matchers.define :be_lucene_query do |expected|
  match do |actual|
    query_to_array(actual).sort == expected.sort
  end
  
  def query_to_array(str)
    unless str[0] == '('
      return [ str[1..-2] ]
    end
    str[1..-2].split(' OR ').map { |n| n[1..-2] }
  end
  
  failure_message_for_should do |actual|
    "expected that #{actual} would be the Lucene query for #{expected.to_s}"
  end
  
  failure_message_for_should_not do |actual|
    "expected that #{actual} would not be the Lucene query for #{expected.to_s}"
  end
  
  description do
    "be a Lucene query for the list #{expected.to_s}"
  end
end

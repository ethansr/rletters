# -*- encoding : utf-8 -*-
RSpec::Matchers.define :be_lucene_query do |expected|
  match do |actual|
    query_to_array(actual).should =~ expected
  end
  
  def query_to_array(str)
    unless str.scan(/./mu)[0] == '('
      return [ str.scan(/./mu)[1..-2].join ]
    end
    str.scan(/./mu)[1..-2].join.split(' OR ').map { |n| n.scan(/./mu)[1..-2].join }
  end
  
  failure_message_for_should do |actual|
    "expected that #{actual} (or #{query_to_array(actual).inspect}) would be the Lucene query for #{expected.inspect}"
  end
  
  failure_message_for_should_not do |actual|
    "expected that #{actual} (or #{query_to_array(actual).inspect}) would not be the Lucene query for #{expected.inspect}"
  end
  
  description do
    "be a Lucene query for the list #{expected.inspect}"
  end
end

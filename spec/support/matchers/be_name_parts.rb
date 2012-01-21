# -*- encoding : utf-8 -*-
RSpec::Matchers.define :be_name_parts do |first, von, last, suffix|
  match do |actual|
    actual[:first] == first && actual[:von] == von && \
    actual[:last] == last && actual[:suffix] == suffix
  end
  
  failure_message_for_should do |actual|
    "expected that #{actual} would be the name [#{first}, #{von}, #{last}, #{suffix}]"
  end
  
  failure_message_for_should_not do |actual|
    "expected that #{actual} would not be the name [#{first}, #{von}, #{last}, #{suffix}]"
  end
  
  description do
    "be the name [#{first}, #{von}, #{last}, #{suffix}]"
  end
end

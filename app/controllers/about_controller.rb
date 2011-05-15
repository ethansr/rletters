class AboutController < ApplicationController
  %W(index).each do |m|
    class_eval <<-RUBY
    def #{m}
    end
    RUBY
  end
end

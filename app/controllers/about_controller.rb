# coding: UTF-8

class AboutController < ApplicationController
  %W(index about).each do |m|
    class_eval <<-RUBY
    def #{m}
    end
    RUBY
  end
end

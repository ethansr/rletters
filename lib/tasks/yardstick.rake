if Rails.env.development?

  require 'yardstick/rake/measurement'
  
  namespace :doc do
    desc "Measure the documentation quality and coverage"
    Yardstick::Rake::Measurement.new(:yardstick) do |measurement|
      measurement.output = 'doc/yardstick.txt'
      measurement.path = ['app/**/*.rb', 'lib/**/*.rb']
    end
  end

end


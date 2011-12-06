require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:fast => "test:prepare") do |t|
    files = FileList["test/unit/**/*_test.rb",
      "test/functional/**/*_test.rb",
      "test/integration/**/*_test.rb"]

    t.libs << 'test'
    ##t.verbose = true
    t.test_files = files
  end
  Rake::Task['test:fast'].comment =
    "Runs unit/functional/integration tests in a single block"
    
  Rake::TestTask.new(:slow => "test:fast") do |t|
    t.libs << 'test'
    t.verbose = true
    t.pattern = 'test/slow/**/*_test.rb'
  end
  Rake::Task['test:slow'].comment = 
    "Runs the slow tests in addition to the fast tests"
end

task :default => "test:fast"
task :test => "test:fast"


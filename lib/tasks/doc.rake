# coding: UTF-8

# Remove the default Rails doc tasks
Rake::Task["doc:app"].clear
Rake::Task["doc:reapp"].clear
Rake::Task["doc:clobber_app"].clear
Rake::Task["doc/app"].clear
Rake::Task["doc/app/index.html"].clear

namespace :doc do
  desc "Generate documentation for the application."
  Rake::RDocTask.new("app") { |rdoc|
    rdoc.rdoc_dir = 'doc/app'
# Can set a custom template here if we decide we want to
#    rdoc.template = ENV['template'] if ENV['template']
    rdoc.title    = "RLetters"
    rdoc.options << '--charset' << 'utf-8'
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('README.rdoc')
    rdoc.main     = 'README.rdoc'
  }
end

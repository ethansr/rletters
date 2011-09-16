require 'bundler'

# Clear the original Rails documentation task
Rake::Task["doc:app"].clear
Rake::Task["doc/app"].clear
Rake::Task["doc/app/index.html"].clear

# Make a custom YARD task
namespace :doc do
  desc "Generate application documentation"
  YARD::Rake::YardocTask.new(:app) do |t|
    t.files += ['app/**/*.rb', 'lib/**/*.rb', '-',
                'README.rdoc', 'COPYING']
    t.options << '-o' << 'doc/app'
    t.options << '--protected' << '--private'
    t.options << '-r' << 'README.rdoc'
  end
end


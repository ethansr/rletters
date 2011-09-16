namespace :doc do
  desc "Runs all docs-related tasks"
  task :all => ["doc:app", "doc:yardstick"]
end


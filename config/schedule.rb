# -*- encoding : utf-8 -*-

job_type :env_command, "cd :path && RAILS_ENV=:environment bundle exec :task :output"


every 1.hours do
  rake "db:sessions:expire"
end

every :reboot do
  env_command "script/delayed_job restart"
end


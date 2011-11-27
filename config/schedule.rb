# -*- encoding : utf-8 -*-

set :output, {:standard => nil}
env :PATH, '/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin'


job_type :env_command, "cd :path && RAILS_ENV=:environment bundle exec :task :output"

every 1.hours do
  rake "db:sessions:expire"
end

every :reboot do
  env_command "script/delayed_job restart"
end


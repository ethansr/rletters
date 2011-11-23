# -*- encoding : utf-8 -*-

every 1.hours do
  rake "db:sessions:expire"
end

every :reboot do
  command "cd :path && RAILS_ENV=:environment script/delayed_job start"
end


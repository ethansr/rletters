# -*- encoding : utf-8 -*-

every 1.hours do
  rake "db:sessions:expire"
end

every :reboot do
  envcommand 'script/delayed_job restart'
end


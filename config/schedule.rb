# -*- encoding : utf-8 -*-

every 1.hours do
  rake "db:sessions:expire"
end

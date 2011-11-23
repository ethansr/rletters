# -*- encoding : utf-8 -*-

# Link the 'static_assets' folder into the public directory for each new
# deployment
task :after_update_code do
  run "ln -s #{shared_path}/static_assets #{release_path}/public/static_assets"
end

# -*- encoding : utf-8 -*-

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  # Link the 'static_assets' folder into the public directory for each new
  # deployment
  task :after_update_code do
    run "ln -s #{shared_path}/static_assets #{release_path}/public/static_assets"
  end

end

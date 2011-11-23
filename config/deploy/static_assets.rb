# -*- encoding : utf-8 -*-

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :rletters do
    
    desc <<-DESC
      Link the static_assets folder (in shared) into the public directory
    DESC
    task :copy_static_assets do
      run "ln -s #{shared_path}/static_assets #{release_path}/public/static_assets"
    end
    
    after "deploy:update_code", "rletters:copy_static_assets"
    
  end
  
end

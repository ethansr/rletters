# -*- encoding : utf-8 -*-

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :rletters do
    
    desc <<-DESC
      Link the downloads folder (in shared) into the Rails root
      
      This task will create an empty directory in shared if this is a 
      new installation.
    DESC
    task :link_downloads do
      run "mkdir -p #{shared_path}/downloads"
      run "ln -s #{shared_path}/downloads #{release_path}"
    end
    
    after "deploy:update_code", "rletters:link_downloads"
    
  end
  
end

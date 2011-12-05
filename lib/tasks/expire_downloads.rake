# -*- encoding : utf-8 -*-

namespace :db do
  namespace :downloads do
    
    desc "Clean up expired file downloads (created before ENV['CREATED_AT'], defaults to 2 weeks)."
    task :expire => :environment do
      created_time = Time.parse( ENV['CREATED_AT'] || 2.weeks.ago.to_s(:db) )
      
      puts "cleaning up expired file downloads (created before #{created_time}) ..."
      
      # Note: This *must* be destroy_all, because we want to make sure to call
      # the +Download#delete_file+ callback in +before_destroy.+
      rows = Download.destroy_all ["created_at < ?", created_time]
      
      puts "destroyed #{rows} download(s) - there are #{Download.count} download(s) left"
    end
    
  end
end

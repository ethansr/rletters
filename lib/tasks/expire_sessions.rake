
namespace :db do
  
  namespace :sessions do
    
    desc "Clean up expired Active Record sessions (updated before ENV['UPDATED_AT'] and ENV['CREATED_AT'])."
    task :expire => :environment do
      updated_time = Time.parse( ENV['UPDATED_AT'] || 2.hours.ago.to_s(:db) )
      created_time = Time.parse( ENV['CREATED_AT'] || 2.days.ago.to_s(:db) )
      
      puts "cleaning up expired sessions (updated before #{updated_time} or created before #{created_time}) ..."
      session = ActiveRecord::SessionStore::Session
      rows = session.delete_all ["updated_at < ? OR created_at < ?", 
          updated_time, created_time]
      puts "deleted #{rows} session row(s) - there are #{session.count} session row(s) left"
    end
    
  end
end

namespace :db do
  namespace :sessions do
    desc "Clean up expired Active Record sessions (updated before ENV['UPDATED_AT'], defaults to 1 month ago)."
    task :expire => :environment do
      time = Time.parse( ENV['UPDATED_AT'] || 1.month.ago.to_s(:db) )
      puts "cleaning up expired sessions (older than #{time}) ..."
      session = ActiveRecord::SessionStore::Session
      rows = session.delete_all ["updated_at < ?", time]
      puts "deleted #{rows} session row(s) - there are #{session.count} session row(s) left"
    end
  end
end

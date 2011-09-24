
def in_memory_database?
  Rails.env == "test" and
     ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLiteAdapter || 
       ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLite3Adapter and
     Rails.configuration.database_configuration['test']['database'] == ':memory:'
end

if in_memory_database?
  load_schema = lambda { load "#{Rails.root}/db/schema.rb" }
  silence_stream(STDOUT, &load_schema)
end


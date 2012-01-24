# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120124192349) do

  create_table "analysis_tasks", :force => true do |t|
    t.string   "name"
    t.datetime "finished_at"
    t.integer  "dataset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "failed",      :default => false
    t.string   "job_type"
  end

  add_index "analysis_tasks", ["dataset_id"], :name => "index_analysis_tasks_on_dataset_id"

  create_table "dataset_entries", :force => true do |t|
    t.string   "shasum"
    t.integer  "dataset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dataset_entries", ["dataset_id"], :name => "index_dataset_entries_on_dataset_id"

  create_table "datasets", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "datasets", ["user_id"], :name => "index_datasets_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "downloads", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "analysis_task_id"
  end

  add_index "downloads", ["analysis_task_id"], :name => "index_downloads_on_analysis_task_id"

  create_table "libraries", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "libraries", ["user_id"], :name => "index_libraries_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "per_page",   :default => 10
    t.string   "language",   :default => "en-US"
    t.string   "csl_style",  :default => ""
    t.string   "timezone",   :default => "Eastern Time (US & Canada)"
  end

end

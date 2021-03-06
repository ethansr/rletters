# -*- encoding : utf-8 -*-
class AddTimezoneToUsers < ActiveRecord::Migration
  def up
    add_column :users, :timezone, :string, :default => 'Eastern Time (US & Canada)'
    User.update_all ["timezone = ?", 'Eastern Time (US & Canada)']
  end
  
  def down
    remove_column :users, :timezone
  end
end

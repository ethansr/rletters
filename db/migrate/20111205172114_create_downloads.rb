# -*- encoding : utf-8 -*-
class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.string :filename

      t.timestamps
    end
  end
end

class CreateDropboxLinks < ActiveRecord::Migration
  def change
    create_table :dropbox_links do |t|
      t.integer :vol
      t.string :link

      t.timestamps null: false
    end

    add_index :dropbox_links, :vol
  end
end

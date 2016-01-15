class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :name, default: ''
      t.string :song_id, default: ''
      t.text :lyric, default: ''
      t.string :singer, default: ''
      t.integer :vol, default: 0

      t.timestamps null: false
    end

    add_index :songs, :vol
    add_index :songs, :singer
    add_index :songs, :song_id
    add_index :songs, :name
  end
end

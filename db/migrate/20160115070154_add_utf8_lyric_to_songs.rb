class AddUtf8LyricToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :utf8_lyric, :text
  end
end

class AddShortLyricToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :short_lyric, :string, default: ''
    add_index :songs, :short_lyric
  end
end

class RemoveSingerFromSongs < ActiveRecord::Migration
  def change
    remove_column :songs, :singer, :string
  end
end

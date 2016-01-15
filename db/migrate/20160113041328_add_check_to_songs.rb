class AddCheckToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :check, :boolean, default: false
  end
end

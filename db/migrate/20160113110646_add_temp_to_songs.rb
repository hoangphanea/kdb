class AddTempToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :temp, :string
  end
end
